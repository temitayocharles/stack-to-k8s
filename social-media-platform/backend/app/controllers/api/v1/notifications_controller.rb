class Api::V1::NotificationsController < Api::V1::BaseController
  before_action :set_notification, only: [:show, :mark_as_read, :destroy]
  
  def index
    notifications = current_user.notifications
                                .includes(:actor, :notifiable)
                                .recent
    
    # Filter by type if specified
    if params[:type].present?
      notifications = notifications.where(notification_type: params[:type])
    end
    
    # Filter by read status
    case params[:filter]
    when 'unread'
      notifications = notifications.unread
    when 'read'
      notifications = notifications.read
    end
    
    notifications = paginate_collection(notifications)
    
    render_success({
      notifications: notifications.map { |notification| notification_data(notification) },
      meta: pagination_meta(notifications),
      unread_count: current_user.notifications.unread.count
    })
  end
  
  def show
    render_success({
      notification: notification_data(@notification, include_details: true)
    })
  end
  
  def mark_as_read
    if @notification.update(read: true, read_at: Time.current)
      render_success({
        notification: notification_data(@notification)
      }, 'Notification marked as read')
    else
      render_error('Unable to mark notification as read')
    end
  end
  
  def mark_all_as_read
    count = current_user.notifications.unread.update_all(
      read: true,
      read_at: Time.current,
      updated_at: Time.current
    )
    
    render_success({
      marked_count: count
    }, "#{count} notifications marked as read")
  end
  
  def destroy
    @notification.destroy!
    render_success({}, 'Notification deleted successfully')
  end
  
  def destroy_all
    count = current_user.notifications.count
    current_user.notifications.destroy_all
    
    render_success({
      deleted_count: count
    }, "#{count} notifications deleted")
  end
  
  def destroy_read
    count = current_user.notifications.read.count
    current_user.notifications.read.destroy_all
    
    render_success({
      deleted_count: count
    }, "#{count} read notifications deleted")
  end
  
  def summary
    summary_data = {
      total_count: current_user.notifications.count,
      unread_count: current_user.notifications.unread.count,
      read_count: current_user.notifications.read.count,
      types: notification_type_counts,
      recent_activity: recent_activity_summary
    }
    
    render_success(summary_data)
  end
  
  def settings
    settings = current_user.notification_settings || current_user.build_notification_settings
    
    render_success({
      settings: notification_settings_data(settings)
    })
  end
  
  def update_settings
    settings = current_user.notification_settings || current_user.build_notification_settings
    
    if settings.update(notification_settings_params)
      render_success({
        settings: notification_settings_data(settings)
      }, 'Notification settings updated successfully')
    else
      render_validation_errors(settings)
    end
  end
  
  def test_notification
    return render_error('Test notifications not allowed in production') if Rails.env.production?
    
    notification = Notification.create!(
      user: current_user,
      actor: current_user,
      notifiable: current_user,
      notification_type: 'test',
      content: 'This is a test notification',
      data: { test: true, timestamp: Time.current }
    )
    
    render_success({
      notification: notification_data(notification)
    }, 'Test notification created')
  end
  
  private
  
  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
  
  def notification_settings_params
    params.require(:notification_settings).permit(
      :email_notifications,
      :push_notifications,
      :likes_notifications,
      :comments_notifications,
      :follows_notifications,
      :mentions_notifications,
      :shares_notifications,
      :direct_messages_notifications,
      :marketing_notifications,
      :digest_frequency
    )
  end
  
  def notification_data(notification, include_details: false)
    data = {
      id: notification.id,
      type: notification.notification_type,
      content: notification.content,
      read: notification.read,
      read_at: notification.read_at,
      created_at: notification.created_at,
      updated_at: notification.updated_at,
      formatted_created_at: notification.formatted_created_at,
      time_ago: time_ago_in_words(notification.created_at),
      actor: notification.actor ? {
        id: notification.actor.id,
        username: notification.actor.username,
        full_name: notification.actor.full_name,
        display_name: notification.actor.display_name,
        verified: notification.actor.verified,
        avatar_url: notification.actor.avatar_url(:small)
      } : nil,
      notifiable_type: notification.notifiable_type,
      notifiable_id: notification.notifiable_id,
      data: notification.data || {}
    }
    
    # Include notifiable object details if requested
    if include_details && notification.notifiable
      data[:notifiable] = notifiable_data(notification.notifiable)
    end
    
    # Add action URL for frontend navigation
    data[:action_url] = notification_action_url(notification)
    
    data
  end
  
  def notifiable_data(notifiable)
    case notifiable
    when Post
      {
        id: notifiable.id,
        content: notifiable.content&.truncate(100),
        created_at: notifiable.created_at,
        user: {
          id: notifiable.user.id,
          username: notifiable.user.username,
          full_name: notifiable.user.full_name
        }
      }
    when Comment
      {
        id: notifiable.id,
        content: notifiable.content&.truncate(100),
        created_at: notifiable.created_at,
        post: {
          id: notifiable.post.id,
          content: notifiable.post.content&.truncate(50)
        },
        user: {
          id: notifiable.user.id,
          username: notifiable.user.username,
          full_name: notifiable.user.full_name
        }
      }
    when Follow
      {
        id: notifiable.id,
        created_at: notifiable.created_at,
        follower: {
          id: notifiable.follower.id,
          username: notifiable.follower.username,
          full_name: notifiable.follower.full_name
        }
      }
    when User
      {
        id: notifiable.id,
        username: notifiable.username,
        full_name: notifiable.full_name,
        verified: notifiable.verified
      }
    else
      {
        id: notifiable.id,
        type: notifiable.class.name
      }
    end
  end
  
  def notification_action_url(notification)
    case notification.notification_type
    when 'like', 'comment', 'share'
      return "/posts/#{notification.notifiable&.post&.id}" if notification.notifiable.is_a?(Comment)
      return "/posts/#{notification.notifiable&.id}" if notification.notifiable.is_a?(Post)
    when 'follow'
      return "/users/#{notification.actor&.username}" if notification.actor
    when 'mention'
      if notification.notifiable.is_a?(Comment)
        return "/posts/#{notification.notifiable&.post&.id}#comment-#{notification.notifiable&.id}"
      elsif notification.notifiable.is_a?(Post)
        return "/posts/#{notification.notifiable&.id}"
      end
    when 'reply'
      return "/posts/#{notification.notifiable&.post&.id}#comment-#{notification.notifiable&.id}" if notification.notifiable.is_a?(Comment)
    end
    
    "/notifications"
  end
  
  def notification_type_counts
    current_user.notifications
                .group(:notification_type)
                .count
  end
  
  def recent_activity_summary
    {
      last_24_hours: current_user.notifications.where('created_at >= ?', 24.hours.ago).count,
      last_week: current_user.notifications.where('created_at >= ?', 1.week.ago).count,
      last_month: current_user.notifications.where('created_at >= ?', 1.month.ago).count
    }
  end
  
  def notification_settings_data(settings)
    {
      id: settings.id,
      email_notifications: settings.email_notifications,
      push_notifications: settings.push_notifications,
      likes_notifications: settings.likes_notifications,
      comments_notifications: settings.comments_notifications,
      follows_notifications: settings.follows_notifications,
      mentions_notifications: settings.mentions_notifications,
      shares_notifications: settings.shares_notifications,
      direct_messages_notifications: settings.direct_messages_notifications,
      marketing_notifications: settings.marketing_notifications,
      digest_frequency: settings.digest_frequency,
      created_at: settings.created_at,
      updated_at: settings.updated_at
    }
  end
end
