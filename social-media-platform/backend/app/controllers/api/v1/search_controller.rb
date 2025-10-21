class Api::V1::SearchController < Api::V1::BaseController
  before_action :validate_search_query, only: [:all, :users, :posts, :hashtags]
  
  def all
    results = perform_global_search
    
    render_success({
      query: @query,
      results: results,
      total_results: calculate_total_results(results)
    })
  end
  
  def users
    users = User.search(@query)
                .active
                .limit(20)
    
    render_success({
      query: @query,
      users: users.map { |user| user_search_data(user) },
      total_count: users.count
    })
  end
  
  def posts
    posts = Post.search(@query)
                .includes(:user, :likes, :original_post, comments: :user)
                .public_posts
                .recent
    
    posts = paginate_collection(posts)
    
    render_success({
      query: @query,
      posts: posts.map { |post| post_search_data(post) },
      meta: pagination_meta(posts)
    })
  end
  
  def hashtags
    hashtags = extract_hashtags_from_query(@query)
    hashtag_results = []
    
    hashtags.each do |hashtag|
      posts_count = Post.by_hashtag(hashtag).public_posts.count
      next if posts_count.zero?
      
      hashtag_results << {
        hashtag: hashtag,
        posts_count: posts_count,
        trending_score: calculate_hashtag_trending_score(hashtag),
        recent_posts: Post.by_hashtag(hashtag)
                          .public_posts
                          .recent
                          .limit(3)
                          .map { |post| post_search_data(post) }
      }
    end
    
    # Also search for hashtags mentioned in posts
    additional_hashtags = find_trending_hashtags(@query)
    hashtag_results.concat(additional_hashtags)
    
    # Sort by trending score and posts count
    hashtag_results = hashtag_results.uniq { |h| h[:hashtag] }
                                    .sort_by { |h| [-h[:trending_score], -h[:posts_count]] }
                                    .first(10)
    
    render_success({
      query: @query,
      hashtags: hashtag_results,
      total_count: hashtag_results.length
    })
  end
  
  def suggestions
    query = params[:q]&.strip&.downcase
    return render_success({ suggestions: [] }) if query.blank? || query.length < 2
    
    suggestions = []
    
    # User suggestions
    user_suggestions = User.where("LOWER(username) LIKE ? OR LOWER(full_name) LIKE ?", 
                                  "%#{query}%", "%#{query}%")
                          .active
                          .limit(5)
                          .map do |user|
      {
        type: 'user',
        id: user.id,
        text: "@#{user.username}",
        display_text: "#{user.display_name} (@#{user.username})",
        avatar_url: user.avatar_url(:small),
        verified: user.verified
      }
    end
    
    # Hashtag suggestions
    hashtag_suggestions = find_hashtag_suggestions(query)
    
    # Recent search suggestions for the current user
    recent_suggestions = get_recent_search_suggestions(query) if current_user
    
    suggestions = [
      *user_suggestions,
      *hashtag_suggestions,
      *(recent_suggestions || [])
    ].first(10)
    
    render_success({
      query: query,
      suggestions: suggestions
    })
  end
  
  def trending
    trending_data = {
      hashtags: get_trending_hashtags,
      users: get_trending_users,
      posts: get_trending_posts
    }
    
    render_success(trending_data)
  end
  
  def recent_searches
    return render_error('Authentication required') unless current_user
    
    recent_searches = current_user.search_histories
                                  .recent
                                  .limit(10)
                                  .pluck(:query)
                                  .uniq
    
    render_success({
      recent_searches: recent_searches
    })
  end
  
  def clear_search_history
    return render_error('Authentication required') unless current_user
    
    count = current_user.search_histories.count
    current_user.search_histories.destroy_all
    
    render_success({
      cleared_count: count
    }, 'Search history cleared')
  end
  
  def advanced
    filters = advanced_search_params
    results = perform_advanced_search(filters)
    
    render_success({
      filters: filters,
      results: results
    })
  end
  
  private
  
  def validate_search_query
    @query = params[:q]&.strip
    return render_error('Search query is required') if @query.blank?
    return render_error('Search query too short') if @query.length < 2
    return render_error('Search query too long') if @query.length > 100
    
    # Save search history for authenticated users
    save_search_history if current_user
  end
  
  def perform_global_search
    {
      users: User.search(@query).active.limit(5).map { |user| user_search_data(user) },
      posts: Post.search(@query).public_posts.recent.limit(10).map { |post| post_search_data(post) },
      hashtags: find_trending_hashtags(@query).first(5),
      comments: Comment.search(@query)
                      .joins(:post)
                      .where(posts: { visibility: 'public' })
                      .recent
                      .limit(5)
                      .map { |comment| comment_search_data(comment) }
    }
  end
  
  def calculate_total_results(results)
    results.values.sum { |category| category.is_a?(Array) ? category.length : 0 }
  end
  
  def user_search_data(user)
    {
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
  end
  
  def post_search_data(post)
    {
      id: post.id,
      content: post.content,
      content_preview: post.content&.truncate(150),
      visibility: post.visibility,
      likes_count: post.likes_count,
      comments_count: post.comments_count,
      shares_count: post.shares_count,
      hashtags: post.hashtags,
      has_media: post.has_media?,
      image_urls: post.image_urls.first(2), # Limit for search results
      created_at: post.created_at,
      formatted_created_at: post.formatted_created_at,
      user: {
        id: post.user.id,
        username: post.user.username,
        full_name: post.user.full_name,
        display_name: post.user.display_name,
        verified: post.user.verified,
        avatar_url: post.user.avatar_url(:small)
      },
      current_user_liked: current_user ? post.liked_by?(current_user) : false
    }
  end
  
  def comment_search_data(comment)
    {
      id: comment.id,
      content: comment.content&.truncate(100),
      likes_count: comment.likes_count,
      created_at: comment.created_at,
      formatted_created_at: comment.formatted_created_at,
      user: {
        id: comment.user.id,
        username: comment.user.username,
        full_name: comment.user.full_name,
        avatar_url: comment.user.avatar_url(:small)
      },
      post: {
        id: comment.post.id,
        content: comment.post.content&.truncate(50)
      }
    }
  end
  
  def extract_hashtags_from_query(query)
    query.scan(/#[\w]+/).map { |tag| tag.gsub('#', '') }
  end
  
  def find_trending_hashtags(query)
    # Find hashtags that contain the search term
    hashtag_pattern = "%#{query.gsub('#', '')}%"
    
    Post.joins("JOIN unnest(hashtags) AS hashtag ON true")
        .where("hashtag ILIKE ?", hashtag_pattern)
        .where('created_at >= ?', 7.days.ago)
        .group('hashtag')
        .order('COUNT(*) DESC')
        .limit(10)
        .count
        .map do |hashtag, count|
      {
        hashtag: hashtag,
        posts_count: count,
        trending_score: calculate_hashtag_trending_score(hashtag),
        recent_posts: []
      }
    end
  end
  
  def find_hashtag_suggestions(query)
    query_without_hash = query.gsub('#', '')
    
    Post.joins("JOIN unnest(hashtags) AS hashtag ON true")
        .where("hashtag ILIKE ?", "#{query_without_hash}%")
        .where('created_at >= ?', 30.days.ago)
        .group('hashtag')
        .order('COUNT(*) DESC')
        .limit(5)
        .count
        .map do |hashtag, count|
      {
        type: 'hashtag',
        text: "##{hashtag}",
        display_text: "##{hashtag} (#{count} posts)",
        posts_count: count
      }
    end
  end
  
  def calculate_hashtag_trending_score(hashtag)
    recent_posts = Post.by_hashtag(hashtag).where('created_at >= ?', 24.hours.ago).count
    total_engagement = Post.by_hashtag(hashtag)
                          .where('created_at >= ?', 7.days.ago)
                          .sum('likes_count + comments_count + shares_count')
    
    (recent_posts * 10) + (total_engagement * 0.1)
  end
  
  def get_recent_search_suggestions(query)
    return [] unless current_user
    
    current_user.search_histories
                .where("query ILIKE ?", "%#{query}%")
                .recent
                .limit(3)
                .pluck(:query)
                .uniq
                .map do |search_query|
      {
        type: 'recent',
        text: search_query,
        display_text: search_query
      }
    end
  end
  
  def get_trending_hashtags
    Post.joins("JOIN unnest(hashtags) AS hashtag ON true")
        .where('created_at >= ?', 7.days.ago)
        .group('hashtag')
        .order('COUNT(*) DESC')
        .limit(10)
        .count
        .map do |hashtag, count|
      {
        hashtag: hashtag,
        posts_count: count,
        trending_score: calculate_hashtag_trending_score(hashtag)
      }
    end
  end
  
  def get_trending_users
    User.joins(:posts)
        .where(posts: { created_at: 7.days.ago..Time.current })
        .group('users.id')
        .order('COUNT(posts.id) DESC, users.followers_count DESC')
        .limit(5)
        .map { |user| user_search_data(user) }
  end
  
  def get_trending_posts
    Post.trending
        .includes(:user, :likes)
        .limit(10)
        .map { |post| post_search_data(post) }
  end
  
  def save_search_history
    # Create or update search history entry
    current_user.search_histories.find_or_create_by(query: @query) do |history|
      history.search_count = 1
    end.tap do |history|
      history.increment!(:search_count)
      history.touch
    end
  end
  
  def advanced_search_params
    params.permit(:q, :user, :from_date, :to_date, :has_media, :min_likes, :hashtag)
  end
  
  def perform_advanced_search(filters)
    posts = Post.includes(:user, :likes, :original_post, comments: :user)
                .public_posts
    
    # Apply filters
    posts = posts.search(filters[:q]) if filters[:q].present?
    posts = posts.joins(:user).where(users: { username: filters[:user] }) if filters[:user].present?
    posts = posts.where('posts.created_at >= ?', filters[:from_date]) if filters[:from_date].present?
    posts = posts.where('posts.created_at <= ?', filters[:to_date]) if filters[:to_date].present?
    posts = posts.with_media if filters[:has_media] == 'true'
    posts = posts.where('likes_count >= ?', filters[:min_likes]) if filters[:min_likes].present?
    posts = posts.by_hashtag(filters[:hashtag]) if filters[:hashtag].present?
    
    posts = paginate_collection(posts.recent)
    
    {
      posts: posts.map { |post| post_search_data(post) },
      meta: pagination_meta(posts)
    }
  end
end
