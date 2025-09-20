# 🆘 **Troubleshooting Guide**
## **When Things Go Wrong - We'll Fix It!**

> **✨ Don't Panic!** Every developer faces issues - this guide helps you fix them fast  
> **🎯 Goal**: Get you back up and running quickly  
> **⏰ Time to Fix**: Usually 5-15 minutes per issue  

---

## 🚨 **Most Common Issues (Start Here!)**

### **Issue 1: "Cannot connect to Docker daemon"**
**What you see:**
```
Error response from daemon: dial unix /var/run/docker.sock: connect: permission denied
```

**Quick Fix:**
```bash
# On Mac/Linux:
sudo docker-compose up -d

# Or add your user to docker group:
sudo usermod -aG docker $USER
# Then logout and login again
```

**Why this happens:** Docker needs special permissions to run

---

### **Issue 2: "Port already in use"**
**What you see:**
```
Error: bind: address already in use
```

**Quick Fix:**
```bash
# Find what's using the port:
lsof -i :5001

# Kill the process (replace PID with actual number):
kill -9 PID

# Or use different ports in docker-compose.yml
```

**Why this happens:** Another app is using the same port

---

### **Issue 3: Application won't start**
**What you see:**
- Browser shows "This site can't be reached"
- No response from http://localhost:5001

**Quick Fix:**
```bash
# Check if containers are running:
docker-compose ps

# If they're not running, check logs:
docker-compose logs

# Restart everything:
docker-compose down && docker-compose up -d
```

**Why this happens:** Container might have crashed or failed to start

---

## 🔍 **Step-by-Step Diagnosis**

### **Step 1: Check Docker is Running**
```bash
docker --version
```
**Should show:** Docker version XX.XX.XX

**If not working:** [Install Docker](./setup-requirements.md)

---

### **Step 2: Check Container Status**
```bash
docker-compose ps
```
**Should show:** All containers "Up" and "healthy"

**If containers are down:**
```bash
docker-compose up -d
```

---

### **Step 3: Check Application Response**
```bash
curl http://localhost:5001/health
```
**Should show:** `{"status": "OK"}`

**If not responding:** [Check the logs](#check-application-logs)

---

### **Step 4: Check Application Logs**
```bash
# Check backend logs:
docker-compose logs backend

# Check frontend logs:
docker-compose logs frontend

# Check database logs:
docker-compose logs mongodb
```

**Look for:** Error messages in red or "ERROR" text

---

## 🛠️ **Specific Problem Solutions**

### **Database Connection Issues**
**Symptoms:**
- App starts but shows "Database connection failed"
- API returns 500 errors

**Solutions:**
```bash
# Restart database:
docker-compose restart mongodb

# Check database is running:
docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')"

# Reset database (WARNING: Deletes all data):
docker-compose down -v && docker-compose up -d
```

---

### **Frontend Won't Load**
**Symptoms:**
- Backend works but frontend shows errors
- Browser console shows JavaScript errors

**Solutions:**
```bash
# Clear browser cache (Ctrl+Shift+R)
# Or try incognito mode

# Restart frontend:
docker-compose restart frontend

# Check frontend logs:
docker-compose logs frontend
```

---

### **Slow Performance**
**Symptoms:**
- Pages load very slowly
- API responses take > 5 seconds

**Solutions:**
```bash
# Check system resources:
docker stats

# Free up memory:
docker system prune

# Restart with fresh containers:
docker-compose down && docker-compose up -d
```

---

## 💡 **Prevention Tips**

### **Before You Start:**
1. **Close other apps** that might use lots of memory
2. **Check available disk space** (need at least 2GB free)
3. **Update Docker** to latest version
4. **Restart your computer** if it's been running for days

### **Good Habits:**
- Run `docker-compose down` when you're done working
- Run `docker system prune` weekly to free up space
- Keep Docker Desktop updated
- Don't run too many containers at once

---

## 🆘 **Still Stuck? Here's What to Do**

### **Option 1: Start Fresh**
```bash
# Nuclear option - resets everything:
docker-compose down -v
docker system prune -a
docker-compose up -d --build
```

### **Option 2: Check System Requirements**
Make sure you have:
- 8GB RAM minimum
- 10GB free disk space
- Docker Desktop running
- No VPN interfering

### **Option 3: Try Alternative Setup**
- Use [Quick Start](./quick-start.md) instead of building from source
- Try [Docker Swarm setup](./docker-swarm-setup.md)
- Use cloud deployment instead

---

## 📚 **Need More Help?**

**Common Issues:**
- [Setup Requirements](./setup-requirements.md) - Make sure your system is ready
- [Architecture Guide](./architecture.md) - Understand how it all works
- [Command Reference](./commands.md) - All the commands you need

**Still having problems?** The issue might be:
1. **System-specific** - Try on a different computer
2. **Network-related** - Check your internet/firewall
3. **Version conflict** - Make sure all software is updated

---

**🎯 Remember: Every expert was once a beginner who kept trying!**