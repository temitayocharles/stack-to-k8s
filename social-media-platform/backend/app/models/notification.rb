# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  actor_id        :bigint
#  action          :string           not null
#  notifiable_id   :bigint
#  notifiable_type :string
#  message         :text
#  read            :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_notifications_on_actor_id                      (actor_id)
#  index_notifications_on_notifiable_type_and_notifiable_id  (notifiable_type,notifiable_id)
#  index_notifications_on_read                          (read)
#  index_notifications_on_user_id                       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (actor_id => users.id)
#  fk_rails_...  (user_id => users.id)
#

class Notification < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  # Validations
  validates :action, presence: true, inclusion: { 
    in: %w[like comment share follow mention like_comment mention_comment welcome] 
  }
  validates :user, presence: true

  # Callbacks
  after_create :broadcast_notification

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_action, ->(action) { where(action: action) }

  # Instance methods
  def mark_as_read!
    update!(read: true)
  end

  def mark_as_unread!
    update!(read: false)
  end

  def formatted_message
    return message if message.present?
    
    return 'Welcome to our platform!' unless actor
    
    case action
    when 'like'
      "#{actor.full_name} liked your post"
    when 'comment'
      "#{actor.full_name} commented on your post"
    when 'share'
      "#{actor.full_name} shared your post"
    when 'follow'
      "#{actor.full_name} started following you"
    when 'mention'
      "#{actor.full_name} mentioned you in a post"
    when 'like_comment'
      "#{actor.full_name} liked your comment"
    when 'mention_comment'
      "#{actor.full_name} mentioned you in a comment"
    else
      'You have a new notification'
    end
  end

  def formatted_created_at
    if created_at > 1.minute.ago
      'just now'
    elsif created_at > 1.hour.ago
      "#{((Time.current - created_at) / 1.minute).round}m"
    elsif created_at > 1.day.ago
      "#{((Time.current - created_at) / 1.hour).round}h"
    elsif created_at > 1.week.ago
      "#{((Time.current - created_at) / 1.day).round}d"
    else
      created_at.strftime('%b %d')
    end
  end

  def icon
    case action
    when 'like', 'like_comment'
      '❤️'
    when 'comment', 'mention_comment'
      '💬'
    when 'share'
      '🔄'
    when 'follow'
      '👤'
    when 'mention'
      '@'
    when 'welcome'
      '🎉'
    else
      '🔔'
    end
  end

  # Class methods
  def self.mark_all_read_for_user(user)
    where(user: user, read: false).update_all(read: true)
  end

  def self.cleanup_old_notifications(days_old: 30)
    where('created_at < ?', days_old.days.ago).delete_all
  end

  private

  def broadcast_notification
    # Broadcast to user's notification channel for real-time updates
    ActionCable.server.broadcast(
      "notifications_#{user_id}",
      {
        id: id,
        action: action,
        message: formatted_message,
        actor: actor&.as_json(only: [:id, :first_name, :last_name, :username]),
        created_at: formatted_created_at,
        read: read,
        icon: icon
      }
    )
  rescue => e
    Rails.logger.error "Failed to broadcast notification: #{e.message}"
  end
end
