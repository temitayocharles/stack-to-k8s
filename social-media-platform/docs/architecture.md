# 📱 **Social Media Platform Architecture Deep Dive**
## **Complete Social Network Design & Implementation**

> **🎯 Goal**: Understand every component of the enterprise social media platform  
> **👨‍💻 For**: Social platform developers, system architects, and product engineers  
> **📚 Level**: Intermediate to Advanced (High-Scale Social Systems)  

---

## 🏗️ **High-Level Architecture Overview**

```
┌─────────────────────────────────────────────────────────────┐
│                Social Media Platform                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  React Native Web ←→    Ruby on Rails API Gateway          │
│  ┌─────────────────┐    ┌─────────────────────────┐         │
│  │ • Social Feed   │    │ • Authentication        │         │
│  │ • User Profiles │    │ • Rate Limiting         │         │
│  │ • Messaging     │    │ • Content Filtering     │         │
│  │ • Live Stream   │    │ • Media Processing      │         │
│  │ • Stories       │    │ • Real-time Updates     │         │
│  └─────────────────┘    └─────────────────────────┘         │
│                                          │                  │
│                             ┌────────────┴────────────┐     │
│                             │   Social Microservices  │     │
│                             │                         │     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  │ User Management │  │ Content Creator │  │ Social Feed     │
│  │ Service         │  │ Service         │  │ Service         │
│  │                 │  │                 │  │                 │
│  │ • Profiles      │  │ • Posts/Stories │  │ • Timeline Algo │
│  │ • Relationships │  │ • Media Upload  │  │ • Trending      │
│  │ • Authentication│  │ • Content Mgmt  │  │ • Personalized │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘
│                                          │                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  │ Real-time Chat  │  │ AI Moderation   │  │ Notification    │
│  │ Service         │  │ Service         │  │ Service         │
│  │                 │  │                 │  │                 │
│  │ • WebSocket     │  │ • Content Safety│  │ • Push Notifs   │
│  │ • Group Chat    │  │ • Auto Flagging │  │ • Email/SMS     │
│  │ • Voice/Video   │  │ • Spam Detection│  │ • In-App Alerts │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘
│                                          │                  │
│                             ┌────────────┴────────────┐     │
│                             │     Data & Storage      │     │
│                             │                         │     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  │ PostgreSQL      │  │ Redis Cache     │  │ CDN & Storage   │
│  │                 │  │                 │  │                 │
│  │ • User Data     │  │ • Feed Cache    │  │ • Media Files   │
│  │ • Posts/Comments│  │ • Session Store │  │ • Image CDN     │
│  │ • Relationships │  │ • Rate Limiting │  │ • Video Stream  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 **Core Social Components**

### **1. Frontend Layer - React Native Web**

#### **Social UI Architecture**
```javascript
// Components structure for social platform
src/
├── components/
│   ├── common/
│   │   ├── Layout/
│   │   │   ├── MainLayout.jsx           // App shell with navigation
│   │   │   ├── SidebarNavigation.jsx    // Main navigation menu
│   │   │   └── MobileNavigation.jsx     // Mobile-optimized nav
│   │   ├── UI/
│   │   │   ├── Button.jsx               // Reusable button component
│   │   │   ├── Modal.jsx                // Modal dialogs
│   │   │   ├── InfiniteScroll.jsx       // Infinite scrolling for feeds
│   │   │   └── MediaViewer.jsx          // Image/video viewer
│   ├── social/
│   │   ├── Feed/
│   │   │   ├── SocialFeed.jsx           // Main social feed
│   │   │   ├── PostCard.jsx             // Individual post display
│   │   │   ├── StoryViewer.jsx          // Stories display
│   │   │   └── TrendingTopics.jsx       // Trending content
│   │   ├── Profile/
│   │   │   ├── UserProfile.jsx          // User profile page
│   │   │   ├── ProfileEdit.jsx          // Profile editing
│   │   │   ├── FollowersList.jsx        // Followers/following
│   │   │   └── UserStats.jsx            // Profile statistics
│   │   ├── Content/
│   │   │   ├── PostCreator.jsx          // Create new posts
│   │   │   ├── StoryCreator.jsx         // Create stories
│   │   │   ├── MediaUploader.jsx        // Media upload component
│   │   │   └── ContentEditor.jsx        // Rich text editor
│   │   ├── Messaging/
│   │   │   ├── ChatList.jsx             // Chat conversations list
│   │   │   ├── ChatWindow.jsx           // Individual chat window
│   │   │   ├── GroupChat.jsx            // Group chat interface
│   │   │   └── VoiceCall.jsx            // Voice/video calling
│   │   └── LiveStream/
│   │       ├── StreamViewer.jsx         // Live stream viewer
│   │       ├── StreamCreator.jsx        // Stream creation
│   │       ├── StreamChat.jsx           // Live chat overlay
│   │       └── StreamStats.jsx          // Stream analytics
├── hooks/
│   ├── useSocialFeed.js                 // Social feed management
│   ├── useRealTimeChat.js               // Chat functionality
│   ├── useContentUpload.js              // Media upload handling
│   └── useLiveStream.js                 // Live streaming features
├── services/
│   ├── api/
│   │   ├── socialAPI.js                 // Social platform API calls
│   │   ├── chatAPI.js                   // Real-time chat API
│   │   ├── mediaAPI.js                  // Media upload API
│   │   └── streamAPI.js                 // Live streaming API
│   ├── websocket/
│   │   ├── ChatWebSocket.js             // Chat WebSocket connection
│   │   ├── FeedWebSocket.js             // Real-time feed updates
│   │   └── StreamWebSocket.js           // Live stream connection
│   └── utils/
│       ├── mediaProcessing.js           // Client-side media processing
│       ├── contentFiltering.js          // Content validation
│       └── socialUtils.js               // Social platform utilities
└── store/
    ├── slices/
    │   ├── userSlice.js                 // User state management
    │   ├── feedSlice.js                 // Social feed state
    │   ├── chatSlice.js                 // Chat state
    │   └── streamSlice.js               // Live streaming state
    └── middleware/
        ├── socialMiddleware.js          // Social actions middleware
        └── realtimeMiddleware.js        // Real-time updates
```

#### **Advanced Social Features Implementation**
```javascript
// hooks/useSocialFeed.js
import { useState, useEffect, useCallback } from 'react';
import { useWebSocket } from './useWebSocket';
import { socialAPI } from '../services/api/socialAPI';

export const useSocialFeed = (userId) => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [page, setPage] = useState(1);
  
  const { socket, isConnected } = useWebSocket('/feed');
  
  // Load initial feed
  const loadInitialFeed = useCallback(async () => {
    setLoading(true);
    try {
      const response = await socialAPI.getFeed({
        userId,
        page: 1,
        limit: 20,
        algorithm: 'personalized'
      });
      
      setPosts(response.posts);
      setHasMore(response.hasMore);
      setPage(2);
    } catch (error) {
      console.error('Failed to load feed:', error);
    } finally {
      setLoading(false);
    }
  }, [userId]);
  
  // Load more posts (infinite scroll)
  const loadMorePosts = useCallback(async () => {
    if (loading || !hasMore) return;
    
    setLoading(true);
    try {
      const response = await socialAPI.getFeed({
        userId,
        page,
        limit: 20,
        algorithm: 'personalized'
      });
      
      setPosts(prev => [...prev, ...response.posts]);
      setHasMore(response.hasMore);
      setPage(prev => prev + 1);
    } catch (error) {
      console.error('Failed to load more posts:', error);
    } finally {
      setLoading(false);
    }
  }, [userId, page, loading, hasMore]);
  
  // Real-time feed updates
  useEffect(() => {
    if (!socket || !isConnected) return;
    
    socket.on('new_post', (newPost) => {
      setPosts(prev => [newPost, ...prev]);
    });
    
    socket.on('post_updated', (updatedPost) => {
      setPosts(prev => prev.map(post => 
        post.id === updatedPost.id ? updatedPost : post
      ));
    });
    
    socket.on('post_deleted', (deletedPostId) => {
      setPosts(prev => prev.filter(post => post.id !== deletedPostId));
    });
    
    return () => {
      socket.off('new_post');
      socket.off('post_updated');
      socket.off('post_deleted');
    };
  }, [socket, isConnected]);
  
  // Engagement actions
  const likePost = useCallback(async (postId) => {
    try {
      await socialAPI.likePost(postId);
      setPosts(prev => prev.map(post => 
        post.id === postId 
          ? { ...post, liked: true, likesCount: post.likesCount + 1 }
          : post
      ));
    } catch (error) {
      console.error('Failed to like post:', error);
    }
  }, []);
  
  const sharePost = useCallback(async (postId, shareData) => {
    try {
      const newPost = await socialAPI.sharePost(postId, shareData);
      setPosts(prev => [newPost, ...prev]);
    } catch (error) {
      console.error('Failed to share post:', error);
    }
  }, []);
  
  return {
    posts,
    loading,
    hasMore,
    loadInitialFeed,
    loadMorePosts,
    likePost,
    sharePost
  };
};
```

### **2. Backend Layer - Ruby on Rails Microservices**

#### **User Management Service**
```ruby
# app/services/user_management_service.rb
class UserManagementService
  include Interactor
  
  def call
    case context.action
    when :create_user
      create_user
    when :update_profile
      update_profile
    when :follow_user
      follow_user
    when :unfollow_user
      unfollow_user
    when :get_social_graph
      get_social_graph
    end
  end
  
  private
  
  def create_user
    user = User.new(context.user_params)
    
    if user.save
      # Create default profile
      create_default_profile(user)
      
      # Initialize social graph
      SocialGraph.create!(user: user)
      
      # Send welcome notification
      NotificationService.call(
        action: :send_welcome,
        user: user
      )
      
      context.user = user
    else
      context.fail!(errors: user.errors)
    end
  end
  
  def follow_user
    follower = User.find(context.follower_id)
    followee = User.find(context.followee_id)
    
    relationship = Relationship.create!(
      follower: follower,
      followee: followee,
      relationship_type: 'follow'
    )
    
    # Update social graph
    SocialGraphService.call(
      action: :add_relationship,
      relationship: relationship
    )
    
    # Send notification
    NotificationService.call(
      action: :new_follower,
      user: followee,
      actor: follower
    )
    
    # Update feed algorithms
    FeedAlgorithmService.perform_async(followee.id, follower.id)
    
    context.relationship = relationship
  end
  
  def get_social_graph
    user = User.find(context.user_id)
    
    # Get direct connections
    followers = user.followers.includes(:profile)
    following = user.following.includes(:profile)
    
    # Get mutual connections
    mutual_connections = calculate_mutual_connections(user)
    
    # Get suggested connections
    suggested_users = SuggestionEngine.call(
      user: user,
      limit: context.suggestions_limit || 10
    )
    
    context.social_graph = {
      followers: followers,
      following: following,
      mutual_connections: mutual_connections,
      suggested_users: suggested_users.result,
      stats: {
        followers_count: followers.count,
        following_count: following.count,
        posts_count: user.posts.published.count
      }
    }
  end
end

# app/models/user.rb
class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_one :social_graph, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  # Follower relationships
  has_many :follower_relationships, class_name: 'Relationship', 
           foreign_key: 'followee_id', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower
  
  # Following relationships
  has_many :following_relationships, class_name: 'Relationship', 
           foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :following_relationships, source: :followee
  
  # Authentication
  devise :database_authenticatable, :registerable, :recoverable, 
         :rememberable, :validatable, :confirmable, :lockable
  
  # Validations
  validates :username, presence: true, uniqueness: true, 
            format: { with: /\A[a-zA-Z0-9_]+\z/ }
  validates :email, presence: true, uniqueness: true
  
  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :active, -> { where(active: true) }
  scope :public_profiles, -> { joins(:profile).where(profiles: { privacy: 'public' }) }
  
  def full_name
    "#{first_name} #{last_name}".strip
  end
  
  def following?(user)
    following.include?(user)
  end
  
  def mutual_connections_with(user)
    following.where(id: user.following.pluck(:id))
  end
end
```

#### **Content Creation Service**
```ruby
# app/services/content_creation_service.rb
class ContentCreationService
  include Interactor
  
  def call
    case context.action
    when :create_post
      create_post
    when :create_story
      create_story
    when :upload_media
      upload_media
    when :process_content
      process_content
    end
  end
  
  private
  
  def create_post
    post = Post.new(context.post_params)
    post.user = User.find(context.user_id)
    
    ActiveRecord::Base.transaction do
      if post.save
        # Process media attachments
        process_media_attachments(post) if context.media_files.present?
        
        # Content moderation
        moderation_result = ContentModerationService.call(
          content: post,
          check_text: true,
          check_media: true
        )
        
        if moderation_result.flagged?
          post.update!(status: :under_review)
          ModerationQueue.add(post)
        else
          post.update!(status: :published)
          publish_post(post)
        end
        
        context.post = post
      else
        context.fail!(errors: post.errors)
      end
    end
  end
  
  def process_media_attachments(post)
    context.media_files.each do |media_file|
      media = MediaAttachment.create!(
        post: post,
        file: media_file,
        media_type: detect_media_type(media_file)
      )
      
      # Queue for processing
      MediaProcessingJob.perform_async(media.id)
    end
  end
  
  def publish_post(post)
    # Add to followers' feeds
    FeedDistributionService.perform_async(post.id)
    
    # Send notifications
    NotificationService.call(
      action: :new_post,
      post: post
    )
    
    # Update trending topics
    TrendingTopicsService.perform_async(post.id)
    
    # Broadcast real-time update
    ActionCable.server.broadcast(
      "user_feed_#{post.user_id}",
      {
        type: 'new_post',
        post: PostSerializer.new(post).as_json
      }
    )
  end
end

# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :shares, dependent: :destroy
  has_many :media_attachments, dependent: :destroy
  has_many :hashtags, through: :post_hashtags
  has_many :post_hashtags, dependent: :destroy
  
  enum status: { draft: 0, published: 1, under_review: 2, flagged: 3, deleted: 4 }
  enum visibility: { public: 0, followers: 1, friends: 2, private: 3 }
  enum post_type: { text: 0, image: 1, video: 2, link: 3, poll: 4 }
  
  validates :content, presence: true, length: { maximum: 5000 }
  validates :user_id, presence: true
  
  scope :published, -> { where(status: :published) }
  scope :recent, -> { order(created_at: :desc) }
  scope :trending, -> { joins(:likes).group(:id).order('COUNT(likes.id) DESC') }
  
  before_save :extract_hashtags
  after_create :increment_user_posts_count
  
  def liked_by?(user)
    likes.exists?(user: user)
  end
  
  def engagement_rate
    total_engagements = likes.count + comments.count + shares.count
    return 0 if user.followers.count == 0
    
    (total_engagements.to_f / user.followers.count * 100).round(2)
  end
  
  private
  
  def extract_hashtags
    hashtag_names = content.scan(/#(\w+)/).flatten
    self.hashtags = hashtag_names.map do |name|
      Hashtag.find_or_create_by(name: name.downcase)
    end
  end
end
```

#### **Real-time Chat Service**
```ruby
# app/services/chat_service.rb
class ChatService
  include Interactor
  
  def call
    case context.action
    when :create_conversation
      create_conversation
    when :send_message
      send_message
    when :join_conversation
      join_conversation
    when :leave_conversation
      leave_conversation
    end
  end
  
  private
  
  def create_conversation
    conversation = Conversation.new(context.conversation_params)
    
    if conversation.save
      # Add participants
      context.participant_ids.each do |user_id|
        ConversationParticipant.create!(
          conversation: conversation,
          user_id: user_id,
          role: user_id == context.creator_id ? 'admin' : 'member'
        )
      end
      
      # Send invitations
      send_conversation_invitations(conversation)
      
      context.conversation = conversation
    else
      context.fail!(errors: conversation.errors)
    end
  end
  
  def send_message
    message = Message.new(context.message_params)
    message.user = User.find(context.user_id)
    message.conversation = Conversation.find(context.conversation_id)
    
    if message.save
      # Broadcast to conversation participants
      broadcast_message(message)
      
      # Send push notifications
      send_message_notifications(message)
      
      # Update conversation timestamp
      message.conversation.touch(:last_message_at)
      
      context.message = message
    else
      context.fail!(errors: message.errors)
    end
  end
  
  def broadcast_message(message)
    ActionCable.server.broadcast(
      "conversation_#{message.conversation_id}",
      {
        type: 'new_message',
        message: MessageSerializer.new(message).as_json
      }
    )
  end
  
  def send_message_notifications(message)
    participants = message.conversation.participants
                          .where.not(id: message.user_id)
                          .includes(:user)
    
    participants.each do |participant|
      NotificationService.call(
        action: :new_message,
        recipient: participant.user,
        sender: message.user,
        message: message
      )
    end
  end
end

# app/channels/conversation_channel.rb
class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])
    
    # Verify user has access to conversation
    if conversation.participants.exists?(user: current_user)
      stream_from "conversation_#{conversation.id}"
      
      # Mark user as online in conversation
      ConversationParticipant.where(
        conversation: conversation,
        user: current_user
      ).update_all(last_seen_at: Time.current, online: true)
      
      # Broadcast user online status
      broadcast_user_status(conversation, current_user, 'online')
    else
      reject
    end
  end
  
  def unsubscribed
    conversation = Conversation.find(params[:conversation_id])
    
    # Mark user as offline
    ConversationParticipant.where(
      conversation: conversation,
      user: current_user
    ).update_all(online: false)
    
    # Broadcast user offline status
    broadcast_user_status(conversation, current_user, 'offline')
  end
  
  def typing(data)
    conversation_id = params[:conversation_id]
    
    ActionCable.server.broadcast(
      "conversation_#{conversation_id}",
      {
        type: 'user_typing',
        user_id: current_user.id,
        username: current_user.username,
        typing: data['typing']
      }
    )
  end
  
  private
  
  def broadcast_user_status(conversation, user, status)
    ActionCable.server.broadcast(
      "conversation_#{conversation.id}",
      {
        type: 'user_status',
        user_id: user.id,
        username: user.username,
        status: status
      }
    )
  end
end
```

---

## 🤖 **AI & Machine Learning Features**

### **1. Content Moderation AI**

#### **Intelligent Content Filtering**
```ruby
# app/services/ai_content_moderation_service.rb
class AIContentModerationService
  include Interactor
  
  def call
    case context.content_type
    when :text
      moderate_text_content
    when :image
      moderate_image_content
    when :video
      moderate_video_content
    end
  end
  
  private
  
  def moderate_text_content
    content = context.content
    
    # Multiple AI checks
    toxicity_score = check_toxicity(content)
    spam_score = check_spam(content)
    sentiment_score = analyze_sentiment(content)
    
    # Custom policy checks
    policy_violations = check_community_policies(content)
    
    # Combine scores for final decision
    moderation_result = ModerationResult.new(
      content: content,
      toxicity_score: toxicity_score,
      spam_score: spam_score,
      sentiment_score: sentiment_score,
      policy_violations: policy_violations
    )
    
    # Auto-moderate based on thresholds
    if should_auto_remove?(moderation_result)
      moderation_result.action = :remove
      moderation_result.reason = :auto_moderation
    elsif should_flag_for_review?(moderation_result)
      moderation_result.action = :flag_for_review
      moderation_result.reason = :requires_human_review
    else
      moderation_result.action = :approve
    end
    
    context.moderation_result = moderation_result
  end
  
  def check_toxicity(content)
    # Integration with Perspective API or custom model
    PerspectiveAPI.analyze(content, attributes: ['TOXICITY', 'SEVERE_TOXICITY'])
  end
  
  def check_spam(content)
    # Custom spam detection model
    SpamDetectionModel.predict(
      content: content,
      user_history: context.user&.recent_posts&.limit(10),
      posting_frequency: calculate_posting_frequency(context.user)
    )
  end
  
  def moderate_image_content
    image_url = context.image_url
    
    # Visual content analysis
    nsfw_score = ImageModerationAPI.check_nsfw(image_url)
    violence_score = ImageModerationAPI.check_violence(image_url)
    hate_symbols = ImageModerationAPI.detect_hate_symbols(image_url)
    
    # Face detection and recognition
    faces_detected = FaceDetectionAPI.detect_faces(image_url)
    
    moderation_result = ImageModerationResult.new(
      image_url: image_url,
      nsfw_score: nsfw_score,
      violence_score: violence_score,
      hate_symbols: hate_symbols,
      faces_detected: faces_detected
    )
    
    # Auto-moderation decision
    if nsfw_score > 0.8 || violence_score > 0.7 || hate_symbols.any?
      moderation_result.action = :remove
    elsif nsfw_score > 0.5 || violence_score > 0.4
      moderation_result.action = :blur_and_warn
    else
      moderation_result.action = :approve
    end
    
    context.moderation_result = moderation_result
  end
end

# app/models/moderation_result.rb
class ModerationResult
  include ActiveModel::Model
  
  attr_accessor :content, :content_type, :toxicity_score, :spam_score,
                :sentiment_score, :policy_violations, :action, :reason,
                :confidence_score
  
  def flagged?
    action == :remove || action == :flag_for_review
  end
  
  def auto_approved?
    action == :approve && reason != :human_reviewed
  end
  
  def requires_human_review?
    action == :flag_for_review
  end
end
```

### **2. Recommendation Engine**

#### **Personalized Content Recommendations**
```ruby
# app/services/recommendation_engine_service.rb
class RecommendationEngineService
  include Interactor
  
  def call
    user = User.find(context.user_id)
    
    case context.recommendation_type
    when :feed_posts
      recommend_feed_posts(user)
    when :users_to_follow
      recommend_users_to_follow(user)
    when :trending_content
      recommend_trending_content(user)
    when :personalized_hashtags
      recommend_hashtags(user)
    end
  end
  
  private
  
  def recommend_feed_posts(user)
    # Collaborative filtering
    similar_users = find_similar_users(user)
    collaborative_posts = get_posts_from_similar_users(similar_users)
    
    # Content-based filtering
    user_interests = extract_user_interests(user)
    content_based_posts = find_posts_by_interests(user_interests)
    
    # Social graph influence
    friend_posts = get_posts_from_connections(user)
    
    # Trending content
    trending_posts = get_trending_posts(user.location)
    
    # Combine and score recommendations
    recommendations = combine_recommendations([
      { posts: collaborative_posts, weight: 0.3 },
      { posts: content_based_posts, weight: 0.3 },
      { posts: friend_posts, weight: 0.25 },
      { posts: trending_posts, weight: 0.15 }
    ])
    
    # Apply diversity and freshness filters
    diverse_recommendations = apply_diversity_filter(recommendations)
    fresh_recommendations = apply_freshness_filter(diverse_recommendations)
    
    context.recommendations = fresh_recommendations.limit(context.limit || 20)
  end
  
  def find_similar_users(user)
    # Use matrix factorization or collaborative filtering
    user_interactions = UserInteraction.where(user: user)
                                      .includes(:target_user, :post)
    
    # Calculate user similarity based on:
    # - Common follows
    # - Similar engagement patterns
    # - Shared interests (hashtags, topics)
    # - Geographic proximity
    # - Demographic similarity
    
    SimilarityCalculator.call(
      user: user,
      interaction_data: user_interactions,
      factors: [:engagement, :social_graph, :interests, :demographics]
    )
  end
  
  def extract_user_interests(user)
    # Analyze user behavior to extract interests
    interests = {}
    
    # From posts and engagement
    liked_posts = user.likes.joins(:post).includes(:post)
    shared_posts = user.shares.joins(:post).includes(:post)
    commented_posts = user.comments.joins(:post).includes(:post)
    
    all_engaged_posts = (liked_posts + shared_posts + commented_posts).map(&:post)
    
    # Extract hashtags and topics
    hashtags = all_engaged_posts.flat_map(&:hashtags).group_by(&:name)
    interests[:hashtags] = hashtags.transform_values(&:count)
    
    # Extract post types preferences
    post_types = all_engaged_posts.group_by(&:post_type)
    interests[:post_types] = post_types.transform_values(&:count)
    
    # Time-based patterns
    interests[:active_hours] = analyze_activity_patterns(user)
    
    # Location-based interests
    interests[:locations] = analyze_location_interests(user)
    
    interests
  end
  
  def recommend_users_to_follow(user)
    recommendations = []
    
    # Friends of friends
    fof_recommendations = get_friends_of_friends(user)
    recommendations.concat(fof_recommendations)
    
    # Users with similar interests
    interest_based = get_users_with_similar_interests(user)
    recommendations.concat(interest_based)
    
    # Popular users in user's network
    popular_in_network = get_popular_users_in_network(user)
    recommendations.concat(popular_in_network)
    
    # Location-based recommendations
    location_based = get_users_by_location(user)
    recommendations.concat(location_based)
    
    # Remove duplicates and already followed users
    recommendations = recommendations.uniq
                                  .reject { |u| user.following?(u) }
                                  .reject { |u| u.id == user.id }
    
    # Score and rank recommendations
    scored_recommendations = score_user_recommendations(user, recommendations)
    
    context.recommendations = scored_recommendations.limit(context.limit || 10)
  end
end

# Background job for updating recommendations
class UpdateRecommendationsJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    
    # Update feed recommendations
    feed_recommendations = RecommendationEngineService.call(
      user_id: user_id,
      recommendation_type: :feed_posts,
      limit: 100
    )
    
    # Cache recommendations in Redis
    Rails.cache.write(
      "user_feed_recommendations:#{user_id}",
      feed_recommendations.result,
      expires_in: 1.hour
    )
    
    # Update user recommendations
    user_recommendations = RecommendationEngineService.call(
      user_id: user_id,
      recommendation_type: :users_to_follow,
      limit: 50
    )
    
    Rails.cache.write(
      "user_recommendations:#{user_id}",
      user_recommendations.result,
      expires_in: 6.hours
    )
  end
end
```

---

## 📊 **Analytics & Insights**

### **1. Social Analytics Engine**

#### **Comprehensive User Analytics**
```ruby
# app/services/social_analytics_service.rb
class SocialAnalyticsService
  include Interactor
  
  def call
    user = User.find(context.user_id)
    time_period = context.time_period || 30.days
    
    case context.analytics_type
    when :user_growth
      analyze_user_growth(user, time_period)
    when :content_performance
      analyze_content_performance(user, time_period)
    when :engagement_metrics
      analyze_engagement_metrics(user, time_period)
    when :audience_insights
      analyze_audience_insights(user, time_period)
    end
  end
  
  private
  
  def analyze_content_performance(user, time_period)
    posts = user.posts.published
                .where(created_at: time_period.ago..Time.current)
                .includes(:likes, :comments, :shares)
    
    analytics = {
      total_posts: posts.count,
      total_likes: posts.sum { |p| p.likes.count },
      total_comments: posts.sum { |p| p.comments.count },
      total_shares: posts.sum { |p| p.shares.count },
      average_engagement_rate: calculate_average_engagement_rate(posts),
      top_performing_posts: get_top_performing_posts(posts, 10),
      best_posting_times: analyze_best_posting_times(posts),
      content_type_performance: analyze_content_type_performance(posts),
      hashtag_performance: analyze_hashtag_performance(posts)
    }
    
    # Trend analysis
    analytics[:engagement_trend] = calculate_engagement_trend(user, time_period)
    analytics[:growth_rate] = calculate_growth_rate(user, time_period)
    
    context.analytics = analytics
  end
  
  def analyze_audience_insights(user, time_period)
    followers = user.followers.includes(:profile)
    
    insights = {
      total_followers: followers.count,
      follower_growth: calculate_follower_growth(user, time_period),
      demographics: {
        age_distribution: analyze_age_distribution(followers),
        gender_distribution: analyze_gender_distribution(followers),
        location_distribution: analyze_location_distribution(followers),
        interests_distribution: analyze_interests_distribution(followers)
      },
      engagement_patterns: {
        most_active_followers: get_most_active_followers(user, 20),
        engagement_by_time: analyze_engagement_by_time(user, time_period),
        engagement_by_content_type: analyze_engagement_by_content_type(user, time_period)
      },
      reach_metrics: {
        impressions: calculate_impressions(user, time_period),
        reach: calculate_reach(user, time_period),
        viral_coefficient: calculate_viral_coefficient(user, time_period)
      }
    }
    
    context.insights = insights
  end
  
  def calculate_engagement_trend(user, time_period)
    # Calculate daily engagement rates
    daily_engagement = []
    
    time_period.to_i.times do |i|
      date = i.days.ago.to_date
      posts_on_date = user.posts.published.where(created_at: date.beginning_of_day..date.end_of_day)
      
      if posts_on_date.any?
        total_engagements = posts_on_date.sum do |post|
          post.likes.count + post.comments.count + post.shares.count
        end
        
        engagement_rate = (total_engagements.to_f / user.followers.count * 100).round(2)
        
        daily_engagement << {
          date: date,
          engagement_rate: engagement_rate,
          posts_count: posts_on_date.count
        }
      end
    end
    
    daily_engagement.reverse
  end
end

# app/models/analytics_dashboard.rb
class AnalyticsDashboard
  include ActiveModel::Model
  
  attr_accessor :user, :time_period, :analytics_data
  
  def initialize(user, time_period = 30.days)
    @user = user
    @time_period = time_period
    @analytics_data = generate_analytics_data
  end
  
  def generate_analytics_data
    {
      overview: generate_overview_metrics,
      content_performance: generate_content_metrics,
      audience_insights: generate_audience_metrics,
      engagement_trends: generate_engagement_trends,
      recommendations: generate_recommendations
    }
  end
  
  def generate_overview_metrics
    {
      total_posts: user.posts.published.count,
      total_followers: user.followers.count,
      total_following: user.following.count,
      average_engagement_rate: calculate_average_engagement_rate,
      growth_metrics: {
        follower_growth: calculate_follower_growth_percentage,
        engagement_growth: calculate_engagement_growth_percentage,
        content_growth: calculate_content_growth_percentage
      }
    }
  end
  
  def top_performing_content(limit = 10)
    user.posts.published
        .joins(:likes, :comments, :shares)
        .group('posts.id')
        .order('(COUNT(DISTINCT likes.id) + COUNT(DISTINCT comments.id) + COUNT(DISTINCT shares.id)) DESC')
        .limit(limit)
        .includes(:user, :media_attachments)
  end
  
  def engagement_by_time_of_day
    # Analyze when user's content gets most engagement
    engagements_by_hour = Array.new(24, 0)
    
    user.posts.published.each do |post|
      hour = post.created_at.hour
      engagement_count = post.likes.count + post.comments.count + post.shares.count
      engagements_by_hour[hour] += engagement_count
    end
    
    engagements_by_hour.map.with_index do |engagement_count, hour|
      {
        hour: hour,
        engagement_count: engagement_count,
        formatted_time: Time.parse("#{hour}:00").strftime("%I %p")
      }
    end
  end
end
```

---

## 🚀 **Scalability & Performance**

### **1. Database Optimization**

#### **High-Performance Social Graph**
```sql
-- Optimized database schema for social media
-- Users table with indexing for social features
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    bio TEXT,
    avatar_url VARCHAR(500),
    verified BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Relationships table for follow/friend connections
CREATE TABLE relationships (
    id BIGSERIAL PRIMARY KEY,
    follower_id BIGINT NOT NULL REFERENCES users(id),
    followee_id BIGINT NOT NULL REFERENCES users(id),
    relationship_type VARCHAR(50) DEFAULT 'follow',
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(follower_id, followee_id)
);

-- Posts table optimized for social feeds
CREATE TABLE posts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    post_type VARCHAR(50) DEFAULT 'text',
    visibility VARCHAR(50) DEFAULT 'public',
    status VARCHAR(50) DEFAULT 'published',
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Feed table for pre-computed feeds (fanout on write)
CREATE TABLE feed_entries (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    post_id BIGINT NOT NULL REFERENCES posts(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- Critical indexes for social media performance
CREATE INDEX idx_relationships_follower ON relationships(follower_id);
CREATE INDEX idx_relationships_followee ON relationships(followee_id);
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);
CREATE INDEX idx_posts_status_created ON posts(status, created_at DESC) WHERE status = 'published';
CREATE INDEX idx_feed_entries_user_created ON feed_entries(user_id, created_at DESC);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- Partitioning for large-scale data
CREATE TABLE posts_y2024m01 PARTITION OF posts
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE posts_y2024m02 PARTITION OF posts
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- Continue partitioning by month...
```

### **2. Caching Strategy**

#### **Multi-Layer Caching Architecture**
```ruby
# config/application.rb - Caching configuration
class Application < Rails::Application
  # Configure Redis for different cache purposes
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    pool_size: 5,
    pool_timeout: 5,
    namespace: 'social_media'
  }
  
  # Configure separate Redis instances for different purposes
  config.x.redis_instances = {
    cache: Redis.new(url: ENV['REDIS_CACHE_URL']),
    sessions: Redis.new(url: ENV['REDIS_SESSIONS_URL']),
    sidekiq: Redis.new(url: ENV['REDIS_SIDEKIQ_URL']),
    action_cable: Redis.new(url: ENV['REDIS_ACTION_CABLE_URL'])
  }
end

# app/services/cache_service.rb
class CacheService
  CACHE_KEYS = {
    user_feed: 'user_feed:%{user_id}',
    user_profile: 'user_profile:%{user_id}',
    trending_posts: 'trending_posts:%{time_window}',
    post_engagement: 'post_engagement:%{post_id}',
    user_recommendations: 'user_recommendations:%{user_id}',
    hashtag_trends: 'hashtag_trends:%{date}'
  }.freeze
  
  CACHE_EXPIRY = {
    user_feed: 15.minutes,
    user_profile: 1.hour,
    trending_posts: 5.minutes,
    post_engagement: 10.minutes,
    user_recommendations: 1.hour,
    hashtag_trends: 30.minutes
  }.freeze
  
  class << self
    def get_user_feed(user_id, page: 1, limit: 20)
      cache_key = CACHE_KEYS[:user_feed] % { user_id: user_id }
      cache_key += ":page_#{page}"
      
      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY[:user_feed]) do
        # Generate feed from database
        FeedGeneratorService.call(
          user_id: user_id,
          page: page,
          limit: limit
        ).result
      end
    end
    
    def invalidate_user_feed(user_id)
      # Clear all cached pages for user feed
      pattern = CACHE_KEYS[:user_feed] % { user_id: user_id }
      Rails.cache.delete_matched("#{pattern}:*")
    end
    
    def get_trending_posts(time_window = '1h')
      cache_key = CACHE_KEYS[:trending_posts] % { time_window: time_window }
      
      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY[:trending_posts]) do
        TrendingPostsService.call(time_window: time_window).result
      end
    end
    
    def warm_cache_for_user(user_id)
      # Pre-warm frequently accessed data
      get_user_feed(user_id)
      get_user_profile(user_id)
      get_user_recommendations(user_id)
    end
  end
end

# Background job for cache warming
class CacheWarmingJob < ApplicationJob
  def perform(user_id)
    CacheService.warm_cache_for_user(user_id)
  end
end
```

### **3. Real-time Features Scaling**

#### **WebSocket Connection Management**
```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    
    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', current_user.username
      
      # Track connection for scaling
      ConnectionTracker.add_connection(current_user.id, connection.object_id)
    end
    
    def disconnect
      ConnectionTracker.remove_connection(current_user.id, connection.object_id)
    end
    
    private
    
    def find_verified_user
      verified_user = User.find_by(id: cookies.encrypted[:user_id])
      if verified_user && valid_session?
        verified_user
      else
        reject_unauthorized_connection
      end
    end
    
    def valid_session?
      # Verify JWT token or session
      session_token = request.params[:token]
      JWTService.verify_token(session_token)
    end
  end
end

# app/services/connection_tracker.rb
class ConnectionTracker
  REDIS_KEY = 'active_connections'
  REDIS_USER_KEY = 'user_connections:%{user_id}'
  
  class << self
    def add_connection(user_id, connection_id)
      redis.sadd(REDIS_KEY, user_id)
      redis.sadd(REDIS_USER_KEY % { user_id: user_id }, connection_id)
      redis.expire(REDIS_USER_KEY % { user_id: user_id }, 1.hour)
      
      # Update user online status
      User.where(id: user_id).update_all(last_seen_at: Time.current, online: true)
    end
    
    def remove_connection(user_id, connection_id)
      redis.srem(REDIS_USER_KEY % { user_id: user_id }, connection_id)
      
      # Check if user has any remaining connections
      remaining_connections = redis.scard(REDIS_USER_KEY % { user_id: user_id })
      
      if remaining_connections == 0
        redis.srem(REDIS_KEY, user_id)
        User.where(id: user_id).update_all(online: false)
      end
    end
    
    def user_online?(user_id)
      redis.sismember(REDIS_KEY, user_id)
    end
    
    def online_users_count
      redis.scard(REDIS_KEY)
    end
    
    private
    
    def redis
      @redis ||= Redis.new(url: ENV['REDIS_ACTION_CABLE_URL'])
    end
  end
end
```

---

## 📚 **Next Steps**

### **Ready to Deploy?**
- **[Production Deployment Guide](./production-deployment.md)** - Deploy to production
- **[Setup Requirements](./setup-requirements.md)** - Development environment
- **[Troubleshooting](./troubleshooting.md)** - Common issues and solutions

### **Want to Extend?**
- **[Social Commerce Integration](./social-commerce.md)** - Add shopping features
- **[Advanced Analytics](./advanced-analytics.md)** - Deep social insights

---

**🎯 This architecture scales to handle millions of users with real-time interactions, AI-powered features, and enterprise-grade social networking capabilities!**