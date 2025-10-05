# Educational Platform Architecture

## 📚 What It Does

A Learning Management System (LMS) with courses, lessons, quizzes, and user progress tracking. Used in **Lab 3** to learn stateful applications and data persistence.

## 🏗️ How It Works

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Angular   │   →     │    Java     │    →    │ PostgreSQL  │
│   Frontend  │  HTTP   │  Spring Boot│  Data   │  Database   │
│   Port 4200 │         │   Port 8080 │         │  Port 5432  │
└─────────────┘         └─────────────┘         └─────────────┘
                              ↓
                         Redis Cache
                         (Port 6379)
```

**Frontend** → Course browsing, lesson viewing, quiz taking  
**Backend** → Course management, user progress, quiz grading  
**PostgreSQL** → Persistent storage (courses, users, progress)  
**Redis** → Session caching and temporary data

## 🛠️ Tech Stack

- **Frontend**: Angular 17
- **Backend**: Java Spring Boot
- **Database**: PostgreSQL (persistent)
- **Cache**: Redis (temporary)

## 📦 Kubernetes Components

When deployed in Lab 3, you'll create:
- **2 Deployments** (frontend, backend)
- **1 StatefulSet** (postgresql - for data persistence)
- **1 Deployment** (redis)
- **4 Services** (ClusterIP for communication)
- **PersistentVolumeClaims** (database storage)
- **ConfigMaps** (database configuration)
- **Secrets** (database credentials)

## 🔗 Service Communication

```bash
# Frontend calls backend
http://educational-backend:8080/api/courses

# Backend calls database
postgresql://postgres-service:5432/educational

# Backend calls cache
redis://redis-service:6379
```

## 💡 What You'll Learn

- Deploying stateful applications
- Using StatefulSets for databases
- Persistent volume management
- Data persistence across pod restarts

---

**👉 Start practicing**: See `labs/03-educational-stateful.md`
