# Social Media Platform Architecture

## Overview

The Social Media Platform is a full-stack web application designed for social networking and content sharing. It follows a modern web architecture with clear separation of concerns and scalable design.

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   Database      │
│   (React Native │◄──►│   (Rails API)   │◄──►│   (PostgreSQL)  │
│    Web)         │    │                 │    │                 │
│                 │    │ - REST API      │    │ - Users         │
│ - Posts Feed    │    │ - Authentication │    │ - Posts        │
│ - User Profiles │    │ - Business Logic │    │ - Comments     │
│ - Real-time     │    │ - File Uploads  │    │ - Likes         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Technology Stack

### Backend

- **Language**: Ruby 3.2
- **Framework**: Rails 7 (API mode)
- **Database**: PostgreSQL
- **Authentication**: JWT with Devise
- **File Storage**: Active Storage with AWS S3
- **Background Jobs**: Sidekiq with Redis

### Frontend

- **Framework**: React Native Web
- **State Management**: Redux Toolkit
- **Styling**: Styled Components
- **HTTP Client**: Axios
- **Real-time**: WebSockets with Action Cable

### Infrastructure

- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana
- **Caching**: Redis

## API Design

### RESTful Endpoints

#### Posts

- `GET /api/posts` - Retrieve timeline posts
- `POST /api/posts` - Create new post
- `GET /api/posts/{id}` - Get specific post
- `PUT /api/posts/{id}` - Update post
- `DELETE /api/posts/{id}` - Delete post
- `POST /api/posts/{id}/like` - Like/unlike post
- `GET /api/posts/{id}/comments` - Get post comments

#### Users

- `GET /api/users` - Retrieve all users
- `POST /api/users` - Register new user
- `GET /api/users/{id}` - Get user profile
- `PUT /api/users/{id}` - Update profile
- `POST /api/users/{id}/follow` - Follow/unfollow user

#### Authentication

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/refresh` - Refresh JWT token

### Data Models

#### Post

```json
{
  "id": 1,
  "content": "Hello world!",
  "image_url": "https://example.com/image.jpg",
  "user_id": 1,
  "likes_count": 15,
  "comments_count": 3,
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

#### User

```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "full_name": "John Doe",
  "bio": "Software developer",
  "avatar_url": "https://example.com/avatar.jpg",
  "followers_count": 150,
  "following_count": 75,
  "created_at": "2024-01-15T10:00:00Z"
}
```

## Database Schema

### Tables

#### users

- id (BIGSERIAL PRIMARY KEY)
- username (VARCHAR(50) UNIQUE NOT NULL)
- email (VARCHAR(255) UNIQUE NOT NULL)
- encrypted_password (VARCHAR(255) NOT NULL)
- full_name (VARCHAR(100))
- bio (TEXT)
- avatar_url (VARCHAR(500))
- created_at (TIMESTAMP NOT NULL)
- updated_at (TIMESTAMP NOT NULL)

#### posts

- id (BIGSERIAL PRIMARY KEY)
- content (TEXT NOT NULL)
- image_url (VARCHAR(500))
- user_id (BIGINT REFERENCES users(id))
- created_at (TIMESTAMP NOT NULL)
- updated_at (TIMESTAMP NOT NULL)

#### likes

- id (BIGSERIAL PRIMARY KEY)
- user_id (BIGINT REFERENCES users(id))
- post_id (BIGINT REFERENCES posts(id))
- created_at (TIMESTAMP NOT NULL)
- UNIQUE(user_id, post_id)

#### comments

- id (BIGSERIAL PRIMARY KEY)
- content (TEXT NOT NULL)
- user_id (BIGINT REFERENCES users(id))
- post_id (BIGINT REFERENCES posts(id))
- created_at (TIMESTAMP NOT NULL)
- updated_at (TIMESTAMP NOT NULL)

#### follows

- id (BIGSERIAL PRIMARY KEY)
- follower_id (BIGINT REFERENCES users(id))
- followed_id (BIGINT REFERENCES users(id))
- created_at (TIMESTAMP NOT NULL)
- UNIQUE(follower_id, followed_id)

## Security Considerations

- JWT-based authentication with refresh tokens
- Password hashing with bcrypt
- CORS configuration
- Input validation and sanitization
- SQL injection prevention with ActiveRecord
- XSS protection with content sanitization
- Rate limiting for API endpoints
- File upload validation and virus scanning

## Performance Optimizations

- Database indexing on frequently queried columns
- Redis caching for user sessions and frequently accessed data
- Image optimization and CDN delivery
- Database query optimization with eager loading
- Background job processing for heavy operations
- Pagination for large data sets

## Deployment Strategy

### Development

- Docker Compose for local development
- Hot reloading for both frontend and backend
- Local PostgreSQL and Redis databases

### Production

- Kubernetes deployment with Helm charts
- PostgreSQL with read replicas
- Redis cluster for caching and sessions
- AWS S3 for file storage
- Load balancing with Ingress
- Horizontal Pod Autoscaling

## Monitoring and Logging

- Structured logging with Lograge
- Health check endpoints
- Prometheus metrics collection
- Grafana dashboards for visualization
- Error tracking with Sentry
- Performance monitoring with New Relic

## Scalability Considerations

- Stateless API design
- Database read replicas and sharding
- CDN for static assets and user uploads
- Microservices-ready architecture
- Event-driven communication with RabbitMQ
- Auto-scaling based on CPU and memory usage
