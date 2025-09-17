require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SocialMediaPlatform
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Set timezone
    config.time_zone = 'UTC'

    # API configuration
    config.api_only = false # We want both API and web capabilities
    
    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch('ALLOWED_HOSTS', 'localhost,127.0.0.1').split(',')
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end

    # Active Job configuration
    config.active_job.queue_adapter = :sidekiq

    # File upload configuration
    config.active_storage.variant_processor = :mini_magick

    # Generator configuration
    config.generators do |g|
      g.test_framework :rspec
      g.factory_bot dir: 'spec/factories'
      g.fixture_replacement :factory_bot
    end

    # Session store configuration
    config.session_store :cookie_store, key: '_social_media_session'

    # Force SSL in production
    config.force_ssl = Rails.env.production?

    # Exception handling
    config.exceptions_app = self.routes
  end
end
