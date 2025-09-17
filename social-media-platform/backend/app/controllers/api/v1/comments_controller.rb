class Api::V1::CommentsController < Api::V1::BaseController
  before_action :set_comment, only: [:show, :update, :destroy, :like, :unlike]
  before_action :check_comment_access, only: [:update, :destroy]
  before_action :set_post, only: [:index, :create]
  
  def index
    return render_error('Post not accessible', :forbidden) unless @post.visible_to?(current_user)
    
    comments = @post.comments
                   .includes(:user, :likes, replies: [:user, :likes])
                   .top_level
                   .recent
    
    comments = paginate_collection(comments)
    
    render_success({
      comments: comments.map { |comment| comment_data(comment, include_replies: true) },
      meta: pagination_meta(comments),
      post: {
        id: @post.id,
        comments_count: @post.comments_count
      }
    })
  end
  
  def show
    return render_error('Comment not accessible', :forbidden) unless @comment.visible_to?(current_user)
    
    render_success({
      comment: comment_data(@comment, include_replies: true)
    })
  end
  
  def create
    return render_error('Post not accessible', :forbidden) unless @post.can_comment?(current_user)
    
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    
    if @comment.save
      # Send notification to post owner
      create_comment_notification
      
      # Send notifications to mentioned users
      create_mention_notifications if @comment.mentions.any?
      
      render_success({
        comment: comment_data(@comment)
      }, 'Comment created successfully', :created)
    else
      render_validation_errors(@comment)
    end
  end
  
  def update
    if @comment.update(comment_params)
      render_success({
        comment: comment_data(@comment)
      }, 'Comment updated successfully')
    else
      render_validation_errors(@comment)
    end
  end
  
  def destroy
    @comment.destroy!
    render_success({}, 'Comment deleted successfully')
  end
  
  def like
    if @comment.like!(current_user)
      render_success({
        liked: true,
        likes_count: @comment.likes_count
      }, 'Comment liked')
    else
      render_error('Unable to like comment')
    end
  end
  
  def unlike
    if @comment.unlike!(current_user)
      render_success({
        liked: false,
        likes_count: @comment.likes_count
      }, 'Comment unliked')
    else
      render_error('Unable to unlike comment')
    end
  end
  
  def replies
    comment = Comment.find(params[:comment_id])
    return render_error('Comment not accessible', :forbidden) unless comment.visible_to?(current_user)
    
    replies = comment.replies
                    .includes(:user, :likes)
                    .recent
    
    replies = paginate_collection(replies)
    
    render_success({
      replies: replies.map { |reply| comment_data(reply) },
      meta: pagination_meta(replies),
      parent_comment: {
        id: comment.id,
        content: comment.content,
        replies_count: comment.replies_count
      }
    })
  end
  
  def create_reply
    parent_comment = Comment.find(params[:comment_id])
    return render_error('Comment not accessible', :forbidden) unless parent_comment.visible_to?(current_user)
    return render_error('Cannot reply to this comment', :forbidden) unless parent_comment.can_reply?(current_user)
    
    @comment = parent_comment.replies.build(comment_params)
    @comment.user = current_user
    @comment.post = parent_comment.post
    
    if @comment.save
      # Send notification to parent comment owner
      create_reply_notification(parent_comment)
      
      # Send notifications to mentioned users
      create_mention_notifications if @comment.mentions.any?
      
      render_success({
        reply: comment_data(@comment)
      }, 'Reply created successfully', :created)
    else
      render_validation_errors(@comment)
    end
  end
  
  def user_comments
    user = User.find(params[:user_id])
    
    comments = user.comments
                  .includes(:user, :post, :likes)
                  .joins(:post)
                  .where(posts: { visibility: 'public' })
                  .recent
    
    comments = paginate_collection(comments)
    
    render_success({
      comments: comments.map { |comment| comment_data(comment, include_post: true) },
      meta: pagination_meta(comments),
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name
      }
    })
  end
  
  def search
    query = params[:q]&.strip
    return render_error('Search query is required') if query.blank?
    
    comments = Comment.search(query)
                     .includes(:user, :post, :likes)
                     .joins(:post)
                     .where(posts: { visibility: 'public' })
                     .recent
    
    comments = paginate_collection(comments)
    
    render_success({
      comments: comments.map { |comment| comment_data(comment, include_post: true) },
      meta: pagination_meta(comments),
      query: query
    })
  end
  
  def trending
    comments = Comment.trending
                     .includes(:user, :post, :likes)
                     .joins(:post)
                     .where(posts: { visibility: 'public' })
                     .limit(20)
    
    render_success({
      comments: comments.map { |comment| comment_data(comment, include_post: true) }
    })
  end
  
  private
  
  def set_comment
    @comment = Comment.find(params[:id])
  end
  
  def set_post
    @post = Post.find(params[:post_id])
  end
  
  def check_comment_access
    unless @comment.user == current_user
      render_error('Access denied', :forbidden)
    end
  end
  
  def comment_params
    params.require(:comment).permit(:content)
  end
  
  def comment_data(comment, include_replies: false, include_post: false)
    data = {
      id: comment.id,
      content: comment.content,
      likes_count: comment.likes_count,
      replies_count: comment.replies_count,
      hashtags: comment.hashtags,
      mentions: comment.mentions,
      is_reply: comment.reply?,
      parent_comment_id: comment.parent_comment_id,
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      formatted_created_at: comment.formatted_created_at,
      user: {
        id: comment.user.id,
        username: comment.user.username,
        full_name: comment.user.full_name,
        display_name: comment.user.display_name,
        verified: comment.user.verified,
        avatar_url: comment.user.avatar_url(:small)
      },
      current_user_liked: current_user ? comment.liked_by?(current_user) : false,
      can_reply: current_user ? comment.can_reply?(current_user) : false,
      can_edit: current_user ? comment.user == current_user : false,
      can_delete: current_user ? (comment.user == current_user || comment.post.user == current_user) : false
    }
    
    # Include post data if requested
    if include_post
      data[:post] = {
        id: comment.post.id,
        content: comment.post.content&.truncate(100),
        created_at: comment.post.created_at,
        user: {
          id: comment.post.user.id,
          username: comment.post.user.username,
          full_name: comment.post.user.full_name,
          avatar_url: comment.post.user.avatar_url(:small)
        }
      }
    end
    
    # Include recent replies if requested
    if include_replies && comment.replies.any?
      data[:recent_replies] = comment.recent_replies.map do |reply|
        {
          id: reply.id,
          content: reply.content,
          likes_count: reply.likes_count,
          created_at: reply.created_at,
          formatted_created_at: reply.formatted_created_at,
          user: {
            id: reply.user.id,
            username: reply.user.username,
            full_name: reply.user.full_name,
            avatar_url: reply.user.avatar_url(:small)
          },
          current_user_liked: current_user ? reply.liked_by?(current_user) : false
        }
      end
    end
    
    data
  end
  
  def create_comment_notification
    return if @comment.post.user == current_user
    
    Notification.create!(
      user: @comment.post.user,
      actor: current_user,
      notifiable: @comment,
      notification_type: 'comment',
      content: "#{current_user.display_name} commented on your post"
    )
  end
  
  def create_reply_notification(parent_comment)
    return if parent_comment.user == current_user
    
    Notification.create!(
      user: parent_comment.user,
      actor: current_user,
      notifiable: @comment,
      notification_type: 'reply',
      content: "#{current_user.display_name} replied to your comment"
    )
  end
  
  def create_mention_notifications
    @comment.mentions.each do |username|
      mentioned_user = User.find_by(username: username.gsub('@', ''))
      next unless mentioned_user && mentioned_user != current_user
      
      Notification.create!(
        user: mentioned_user,
        actor: current_user,
        notifiable: @comment,
        notification_type: 'mention',
        content: "#{current_user.display_name} mentioned you in a comment"
      )
    end
  end
end
