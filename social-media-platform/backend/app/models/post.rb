# == Schema Information
#
# Table name: posts
#
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  content          :text             not null
#  likes_count      :integer          default(0)
#  comments_count   :integer          default(0)
#  shares_count     :integer          default(0)
#  visibility       :string           default("public")
#  original_post_id :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_posts_on_created_at       (created_at)
#  index_posts_on_original_post_id (original_post_id)
#  index_posts_on_user_id          (user_id)
#  index_posts_on_visibility       (visibility)
#
# Foreign Keys
#
#  fk_rails_...  (original_post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#

class Post < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :original_post, class_name: 'Post', optional: true
  
  has_many_attached :images
  has_many_attached :videos
  
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :shares, class_name: 'Post', foreign_key: 'original_post_id', dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Validations
  validates :content, presence: true, length: { maximum: 500 }
  validates :visibility, inclusion: { in: %w[public private followers_only] }
  validates :user, presence: true

  # Callbacks
  after_create :increment_user_posts_count
  after_destroy :decrement_user_posts_count
  after_create :create_mention_notifications

  # Scopes
  scope :public_posts, -> { where(visibility: 'public') }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(likes_count: :desc, comments_count: :desc) }
  scope :trending, -> { where('created_at > ?', 24.hours.ago).order(likes_count: :desc, comments_count: :desc) }
  scope :with_images, -> { joins(:images_attachments) }
  scope :with_videos, -> { joins(:videos_attachments) }
  scope :original_posts, -> { where(original_post_id: nil) }
  scope :shared_posts, -> { where.not(original_post_id: nil) }

  # Instance methods
  def like!(user)
    return false if liked_by?(user)
    
    likes.create!(user: user)
    increment_likes_count!
    
    # Create notification for post owner (unless they liked their own post)
    if user != self.user
      Notification.create!(
        user: self.user,
        actor: user,
        action: 'like',
        notifiable: self,
        message: "#{user.full_name} liked your post"
      )
    end
    
    true
  end

  def unlike!(user)
    return false unless liked_by?(user)
    
    likes.find_by(user: user)&.destroy
    decrement_likes_count!
    
    true
  end

  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end

  def share!(user, content: nil)
    return false if user == self.user
    
    shared_post = user.posts.create!(
      content: content || "Shared: #{self.content.truncate(100)}",
      original_post: self,
      visibility: 'public'
    )
    
    if shared_post.persisted?
      increment_shares_count!
      
      # Create notification for original post owner
      Notification.create!(
        user: self.user,
        actor: user,
        action: 'share',
        notifiable: self,
        message: "#{user.full_name} shared your post"
      )
      
      shared_post
    else
      false
    end
  end

  def shared_post?
    original_post_id.present?
  end

  def original_post?
    original_post_id.nil?
  end

  def has_media?
    images.attached? || videos.attached?
  end

  def image_urls(size: :medium)
    return [] unless images.attached?
    
    images.map do |image|
      case size
      when :thumbnail
        image.variant(resize_to_limit: [200, 200])
      when :medium
        image.variant(resize_to_limit: [600, 600])
      when :large
        image.variant(resize_to_limit: [1200, 1200])
      else
        image
      end
    end
  end

  def video_urls
    return [] unless videos.attached?
    videos.map(&:url)
  end

  def engagement_score
    (likes_count * 1) + (comments_count * 2) + (shares_count * 3)
  end

  def hashtags
    content.scan(/#\w+/).map(&:downcase).uniq
  end

  def mentions
    content.scan(/@\w+/).map { |mention| mention[1..-1].downcase }.uniq
  end

  def mentioned_users
    usernames = mentions
    return [] if usernames.empty?
    
    User.where('LOWER(username) IN (?)', usernames)
  end

  def visible_to?(user)
    case visibility
    when 'public'
      true
    when 'private'
      user == self.user
    when 'followers_only'
      user == self.user || self.user.followed_by?(user)
    else
      false
    end
  end

  def can_comment?(user)
    return false unless visible_to?(user)
    return true if visibility == 'public'
    return true if user == self.user
    return true if self.user.followed_by?(user)
    
    false
  end

  def formatted_created_at
    if created_at > 1.day.ago
      created_at.strftime('%l:%M %p')
    elsif created_at > 1.week.ago
      created_at.strftime('%a %l:%M %p')
    else
      created_at.strftime('%b %d, %Y')
    end
  end

  def recent_comments(limit: 3)
    comments.includes(:user).order(created_at: :desc).limit(limit)
  end

  def recent_likes(limit: 10)
    likes.includes(:user).order(created_at: :desc).limit(limit)
  end

  # Class methods
  def self.search(query)
    where('LOWER(content) LIKE ?', "%#{query.downcase}%")
  end

  def self.by_hashtag(hashtag)
    hashtag = hashtag.gsub('#', '').downcase
    where('LOWER(content) LIKE ?', "%##{hashtag}%")
  end

  def self.feed_for_user(user, limit: 20, offset: 0)
    return none unless user
    
    following_ids = user.following.pluck(:id)
    following_ids << user.id # Include user's own posts
    
    includes(:user, :likes, :original_post, comments: :user)
      .where(user_id: following_ids)
      .where(visibility: ['public', 'followers_only'])
      .order(created_at: :desc)
      .limit(limit)
      .offset(offset)
  end

  def self.discover_for_user(user, limit: 20)
    following_ids = user&.following&.pluck(:id) || []
    following_ids << user&.id if user
    
    public_posts
      .where.not(user_id: following_ids)
      .includes(:user, :likes, comments: :user)
      .order(engagement_score: :desc, created_at: :desc)
      .limit(limit)
  end

  private

  def increment_likes_count!
    increment!(:likes_count)
  end

  def decrement_likes_count!
    decrement!(:likes_count) if likes_count > 0
  end

  def increment_shares_count!
    increment!(:shares_count)
  end

  def increment_user_posts_count
    user.increment!(:posts_count)
  end

  def decrement_user_posts_count
    user.decrement!(:posts_count) if user.posts_count > 0
  end

  def create_mention_notifications
    mentioned_users.each do |mentioned_user|
      next if mentioned_user == user # Don't notify yourself
      
      Notification.create!(
        user: mentioned_user,
        actor: user,
        action: 'mention',
        notifiable: self,
        message: "#{user.full_name} mentioned you in a post"
      )
    end
  end
end
