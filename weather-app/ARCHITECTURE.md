# Weather Application Architecture

## 🌤️ What It Does

A weather forecasting application that displays current conditions and forecasts. Used in **Lab 1** to learn Kubernetes basics.

## 🏗️ How It Works

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Vue.js    │   →     │   Flask     │    →    │   Redis     │
│   Frontend  │  HTTP   │   Backend   │  Cache  │   Cache     │
│   Port 80   │         │   Port 5000 │         │   Port 6379 │
└─────────────┘         └─────────────┘         └─────────────┘
                              ↓
                        OpenWeather API
```

**Frontend** → User interface for weather data  
**Backend** → Fetches and processes weather data  
**Redis** → Caches API responses

## 🛠️ Tech Stack

- **Frontend**: Vue.js 3
- **Backend**: Python Flask
- **Cache**: Redis
- **API**: OpenWeatherMap

## 📦 Kubernetes Components

When deployed in Lab 1, you'll create:
- **3 Deployments** (frontend, backend, redis)
- **3 Services** (ClusterIP for communication)
- **ConfigMap** (API configuration)

## 🔗 Service Communication

```bash
# Frontend calls backend
http://weather-backend:5000/api/weather

# Backend calls redis
redis://redis-service:6379
```

---

**👉 Start practicing**: See `labs/01-weather-basics.md`
