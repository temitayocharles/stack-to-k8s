# == Schema Information
#
# Table name: comments
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  post_id      :bigint           not null
#  content      :text             not null
#  likes_count  :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_comments_on_post_id  (post_id)
#  index_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#

class Comment < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :post, counter_cache: true
  
  has_many :likes, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Validations
  validates :content, presence: true, length: { maximum: 250 }
  validates :user, presence: true
  validates :post, presence: true

  # Callbacks
  after_create :create_comment_notification
  after_create :create_mention_notifications

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(likes_count: :desc) }

  # Instance methods
  def like!(user)
    return false if liked_by?(user)
    
    likes.create!(user: user)
    increment!(:likes_count)
    
    # Create notification for comment owner (unless they liked their own comment)
    if user != self.user
      Notification.create!(
        user: self.user,
        actor: user,
        action: 'like_comment',
        notifiable: self,
        message: "#{user.full_name} liked your comment"
      )
    end
    
    true
  end

  def unlike!(user)
    return false unless liked_by?(user)
    
    likes.find_by(user: user)&.destroy
    decrement!(:likes_count) if likes_count > 0
    
    true
  end

  def liked_by?(user)
    return false unless user
    likes.exists?(user: user)
  end

  def mentions
    content.scan(/@\w+/).map { |mention| mention[1..-1].downcase }.uniq
  end

  def mentioned_users
    usernames = mentions
    return [] if usernames.empty?
    
    User.where('LOWER(username) IN (?)', usernames)
  end

  def formatted_created_at
    if created_at > 1.day.ago
      created_at.strftime('%l:%M %p')
    elsif created_at > 1.week.ago
      created_at.strftime('%a %l:%M %p')
    else
      created_at.strftime('%b %d')
    end
  end

  private

  def create_comment_notification
    # Don't notify if commenting on own post
    return if user == post.user
    
    Notification.create!(
      user: post.user,
      actor: user,
      action: 'comment',
      notifiable: self,
      message: "#{user.full_name} commented on your post"
    )
  end

  def create_mention_notifications
    mentioned_users.each do |mentioned_user|
      next if mentioned_user == user || mentioned_user == post.user # Don't double-notify post owner
      
      Notification.create!(
        user: mentioned_user,
        actor: user,
        action: 'mention_comment',
        notifiable: self,
        message: "#{user.full_name} mentioned you in a comment"
      )
    end
  end
end
