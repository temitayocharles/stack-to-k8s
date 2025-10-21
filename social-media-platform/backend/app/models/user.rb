# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string           not null
#  last_name              :string           not null
#  username               :string           not null
#  bio                    :text
#  website                :string
#  location               :string
#  birthday               :date
#  verified               :boolean          default(FALSE)
#  private_account        :boolean          default(FALSE)
#  followers_count        :integer          default(0)
#  following_count        :integer          default(0)
#  posts_count            :integer          default(0)
#  last_active_at         :datetime
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Associations
  has_many_attached :avatar
  has_many_attached :cover_photo
  
  # Posts
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  
  # Followers/Following relationships
  has_many :follower_relationships, class_name: 'Follow', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower
  
  has_many :following_relationships, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :following_relationships, source: :followed
  
  # Notifications
  has_many :notifications, dependent: :destroy
  has_many :sent_notifications, class_name: 'Notification', foreign_key: 'actor_id', dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: 'can only contain letters, numbers, and underscores' },
                       length: { minimum: 3, maximum: 30 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }, allow_blank: true
  validates :location, length: { maximum: 100 }

  # Callbacks
  before_save :update_last_active
  after_create :create_welcome_notification
  
  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :active, -> { where('last_active_at > ?', 30.days.ago) }
  scope :search_by_name, ->(query) { where('LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(username) LIKE ?', "%#{query.downcase}%", "%#{query.downcase}%", "%#{query.downcase}%") }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    "@#{username}"
  end

  def follow!(user)
    return false if user == self || following?(user)
    
    following_relationships.create!(followed: user)
    increment_following_count!
    user.increment_followers_count!
    
    # Create notification
    Notification.create!(
      user: user,
      actor: self,
      action: 'follow',
      notifiable: user
    )
    
    true
  end

  def unfollow!(user)
    return false unless following?(user)
    
    following_relationships.find_by(followed: user)&.destroy
    decrement_following_count!
    user.decrement_followers_count!
    
    true
  end

  def following?(user)
    following.include?(user)
  end

  def followed_by?(user)
    followers.include?(user)
  end

  def can_view_posts?(user)
    return true unless private_account?
    return true if user == self
    return true if followed_by?(user)
    
    false
  end

  def avatar_url(size: :medium)
    return nil unless avatar.attached?
    
    case size
    when :small
      avatar.variant(resize_to_limit: [50, 50])
    when :medium
      avatar.variant(resize_to_limit: [150, 150])
    when :large
      avatar.variant(resize_to_limit: [300, 300])
    else
      avatar
    end
  end

  def cover_photo_url
    return nil unless cover_photo.attached?
    cover_photo.variant(resize_to_limit: [1200, 400])
  end

  def age
    return nil unless birthday
    ((Date.current - birthday) / 365.25).floor
  end

  def online?
    last_active_at && last_active_at > 10.minutes.ago
  end

  def feed_posts(limit: 20, offset: 0)
    following_ids = following.pluck(:id)
    following_ids << id # Include own posts
    
    Post.includes(:user, :likes, comments: :user)
        .where(user_id: following_ids)
        .order(created_at: :desc)
        .limit(limit)
        .offset(offset)
  end

  def unread_notifications_count
    notifications.unread.count
  end

  # JWT token methods
  def generate_jwt_token
    payload = {
      user_id: id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def self.decode_jwt_token(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base).first
    find(decoded['user_id'])
  rescue JWT::DecodeError
    nil
  end

  private

  def update_last_active
    self.last_active_at = Time.current if changed? && !new_record?
  end

  def increment_following_count!
    increment!(:following_count)
  end

  def decrement_following_count!
    decrement!(:following_count) if following_count > 0
  end

  def increment_followers_count!
    increment!(:followers_count)
  end

  def decrement_followers_count!
    decrement!(:followers_count) if followers_count > 0
  end

  def create_welcome_notification
    Notification.create!(
      user: self,
      actor: self,
      action: 'welcome',
      message: 'Welcome to our social media platform! Start by uploading a profile picture and following some interesting people.'
    )
  end
end
