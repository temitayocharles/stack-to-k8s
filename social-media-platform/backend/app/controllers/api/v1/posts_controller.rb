class Api::V1::PostsController < Api::V1::BaseController
  before_action :set_post, only: [:show, :update, :destroy, :like, :unlike, :share]
  before_action :check_post_access, only: [:update, :destroy]
  before_action :check_post_visibility, only: [:show, :like, :unlike, :share]
  
  def index
    posts = Post.includes(:user, :likes, :original_post, comments: :user)
                .public_posts
                .recent
    
    posts = paginate_collection(posts)
    
    render_success({
      posts: posts.map { |post| post_data(post) },
      meta: pagination_meta(posts)
    })
  end
  
  def show
    render_success({
      post: post_data(@post, include_comments: true)
    })
  end
  
  def create
    @post = current_user.posts.build(post_params)
    
    if @post.save
      attach_media if params[:images].present? || params[:videos].present?
      
      render_success({
        post: post_data(@post)
      }, 'Post created successfully', :created)
    else
      render_validation_errors(@post)
    end
  end
  
  def update
    if @post.update(post_params)
      render_success({
        post: post_data(@post)
      }, 'Post updated successfully')
    else
      render_validation_errors(@post)
    end
  end
  
  def destroy
    @post.destroy!
    render_success({}, 'Post deleted successfully')
  end
  
  def like
    if @post.like!(current_user)
      render_success({
        liked: true,
        likes_count: @post.likes_count
      }, 'Post liked')
    else
      render_error('Unable to like post')
    end
  end
  
  def unlike
    if @post.unlike!(current_user)
      render_success({
        liked: false,
        likes_count: @post.likes_count
      }, 'Post unliked')
    else
      render_error('Unable to unlike post')
    end
  end
  
  def share
    shared_post = @post.share!(current_user, content: params[:content])
    
    if shared_post
      render_success({
        shared_post: post_data(shared_post),
        shares_count: @post.shares_count
      }, 'Post shared successfully', :created)
    else
      render_error('Unable to share post')
    end
  end
  
  def feed
    posts = Post.feed_for_user(current_user, limit: params[:per_page], offset: params[:page])
    posts = paginate_collection(posts)
    
    render_success({
      posts: posts.map { |post| post_data(post) },
      meta: pagination_meta(posts)
    })
  end
  
  def trending
    posts = Post.trending
                .includes(:user, :likes, :original_post, comments: :user)
                .limit(20)
    
    render_success({
      posts: posts.map { |post| post_data(post) }
    })
  end
  
  def discover
    posts = Post.discover_for_user(current_user, limit: 20)
    
    render_success({
      posts: posts.map { |post| post_data(post) }
    })
  end
  
  def user_posts
    user = User.find(params[:user_id])
    
    unless user.can_view_posts?(current_user)
      return render_error('Cannot view posts from this private account', :forbidden)
    end
    
    posts = user.posts.includes(:user, :likes, :original_post, comments: :user)
                     .recent
    
    posts = paginate_collection(posts)
    
    render_success({
      posts: posts.map { |post| post_data(post) },
      meta: pagination_meta(posts),
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name
      }
    })
  end
  
  def search
    query = params[:q]&.strip
    return render_error('Search query is required') if query.blank?
    
    posts = Post.search(query)
                .includes(:user, :likes, :original_post, comments: :user)
                .public_posts
                .recent
    
    posts = paginate_collection(posts)
    
    render_success({
      posts: posts.map { |post| post_data(post) },
      meta: pagination_meta(posts),
      query: query
    })
  end
  
  def hashtag
    hashtag = params[:hashtag]
    return render_error('Hashtag is required') if hashtag.blank?
    
    posts = Post.by_hashtag(hashtag)
                .includes(:user, :likes, :original_post, comments: :user)
                .public_posts
                .recent
    
    posts = paginate_collection(posts)
    
    render_success({
      posts: posts.map { |post| post_data(post) },
      meta: pagination_meta(posts),
      hashtag: hashtag
    })
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def check_post_access
    unless @post.user == current_user
      render_error('Access denied', :forbidden)
    end
  end
  
  def check_post_visibility
    unless @post.visible_to?(current_user)
      render_error('Post not accessible', :forbidden)
    end
  end
  
  def post_params
    params.require(:post).permit(:content, :visibility)
  end
  
  def attach_media
    @post.images.attach(params[:images]) if params[:images].present?
    @post.videos.attach(params[:videos]) if params[:videos].present?
  end
  
  def post_data(post, include_comments: false)
    data = {
      id: post.id,
      content: post.content,
      visibility: post.visibility,
      likes_count: post.likes_count,
      comments_count: post.comments_count,
      shares_count: post.shares_count,
      engagement_score: post.engagement_score,
      hashtags: post.hashtags,
      mentions: post.mentions,
      has_media: post.has_media?,
      image_urls: post.image_urls,
      video_urls: post.video_urls,
      is_shared: post.shared_post?,
      created_at: post.created_at,
      updated_at: post.updated_at,
      formatted_created_at: post.formatted_created_at,
      user: {
        id: post.user.id,
        username: post.user.username,
        full_name: post.user.full_name,
        display_name: post.user.display_name,
        verified: post.user.verified,
        avatar_url: post.user.avatar_url(:small)
      },
      current_user_liked: current_user ? post.liked_by?(current_user) : false,
      can_comment: current_user ? post.can_comment?(current_user) : false
    }
    
    # Include original post data if this is a shared post
    if post.shared_post? && post.original_post
      data[:original_post] = {
        id: post.original_post.id,
        content: post.original_post.content,
        created_at: post.original_post.created_at,
        user: {
          id: post.original_post.user.id,
          username: post.original_post.user.username,
          full_name: post.original_post.user.full_name,
          avatar_url: post.original_post.user.avatar_url(:small)
        },
        has_media: post.original_post.has_media?,
        image_urls: post.original_post.image_urls,
        video_urls: post.original_post.video_urls
      }
    end
    
    # Include recent comments if requested
    if include_comments
      data[:recent_comments] = post.recent_comments.map do |comment|
        {
          id: comment.id,
          content: comment.content,
          likes_count: comment.likes_count,
          created_at: comment.created_at,
          formatted_created_at: comment.formatted_created_at,
          user: {
            id: comment.user.id,
            username: comment.user.username,
            full_name: comment.user.full_name,
            avatar_url: comment.user.avatar_url(:small)
          },
          current_user_liked: current_user ? comment.liked_by?(current_user) : false
        }
      end
      
      data[:recent_likes] = post.recent_likes.map do |like|
        {
          id: like.id,
          created_at: like.created_at,
          user: {
            id: like.user.id,
            username: like.user.username,
            full_name: like.user.full_name,
            avatar_url: like.user.avatar_url(:small)
          }
        }
      end
    end
    
    data
  end
end
