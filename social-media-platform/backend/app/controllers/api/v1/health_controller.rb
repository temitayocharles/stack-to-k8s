class Api::V1::HealthController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:status, :ping, :version]
  
  def status
    health_checks = perform_health_checks
    overall_status = health_checks.all? { |_, check| check[:status] == 'healthy' } ? 'healthy' : 'unhealthy'
    
    response_data = {
      status: overall_status,
      timestamp: Time.current.iso8601,
      version: app_version,
      environment: Rails.env,
      uptime: app_uptime,
      checks: health_checks
    }
    
    status_code = overall_status == 'healthy' ? :ok : :service_unavailable
    
    render json: response_data, status: status_code
  end
  
  def ping
    render json: { 
      pong: true, 
      timestamp: Time.current.iso8601,
      server_time: Time.current.to_i
    }, status: :ok
  end
  
  def version
    render json: {
      version: app_version,
      rails_version: Rails.version,
      ruby_version: RUBY_VERSION,
      environment: Rails.env,
      git_commit: git_commit_hash,
      build_date: build_date
    }, status: :ok
  end
  
  def metrics
    return render_error('Access denied', :forbidden) unless can_view_metrics?
    
    metrics_data = {
      timestamp: Time.current.iso8601,
      application: application_metrics,
      database: database_metrics,
      cache: cache_metrics,
      storage: storage_metrics,
      system: system_metrics
    }
    
    render_success(metrics_data)
  end
  
  def database_check
    return render_error('Access denied', :forbidden) unless can_view_detailed_status?
    
    database_status = check_database_connection
    
    render json: {
      database: database_status,
      timestamp: Time.current.iso8601
    }, status: database_status[:status] == 'healthy' ? :ok : :service_unavailable
  end
  
  def cache_check
    return render_error('Access denied', :forbidden) unless can_view_detailed_status?
    
    cache_status = check_cache_connection
    
    render json: {
      cache: cache_status,
      timestamp: Time.current.iso8601
    }, status: cache_status[:status] == 'healthy' ? :ok : :service_unavailable
  end
  
  def storage_check
    return render_error('Access denied', :forbidden) unless can_view_detailed_status?
    
    storage_status = check_storage_connection
    
    render json: {
      storage: storage_status,
      timestamp: Time.current.iso8601
    }, status: storage_status[:status] == 'healthy' ? :ok : :service_unavailable
  end
  
  def dependencies
    return render_error('Access denied', :forbidden) unless can_view_detailed_status?
    
    dependencies_status = check_external_dependencies
    
    render json: {
      dependencies: dependencies_status,
      timestamp: Time.current.iso8601
    }, status: :ok
  end
  
  def readiness
    readiness_checks = perform_readiness_checks
    ready = readiness_checks.all? { |_, check| check[:status] == 'ready' }
    
    response_data = {
      ready: ready,
      timestamp: Time.current.iso8601,
      checks: readiness_checks
    }
    
    status_code = ready ? :ok : :service_unavailable
    render json: response_data, status: status_code
  end
  
  def liveness
    # Simple liveness check - if we can respond, we're alive
    render json: {
      alive: true,
      timestamp: Time.current.iso8601,
      pid: Process.pid,
      uptime: app_uptime
    }, status: :ok
  end
  
  private
  
  def perform_health_checks
    {
      database: check_database_connection,
      cache: check_cache_connection,
      storage: check_storage_connection,
      memory: check_memory_usage,
      disk_space: check_disk_space
    }
  end
  
  def perform_readiness_checks
    {
      database: check_database_readiness,
      migrations: check_migrations_status,
      dependencies: check_critical_dependencies
    }
  end
  
  def check_database_connection
    start_time = Time.current
    
    begin
      ActiveRecord::Base.connection.execute('SELECT 1')
      response_time = ((Time.current - start_time) * 1000).round(2)
      
      {
        status: 'healthy',
        response_time_ms: response_time,
        pool_size: ActiveRecord::Base.connection_pool.size,
        active_connections: ActiveRecord::Base.connection_pool.connections.count,
        message: 'Database connection successful'
      }
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        message: 'Database connection failed'
      }
    end
  end
  
  def check_cache_connection
    start_time = Time.current
    
    begin
      Rails.cache.write('health_check', 'ok', expires_in: 10.seconds)
      result = Rails.cache.read('health_check')
      response_time = ((Time.current - start_time) * 1000).round(2)
      
      if result == 'ok'
        {
          status: 'healthy',
          response_time_ms: response_time,
          message: 'Cache connection successful'
        }
      else
        {
          status: 'unhealthy',
          message: 'Cache read/write failed'
        }
      end
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        message: 'Cache connection failed'
      }
    end
  end
  
  def check_storage_connection
    return { status: 'skipped', message: 'Storage check not applicable in development' } if Rails.env.development?
    
    begin
      # Test S3 connection if using S3
      if Rails.application.config.active_storage.service == :amazon
        s3_client = Aws::S3::Client.new
        s3_client.head_bucket(bucket: Rails.application.credentials.aws[:s3_bucket])
      end
      
      {
        status: 'healthy',
        message: 'Storage connection successful'
      }
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        message: 'Storage connection failed'
      }
    end
  end
  
  def check_memory_usage
    # Get memory usage (works on Unix systems)
    begin
      if File.exist?('/proc/meminfo')
        meminfo = File.read('/proc/meminfo')
        total_memory = meminfo.match(/MemTotal:\s+(\d+)/)[1].to_i
        free_memory = meminfo.match(/MemFree:\s+(\d+)/)[1].to_i
        used_percentage = ((total_memory - free_memory).to_f / total_memory * 100).round(2)
        
        status = used_percentage > 90 ? 'unhealthy' : 'healthy'
        
        {
          status: status,
          used_percentage: used_percentage,
          total_mb: (total_memory / 1024.0).round(2),
          free_mb: (free_memory / 1024.0).round(2),
          message: "Memory usage: #{used_percentage}%"
        }
      else
        {
          status: 'skipped',
          message: 'Memory check not available on this system'
        }
      end
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        message: 'Memory check failed'
      }
    end
  end
  
  def check_disk_space
    begin
      disk_usage = `df -h /`.split("\n")[1].split
      used_percentage = disk_usage[4].to_i
      
      status = used_percentage > 90 ? 'unhealthy' : 'healthy'
      
      {
        status: status,
        used_percentage: used_percentage,
        total: disk_usage[1],
        used: disk_usage[2],
        available: disk_usage[3],
        message: "Disk usage: #{used_percentage}%"
      }
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        message: 'Disk space check failed'
      }
    end
  end
  
  def check_database_readiness
    begin
      User.connection.schema_cache.clear!
      User.first
      
      {
        status: 'ready',
        message: 'Database is ready'
      }
    rescue => e
      {
        status: 'not_ready',
        error: e.message,
        message: 'Database not ready'
      }
    end
  end
  
  def check_migrations_status
    begin
      pending_migrations = ActiveRecord::Base.connection.migration_context.needs_migration?
      
      if pending_migrations
        {
          status: 'not_ready',
          message: 'Pending migrations detected'
        }
      else
        {
          status: 'ready',
          message: 'All migrations applied'
        }
      end
    rescue => e
      {
        status: 'not_ready',
        error: e.message,
        message: 'Migration check failed'
      }
    end
  end
  
  def check_critical_dependencies
    # Check if critical models and services are available
    begin
      User.table_exists?
      Post.table_exists?
      
      {
        status: 'ready',
        message: 'Critical dependencies available'
      }
    rescue => e
      {
        status: 'not_ready',
        error: e.message,
        message: 'Critical dependencies not available'
      }
    end
  end
  
  def check_external_dependencies
    dependencies = {}
    
    # Add external service checks here
    # Example: Email service, third-party APIs, etc.
    
    dependencies
  end
  
  def application_metrics
    {
      users_count: User.count,
      posts_count: Post.count,
      comments_count: Comment.count,
      notifications_count: Notification.count,
      active_users_24h: User.where('last_sign_in_at > ?', 24.hours.ago).count,
      posts_24h: Post.where('created_at > ?', 24.hours.ago).count
    }
  end
  
  def database_metrics
    {
      pool_size: ActiveRecord::Base.connection_pool.size,
      active_connections: ActiveRecord::Base.connection_pool.connections.count,
      database_size: calculate_database_size
    }
  end
  
  def cache_metrics
    {
      hit_rate: calculate_cache_hit_rate,
      memory_usage: Rails.cache.stats if Rails.cache.respond_to?(:stats)
    }.compact
  end
  
  def storage_metrics
    return {} if Rails.env.development?
    
    {
      total_files: ActiveStorage::Blob.count,
      total_size_bytes: ActiveStorage::Blob.sum(:byte_size)
    }
  end
  
  def system_metrics
    {
      ruby_version: RUBY_VERSION,
      rails_version: Rails.version,
      pid: Process.pid,
      uptime_seconds: app_uptime_seconds
    }
  end
  
  def can_view_metrics?
    return false unless current_user
    return true if Rails.env.development?
    
    # Add authorization logic here (admin users, etc.)
    current_user.admin? if current_user.respond_to?(:admin?)
  end
  
  def can_view_detailed_status?
    can_view_metrics?
  end
  
  def app_version
    ENV['APP_VERSION'] || Rails.application.config.version || '1.0.0'
  end
  
  def app_uptime
    uptime_seconds = app_uptime_seconds
    
    days = uptime_seconds / 86400
    hours = (uptime_seconds % 86400) / 3600
    minutes = (uptime_seconds % 3600) / 60
    
    "#{days}d #{hours}h #{minutes}m"
  end
  
  def app_uptime_seconds
    @start_time ||= Time.current
    Time.current - @start_time
  end
  
  def git_commit_hash
    ENV['GIT_COMMIT'] || `git rev-parse HEAD 2>/dev/null`.strip.presence || 'unknown'
  end
  
  def build_date
    ENV['BUILD_DATE'] || File.mtime(Rails.root).iso8601
  end
  
  def calculate_database_size
    # PostgreSQL specific query
    return 'unknown' unless ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
    
    result = ActiveRecord::Base.connection.execute(
      "SELECT pg_size_pretty(pg_database_size(current_database()))"
    )
    result.first['pg_size_pretty'] if result.any?
  rescue
    'unknown'
  end
  
  def calculate_cache_hit_rate
    # Implementation depends on cache store
    if Rails.cache.respond_to?(:stats)
      stats = Rails.cache.stats
      return ((stats['get_hits'].to_f / (stats['get_hits'] + stats['get_misses'])) * 100).round(2) if stats['get_hits'] && stats['get_misses']
    end
    
    nil
  end
end
