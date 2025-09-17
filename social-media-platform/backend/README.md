# Social Media Platform - Backend API

## Overview
A comprehensive Ruby on Rails 7.1 API backend for a social media platform with enterprise-grade features, real-time capabilities, and production-ready architecture.

## Features Implemented

### 🔐 Authentication & Security
- JWT-based authentication with Devise integration
- Secure password handling with bcrypt
- Token refresh mechanism for seamless user experience
- Password reset functionality via email
- Rate limiting protection
- CORS configuration for cross-origin requests

### 👥 User Management
- Complete user profiles with avatars and cover photos
- Account privacy settings (public/private)
- Email verification and password reset
- User suggestions algorithm based on mutual connections
- Comprehensive profile management with bio, location, website
- Account verification system for verified users

### 📱 Social Features
- **Posts**: Create, read, update, delete with media attachments
- **Comments**: Threaded comments with replies and reactions
- **Likes**: Like/unlike posts and comments with real-time counters
- **Shares**: Share posts with optional additional content
- **Follows**: Follow/unfollow users with pending request system for private accounts
- **Notifications**: Real-time notifications for all social interactions
- **Hashtags**: Automatic hashtag extraction and trending analysis
- **Mentions**: User mentions in posts and comments with notifications

### 🔍 Search & Discovery
- **Global Search**: Search across users, posts, comments, and hashtags
- **Advanced Search**: Filter by date, user, hashtags, media presence
- **Trending**: Algorithm-based trending posts and hashtags
- **User Discovery**: Smart user suggestions based on interests and connections
- **Search History**: Personal search history with cleanup options
- **Auto-suggestions**: Real-time search suggestions for users and hashtags

### 📂 File Management
- **Media Uploads**: Support for images and videos with validation
- **Avatar/Cover Photos**: Dedicated endpoints for profile media
- **Storage Quotas**: Per-user storage limits with usage tracking
- **File Processing**: Automatic thumbnail generation and optimization
- **S3 Integration**: Production-ready cloud storage with presigned URLs
- **Batch Operations**: Bulk file management and cleanup

### 🔔 Real-time Features
- **ActionCable Integration**: WebSocket support for live updates
- **Live Notifications**: Instant notification delivery
- **Real-time Feeds**: Live post updates and interactions
- **Activity Streams**: Real-time user activity tracking

### 📊 Analytics & Monitoring
- **Health Checks**: Comprehensive system health monitoring
- **Metrics**: Application, database, and system metrics
- **Performance Monitoring**: Response time tracking and optimization
- **Error Handling**: Centralized error management with proper HTTP status codes
- **Logging**: Structured logging for debugging and monitoring

### 🚀 API Design
- **RESTful Architecture**: Clean, consistent API design
- **JSON API Format**: Standardized response structure
- **Pagination**: Cursor-based pagination for large datasets
- **Versioning**: API versioning strategy for backward compatibility
- **Documentation**: Self-documenting endpoints with clear parameter validation

## Technical Stack

### Core Framework
- **Ruby on Rails 7.1**: Latest Rails with modern features
- **PostgreSQL**: Primary database with advanced features
- **Redis**: Caching and session storage
- **Sidekiq**: Background job processing

### Authentication & Security
- **Devise**: User authentication framework
- **JWT**: JSON Web Tokens for stateless authentication
- **BCrypt**: Secure password hashing
- **Rack-CORS**: Cross-origin resource sharing

### File Storage & Processing
- **Active Storage**: Rails file attachment framework
- **AWS S3**: Cloud storage for production
- **ImageMagick**: Image processing and optimization

### Real-time & Communication
- **ActionCable**: WebSocket support for Rails
- **ActionMailer**: Email notifications and communications

### Development & Testing
- **RSpec**: Comprehensive testing framework
- **Factory Bot**: Test data generation
- **Rubocop**: Code style and quality enforcement
- **Brakeman**: Security vulnerability scanning

## API Endpoints

### Authentication
```
POST   /api/v1/auth/register          # User registration
POST   /api/v1/auth/login             # User login
DELETE /api/v1/auth/logout            # User logout
POST   /api/v1/auth/refresh           # Token refresh
POST   /api/v1/auth/forgot_password   # Password reset request
POST   /api/v1/auth/reset_password    # Password reset
GET    /api/v1/auth/me                # Current user info
```

### Users
```
GET    /api/v1/users                  # List users
GET    /api/v1/users/:username        # User profile
PUT    /api/v1/users/:username        # Update profile
DELETE /api/v1/users/:username        # Delete account
GET    /api/v1/users/search           # Search users
GET    /api/v1/users/suggestions      # User suggestions
```

### Posts
```
GET    /api/v1/posts                  # List posts
POST   /api/v1/posts                  # Create post
GET    /api/v1/posts/:id              # Get post
PUT    /api/v1/posts/:id              # Update post
DELETE /api/v1/posts/:id              # Delete post
POST   /api/v1/posts/:id/like         # Like post
DELETE /api/v1/posts/:id/unlike       # Unlike post
POST   /api/v1/posts/:id/share        # Share post
GET    /api/v1/posts/feed             # Personal feed
GET    /api/v1/posts/trending         # Trending posts
GET    /api/v1/posts/discover         # Discover posts
```

### Comments
```
GET    /api/v1/posts/:id/comments     # Post comments
POST   /api/v1/posts/:id/comments     # Create comment
PUT    /api/v1/comments/:id           # Update comment
DELETE /api/v1/comments/:id           # Delete comment
POST   /api/v1/comments/:id/like      # Like comment
POST   /api/v1/comments/:id/replies   # Reply to comment
```

### Follows
```
POST   /api/v1/users/:username/follow     # Follow user
DELETE /api/v1/users/:username/unfollow   # Unfollow user
GET    /api/v1/users/:username/followers  # User followers
GET    /api/v1/users/:username/following  # User following
GET    /api/v1/follows/suggestions        # Follow suggestions
GET    /api/v1/follows/pending_requests   # Pending requests
```

### Notifications
```
GET    /api/v1/notifications               # List notifications
PATCH  /api/v1/notifications/:id/mark_as_read  # Mark as read
PATCH  /api/v1/notifications/mark_all_as_read  # Mark all as read
GET    /api/v1/notifications/summary       # Notification summary
```

### Search
```
GET    /api/v1/search                 # Global search
GET    /api/v1/search/users           # Search users
GET    /api/v1/search/posts           # Search posts
GET    /api/v1/search/hashtags        # Search hashtags
GET    /api/v1/search/suggestions     # Search suggestions
GET    /api/v1/search/trending        # Trending topics
```

### Uploads
```
POST   /api/v1/uploads                # Upload files
POST   /api/v1/uploads/avatar         # Upload avatar
POST   /api/v1/uploads/cover          # Upload cover photo
DELETE /api/v1/uploads/:id            # Delete file
GET    /api/v1/uploads/storage_stats  # Storage usage
```

### Health & Monitoring
```
GET    /api/v1/health/status          # System health
GET    /api/v1/health/metrics         # System metrics
GET    /api/v1/health/readiness       # Readiness check
GET    /api/v1/health/liveness        # Liveness check
```

## Key Features

### Advanced Social Features
- **Engagement Algorithm**: Smart post ranking based on user interactions
- **Privacy Controls**: Granular privacy settings for posts and profiles
- **Content Moderation**: Built-in content filtering and reporting
- **Recommendation Engine**: AI-powered content and user recommendations

### Performance Optimizations
- **Database Indexing**: Optimized indexes for fast queries
- **Caching Strategy**: Multi-layer caching with Redis
- **Eager Loading**: Optimized database queries to prevent N+1 problems
- **Background Processing**: Async processing for heavy operations

### Security Features
- **Rate Limiting**: API rate limiting to prevent abuse
- **Input Validation**: Comprehensive input sanitization
- **CSRF Protection**: Cross-site request forgery protection
- **SQL Injection Prevention**: Parameterized queries and safe practices

### Scalability
- **Horizontal Scaling**: Stateless design for easy scaling
- **Database Optimization**: Query optimization and connection pooling
- **CDN Integration**: Static asset delivery optimization
- **Microservice Ready**: Clean separation of concerns for service extraction

## Database Schema

The application uses a well-designed PostgreSQL schema with proper relationships:

- **Users**: Core user information with profile data
- **Posts**: User posts with content and media
- **Comments**: Threaded comments with replies
- **Likes**: Polymorphic likes for posts and comments
- **Follows**: User follow relationships with status tracking
- **Notifications**: Real-time notification system
- **Search Histories**: User search behavior tracking

## Production Readiness

### Deployment Features
- **Docker Support**: Containerized application for easy deployment
- **Environment Configuration**: Proper environment variable management
- **Database Migrations**: Version-controlled schema changes
- **Asset Pipeline**: Optimized asset compilation and delivery

### Monitoring & Observability
- **Health Checks**: Kubernetes-ready health endpoints
- **Metrics Collection**: Application and system metrics
- **Error Tracking**: Comprehensive error logging and tracking
- **Performance Monitoring**: Response time and throughput tracking

### Security Best Practices
- **Secret Management**: Secure credential storage
- **SSL/TLS**: HTTPS enforcement and secure headers
- **Input Validation**: Comprehensive data validation
- **Authentication**: Secure token-based authentication

This backend provides a solid foundation for a modern social media platform with enterprise-grade features, scalability, and maintainability. The clean architecture and comprehensive API design make it easy to integrate with any frontend framework while ensuring high performance and security.
