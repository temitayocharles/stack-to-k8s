# Social Media Platform Architecture

## 📱 What It Does

A social networking platform with posts, comments, likes, follows, and real-time feeds. Used in **Lab 6** to learn autoscaling and performance optimization.

## 🏗️ How It Works

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│    React    │   →     │    Ruby     │    →    │ PostgreSQL  │
│   Native    │  HTTP   │    Rails    │  Data   │  Database   │
│   Port 3000 │         │   Port 3000 │         │  Port 5432  │
└─────────────┘         └─────────────┘         └─────────────┘
                              ↓
                         Redis Cache
                         (Port 6379)
```

**Frontend** → Social feed UI, posts, profiles, real-time updates  
**Backend** → Posts API, user management, notifications  
**PostgreSQL** → Stores users, posts, comments, likes  
**Redis** → Caching, session storage, real-time features

## 🛠️ Tech Stack

- **Frontend**: React Native Web
- **Backend**: Ruby on Rails (API mode)
- **Database**: PostgreSQL
- **Cache**: Redis
- **Real-time**: WebSockets (Action Cable)

## 📦 Kubernetes Components

When deployed in Lab 6, you'll create:
- **2 Deployments** (frontend, backend with HPA)
- **1 StatefulSet** (postgresql)
- **1 Deployment** (redis)
- **4 Services** (frontend, backend, database, cache)
- **HorizontalPodAutoscaler** (auto-scaling based on CPU/memory)
- **PodDisruptionBudget** (high availability)
- **Resource Limits** (CPU/memory management)

## 🔗 Service Communication

```bash
# Frontend calls backend
http://social-backend:3000/api/posts

# Backend calls database
postgresql://postgres-service:5432/social

# Backend calls cache
redis://redis-service:6379
```

## 💡 What You'll Learn

- Horizontal Pod Autoscaling (HPA)
- Resource requests and limits
- Pod Disruption Budgets
- Performance testing and optimization
- Load testing with realistic traffic

---

**👉 Start practicing**: See `labs/06-social-scaling.md`
