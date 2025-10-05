# Medical Care System Architecture

## 🏥 What It Does

A healthcare management system with patient records, appointments, prescriptions, and access control. Used in **Lab 5** to learn Kubernetes security (RBAC, Network Policies, Secrets).

## 🏗️ How It Works

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Blazor    │   →     │    .NET     │    →    │ PostgreSQL  │
│   Frontend  │  HTTP   │   Backend   │  Data   │  Database   │
│   Port 80   │         │   Port 5000 │         │  Port 5432  │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Frontend** → Patient portal, staff dashboard, admin interface  
**Backend** → Medical records API, appointment scheduling, HIPAA-compliant security  
**PostgreSQL** → Encrypted patient data, appointments, prescriptions

## 🛠️ Tech Stack

- **Frontend**: Blazor WebAssembly (.NET 8)
- **Backend**: ASP.NET Core Web API
- **Database**: PostgreSQL
- **Security**: Role-Based Access Control (RBAC)

## 📦 Kubernetes Components

When deployed in Lab 5, you'll create:
- **2 Deployments** (frontend, backend)
- **1 StatefulSet** (postgresql with encryption)
- **3 Services** (ClusterIP for secure communication)
- **RBAC Policies** (ServiceAccounts, Roles, RoleBindings)
- **Network Policies** (restrict pod-to-pod communication)
- **Secrets** (database credentials, API keys)
- **Pod Security Standards** (restricted mode)

## 🔗 Service Communication

```bash
# Frontend calls backend
http://medical-backend:5000/api/patients

# Backend calls database (encrypted)
postgresql://postgres-service:5432/medical?sslmode=require
```

## 💡 What You'll Learn

- Kubernetes RBAC (Role-Based Access Control)
- Network Policies for isolation
- Secrets management
- Pod Security Standards
- Secure service-to-service communication
- Healthcare data compliance patterns

---

**👉 Start practicing**: See `labs/05-medical-security.md`
