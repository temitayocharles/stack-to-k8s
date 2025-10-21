Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Health and monitoring routes
      get 'health/status', to: 'health#status'
      get 'health/ping', to: 'health#ping'
      get 'health/version', to: 'health#version'
      get 'health/metrics', to: 'health#metrics'
      get 'health/database', to: 'health#database_check'
      get 'health/cache', to: 'health#cache_check'
      get 'health/storage', to: 'health#storage_check'
      get 'health/dependencies', to: 'health#dependencies'
      get 'health/readiness', to: 'health#readiness'
      get 'health/liveness', to: 'health#liveness'
      
      # Authentication routes
      post 'auth/register', to: 'authentication#register'
      post 'auth/login', to: 'authentication#login'
      delete 'auth/logout', to: 'authentication#logout'
      post 'auth/refresh', to: 'authentication#refresh_token'
      post 'auth/forgot_password', to: 'authentication#forgot_password'
      post 'auth/reset_password', to: 'authentication#reset_password'
      get 'auth/me', to: 'authentication#me'
      
      # User routes
      resources :users, param: :username, except: [:new, :edit] do
        member do
          get :posts, to: 'posts#user_posts'
          get :comments, to: 'comments#user_comments'
          get :uploads, to: 'uploads#user_uploads'
          patch :update_avatar, to: 'uploads#avatar'
          patch :update_cover, to: 'uploads#cover'
        end
        
        collection do
          get :search
          get :suggestions
          get :me
        end
      end
      
      # Posts routes
      resources :posts do
        member do
          post :like
          delete :unlike
          post :share
        end
        
        collection do
          get :feed
          get :trending
          get :discover
          get :search
          get 'hashtag/:hashtag', to: 'posts#hashtag', as: :hashtag
        end
        
        # Nested comments routes
        resources :comments, except: [:new, :edit] do
          member do
            post :like
            delete :unlike
          end
          
          resources :replies, controller: 'comments', only: [:index, :create] do
            collection do
              post '', to: 'comments#create_reply'
            end
          end
        end
      end
      
      # Comments routes (top-level)
      resources :comments, only: [:index, :show] do
        member do
          post :like
          delete :unlike
        end
        
        collection do
          get :search
          get :trending
        end
        
        resources :replies, controller: 'comments', only: [:index, :create]
      end
      
      # Follow/relationship routes
      resources :follows, only: [:create, :destroy] do
        collection do
          get :suggestions
          get :pending_requests
          post 'approve/:follow_id', to: 'follows#approve_request', as: :approve
          delete 'reject/:follow_id', to: 'follows#reject_request', as: :reject
          post :bulk_approve
          post :bulk_reject
        end
      end
      
      # User-specific follow routes
      get 'users/:username/followers', to: 'follows#followers'
      get 'users/:username/following', to: 'follows#following'
      get 'users/:username/mutual_followers', to: 'follows#mutual_followers'
      get 'users/:username/activity', to: 'follows#activity'
      post 'users/:username/follow', to: 'follows#create'
      delete 'users/:username/unfollow', to: 'follows#destroy'
      get 'users/:username/relationship', to: 'follows#check_relationship'
      
      # Notifications routes
      resources :notifications, only: [:index, :show, :destroy] do
        member do
          patch :mark_as_read
        end
        
        collection do
          patch :mark_all_as_read
          delete :destroy_all
          delete :destroy_read
          get :summary
          get :settings
          patch :update_settings
          post :test_notification
        end
      end
      
      # Search routes
      scope :search do
        get '', to: 'search#all'
        get :users, to: 'search#users'
        get :posts, to: 'search#posts'
        get :hashtags, to: 'search#hashtags'
        get :suggestions, to: 'search#suggestions'
        get :trending, to: 'search#trending'
        get :recent, to: 'search#recent_searches'
        delete :clear_history, to: 'search#clear_search_history'
        get :advanced, to: 'search#advanced'
      end
      
      # Upload routes
      resources :uploads, only: [:create, :show, :destroy] do
        member do
          get :info, to: 'uploads#media_info'
        end
        
        collection do
          post :avatar, to: 'uploads#avatar'
          post :cover, to: 'uploads#cover'
          post :presigned_url
          delete :batch_delete
          get :storage_stats
        end
      end
      
      # Backward compatibility routes
      get 'health', to: 'health#status'
    end
  end
  
  # Health check for load balancers (backward compatibility)
  get 'health', to: 'api/v1/health#status'
  
  # WebSocket routes for ActionCable
  mount ActionCable.server => '/cable'
  
  # Sidekiq Web UI (for development/admin)
  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  # Root route
  root 'api/v1/health#status'
end
