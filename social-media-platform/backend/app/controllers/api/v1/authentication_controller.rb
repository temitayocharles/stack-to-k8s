class Api::V1::AuthenticationController < Api::V1::BaseController
  skip_before_action :authenticate_user!
  
  def register
    user = User.new(registration_params)
    
    if user.save
      token = user.generate_jwt_token
      render_success({
        user: user_data(user),
        token: token
      }, 'Registration successful', :created)
    else
      render_validation_errors(user)
    end
  end
  
  def login
    user = User.find_by(email: login_params[:email].downcase)
    
    if user&.valid_password?(login_params[:password])
      # Update last sign in
      user.update!(
        current_sign_in_at: Time.current,
        last_sign_in_at: user.current_sign_in_at,
        current_sign_in_ip: request.remote_ip,
        last_sign_in_ip: user.current_sign_in_ip,
        sign_in_count: user.sign_in_count + 1
      )
      
      token = user.generate_jwt_token
      render_success({
        user: user_data(user),
        token: token
      }, 'Login successful')
    else
      render_error('Invalid email or password', :unauthorized)
    end
  end
  
  def logout
    # With JWT, we don't need to do anything server-side for logout
    # The frontend should remove the token from storage
    render_success({}, 'Logout successful')
  end
  
  def refresh
    if current_user
      token = current_user.generate_jwt_token
      render_success({
        user: user_data(current_user),
        token: token
      }, 'Token refreshed')
    else
      render_error('Invalid token', :unauthorized)
    end
  end
  
  def forgot_password
    user = User.find_by(email: params[:email].downcase)
    
    if user
      # Generate reset token (you might want to use a proper reset token system)
      reset_token = SecureRandom.urlsafe_base64(32)
      user.update!(
        reset_password_token: reset_token,
        reset_password_sent_at: Time.current
      )
      
      # Send reset email (implement with your email service)
      # UserMailer.password_reset(user).deliver_now
      
      render_success({}, 'Password reset instructions sent to your email')
    else
      # Don't reveal if email exists for security
      render_success({}, 'If the email exists, password reset instructions have been sent')
    end
  end
  
  def reset_password
    user = User.find_by(
      reset_password_token: params[:token],
      reset_password_sent_at: (4.hours.ago..Time.current)
    )
    
    if user && params[:password].present?
      if user.update(
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        reset_password_token: nil,
        reset_password_sent_at: nil
      )
        token = user.generate_jwt_token
        render_success({
          user: user_data(user),
          token: token
        }, 'Password reset successful')
      else
        render_validation_errors(user)
      end
    else
      render_error('Invalid or expired reset token', :unprocessable_entity)
    end
  end
  
  def change_password
    authenticate_user!
    
    if current_user.valid_password?(params[:current_password])
      if current_user.update(
        password: params[:new_password],
        password_confirmation: params[:password_confirmation]
      )
        token = current_user.generate_jwt_token
        render_success({
          user: user_data(current_user),
          token: token
        }, 'Password changed successfully')
      else
        render_validation_errors(current_user)
      end
    else
      render_error('Current password is incorrect', :unprocessable_entity)
    end
  end
  
  private
  
  def registration_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
  end
  
  def login_params
    params.require(:user).permit(:email, :password)
  end
  
  def user_data(user)
    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      username: user.username,
      email: user.email,
      bio: user.bio,
      website: user.website,
      location: user.location,
      verified: user.verified,
      private_account: user.private_account,
      followers_count: user.followers_count,
      following_count: user.following_count,
      posts_count: user.posts_count,
      avatar_url: user.avatar_url,
      cover_photo_url: user.cover_photo_url,
      created_at: user.created_at,
      last_active_at: user.last_active_at
    }
  end
end
