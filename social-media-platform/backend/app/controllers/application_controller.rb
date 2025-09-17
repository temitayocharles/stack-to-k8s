class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
  # Skip CSRF token verification for API requests
  skip_before_action :verify_authenticity_token, if: :json_request?
  
  before_action :authenticate_user_from_token!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from JWT::DecodeError, with: :unauthorized
  
  protected
  
  def authenticate_user_from_token!
    return unless json_request?
    
    token = request.headers['Authorization']&.split(' ')&.last
    return unless token
    
    begin
      decoded_token = JWT.decode(token, Rails.application.secret_key_base).first
      @current_user = User.find(decoded_token['user_id'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end
  
  def current_user
    @current_user || super
  end
  
  def user_signed_in?
    current_user.present?
  end
  
  def authenticate_user!
    if json_request?
      render json: { error: 'Authentication required' }, status: :unauthorized unless current_user
    else
      super
    end
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :username, :bio, :website, :location, :birthday])
  end
  
  def json_request?
    request.format.json?
  end
  
  # Health check endpoint
  def health
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      version: ENV.fetch('APP_VERSION', '1.0.0'),
      environment: Rails.env
    }
  end
  
  # Root endpoint
  def index
    if json_request?
      render json: { 
        message: 'Social Media Platform API',
        version: 'v1',
        documentation: '/api/docs'
      }
    else
      render html: '<h1>Social Media Platform</h1><p>API available at /api/v1</p>'.html_safe
    end
  end
  
  private
  
  def not_found(exception)
    if json_request?
      render json: { error: 'Resource not found', message: exception.message }, status: :not_found
    else
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end
  
  def unprocessable_entity(exception)
    if json_request?
      render json: { 
        error: 'Validation failed', 
        message: exception.message,
        details: exception.record.errors.full_messages
      }, status: :unprocessable_entity
    else
      render file: Rails.root.join('public', '422.html'), status: :unprocessable_entity
    end
  end
  
  def bad_request(exception)
    if json_request?
      render json: { error: 'Bad request', message: exception.message }, status: :bad_request
    else
      render file: Rails.root.join('public', '400.html'), status: :bad_request
    end
  end
  
  def unauthorized
    if json_request?
      render json: { error: 'Unauthorized access' }, status: :unauthorized
    else
      redirect_to new_user_session_path
    end
  end
  
  def forbidden
    if json_request?
      render json: { error: 'Access forbidden' }, status: :forbidden
    else
      render file: Rails.root.join('public', '403.html'), status: :forbidden
    end
  end
  
  def internal_server_error(exception)
    Rails.logger.error "Internal server error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    if json_request?
      render json: { error: 'Internal server error' }, status: :internal_server_error
    else
      render file: Rails.root.join('public', '500.html'), status: :internal_server_error
    end
  end
end
