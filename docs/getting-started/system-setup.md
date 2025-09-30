# 🔧 System Setup - Prepare Your Computer

**Goal**: Optimize your computer for the best Docker and Kubernetes experience.

> **Perfect for**: "I want everything to work smoothly"

## 🎯 What You'll Get
- ✅ Optimized Docker performance
- ✅ Faster container startup times
- ✅ Better resource usage
- ✅ Fewer conflicts and issues

## 📋 Before You Start
**Required time**: 10-15 minutes  
**What you need**: Administrator access to your computer

## 🚀 Automated Setup (Recommended)

We've created a smart script that detects your system and optimizes it automatically.

### Step 1: Run the Optimizer
```bash
cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps
./scripts/setup-optimize.sh
```

### Step 2: Follow the Prompts
The script will:
- ✅ **Detect your system**: Mac (Intel/Silicon), Windows, or Linux
- ✅ **Check your current setup**: What's already installed
- ✅ **Recommend improvements**: Best tools for your system
- ✅ **Install automatically**: If you choose to

### Step 3: Restart When Asked
Some changes require a restart to take effect.

## 🔧 Manual Setup (If You Prefer)

### For Mac (Apple Silicon)
**Recommended**: OrbStack (fastest performance)
```bash
brew install orbstack
```

### For Mac (Intel)
**Recommended**: Colima (best compatibility)
```bash
brew install colima docker
colima start
```

### For Windows
**Recommended**: Rancher Desktop (easiest setup)
1. Download from: https://rancherdesktop.io/
2. Install with default settings
3. Enable "dockerd" in settings

### For Linux
**Recommended**: Docker Engine (native performance)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

## ✅ Verify Everything Works

### Test Docker
```bash
docker run hello-world
```
**You should see**: "Hello from Docker!" message

### Test Docker Compose
```bash
docker-compose --version
```
**You should see**: Version number (like "2.21.0")

## 🆘 If Something Goes Wrong

**Error: "command not found"**
- Solution: Restart your terminal and try again

**Error: "permission denied"**  
- Mac/Linux: Add `sudo` before the command
- Windows: Run as Administrator

**Docker won't start**
- Solution: Restart your computer and try again

## ➡️ What's Next?

✅ **System optimized?** → [Deploy your first app](first-app.md)  
✅ **Want to understand more?** → [How Docker works](../troubleshooting/how-it-works.md)  
✅ **Need help?** → [Common issues](../troubleshooting/common-issues.md)

---

**Questions?** The setup script includes detailed help and suggestions. Run it to get personalized advice!