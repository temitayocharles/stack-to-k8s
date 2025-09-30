# 📱 Social Media Platform - Massive Scale React Native Web

**Technology**: React Native Web + Ruby on Rails + PostgreSQL  
**Difficulty**: ⭐⭐⭐⭐⭐ Expert  
**Time**: 60 minutes

> **Perfect for**: Learning massive scale architecture and modern web technologies

## 🎯 What You'll Build
- ✅ **Social networking platform** with posts, likes, and comments
- ✅ **Real-time messaging** with chat and video calls
- ✅ **Content recommendation** with AI-powered algorithms
- ✅ **Media streaming** with image and video processing
- ✅ **Advanced analytics** with user behavior tracking

## 📋 Before You Start
**Required time**: 60 minutes  
**Prerequisites**: [System setup](../getting-started/system-setup.md) completed  
**Skills**: Advanced understanding of web development recommended

## 🚀 Quick Start

### 1. Navigate to Application
```bash
cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/social-media-platform
```

### 2. Start Everything
```bash
docker-compose up -d
```

### 3. Open in Browser
- **Frontend**: http://localhost:3005
- **API Documentation**: http://localhost:3000/api/docs
- **Admin Dashboard**: http://localhost:3005/admin

## 🔍 What's Inside

### Frontend Features (React Native Web)
- **News feed** with infinite scroll and real-time updates
- **Media upload** with image/video processing
- **Real-time chat** with typing indicators
- **Video calling** with WebRTC integration
- **Push notifications** for mobile-like experience

### Backend APIs (Ruby on Rails)
- **User Management API** - Authentication and profiles
- **Content API** - Posts, comments, likes, shares
- **Media Processing API** - Image/video upload and optimization
- **Recommendation API** - AI-powered content suggestions
- **Analytics API** - User behavior and engagement metrics

### Infrastructure (PostgreSQL + Redis)
- **PostgreSQL** - Primary data storage
- **Redis** - Caching and session management
- **Background jobs** - Async processing with Sidekiq
- **Full-text search** - Content discovery
- **Real-time features** - ActionCable WebSocket

## 🧪 Test It Out

### 1. Social Features
1. Go to http://localhost:3005
2. Create a user account
3. Post content with images
4. Like and comment on posts
5. Follow other users

### 2. Real-Time Features
1. Open chat with another user
2. Send messages in real-time
3. Test video calling features
4. Receive live notifications

### 3. Content Discovery
1. Use search to find content
2. Explore trending topics
3. View personalized recommendations
4. Analyze engagement metrics

## 🔧 Technical Details

### Frontend (React Native Web)
- **Universal components** working on web and mobile
- **React Navigation** for routing
- **React Query** for data fetching and caching
- **WebRTC** for video calling
- **PWA features** for mobile-like experience

### Backend (Ruby on Rails 7)
- **Rails API mode** with JSON responses
- **Active Storage** for file uploads
- **ActionCable** for WebSocket connections
- **Sidekiq** for background job processing
- **Devise** for authentication

### Performance & Scale
- **Database indexing** for fast queries
- **Image optimization** with ImageMagick
- **CDN integration** for media delivery
- **Caching strategies** at multiple layers
- **Load balancing** preparation

## 🚀 Kubernetes Deployment

Ready to deploy to Kubernetes?

### 1. Deploy to Kubernetes
```bash
kubectl apply -f k8s/
```

### 2. Access via Port Forward
```bash
kubectl port-forward service/social-frontend 3005:80
kubectl port-forward service/social-backend 3000:3000
```

### 3. View in Browser
Go to http://localhost:3005

## 📊 Monitoring

### Check Application Health
```bash
curl http://localhost:3000/health
```

### View Background Jobs
```bash
curl http://localhost:3000/sidekiq/stats
```

### Monitor Real-Time Connections
```bash
docker-compose logs -f social-backend | grep "ActionCable"
```

## 🔄 Stop Application

```bash
docker-compose down
```

## ➡️ What's Next?

✅ **Mastered all apps?** → [Production deployment guide](../deployment/production-ready.md)  
✅ **Ready for scale?** → [High-availability setup](../kubernetes/high-availability.md)  
✅ **Want CI/CD?** → [Advanced pipeline setup](../getting-started/enterprise-setup.md)

## 🆘 Need Help?

**Common issues**:
- **Ruby version conflicts**: Use Docker containers exclusively
- **WebSocket connection failures**: Check ActionCable configuration
- **Background job processing**: Verify Redis and Sidekiq setup

**More help**: [Troubleshooting guide](../troubleshooting/common-issues.md)

---

**Expert level!** The social media platform demonstrates scale patterns used by major social networks and streaming platforms.