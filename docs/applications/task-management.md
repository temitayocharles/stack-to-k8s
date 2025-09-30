# ✅ Task Management App - Advanced Go Microservices

**Technology**: Svelte + Go + PostgreSQL  
**Difficulty**: ⭐⭐⭐⭐ Advanced  
**Time**: 45 minutes

> **Perfect for**: Learning Go microservices architecture and modern frontend frameworks

## 🎯 What You'll Build
- ✅ **Project management system** with agile workflows
- ✅ **Real-time collaboration** with WebSocket connections
- ✅ **Advanced task tracking** with custom fields and automation
- ✅ **Team analytics** with performance metrics
- ✅ **Integration APIs** for third-party tools

## 📋 Before You Start
**Required time**: 45 minutes  
**Prerequisites**: [System setup](../getting-started/system-setup.md) completed  
**Skills**: Understanding of microservices concepts helpful

## 🚀 Quick Start

### 1. Navigate to Application
```bash
cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/task-management-app
```

### 2. Start Everything
```bash
docker-compose up -d
```

### 3. Open in Browser
- **Frontend**: http://localhost:3004
- **API Gateway**: http://localhost:8004/docs
- **Metrics Dashboard**: http://localhost:3004/metrics

## 🔍 What's Inside

### Frontend Features (Svelte)
- **Kanban boards** with drag-and-drop
- **Gantt charts** for project timeline visualization
- **Real-time notifications** via WebSocket
- **Advanced filtering** and search capabilities
- **Team collaboration** tools and comments

### Backend Microservices (Go)
- **API Gateway** - Request routing and authentication
- **Task Service** - Core task management logic
- **User Service** - Authentication and user management
- **Notification Service** - Real-time updates
- **Analytics Service** - Metrics and reporting

### Database Architecture (PostgreSQL)
- **Microservice per database** pattern
- **Event sourcing** for task state changes
- **CQRS** for read/write optimization
- **Database migrations** with Go-migrate
- **Connection pooling** for performance

## 🧪 Test It Out

### 1. Project Management
1. Go to http://localhost:3004
2. Create a new project
3. Add tasks to different columns
4. Drag tasks between stages
5. Assign team members

### 2. Real-Time Features
1. Open the app in two browser tabs
2. Make changes in one tab
3. Watch real-time updates in the other
4. Test chat and notifications

### 3. Analytics Dashboard
1. Navigate to metrics section
2. View team productivity charts
3. Analyze task completion rates
4. Export reports

## 🔧 Technical Details

### Frontend (Svelte/SvelteKit)
- **Component-based architecture** with reactive updates
- **Stores** for state management
- **SvelteKit routing** with page transitions
- **WebSocket client** for real-time features
- **Chart.js integration** for analytics

### Backend (Go Microservices)
- **Gin framework** for HTTP routing
- **GORM** for database operations
- **Gorilla WebSocket** for real-time communication
- **Go-jwt** for authentication
- **Prometheus metrics** for monitoring

### Infrastructure
- **Docker Compose** with service discovery
- **NGINX** as reverse proxy
- **Redis** for session management
- **PostgreSQL** with replication
- **Grafana** for metrics visualization

## 🚀 Kubernetes Deployment

Ready to deploy to Kubernetes?

### 1. Deploy to Kubernetes
```bash
kubectl apply -f k8s/
```

### 2. Access via Port Forward
```bash
kubectl port-forward service/task-frontend 3004:80
kubectl port-forward service/api-gateway 8004:8080
```

### 3. View in Browser
Go to http://localhost:3004

## 📊 Monitoring

### Check Service Health
```bash
curl http://localhost:8004/health
```

### View Microservice Status
```bash
curl http://localhost:8004/services/status
```

### Monitor WebSocket Connections
```bash
docker-compose logs -f task-notification-service | grep "websocket"
```

## 🔄 Stop Application

```bash
docker-compose down
```

## ➡️ What's Next?

✅ **Master this app?** → [Try the social media platform](social-media.md) (ultimate challenge)  
✅ **Ready for production?** → [Microservices in production](../kubernetes/microservices-guide.md)  
✅ **Want monitoring?** → [Advanced monitoring setup](../deployment/monitoring.md)

## 🆘 Need Help?

**Common issues**:
- **Service discovery failures**: Check Docker Compose networking
- **WebSocket connection errors**: Verify proxy configuration
- **Database migration issues**: Check Go-migrate setup

**More help**: [Troubleshooting guide](../troubleshooting/common-issues.md)

---

**Advanced choice!** The task management app showcases modern Go microservices patterns used in high-scale systems.