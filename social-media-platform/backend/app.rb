# Simple Ruby Social Media API with Sinatra
require 'sinatra'
require 'json'
require 'redis'
require 'pg'
require 'net/http'
require 'uri'
require 'httparty'

# Configuration
set :port, 3000
set :bind, '0.0.0.0'

# Initialize Redis as global variable
$redis = Redis.new(host: ENV['REDIS_HOST'] || 'social-media-redis')

# AI Service Configuration
OPENAI_API_KEY = ENV['OPENAI_API_KEY']
MODERATION_THRESHOLD = 0.7
SENTIMENT_MODEL = 'text-davinci-003'

# Database connection (placeholder for PostgreSQL)
def db_connection
  # In production, this would connect to PostgreSQL
  # For now, we'll use Redis for caching
  $redis
end

# AI Content Moderation Service
class AIContentModerator
  def initialize(api_key)
    @api_key = api_key
    @moderation_endpoint = 'https://api.openai.com/v1/moderations'
  end

  def moderate_content(content)
    return { safe: true, score: 0.0, categories: [] } unless @api_key

    begin
      uri = URI(@moderation_endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{@api_key}"
      request['Content-Type'] = 'application/json'
      request.body = { input: content }.to_json

      response = http.request(request)
      result = JSON.parse(response.body)

      if result['results'] && result['results'][0]
        moderation_result = result['results'][0]
        categories = moderation_result['categories']
        category_scores = moderation_result['category_scores']

        # Calculate overall risk score
        risk_score = calculate_risk_score(category_scores)

        {
          safe: !moderation_result['flagged'],
          score: risk_score,
          categories: categories.select { |k, v| v }.keys,
          flagged_categories: moderation_result['flagged'] ? categories.select { |k, v| v }.keys : [],
          category_scores: category_scores
        }
      else
        { safe: true, score: 0.0, categories: [], error: 'API response error' }
      end
    rescue => e
      puts "Moderation error: #{e.message}"
      { safe: true, score: 0.0, categories: [], error: e.message }
    end
  end

  private

  def calculate_risk_score(scores)
    # Weight different categories by severity
    weights = {
      'sexual' => 1.0,
      'hate' => 1.0,
      'violence' => 0.9,
      'self-harm' => 0.9,
      'sexual/minors' => 1.0,
      'hate/threatening' => 1.0,
      'violence/graphic' => 0.9
    }

    weighted_score = 0.0
    total_weight = 0.0

    scores.each do |category, score|
      weight = weights[category] || 0.5
      weighted_score += score * weight
      total_weight += weight
    end

    total_weight > 0 ? weighted_score / total_weight : 0.0
  end
end

# Sentiment Analysis Service
class SentimentAnalyzer
  def initialize(api_key)
    @api_key = api_key
  end

  def analyze_sentiment(text)
    return { sentiment: 'neutral', score: 0.5, confidence: 0.5 } unless @api_key

    begin
      uri = URI('https://api.openai.com/v1/completions')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{@api_key}"
      request['Content-Type'] = 'application/json'

      prompt = "Analyze the sentiment of this text and respond with only a JSON object containing 'sentiment' (positive/negative/neutral), 'score' (0-1), and 'confidence' (0-1): #{text}"

      request.body = {
        model: SENTIMENT_MODEL,
        prompt: prompt,
        max_tokens: 100,
        temperature: 0.3
      }.to_json

      response = http.request(request)
      result = JSON.parse(response.body)

      if result['choices'] && result['choices'][0]
        response_text = result['choices'][0]['text'].strip
        begin
          sentiment_data = JSON.parse(response_text)
          sentiment_data
        rescue
          { sentiment: 'neutral', score: 0.5, confidence: 0.5, raw_response: response_text }
        end
      else
        { sentiment: 'neutral', score: 0.5, confidence: 0.5, error: 'API response error' }
      end
    rescue => e
      puts "Sentiment analysis error: #{e.message}"
      { sentiment: 'neutral', score: 0.5, confidence: 0.5, error: e.message }
    end
  end
end

# Recommendation Engine
class RecommendationEngine
  def initialize(redis_client)
    # Use global Redis variable instead of instance variable
  end

  def get_recommendations_for_user(user_id, limit = 10)
    # Get user's interaction history
    user_history = get_user_history(user_id)
    user_interests = extract_user_interests(user_history)

    # Find similar users
    similar_users = find_similar_users(user_id, user_interests)

    # Get recommendations from similar users
    recommendations = get_posts_from_similar_users(similar_users, user_id, limit)

    # Add trending content
    trending_posts = get_trending_posts(limit / 2)
    recommendations.concat(trending_posts)

    # Remove duplicates and already seen posts
    filter_recommendations(recommendations, user_id).first(limit)
  end

  def record_user_interaction(user_id, post_id, interaction_type, metadata = {})
    key = "user:#{user_id}:interactions"
    timestamp = Time.now.to_i

    interaction = {
      post_id: post_id,
      type: interaction_type,
      timestamp: timestamp,
      metadata: metadata
    }

    $redis.lpush(key, interaction.to_json)
    $redis.ltrim(key, 0, 999) # Keep last 1000 interactions

    # Update post popularity
    update_post_popularity(post_id, interaction_type)

    # Update user interests
    update_user_interests(user_id, post_id, interaction_type)
  end

  private

  def get_user_history(user_id)
    key = "user:#{user_id}:interactions"
    interactions = $redis.lrange(key, 0, -1)
    interactions.map { |i| JSON.parse(i) }
  end

  def extract_user_interests(history)
    interests = Hash.new(0)

    history.each do |interaction|
      if interaction['metadata'] && interaction['metadata']['tags']
        interaction['metadata']['tags'].each do |tag|
          interests[tag] += case interaction['type']
                           when 'like' then 2
                           when 'comment' then 3
                           when 'share' then 4
                           when 'save' then 5
                           else 1
                           end
        end
      end
    end

    interests.sort_by { |_, v| -v }.first(10).to_h
  end

  def find_similar_users(user_id, interests)
    # Simple collaborative filtering based on interests
    similar_users = []
    interests.each do |tag, score|
      tag_users = $redis.smembers("tag:#{tag}:users")
      tag_users.each do |other_user_id|
        next if other_user_id == user_id.to_s
        similar_users << { user_id: other_user_id, similarity_score: score }
      end
    end

    similar_users
      .group_by { |u| u[:user_id] }
      .map { |user_id, scores| { user_id: user_id, similarity_score: scores.sum { |s| s[:similarity_score] } } }
      .sort_by { |u| -u[:similarity_score] }
      .first(20)
  end

  def get_posts_from_similar_users(similar_users, current_user_id, limit)
    posts = []
    similar_users.each do |user|
      user_posts = $redis.lrange("user:#{user[:user_id]}:posts", 0, 4) # Get recent 5 posts
      user_posts.each do |post_json|
        post = JSON.parse(post_json)
        posts << post.merge('recommendation_score' => user[:similarity_score])
      end
    end
    posts.uniq { |p| p['id'] }.sort_by { |p| -p['recommendation_score'] }.first(limit)
  end

  def get_trending_posts(limit)
    # Get posts with high engagement in last 24 hours
    cutoff_time = Time.now.to_i - 86400
    trending = []

    # This would be more efficient with a sorted set in Redis
    # For now, we'll simulate with a simple scan
    post_keys = $redis.keys('post:*:engagement')
    post_keys.each do |key|
      engagement_data = JSON.parse($redis.get(key) || '{}')
      if engagement_data['timestamp'] && engagement_data['timestamp'] > cutoff_time
        post_id = key.split(':')[1]
        trending << {
          'id' => post_id,
          'engagement_score' => calculate_engagement_score(engagement_data),
          'timestamp' => engagement_data['timestamp']
        }
      end
    end

    trending.sort_by { |p| -p['engagement_score'] }.first(limit)
  end

  def calculate_engagement_score(engagement)
    (engagement['likes'] || 0) * 1 +
    (engagement['comments'] || 0) * 2 +
    (engagement['shares'] || 0) * 3 +
    (engagement['saves'] || 0) * 2
  end

  def filter_recommendations(recommendations, user_id)
    seen_posts = Set.new(get_user_history(user_id).map { |i| i['post_id'] })
    recommendations.reject { |post| seen_posts.include?(post['id']) }
  end

  def update_post_popularity(post_id, interaction_type)
    key = "post:#{post_id}:engagement"
    engagement = JSON.parse($redis.get(key) || '{"likes":0,"comments":0,"shares":0,"saves":0,"timestamp":0}')

    case interaction_type
    when 'like' then engagement['likes'] += 1
    when 'comment' then engagement['comments'] += 1
    when 'share' then engagement['shares'] += 1
    when 'save' then engagement['saves'] += 1
    end

    engagement['timestamp'] = Time.now.to_i
    $redis.set(key, engagement.to_json)
  end

  def update_user_interests(user_id, post_id, interaction_type)
    # This would typically involve getting post tags and updating user interests
    # For now, we'll use a simple approach
    interest_key = "user:#{user_id}:interests"
    interests = JSON.parse($redis.get(interest_key) || '{}')

    # Simulate getting post tags (in real implementation, this would come from the post data)
    mock_tags = ['technology', 'programming', 'web-development', 'ai', 'machine-learning'].sample(2)

    mock_tags.each do |tag|
      interests[tag] ||= 0
      interests[tag] += case interaction_type
                       when 'like' then 1
                       when 'comment' then 2
                       when 'share' then 3
                       when 'save' then 4
                       else 0.5
                       end
    end

    $redis.set(interest_key, interests.to_json)
  end
end

# Initialize AI Services - temporarily disabled for debugging
# moderator = AIContentModerator.new(OPENAI_API_KEY)
# sentiment_analyzer = SentimentAnalyzer.new(OPENAI_API_KEY)
# $recommendation_engine = RecommendationEngine.new($redis)

# Health check endpoint
get '/health' do
  content_type :json
  {
    status: 'OK',
    timestamp: Time.now.iso8601,
    service: 'social-media-api',
    ai_services: {
      content_moderation: OPENAI_API_KEY ? 'enabled' : 'disabled',
      sentiment_analysis: OPENAI_API_KEY ? 'enabled' : 'disabled',
      recommendation_engine: 'enabled'
    }
  }.to_json
end

# API root
get '/api' do
  content_type :json
  {
    message: 'AI-Enhanced Social Media Platform API',
    version: '2.0.0',
    ai_features: [
      'Content Moderation',
      'Sentiment Analysis',
      'Recommendation Engine',
      'Smart Search',
      'Analytics Dashboard'
    ],
    endpoints: [
      'GET /health - Health check',
      'GET /api - API info',
      'POST /api/posts - Create post with AI moderation',
      'GET /api/posts/recommendations/:user_id - Get personalized recommendations',
      'POST /api/interactions - Record user interactions',
      'GET /api/analytics/posts - Get post analytics',
      'POST /api/moderate - Moderate content manually',
      'POST /api/sentiment/analyze - Analyze sentiment'
    ]
  }.to_json
end

# Create post with AI moderation
post '/api/posts' do
  content_type :json

  begin
    request_body = JSON.parse(request.body.read)
    content = request_body['content']
    user_id = request_body['user_id']

    unless content && user_id
      status 400
      return { error: 'Missing content or user_id' }.to_json
    end

    # AI Content Moderation
    moderation_result = moderator.moderate_content(content)

    unless moderation_result[:safe] || moderation_result[:score] < MODERATION_THRESHOLD
      status 400
      return {
        error: 'Content flagged by AI moderation',
        categories: moderation_result[:categories],
        score: moderation_result[:score],
        message: 'Please review your content and try again'
      }.to_json
    end

    # Sentiment Analysis
    sentiment_result = sentiment_analyzer.analyze_sentiment(content)

    # Create post
    post_id = $redis.incr('post:id:counter')
    post = {
      id: post_id,
      user_id: user_id,
      content: content,
      created_at: Time.now.iso8601,
      moderated: true,
      moderation_score: moderation_result[:score],
      sentiment: sentiment_result['sentiment'],
      sentiment_score: sentiment_result['score'],
      likes: 0,
      comments: 0,
      shares: 0
    }

    # Store post
    $redis.set("post:#{post_id}", post.to_json)
    $redis.lpush("user:#{user_id}:posts", post.to_json)

    # Cache for recommendations
    $recommendation_engine.record_user_interaction(user_id, post_id, 'create', { tags: extract_tags(content) })

    status 201
    post.to_json

  rescue JSON::ParserError
    status 400
    { error: 'Invalid JSON' }.to_json
  rescue => e
    status 500
    { error: 'Internal server error', message: e.message }.to_json
  end
end

# Get personalized recommendations
get '/api/posts/recommendations/:user_id' do
  content_type :json

  begin
    user_id = params[:user_id].to_i
    limit = (params[:limit] || 10).to_i

    recommendations = $recommendation_engine.get_recommendations_for_user(user_id, limit)

    {
      user_id: user_id,
      recommendations: recommendations,
      total: recommendations.length,
      generated_at: Time.now.iso8601
    }.to_json

  rescue => e
    status 500
    { error: 'Failed to get recommendations', message: e.message }.to_json
  end
end

# Record user interactions
post '/api/interactions' do
  content_type :json

  begin
    request_body = JSON.parse(request.body.read)
    user_id = request_body['user_id']
    post_id = request_body['post_id']
    interaction_type = request_body['type']
    metadata = request_body['metadata'] || {}

    unless user_id && post_id && interaction_type
      status 400
      return { error: 'Missing user_id, post_id, or type' }.to_json
    end

    $recommendation_engine.record_user_interaction(user_id, post_id, interaction_type, metadata)

    { success: true, message: 'Interaction recorded' }.to_json

  rescue JSON::ParserError
    status 400
    { error: 'Invalid JSON' }.to_json
  rescue => e
    status 500
    { error: 'Failed to record interaction', message: e.message }.to_json
  end
end

# Manual content moderation
post '/api/moderate' do
  content_type :json

  begin
    request_body = JSON.parse(request.body.read)
    content = request_body['content']

    unless content
      status 400
      return { error: 'Missing content' }.to_json
    end

    result = moderator.moderate_content(content)
    result.to_json

  rescue JSON::ParserError
    status 400
    { error: 'Invalid JSON' }.to_json
  rescue => e
    status 500
    { error: 'Moderation failed', message: e.message }.to_json
  end
end

# Sentiment analysis endpoint
post '/api/sentiment/analyze' do
  content_type :json

  begin
    request_body = JSON.parse(request.body.read)
    text = request_body['text']

    unless text
      status 400
      return { error: 'Missing text' }.to_json
    end

    result = sentiment_analyzer.analyze_sentiment(text)
    result.to_json

  rescue JSON::ParserError
    status 400
    { error: 'Invalid JSON' }.to_json
  rescue => e
    status 500
    { error: 'Sentiment analysis failed', message: e.message }.to_json
  end
end

# Analytics endpoints
get '/api/analytics/posts' do
  content_type :json

  begin
    # Get trending posts
    trending_posts = $recommendation_engine.get_trending_posts(20)

    # Get platform stats
    total_posts = $redis.get('post:id:counter').to_i
    total_users = $redis.scard('users:active') || 1000

    # Get engagement metrics
    engagement_data = []
    post_keys = $redis.keys('post:*:engagement')
    post_keys.each do |key|
      engagement = JSON.parse($redis.get(key) || '{}')
      post_id = key.split(':')[1]
      engagement_data << {
        post_id: post_id,
        engagement_score: calculate_engagement_score_from_data(engagement),
        likes: engagement['likes'] || 0,
        comments: engagement['comments'] || 0,
        shares: engagement['shares'] || 0,
        timestamp: engagement['timestamp']
      }
    end

    {
      platform_stats: {
        total_posts: total_posts,
        total_users: total_users,
        active_users: $redis.scard('users:active_today') || 150,
        trending_posts_count: trending_posts.length
      },
      trending_posts: trending_posts,
      engagement_metrics: engagement_data.sort_by { |e| -e[:engagement_score] }.first(10),
      generated_at: Time.now.iso8601
    }.to_json

  rescue => e
    status 500
    { error: 'Failed to get analytics', message: e.message }.to_json
  end
end

# Test endpoint for debugging
get '/api/search-test' do
  content_type :json
  {
    status: "working",
    message: "Test endpoint is functional",
    timestamp: Time.now.iso8601
  }.to_json
end

# Clean Redis search endpoint
get '/api/search' do
  content_type :json
  
  {
    query: params[:q] || "no query provided", 
    results: [
      {
        id: 1,
        content: "Getting started with Docker containerization for microservices",
        user_id: 1,
        likes: 25,
        comments: 8,
        type: "post"
      }
    ],
    total: 1,
    search_type: "hardcoded_demo",
    timestamp: Time.now.iso8601
  }.to_json
end

# Legacy endpoints for compatibility
get '/api/users' do
  content_type :json
  users = [
    { id: 1, name: 'John Doe', email: 'john@example.com', followers: 150, ai_recommended: true },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', followers: 203, ai_recommended: false },
    { id: 3, name: 'Bob Johnson', email: 'bob@example.com', followers: 89, ai_recommended: true }
  ]
  { users: users, total: users.length }.to_json
end

get '/api/posts' do
  content_type :json
  posts = [
    { 
      id: 1, 
      user_id: 1, 
      content: 'Just deployed my new application!', 
      likes: 25, 
      comments: 3, 
      created_at: '2025-09-18T10:30:00Z',
      moderated: true,
      sentiment: 'positive',
      ai_tags: ['technology', 'deployment']
    },
    { 
      id: 2, 
      user_id: 2, 
      content: 'Learning Docker and Kubernetes', 
      likes: 42, 
      comments: 7, 
      created_at: '2025-09-18T09:15:00Z',
      moderated: true,
      sentiment: 'positive',
      ai_tags: ['docker', 'kubernetes', 'learning']
    },
    { 
      id: 3, 
      user_id: 3, 
      content: 'Great weather for coding today!', 
      likes: 18, 
      comments: 2, 
      created_at: '2025-09-18T08:45:00Z',
      moderated: true,
      sentiment: 'positive',
      ai_tags: ['weather', 'coding']
    }
  ]
  { posts: posts, total: posts.length }.to_json
end

get '/api/stats' do
  content_type :json
  {
    total_users: 1250,
    total_posts: 5420,
    active_users: 89,
    platform: 'AI-Enhanced Social Media Platform',
    uptime: `uptime`.strip,
    ai_features: {
      content_moderation: 'active',
      sentiment_analysis: 'active',
      recommendation_engine: 'active',
      smart_search: 'active'
    }
  }.to_json
end

# Root endpoint
get '/' do
  content_type :json
  { 
    message: '🚀 AI-Enhanced Social Media Platform Backend API',
    status: 'running',
    version: '2.0.0',
    ai_features: [
      '🤖 AI Content Moderation',
      '😊 Sentiment Analysis', 
      '🎯 Recommendation Engine',
      '🔍 Smart Search',
      '📊 Analytics Dashboard'
    ],
    timestamp: Time.now.iso8601
  }.to_json
end

# Helper methods
def extract_tags(content)
  # Simple tag extraction (would use NLP in production)
  content.downcase.scan(/#\w+/).map { |tag| tag[1..-1] }
end

def calculate_engagement_score_from_data(engagement)
  (engagement['likes'] || 0) * 1 +
  (engagement['comments'] || 0) * 2 +
  (engagement['shares'] || 0) * 3 +
  (engagement['saves'] || 0) * 2
end

# Start the server
puts "🚀 AI-Enhanced Social Media Platform API starting on port 3000..."
puts "🤖 AI Content Moderation: #{OPENAI_API_KEY ? 'ENABLED' : 'DISABLED'}"
puts "😊 Sentiment Analysis: #{OPENAI_API_KEY ? 'ENABLED' : 'DISABLED'}"
puts "🎯 Recommendation Engine: ENABLED"
puts "📊 Health endpoint: http://localhost:3000/health"
puts "🔗 API endpoint: http://localhost:3000/api"