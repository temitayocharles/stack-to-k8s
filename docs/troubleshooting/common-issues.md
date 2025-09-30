# 🔍 Common Issues - Detailed Troubleshooting Guide

**Stuck on something specific?** This guide covers detailed solutions for common problems.

## 🐳 Docker Issues

### Problem: "Docker daemon not running"
**Symptoms**: Commands fail with "Cannot connect to Docker daemon"

**Solution for Mac**:
```bash
# Start Docker Desktop
open -a Docker

# Wait for Docker to start (2-3 minutes)
docker --version
```

**Solution for Windows**:
1. Open Docker Desktop from Start menu
2. Wait for "Docker Desktop is running" notification
3. Test: `docker --version`

**Solution for Linux**:
```bash
# Start Docker service
sudo systemctl start docker

# Enable auto-start
sudo systemctl enable docker
```

### Problem: "Port already in use"
**Symptoms**: "bind: address already in use" error

**Find what's using the port**:
```bash
# Check port 3001 (replace with your port)
lsof -i :3001

# Kill the process (replace PID)
kill -9 <PID>
```

**Alternative ports**: Edit `docker-compose.yml`:
```yaml
ports:
  - "3002:3000"  # Use 3002 instead of 3001
```

### Problem: "No space left on device"
**Symptoms**: Docker commands fail with disk space errors

**Clean up Docker**:
```bash
# Remove unused containers and images
docker system prune -a

# Remove unused volumes
docker volume prune

# Check disk usage
docker system df
```

## ☸️ Kubernetes Issues

### Problem: "kubectl command not found"
**Install kubectl**:

**Mac**:
```bash
brew install kubectl
```

**Windows**:
```bash
# Using chocolatey
choco install kubernetes-cli

# Or download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

**Linux**:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Problem: "No cluster found"
**Symptoms**: "The connection to the server localhost:8080 was refused"

**Enable Kubernetes in Docker Desktop**:
1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait 5-10 minutes for setup

**Verify setup**:
```bash
kubectl cluster-info
```

### Problem: "ImagePullBackOff"
**Symptoms**: Pods stuck in ImagePullBackOff state

**Check the error**:
```bash
kubectl describe pod <pod-name>
```

**Common fixes**:
```bash
# Build local image
docker build -t myapp:latest .

# Load image into kind/minikube
kind load docker-image myapp:latest
# OR
minikube image load myapp:latest
```

### Problem: "Pods in Pending state"
**Check resource requirements**:
```bash
kubectl describe pod <pod-name>
```

**Common causes**:
- Insufficient CPU/memory
- No nodes available
- Image pull issues

**Solutions**:
```bash
# Reduce resource requests in YAML
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
```

## 🌐 Network Issues

### Problem: "Cannot access application in browser"
**Step-by-step diagnosis**:

**1. Check if containers are running**:
```bash
docker-compose ps
# All should show "Up"
```

**2. Check if ports are exposed**:
```bash
docker-compose port frontend 3000
# Should show: 0.0.0.0:3001
```

**3. Test with curl**:
```bash
curl http://localhost:3001
# Should return HTML or JSON
```

**4. Check firewall (Mac)**:
```bash
# Allow ports through firewall
sudo pfctl -f /etc/pf.conf
```

**5. Check firewall (Windows)**:
- Open Windows Defender Firewall
- Allow Docker Desktop through firewall

### Problem: "Services can't communicate"
**Check Docker network**:
```bash
# List networks
docker network ls

# Inspect network
docker network inspect <network-name>
```

**Fix communication**:
```bash
# Restart with fresh network
docker-compose down
docker-compose up -d
```

## 💾 Database Issues

### Problem: "Database connection refused"
**Check database container**:
```bash
# See if database is running
docker-compose ps database

# Check logs for errors
docker-compose logs database
```

**Common fixes**:
```bash
# Wait longer for database startup
sleep 60

# Restart database container
docker-compose restart database

# Reset database data
docker-compose down -v
docker-compose up -d
```

### Problem: "Authentication failed for user"
**Check credentials**:
```bash
# Verify environment variables
docker-compose exec backend env | grep DB
```

**Reset credentials**:
```bash
# Edit .env file
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=your_database

# Restart services
docker-compose down
docker-compose up -d
```

### Problem: "Table doesn't exist"
**Run migrations**:
```bash
# Node.js apps
docker-compose exec backend npm run migrate

# Rails apps
docker-compose exec backend rails db:migrate

# Django apps
docker-compose exec backend python manage.py migrate
```

## 🔧 Performance Issues

### Problem: "Application is very slow"
**Check resource usage**:
```bash
# Monitor containers
docker stats

# Check available resources
free -h  # Linux/Mac
```

**Optimize performance**:
```bash
# Increase container memory
docker-compose.yml:
  services:
    backend:
      deploy:
        resources:
          limits:
            memory: 1G
```

### Problem: "High CPU usage"
**Identify the problem**:
```bash
# Check which container is using CPU
docker stats --no-stream

# Check logs for errors
docker-compose logs backend | grep ERROR
```

## 🆘 Getting More Help

### Gather Information Before Asking
```bash
# System information
uname -a
docker --version
docker-compose --version

# Application status
docker-compose ps
docker-compose logs --tail=50

# Error messages
kubectl describe pod <pod-name>
```

### Where to Get Help
- **Docker Issues**: [Docker Documentation](https://docs.docker.com/)
- **Kubernetes Issues**: [Kubernetes Documentation](https://kubernetes.io/docs/)
- **Application Specific**: Check the app's README.md

### Information to Include in Help Requests
```
**Operating System**: macOS/Windows/Linux
**Docker Version**: (output of docker --version)
**Application**: ecommerce-app/weather-app/etc.
**Error Message**: (exact text from terminal)
**Steps to Reproduce**: What you did before the error
**What You've Tried**: Solutions you already attempted
```

---

**Remember**: Most issues are solved by restarting Docker or waiting longer for services to start. Don't panic! 🧘‍♀️