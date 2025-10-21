# Task Management Application Architecture

## ✅ What It Does

A task tracking application with boards, tasks, assignments, and team collaboration features. Used in **Lab 4** to learn Ingress controllers and external access.

## 🏗️ How It Works

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Svelte    │   →     │     Go      │    →    │ PostgreSQL  │
│   Frontend  │  HTTP   │   Backend   │  Data   │  Database   │
│   Port 3000 │         │   Port 8080 │         │  Port 5432  │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Frontend** → Task board UI, drag-and-drop interface  
**Backend** → RESTful API for tasks, users, assignments  
**PostgreSQL** → Stores tasks, users, projects

## 🛠️ Tech Stack

- **Frontend**: Svelte
- **Backend**: Go + Gorilla Mux
- **Database**: PostgreSQL

## 📦 Kubernetes Components

When deployed in Lab 4, you'll create:
- **2 Deployments** (frontend, backend)
- **1 StatefulSet** (postgresql)
- **3 Services** (frontend, backend, database)
- **Ingress** (external access with routing)
- **TLS Certificates** (HTTPS support)
- **ConfigMaps** (application config)

## 🔗 Service Communication

```bash
# Frontend calls backend
http://task-backend:8080/api/tasks

# Backend calls database
postgresql://postgres-service:5432/tasks
```

## 💡 What You'll Learn

- Exposing apps externally with Ingress
- Configuring routing rules
- Setting up TLS/HTTPS
- Managing external DNS

---

**👉 Start practicing**: See `labs/04-task-ingress.md`
