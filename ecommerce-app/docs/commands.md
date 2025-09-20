# 📝 **Command Reference**
## **All the Commands You Need**

> **✨ Quick Reference Sheet** for common tasks  
> **🎯 Goal**: Find the right command fast  
> **⏰ Find & Run**: Usually under 30 seconds  

---

## 🚀 **Getting Started Commands**

### **Basic Setup**
```bash
# Clone and start everything:
git clone <repository>
cd ecommerce-app
docker-compose up -d

# Check if everything is running:
docker-compose ps

# View the application:
open http://localhost:3001
```

### **Stop Everything**
```bash
# Stop containers (keeps data):
docker-compose down

# Stop and remove all data:
docker-compose down -v

# Stop and clean up everything:
docker-compose down -v && docker system prune
```

---

## 🐳 **Docker Commands**

### **Container Management**
```bash
# See all running containers:
docker-compose ps

# Start specific service:
docker-compose up -d frontend

# Restart a service:
docker-compose restart backend

# Stop specific service:
docker-compose stop mongodb
```

### **Logs and Debugging**
```bash
# View all logs:
docker-compose logs

# View specific service logs:
docker-compose logs backend
docker-compose logs -f frontend  # Follow logs in real-time

# See last 50 lines:
docker-compose logs --tail 50 backend
```

### **Container Resource Usage**
```bash
# See CPU/Memory usage:
docker stats

# See disk usage:
docker system df

# Clean up unused resources:
docker system prune
```

---

## 🔧 **Development Commands**

### **Build and Rebuild**
```bash
# Build all containers:
docker-compose build

# Build specific container:
docker-compose build backend

# Build without cache (fresh build):
docker-compose build --no-cache

# Build and start:
docker-compose up -d --build
```

### **Access Container Shell**
```bash
# Get shell access to backend:
docker-compose exec backend bash

# Get shell access to database:
docker-compose exec mongodb mongosh

# Run commands in container:
docker-compose exec backend npm install
```

---

## 📊 **Monitoring Commands**

### **Health Checks**
```bash
# Check API health:
curl http://localhost:5001/health

# Check database connection:
curl http://localhost:5001/api/products

# Check frontend:
curl http://localhost:3001

# Full system check:
curl http://localhost:5001/health && \
curl http://localhost:3001 && \
echo "System is healthy!"
```

### **Performance Testing**
```bash
# Test API response time:
time curl http://localhost:5001/api/products

# Simple load test (requires 'ab'):
ab -n 100 -c 10 http://localhost:5001/api/products

# Monitor resource usage during load:
docker stats
```

---

## 💾 **Database Commands**

### **MongoDB Operations**
```bash
# Connect to database:
docker-compose exec mongodb mongosh

# Inside MongoDB shell:
show dbs                    # List databases
use ecommerce              # Switch to app database
show collections           # List tables
db.products.find()         # Show all products
db.orders.find().limit(5)  # Show 5 orders
```

### **Database Backup & Restore**
```bash
# Backup database:
docker-compose exec mongodb mongodump --out /backup

# Restore database:
docker-compose exec mongodb mongorestore /backup

# Reset database (WARNING: Deletes all data):
docker-compose down -v
docker-compose up -d
```

---

## 🧹 **Cleanup Commands**

### **Gentle Cleanup**
```bash
# Remove stopped containers:
docker container prune

# Remove unused images:
docker image prune

# Remove unused volumes:
docker volume prune
```

### **Nuclear Cleanup (Use with Caution)**
```bash
# Remove EVERYTHING Docker-related:
docker system prune -a --volumes

# Start completely fresh:
docker-compose down -v && \
docker system prune -a && \
docker-compose up -d --build
```

---

## 🚨 **Troubleshooting Commands**

### **When Things Go Wrong**
```bash
# Check what's using ports:
lsof -i :3001  # Frontend port
lsof -i :5001  # Backend port
lsof -i :27017 # Database port

# Kill process using port:
kill -9 <PID>

# Check Docker daemon:
docker version
docker info
```

### **Common Fix Commands**
```bash
# Restart Docker Desktop (Mac):
osascript -e 'quit app "Docker Desktop"'
open -a "Docker Desktop"

# Free up memory:
docker system prune -f

# Reset to known good state:
git checkout main
docker-compose down -v
docker-compose up -d --build
```

---

## 🎯 **Environment-Specific Commands**

### **Development Environment**
```bash
# Start with file watching:
docker-compose -f docker-compose.dev.yml up -d

# Install new dependencies:
docker-compose exec backend npm install package-name

# Run tests:
docker-compose exec backend npm test
```

### **Production Environment**
```bash
# Deploy to production:
docker-compose -f docker-compose.prod.yml up -d

# Check production logs:
docker-compose -f docker-compose.prod.yml logs

# Scale services:
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

---

## 📊 **Useful One-Liners**

### **Quick Status Checks**
```bash
# Check everything is running:
docker-compose ps | grep -v Exit

# Count running containers:
docker-compose ps | grep Up | wc -l

# Check disk space:
df -h | grep -E "Available|/"

# Check memory usage:
free -h
```

### **Quick Fixes**
```bash
# Restart everything:
docker-compose restart

# Update and restart:
git pull && docker-compose up -d --build

# Clean start:
docker-compose down && docker-compose up -d

# Emergency reset:
docker-compose down -v && docker system prune -f && docker-compose up -d
```

---

## 🔄 **CI/CD Commands**

### **Continuous Integration**
```bash
# Run all tests:
docker-compose exec backend npm test
docker-compose exec frontend npm test

# Build for production:
docker-compose build --parallel

# Tag and push images:
docker tag ecommerce-backend:latest myrepo/ecommerce-backend:v1.0
docker push myrepo/ecommerce-backend:v1.0
```

---

## 💡 **Pro Tips**

### **Time-Saving Aliases**
Add these to your `.bashrc` or `.zshrc`:
```bash
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dcl="docker-compose logs"
alias dcp="docker-compose ps"
alias dcr="docker-compose restart"
```

### **Commonly Used Combos**
```bash
# Quick restart and check:
docker-compose restart && docker-compose ps

# Clean build and start:
docker-compose down && docker-compose up -d --build

# Check logs for errors:
docker-compose logs | grep -i error

# Monitor live logs:
docker-compose logs -f | grep -v "GET /health"
```

---

**🎯 Bookmark this page - you'll use these commands often!**