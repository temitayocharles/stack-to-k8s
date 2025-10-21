class Api::V1::UploadsController < Api::V1::BaseController
  before_action :validate_file_params, only: [:create, :avatar, :cover]
  before_action :check_file_limits, only: [:create, :avatar, :cover]
  
  def create
    uploaded_files = []
    
    begin
      files_params.each do |file_param|
        file = process_file_upload(file_param)
        uploaded_files << file if file
      end
      
      render_success({
        files: uploaded_files.map { |file| file_data(file) },
        uploaded_count: uploaded_files.length
      }, 'Files uploaded successfully', :created)
      
    rescue StandardError => e
      Rails.logger.error "File upload error: #{e.message}"
      render_error('File upload failed', :unprocessable_entity)
    end
  end
  
  def avatar
    begin
      if current_user.avatar.attached?
        current_user.avatar.purge
      end
      
      current_user.avatar.attach(params[:avatar])
      
      render_success({
        user: {
          id: current_user.id,
          username: current_user.username,
          avatar_url: current_user.avatar_url(:large)
        }
      }, 'Avatar updated successfully')
      
    rescue StandardError => e
      Rails.logger.error "Avatar upload error: #{e.message}"
      render_error('Avatar upload failed', :unprocessable_entity)
    end
  end
  
  def cover
    begin
      if current_user.cover_photo.attached?
        current_user.cover_photo.purge
      end
      
      current_user.cover_photo.attach(params[:cover])
      
      render_success({
        user: {
          id: current_user.id,
          username: current_user.username,
          cover_photo_url: current_user.cover_photo_url
        }
      }, 'Cover photo updated successfully')
      
    rescue StandardError => e
      Rails.logger.error "Cover photo upload error: #{e.message}"
      render_error('Cover photo upload failed', :unprocessable_entity)
    end
  end
  
  def destroy
    attachment = find_attachment(params[:id])
    return render_error('File not found', :not_found) unless attachment
    return render_error('Access denied', :forbidden) unless can_delete_attachment?(attachment)
    
    attachment.purge
    
    render_success({}, 'File deleted successfully')
  end
  
  def presigned_url
    return render_error('Presigned URLs not available in development') unless Rails.env.production?
    
    filename = params[:filename]
    content_type = params[:content_type]
    
    return render_error('Filename is required') if filename.blank?
    return render_error('Content type is required') if content_type.blank?
    return render_error('Invalid file type') unless valid_content_type?(content_type)
    
    key = generate_upload_key(filename)
    
    begin
      presigned_post = s3_presigned_post(key, content_type)
      
      render_success({
        presigned_url: presigned_post.url,
        fields: presigned_post.fields,
        key: key,
        expires_at: 1.hour.from_now
      })
      
    rescue StandardError => e
      Rails.logger.error "Presigned URL generation error: #{e.message}"
      render_error('Failed to generate upload URL')
    end
  end
  
  def media_info
    attachment = find_attachment(params[:id])
    return render_error('File not found', :not_found) unless attachment
    return render_error('Access denied', :forbidden) unless can_view_attachment?(attachment)
    
    render_success({
      file: detailed_file_data(attachment)
    })
  end
  
  def batch_delete
    file_ids = params[:file_ids] || []
    return render_error('No files specified') if file_ids.empty?
    
    deleted_count = 0
    errors = []
    
    file_ids.each do |file_id|
      attachment = find_attachment(file_id)
      
      if attachment && can_delete_attachment?(attachment)
        attachment.purge
        deleted_count += 1
      else
        errors << "Unable to delete file #{file_id}"
      end
    end
    
    render_success({
      deleted_count: deleted_count,
      errors: errors
    }, "#{deleted_count} files deleted")
  end
  
  def user_uploads
    user = params[:user_id] ? User.find(params[:user_id]) : current_user
    return render_error('Access denied', :forbidden) unless can_view_user_uploads?(user)
    
    # Get all attachments for the user's posts
    attachments = ActiveStorage::Attachment.joins(
      "JOIN posts ON posts.id = active_storage_attachments.record_id"
    ).where(
      active_storage_attachments: { record_type: 'Post' },
      posts: { user_id: user.id }
    ).includes(:blob)
    
    # Filter by type if specified
    if params[:type].present?
      case params[:type]
      when 'images'
        attachments = attachments.joins(:blob).where(active_storage_blobs: { content_type: image_content_types })
      when 'videos'
        attachments = attachments.joins(:blob).where(active_storage_blobs: { content_type: video_content_types })
      end
    end
    
    attachments = paginate_collection(attachments.order(created_at: :desc))
    
    render_success({
      files: attachments.map { |attachment| file_data(attachment) },
      meta: pagination_meta(attachments),
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name
      }
    })
  end
  
  def storage_stats
    stats = calculate_storage_stats(current_user)
    
    render_success(stats)
  end
  
  private
  
  def validate_file_params
    if action_name == 'create'
      return render_error('No files provided') if files_params.empty?
    elsif action_name == 'avatar'
      return render_error('Avatar file is required') unless params[:avatar].present?
    elsif action_name == 'cover'
      return render_error('Cover photo file is required') unless params[:cover].present?
    end
  end
  
  def check_file_limits
    files = files_params
    
    # Check file count limit
    if files.length > max_files_per_upload
      return render_error("Maximum #{max_files_per_upload} files allowed per upload")
    end
    
    # Check individual file sizes and types
    files.each do |file|
      unless valid_file?(file)
        return render_error("Invalid file: #{file.original_filename}")
      end
      
      unless valid_file_size?(file)
        return render_error("File too large: #{file.original_filename} (max #{max_file_size_mb}MB)")
      end
    end
    
    # Check total upload size
    total_size = files.sum(&:size)
    if total_size > max_total_upload_size
      return render_error("Total upload size too large (max #{max_total_upload_size_mb}MB)")
    end
    
    # Check user storage quota
    if exceeds_user_quota?(current_user, total_size)
      return render_error("Upload would exceed storage quota")
    end
  end
  
  def files_params
    case action_name
    when 'create'
      (params[:files] || []).compact
    when 'avatar'
      [params[:avatar]].compact
    when 'cover'
      [params[:cover]].compact
    else
      []
    end
  end
  
  def process_file_upload(file)
    # Generate unique filename
    filename = generate_unique_filename(file.original_filename)
    
    # Create attachment record
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: filename,
      content_type: file.content_type,
      metadata: {
        original_filename: file.original_filename,
        uploaded_by: current_user.id,
        upload_timestamp: Time.current.to_i
      }
    )
    
    blob
  end
  
  def find_attachment(id)
    ActiveStorage::Attachment.find_by(id: id) ||
    ActiveStorage::Blob.find_by(id: id)
  end
  
  def can_delete_attachment?(attachment)
    return false unless current_user
    
    # Check if user owns the record this attachment belongs to
    case attachment.record_type
    when 'Post'
      attachment.record.user == current_user
    when 'User'
      attachment.record == current_user
    else
      false
    end
  end
  
  def can_view_attachment?(attachment)
    return true if attachment.record_type == 'Post' && attachment.record.public?
    return true if attachment.record_type == 'User'
    
    can_delete_attachment?(attachment)
  end
  
  def can_view_user_uploads?(user)
    return true if user == current_user
    return true if user.public_profile?
    return true if current_user&.following?(user)
    
    false
  end
  
  def file_data(attachment_or_blob)
    if attachment_or_blob.is_a?(ActiveStorage::Attachment)
      blob = attachment_or_blob.blob
      attachment = attachment_or_blob
    else
      blob = attachment_or_blob
      attachment = nil
    end
    
    {
      id: attachment&.id || blob.id,
      filename: blob.filename.to_s,
      content_type: blob.content_type,
      byte_size: blob.byte_size,
      human_size: human_file_size(blob.byte_size),
      checksum: blob.checksum,
      created_at: blob.created_at,
      url: blob.url,
      metadata: blob.metadata,
      is_image: image_file?(blob),
      is_video: video_file?(blob),
      thumbnail_url: attachment&.variant(resize_to_limit: [200, 200])&.url if image_file?(blob)
    }
  end
  
  def detailed_file_data(attachment_or_blob)
    data = file_data(attachment_or_blob)
    
    if attachment_or_blob.is_a?(ActiveStorage::Attachment)
      blob = attachment_or_blob.blob
    else
      blob = attachment_or_blob
    end
    
    # Add detailed metadata for images
    if image_file?(blob) && blob.metadata['analyzed']
      data.merge!({
        width: blob.metadata['width'],
        height: blob.metadata['height'],
        aspect_ratio: blob.metadata['width'].to_f / blob.metadata['height'].to_f
      })
    end
    
    # Add detailed metadata for videos
    if video_file?(blob) && blob.metadata['analyzed']
      data.merge!({
        width: blob.metadata['width'],
        height: blob.metadata['height'],
        duration: blob.metadata['duration']
      })
    end
    
    data
  end
  
  def valid_file?(file)
    return false unless file.respond_to?(:content_type)
    
    valid_content_type?(file.content_type)
  end
  
  def valid_content_type?(content_type)
    allowed_content_types.include?(content_type)
  end
  
  def valid_file_size?(file)
    file.size <= max_file_size
  end
  
  def allowed_content_types
    image_content_types + video_content_types
  end
  
  def image_content_types
    %w[
      image/jpeg
      image/png
      image/gif
      image/webp
      image/svg+xml
    ]
  end
  
  def video_content_types
    %w[
      video/mp4
      video/mov
      video/avi
      video/webm
    ]
  end
  
  def image_file?(blob)
    image_content_types.include?(blob.content_type)
  end
  
  def video_file?(blob)
    video_content_types.include?(blob.content_type)
  end
  
  def max_files_per_upload
    10
  end
  
  def max_file_size
    10.megabytes
  end
  
  def max_file_size_mb
    max_file_size / 1.megabyte
  end
  
  def max_total_upload_size
    50.megabytes
  end
  
  def max_total_upload_size_mb
    max_total_upload_size / 1.megabyte
  end
  
  def user_storage_quota
    100.megabytes
  end
  
  def exceeds_user_quota?(user, additional_size)
    current_usage = calculate_user_storage(user)
    (current_usage + additional_size) > user_storage_quota
  end
  
  def calculate_user_storage(user)
    # Calculate total storage used by user's uploads
    user.posts.joins(images_attachments: :blob)
        .sum('active_storage_blobs.byte_size') +
    user.posts.joins(videos_attachments: :blob)
        .sum('active_storage_blobs.byte_size') +
    (user.avatar.attached? ? user.avatar.blob.byte_size : 0) +
    (user.cover_photo.attached? ? user.cover_photo.blob.byte_size : 0)
  end
  
  def calculate_storage_stats(user)
    current_usage = calculate_user_storage(user)
    quota = user_storage_quota
    
    {
      current_usage: current_usage,
      current_usage_human: human_file_size(current_usage),
      quota: quota,
      quota_human: human_file_size(quota),
      usage_percentage: (current_usage.to_f / quota * 100).round(2),
      remaining: quota - current_usage,
      remaining_human: human_file_size(quota - current_usage)
    }
  end
  
  def human_file_size(bytes)
    return '0 B' if bytes.zero?
    
    units = %w[B KB MB GB TB]
    index = 0
    size = bytes.to_f
    
    while size >= 1024 && index < units.length - 1
      size /= 1024.0
      index += 1
    end
    
    "#{size.round(2)} #{units[index]}"
  end
  
  def generate_unique_filename(original_filename)
    extension = File.extname(original_filename)
    basename = File.basename(original_filename, extension)
    timestamp = Time.current.to_i
    random = SecureRandom.hex(8)
    
    "#{basename}_#{timestamp}_#{random}#{extension}"
  end
  
  def generate_upload_key(filename)
    timestamp = Time.current.strftime('%Y/%m/%d')
    user_id = current_user.id
    random = SecureRandom.hex(8)
    
    "uploads/#{user_id}/#{timestamp}/#{random}_#{filename}"
  end
  
  def s3_presigned_post(key, content_type)
    s3_bucket = Rails.application.credentials.aws[:s3_bucket]
    
    Aws::S3::Bucket.new(s3_bucket).presigned_post(
      key: key,
      content_type: content_type,
      content_length_range: 1..max_file_size,
      expires: 1.hour.from_now
    )
  end
end
