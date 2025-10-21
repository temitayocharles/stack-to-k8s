class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update, :destroy, :follow, :unfollow, :followers, :following]
  before_action :check_user_access, only: [:update, :destroy]
  
  def show
    render_success({
      user: user_data(@user),
      is_following: current_user&.following?(@user),
      is_followed_by: current_user&.followed_by?(@user),
      can_view_posts: @user.can_view_posts?(current_user)
    })
  end
  
  def update
    if @user.update(user_params)
      render_success({
        user: user_data(@user)
      }, 'Profile updated successfully')
    else
      render_validation_errors(@user)
    end
  end
  
  def destroy
    @user.destroy!
    render_success({}, 'Account deleted successfully')
  end
  
  def profile
    render_success({
      user: user_data(current_user),
      unread_notifications: current_user.unread_notifications_count
    })
  end
  
  def update_profile
    if current_user.update(profile_params)
      render_success({
        user: user_data(current_user)
      }, 'Profile updated successfully')
    else
      render_validation_errors(current_user)
    end
  end
  
  def follow
    if current_user.follow!(@user)
      render_success({
        message: "You are now following #{@user.full_name}",
        is_following: true,
        followers_count: @user.followers_count
      }, 'Successfully followed user')
    else
      render_error('Unable to follow user')
    end
  end
  
  def unfollow
    if current_user.unfollow!(@user)
      render_success({
        message: "You unfollowed #{@user.full_name}",
        is_following: false,
        followers_count: @user.followers_count
      }, 'Successfully unfollowed user')
    else
      render_error('Unable to unfollow user')
    end
  end
  
  def followers
    followers = paginate_collection(@user.followers.includes(:avatar_attachment))
    
    render_success({
      followers: followers.map { |user| user_summary(user) },
      meta: pagination_meta(followers)
    })
  end
  
  def following
    following = paginate_collection(@user.following.includes(:avatar_attachment))
    
    render_success({
      following: following.map { |user| user_summary(user) },
      meta: pagination_meta(following)
    })
  end
  
  def search
    query = params[:q]&.strip
    return render_error('Search query is required') if query.blank?
    
    users = User.search_by_name(query)
                .where.not(id: current_user&.id)
                .includes(:avatar_attachment)
    
    users = paginate_collection(users)
    
    render_success({
      users: users.map { |user| user_summary(user) },
      meta: pagination_meta(users),
      query: query
    })
  end
  
  def suggestions
    # Get users that current user doesn't follow
    following_ids = current_user.following.pluck(:id)
    following_ids << current_user.id
    
    suggested_users = User.where.not(id: following_ids)
                         .verified
                         .active
                         .includes(:avatar_attachment)
                         .limit(10)
                         .order(:followers_count)
    
    render_success({
      suggestions: suggested_users.map { |user| user_summary(user) }
    })
  end
  
  def upload_avatar
    if params[:avatar].present?
      current_user.avatar.attach(params[:avatar])
      render_success({
        avatar_url: current_user.avatar_url,
        message: 'Avatar uploaded successfully'
      })
    else
      render_error('No avatar file provided')
    end
  end
  
  def upload_cover_photo
    if params[:cover_photo].present?
      current_user.cover_photo.attach(params[:cover_photo])
      render_success({
        cover_photo_url: current_user.cover_photo_url,
        message: 'Cover photo uploaded successfully'
      })
    else
      render_error('No cover photo file provided')
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def check_user_access
    unless @user == current_user
      render_error('Access denied', :forbidden)
    end
  end
  
  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :username, :email, :bio, :website, 
      :location, :birthday, :private_account
    )
  end
  
  def profile_params
    params.permit(
      :first_name, :last_name, :username, :bio, :website, 
      :location, :birthday, :private_account
    )
  end
  
  def user_data(user)
    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      username: user.username,
      display_name: user.display_name,
      email: user.email,
      bio: user.bio,
      website: user.website,
      location: user.location,
      birthday: user.birthday,
      age: user.age,
      verified: user.verified,
      private_account: user.private_account,
      followers_count: user.followers_count,
      following_count: user.following_count,
      posts_count: user.posts_count,
      avatar_url: user.avatar_url,
      cover_photo_url: user.cover_photo_url,
      online: user.online?,
      created_at: user.created_at,
      last_active_at: user.last_active_at
    }
  end
  
  def user_summary(user)
    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      username: user.username,
      display_name: user.display_name,
      bio: user.bio,
      verified: user.verified,
      followers_count: user.followers_count,
      avatar_url: user.avatar_url(:small),
      is_following: current_user&.following?(user),
      online: user.online?
    }
  end
end
