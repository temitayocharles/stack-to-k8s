class Api::V1::FollowsController < Api::V1::BaseController
  before_action :set_user, only: [:create, :destroy, :followers, :following]
  
  def create
    unless current_user.can_follow?(@user)
      return render_error('Cannot follow this user', :forbidden)
    end
    
    follow = current_user.follow!(@user)
    
    if follow
      # Create notification for the followed user
      create_follow_notification
      
      render_success({
        following: true,
        follow_id: follow.id,
        user: {
          id: @user.id,
          username: @user.username,
          full_name: @user.full_name,
          followers_count: @user.followers_count
        }
      }, 'User followed successfully', :created)
    else
      render_error('Unable to follow user')
    end
  end
  
  def destroy
    follow = current_user.follows.find_by(following: @user)
    
    unless follow
      return render_error('Not following this user', :not_found)
    end
    
    follow.destroy!
    
    render_success({
      following: false,
      user: {
        id: @user.id,
        username: @user.username,
        full_name: @user.full_name,
        followers_count: @user.followers_count
      }
    }, 'User unfollowed successfully')
  end
  
  def followers
    return render_error('Cannot view followers', :forbidden) unless can_view_followers?(@user)
    
    followers = @user.followers
                    .active
                    .includes(:follower)
                    .recent
    
    followers = paginate_collection(followers)
    
    render_success({
      followers: followers.map { |follow| follower_data(follow) },
      meta: pagination_meta(followers),
      user: {
        id: @user.id,
        username: @user.username,
        full_name: @user.full_name,
        followers_count: @user.followers_count
      }
    })
  end
  
  def following
    return render_error('Cannot view following', :forbidden) unless can_view_following?(@user)
    
    following = @user.follows
                    .active
                    .includes(:following)
                    .recent
    
    following = paginate_collection(following)
    
    render_success({
      following: following.map { |follow| following_data(follow) },
      meta: pagination_meta(following),
      user: {
        id: @user.id,
        username: @user.username,
        full_name: @user.full_name,
        following_count: @user.following_count
      }
    })
  end
  
  def mutual_followers
    return render_error('User not found', :not_found) unless @user
    return render_error('Cannot view mutual followers', :forbidden) unless can_view_mutual_followers?(@user)
    
    mutual_followers = current_user.mutual_followers_with(@user)
                                   .active
                                   .limit(20)
    
    render_success({
      mutual_followers: mutual_followers.map { |user| user_summary(user) },
      count: mutual_followers.count,
      target_user: {
        id: @user.id,
        username: @user.username,
        full_name: @user.full_name
      }
    })
  end
  
  def suggestions
    suggestions = current_user.follow_suggestions(limit: 20)
    
    render_success({
      suggestions: suggestions.map { |user| user_suggestion_data(user) }
    })
  end
  
  def pending_requests
    return render_error('User does not have private account') unless current_user.private_account?
    
    pending_requests = current_user.followers
                                   .pending
                                   .includes(:follower)
                                   .recent
    
    pending_requests = paginate_collection(pending_requests)
    
    render_success({
      pending_requests: pending_requests.map { |follow| pending_request_data(follow) },
      meta: pagination_meta(pending_requests),
      total_pending: current_user.followers.pending.count
    })
  end
  
  def approve_request
    follow = current_user.followers.pending.find(params[:follow_id])
    
    unless follow
      return render_error('Follow request not found', :not_found)
    end
    
    if follow.approve!
      # Create notification for the requester
      create_follow_approved_notification(follow)
      
      render_success({
        approved: true,
        follow: follower_data(follow)
      }, 'Follow request approved')
    else
      render_error('Unable to approve follow request')
    end
  end
  
  def reject_request
    follow = current_user.followers.pending.find(params[:follow_id])
    
    unless follow
      return render_error('Follow request not found', :not_found)
    end
    
    follow.destroy!
    
    render_success({
      rejected: true
    }, 'Follow request rejected')
  end
  
  def bulk_approve
    follow_ids = params[:follow_ids] || []
    return render_error('No follow requests specified') if follow_ids.empty?
    
    approved_count = 0
    errors = []
    
    follow_ids.each do |follow_id|
      follow = current_user.followers.pending.find_by(id: follow_id)
      
      if follow && follow.approve!
        create_follow_approved_notification(follow)
        approved_count += 1
      else
        errors << "Unable to approve request #{follow_id}"
      end
    end
    
    render_success({
      approved_count: approved_count,
      errors: errors
    }, "#{approved_count} follow requests approved")
  end
  
  def bulk_reject
    follow_ids = params[:follow_ids] || []
    return render_error('No follow requests specified') if follow_ids.empty?
    
    rejected_count = current_user.followers
                                 .pending
                                 .where(id: follow_ids)
                                 .destroy_all
                                 .count
    
    render_success({
      rejected_count: rejected_count
    }, "#{rejected_count} follow requests rejected")
  end
  
  def check_relationship
    return render_error('User not found', :not_found) unless @user
    
    relationship = current_user.relationship_with(@user)
    
    render_success({
      relationship: relationship,
      user: {
        id: @user.id,
        username: @user.username,
        full_name: @user.full_name
      }
    })
  end
  
  def activity
    return render_error('Cannot view follow activity', :forbidden) unless can_view_follow_activity?(@user)
    
    # Recent follows by the user
    recent_follows = @user.follows
                         .active
                         .includes(:following)
                         .recent
                         .limit(10)
    
    # Recent followers of the user
    recent_followers = @user.followers
                           .active
                           .includes(:follower)
                           .recent
                           .limit(10)
    
    render_success({
      recent_follows: recent_follows.map { |follow| following_activity_data(follow) },
      recent_followers: recent_followers.map { |follow| follower_activity_data(follow) },
      user: {
        id: @user.id,
        username: @user.username,
        full_name: @user.full_name,
        followers_count: @user.followers_count,
        following_count: @user.following_count
      }
    })
  end
  
  private
  
  def set_user
    @user = User.find_by(username: params[:username]) || User.find_by(id: params[:user_id])
    render_error('User not found', :not_found) unless @user
  end
  
  def can_view_followers?(user)
    return true if user == current_user
    return true if user.public_profile?
    return true if current_user&.following?(user)
    
    false
  end
  
  def can_view_following?(user)
    return true if user == current_user
    return true if user.public_profile?
    return true if current_user&.following?(user)
    
    false
  end
  
  def can_view_mutual_followers?(user)
    return false if user == current_user
    return true if user.public_profile?
    return true if current_user&.following?(user)
    
    false
  end
  
  def can_view_follow_activity?(user)
    return true if user == current_user
    return true if user.public_profile?
    
    false
  end
  
  def follower_data(follow)
    user = follow.follower
    
    {
      id: follow.id,
      status: follow.status,
      created_at: follow.created_at,
      formatted_created_at: follow.formatted_created_at,
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        display_name: user.display_name,
        bio: user.bio&.truncate(100),
        verified: user.verified,
        followers_count: user.followers_count,
        following_count: user.following_count,
        posts_count: user.posts_count,
        avatar_url: user.avatar_url(:medium),
        is_following: current_user ? current_user.following?(user) : false,
        is_follower: current_user ? user.following?(current_user) : false,
        can_follow: current_user ? current_user.can_follow?(user) : false
      }
    }
  end
  
  def following_data(follow)
    user = follow.following
    
    {
      id: follow.id,
      status: follow.status,
      created_at: follow.created_at,
      formatted_created_at: follow.formatted_created_at,
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        display_name: user.display_name,
        bio: user.bio&.truncate(100),
        verified: user.verified,
        followers_count: user.followers_count,
        following_count: user.following_count,
        posts_count: user.posts_count,
        avatar_url: user.avatar_url(:medium),
        is_following: current_user ? current_user.following?(user) : false,
        is_follower: current_user ? user.following?(current_user) : false,
        can_follow: current_user ? current_user.can_follow?(user) : false
      }
    }
  end
  
  def user_summary(user)
    {
      id: user.id,
      username: user.username,
      full_name: user.full_name,
      display_name: user.display_name,
      verified: user.verified,
      avatar_url: user.avatar_url(:small)
    }
  end
  
  def user_suggestion_data(user)
    {
      id: user.id,
      username: user.username,
      full_name: user.full_name,
      display_name: user.display_name,
      bio: user.bio&.truncate(100),
      verified: user.verified,
      followers_count: user.followers_count,
      posts_count: user.posts_count,
      avatar_url: user.avatar_url(:medium),
      suggestion_reason: user.suggestion_reason,
      mutual_followers_count: current_user.mutual_followers_with(user).count,
      recent_post: user.posts.recent.first&.then do |post|
        {
          id: post.id,
          content: post.content&.truncate(50),
          created_at: post.created_at
        }
      end
    }
  end
  
  def pending_request_data(follow)
    user = follow.follower
    
    {
      id: follow.id,
      created_at: follow.created_at,
      formatted_created_at: follow.formatted_created_at,
      time_ago: time_ago_in_words(follow.created_at),
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        display_name: user.display_name,
        bio: user.bio&.truncate(100),
        verified: user.verified,
        followers_count: user.followers_count,
        posts_count: user.posts_count,
        avatar_url: user.avatar_url(:medium),
        mutual_followers_count: current_user.mutual_followers_with(user).count
      }
    }
  end
  
  def following_activity_data(follow)
    user = follow.following
    
    {
      id: follow.id,
      created_at: follow.created_at,
      formatted_created_at: follow.formatted_created_at,
      user: user_summary(user)
    }
  end
  
  def follower_activity_data(follow)
    user = follow.follower
    
    {
      id: follow.id,
      created_at: follow.created_at,
      formatted_created_at: follow.formatted_created_at,
      user: user_summary(user)
    }
  end
  
  def create_follow_notification
    return if @user == current_user
    
    Notification.create!(
      user: @user,
      actor: current_user,
      notifiable: current_user.follows.find_by(following: @user),
      notification_type: 'follow',
      content: "#{current_user.display_name} started following you"
    )
  end
  
  def create_follow_approved_notification(follow)
    Notification.create!(
      user: follow.follower,
      actor: current_user,
      notifiable: follow,
      notification_type: 'follow_approved',
      content: "#{current_user.display_name} approved your follow request"
    )
  end
end
