# 🆘 Quick Fixes - Common Issues Solved

**Got stuck?** Most issues have simple solutions. Try these first!

## 🔥 Emergency Fixes (Try These First)

### "Docker command not found"
**Quick fix**:
```bash
# Restart your terminal
# Then try: 
docker --version
```
**If still broken**: [Install Docker properly](../getting-started/system-setup.md)

### "Port already in use"
**Quick fix**:
```bash
# Stop everything:
docker-compose down
# Wait 10 seconds, then start again:
docker-compose up -d
```

### "Container won't start"
**Quick fix**:
```bash
# Force clean restart:
docker-compose down -v
docker-compose up -d --build
```

### "Website won't load"
**Quick fix**:
1. **Wait 2 minutes** (services take time to start)
2. **Check if running**: `docker-compose ps`
3. **Try again**: Refresh your browser

## 🔍 Step-by-Step Diagnosis

### Problem: Application Won't Start

**Step 1: Check what's running**
```bash
docker-compose ps
```
**You should see**: All services showing "Up"  
**If not**: Continue to Step 2

**Step 2: Look for error messages**
```bash
docker-compose logs
```
**Look for**: Lines with "ERROR" or "FAILED"  
**Common errors**: Port conflicts, missing files, permission issues

**Step 3: Try fresh start**
```bash
docker-compose down -v
docker-compose up -d
```

### Problem: Can't Access Website

**Step 1: Verify service is running**
```bash
curl http://localhost:3001
```
**You should get**: HTML response or connection  
**If connection refused**: Service isn't started

**Step 2: Check the correct port**
- **E-commerce**: http://localhost:3001
- **Educational**: http://localhost:4001  
- **Medical**: http://localhost:3002
- **Weather**: http://localhost:3003
- **Task Management**: http://localhost:3004
- **Social Media**: http://localhost:3005

**Step 3: Clear browser cache**
- **Chrome**: Ctrl+Shift+R (Windows) / Cmd+Shift+R (Mac)
- **Firefox**: Ctrl+F5 (Windows) / Cmd+Shift+R (Mac)

### Problem: Database Connection Failed

**Step 1: Wait for database startup**
```bash
# Database takes 30-60 seconds to start
sleep 60
docker-compose restart backend
```

**Step 2: Check database health**
```bash
docker-compose exec backend npm run db:check
```

**Step 3: Reset database if needed**
```bash
docker-compose down -v
docker-compose up -d
```

## 📱 Platform-Specific Issues

### macOS Issues

**"Permission denied"**
```bash
sudo chown -R $(whoami) /Volumes/512-B/Documents/PERSONAL/full-stack-apps
```

**"OrbStack not working"**
```bash
brew uninstall orbstack
brew install --cask docker
```

### Windows Issues

**"Docker Desktop won't start"**
1. **Enable WSL 2**: Follow [Microsoft's guide](https://docs.microsoft.com/en-us/windows/wsl/install)
2. **Restart computer**
3. **Try Rancher Desktop**: Download from [rancherdesktop.io](https://rancherdesktop.io/)

**"Path not found"**
- Use **Git Bash** or **PowerShell** instead of Command Prompt
- Replace `/` with `\` in file paths

### Linux Issues

**"Docker permission denied"**
```bash
sudo usermod -a -G docker $USER
# Log out and log back in
```

**"Service not accessible"**
```bash
# Check firewall:
sudo ufw allow 3001
sudo ufw allow 5001
```

## 🔄 Nuclear Options (When All Else Fails)

### Complete Docker Reset
```bash
# WARNING: This removes ALL Docker data
docker system prune -a --volumes
docker-compose up -d --build
```

### Start Over with One App
```bash
# Pick just one application and test it:
cd ecommerce-app
docker-compose down -v
docker-compose up -d
# Wait 3 minutes
open http://localhost:3001
```

### Check System Resources
```bash
# Make sure you have enough:
df -h  # Disk space (need 10GB free)
free -m  # Memory (need 4GB free)
```

## 📞 Still Stuck?

### Before Asking for Help

1. **Try the nuclear options above**
2. **Copy the exact error message**
3. **Note which application you're trying**
4. **Include your operating system**

### Where to Get Help

- **Check detailed guides**: [How it works](how-it-works.md)
- **Review setup**: [System setup guide](../getting-started/system-setup.md)
- **Common patterns**: [Detailed troubleshooting](common-issues.md)

### Format for Help Requests

```
**Problem**: [Brief description]
**Application**: [Which app - ecommerce, weather, etc.]
**Operating System**: [macOS, Windows, Linux]
**Error Message**: [Exact text from terminal]
**What I tried**: [List the steps you already tried]
```

---

**Remember**: 99% of issues are solved by waiting longer or restarting Docker. Don't panic! 🧘‍♀️