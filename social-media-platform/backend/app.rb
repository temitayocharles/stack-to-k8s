# Simple Ruby Social Media API with Sinatra
require 'sinatra'
require 'json'
require 'redis'
require 'pg'

# Configuration
set :port, 3000
set :bind, '0.0.0.0'

# Initialize Redis
redis = Redis.new(host: ENV['REDIS_HOST'] || 'social-media-redis')

# Health check endpoint
get '/health' do
  content_type :json
  { status: 'OK', timestamp: Time.now.iso8601, service: 'social-media-api' }.to_json
end

# API root
get '/api' do
  content_type :json
  { 
    message: 'Social Media Platform API',
    version: '1.0.0',
    endpoints: [
      'GET /health - Health check',
      'GET /api - API info',
      'GET /api/users - Get users',
      'GET /api/posts - Get posts'
    ]
  }.to_json
end

# Mock users endpoint
get '/api/users' do
  content_type :json
  users = [
    { id: 1, name: 'John Doe', email: 'john@example.com', followers: 150 },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', followers: 203 },
    { id: 3, name: 'Bob Johnson', email: 'bob@example.com', followers: 89 }
  ]
  { users: users, total: users.length }.to_json
end

# Mock posts endpoint
get '/api/posts' do
  content_type :json
  posts = [
    { 
      id: 1, 
      user_id: 1, 
      content: 'Just deployed my new application!', 
      likes: 25, 
      comments: 3, 
      created_at: '2025-09-18T10:30:00Z' 
    },
    { 
      id: 2, 
      user_id: 2, 
      content: 'Learning Docker and Kubernetes', 
      likes: 42, 
      comments: 7, 
      created_at: '2025-09-18T09:15:00Z' 
    },
    { 
      id: 3, 
      user_id: 3, 
      content: 'Great weather for coding today!', 
      likes: 18, 
      comments: 2, 
      created_at: '2025-09-18T08:45:00Z' 
    }
  ]
  { posts: posts, total: posts.length }.to_json
end

# Stats endpoint
get '/api/stats' do
  content_type :json
  {
    total_users: 1250,
    total_posts: 5420,
    active_users: 89,
    platform: 'Social Media Platform',
    uptime: `uptime`.strip
  }.to_json
end

# Root endpoint
get '/' do
  content_type :json
  { 
    message: 'Social Media Platform Backend API',
    status: 'running',
    timestamp: Time.now.iso8601
  }.to_json
end

# Start the server
puts "🚀 Social Media Platform API starting on port 3000..."
puts "📊 Health endpoint: http://localhost:3000/health"
puts "🔗 API endpoint: http://localhost:3000/api"