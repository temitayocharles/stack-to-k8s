# 🐳 Install Docker (5 minutes)

**What Docker does**: Packages applications so they run the same everywhere.

## For macOS (3 minutes)

### Step 1: Download Docker Desktop
**Click here**: [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)

**You will see**: Download page with blue "Download for Mac" button.

### Step 2: Install Docker Desktop
1. **Open**: The downloaded .dmg file
2. **Drag**: Docker icon to Applications folder
3. **Launch**: Docker from Applications
4. **Wait**: For Docker to start (you'll see whale icon in menu bar)

### Step 3: Test Docker Works
```bash
# Copy and paste this command
docker run hello-world
```

**You should see**: "Hello from Docker!" message.

**If you see an error**: [→ Docker Troubleshooting](./docker-troubleshooting.md)

---

## For Windows (3 minutes)

### Step 1: Download Docker Desktop
**Click here**: [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)

**You will see**: Download page with blue "Download for Windows" button.

### Step 2: Enable WSL 2
**Before installing**: You need Windows Subsystem for Linux.

**Click here**: [Enable WSL 2](./enable-wsl2.md) *(Opens in new page)*

### Step 3: Install Docker Desktop
1. **Run**: The downloaded installer
2. **Follow**: Installation wizard
3. **Restart**: Your computer when prompted
4. **Launch**: Docker Desktop

### Step 4: Test Docker Works
```bash
# Copy and paste this command
docker run hello-world
```

**You should see**: "Hello from Docker!" message.

---

## For Linux (3 minutes)

### Step 1: Install Docker Engine
```bash
# Copy and paste these commands one by one

# Update package index
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group
sudo usermod -aG docker $USER
```

### Step 2: Start Docker Service
```bash
# Start Docker
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker
```

### Step 3: Test Docker Works
```bash
# Test Docker (you may need to log out and back in)
docker run hello-world
```

**You should see**: "Hello from Docker!" message.

---

**✅ Docker Installed**: [→ Next: Install Kubernetes Tools](./install-kubernetes.md)