# E-commerce Platform Architecture

## 🛒 What It Does

An online shopping platform with product catalog, shopping cart, and order management. Used in **Lab 2** to learn multi-tier application deployment.

## 🏗️ How It Works

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│    React    │   →     │   Node.js   │    →    │   MongoDB   │
│   Frontend  │  HTTP   │   Backend   │  Data   │   Database  │
│   Port 3000 │         │   Port 5000 │         │   Port 27017│
└─────────────┘         └─────────────┘         └─────────────┘
```

**Frontend** → Shopping interface (products, cart, checkout)  
**Backend** → API for products, orders, users  
**MongoDB** → Stores products, orders, user data

## 🛠️ Tech Stack

- **Frontend**: React + Redux
- **Backend**: Node.js + Express
- **Database**: MongoDB
- **Cache**: Redis (optional)

## 📦 Kubernetes Components

When deployed in Lab 2, you'll create:
- **2 Deployments** (frontend, backend)
- **1 StatefulSet** (mongodb)
- **3 Services** (frontend LoadBalancer, backend ClusterIP, mongo ClusterIP)
- **ConfigMaps** (app configuration)
- **Secrets** (database credentials)

## 🔗 Service Communication

```bash
# Frontend calls backend
http://ecommerce-backend:5000/api/products

# Backend calls database
mongodb://mongo-service:27017/ecommerce
```

## 💡 What You'll Learn

- Deploying multi-tier applications
- Service discovery between pods
- Using ConfigMaps for configuration
- Managing secrets for databases

---

**👉 Start practicing**: See `labs/02-ecommerce-basics.md`
