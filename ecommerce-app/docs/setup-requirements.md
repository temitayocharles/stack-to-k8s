# 📋 **SETUP REQUIREMENTS - GET READY**
## **Make Sure You Have Everything You Need**

> **🎯 Goal**: Check you have the right tools installed  
> **⏰ Time**: 15-30 minutes (if you need to install things)  
> **🤝 Approach**: Check each item, install what's missing  

---

## **✅ Quick Check - Do You Have These?**

### **1. Docker Desktop**
**Copy and paste this in your terminal:**
```bash
docker --version
```

**You should see:** Something like "Docker version 20.10.x"

**If you see "command not found":** You need to install Docker

**👆 Install Docker:** [Docker Installation Guide](./install-docker.md)

---

### **2. Git (for downloading the code)**
**Copy and paste this:**
```bash
git --version
```

**You should see:** Something like "git version 2.x.x"

**If you see "command not found":** You need to install Git

**👆 Install Git:** [Git Installation Guide](./install-git.md)

---

### **3. A Code Editor (recommended)**
**Any of these work great:**
- VS Code (most popular)
- Sublime Text
- Atom
- Even Notepad++ on Windows

**Don't have one?** → [VS Code Installation](./install-vscode.md)

---

### **4. Web Browser**
**Any modern browser works:**
- Chrome ✅
- Firefox ✅  
- Safari ✅
- Edge ✅

**Already have one?** You're good to go!

---

## **💻 System Requirements**

### **Minimum Specs:**
- **RAM**: 8GB (4GB might work but will be slow)
- **Disk Space**: 10GB free space
- **CPU**: Any modern processor (last 5 years)
- **Internet**: Broadband connection for downloading

### **Recommended Specs:**
- **RAM**: 16GB or more
- **Disk Space**: 20GB+ free space
- **CPU**: 4+ cores
- **Internet**: Fast connection for quicker setup

**Not sure about your specs?** → [How to Check Your System](./check-system.md)

---

## **🛠️ Installation Help by Operating System**

### **Windows Users**
**👆 Click here:** [Windows Setup Guide](./windows-setup.md)
- Docker Desktop for Windows
- Git for Windows
- Windows-specific tips

### **Mac Users**
**👆 Click here:** [Mac Setup Guide](./mac-setup.md)
- Docker Desktop for Mac
- Homebrew package manager
- Mac-specific tips

### **Linux Users**
**👆 Click here:** [Linux Setup Guide](./linux-setup.md)
- Docker CE installation
- Package manager commands
- Linux-specific tips

---

## **⚡ Quick Setup (If You're in a Hurry)**

### **For Mac Users:**
```bash
# Install Homebrew first (if you don't have it)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then install everything
brew install --cask docker
brew install git
brew install --cask visual-studio-code
```

### **For Windows Users:**
1. Download Docker Desktop from docker.com
2. Download Git from git-scm.com
3. Download VS Code from code.visualstudio.com
4. Install each one by double-clicking

### **For Ubuntu/Debian Users:**
```bash
# Update package list
sudo apt update

# Install Docker
sudo apt install docker.io docker-compose

# Install Git
sudo apt install git

# Install VS Code
sudo snap install code --classic
```

---

## **🧪 Test Everything Works**

**After installing, test each tool:**

### **Test Docker:**
```bash
docker run hello-world
```
**You should see:** A welcome message from Docker

### **Test Git:**
```bash
git --version
```
**You should see:** Your Git version

### **Test VS Code:**
```bash
code --version
```
**You should see:** Your VS Code version

**All working?** → [Go Back to Get Started](../GET-STARTED.md)

---

## **🆘 Installation Problems?**

### **Docker Won't Install**
- **Windows**: Make sure virtualization is enabled in BIOS
- **Mac**: Check you have macOS 10.14 or newer
- **Linux**: Make sure you're in the docker group

### **Permission Errors**
- **Windows**: Run terminal as Administrator
- **Mac/Linux**: Use `sudo` for system installations

### **Download Problems**
- Check your internet connection
- Try downloading directly from official websites
- Disable VPN if you're using one

**Still stuck?** → [Detailed Installation Help](./installation-troubleshooting.md)

---

## **⏭️ What's Next?**

**Once you have everything installed:**

1. **Go back:** [Choose Your Learning Path](../GET-STARTED.md)
2. **Quick start:** [Get It Running in 30 Minutes](./quick-start.md)
3. **Learn deeply:** [Step-by-Step Guide](./step-by-step.md)

---

**🎯 Remember: Setting up your development environment is part of learning. Every professional developer has been through this exact process!**