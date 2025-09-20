# 🛠️ **Setup Requirements**
## **Get Your Development Environment Ready**

> **🎯 Goal**: Set up everything you need to develop and run the educational platform  
> **⏰ Time**: 30-45 minutes for complete setup  
> **💻 Works on**: macOS, Linux, Windows  

---

## 🗺️ **Setup Paths**

### **🟢 Quick Start (Recommended)**
**Best for:** Getting started fast
- **Time:** 15-20 minutes
- **Requirements:** Docker only
- **Complexity:** Beginner-friendly

### **🟡 Full Development Setup**
**Best for:** Active development and customization
- **Time:** 30-45 minutes
- **Requirements:** Java, Node.js, PostgreSQL
- **Complexity:** Intermediate

### **🔴 Enterprise Development**
**Best for:** Production-like development environment
- **Time:** 60-90 minutes
- **Requirements:** Kubernetes, monitoring tools
- **Complexity:** Advanced

---

## 🟢 **Quick Start Setup**

### **What You Need (Minimum)**
```bash
✅ Docker Desktop
✅ Git
✅ Text editor (VS Code recommended)
✅ 4GB RAM available
✅ 10GB disk space
```

### **Step 1: Install Docker Desktop**

#### **macOS**
```bash
# Download and install Docker Desktop
open https://docs.docker.com/desktop/mac/install/

# Or install with Homebrew
brew install --cask docker

# Start Docker Desktop from Applications
# Wait for Docker to start (you'll see the whale icon in menu bar)
```

#### **Windows**
```bash
# Download Docker Desktop for Windows
# Go to: https://docs.docker.com/desktop/windows/install/
# Run Docker Desktop Installer.exe
# Follow the installation wizard
# Restart your computer when prompted
```

#### **Linux (Ubuntu/Debian)**
```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then test
docker run hello-world
```

### **Step 2: Clone and Start**
```bash
# Clone the repository
git clone https://github.com/your-username/full-stack-apps.git
cd full-stack-apps/educational-platform

# Start everything with one command
docker-compose up -d

# Wait for services to start (2-3 minutes)
# Check status
docker-compose ps

# Expected output:
# educational-platform-backend   Up    0.0.0.0:8080->8080/tcp
# educational-platform-frontend  Up    0.0.0.0:3001->80/tcp
# educational-platform-db        Up    0.0.0.0:5433->5432/tcp
```

### **Step 3: Verify Everything Works**
```bash
# Test backend
curl http://localhost:8080/actuator/health

# Expected: {"status":"UP"}

# Test frontend
open http://localhost:3001

# Expected: Angular application loads with course catalog
```

**🎉 That's it! Your educational platform is running.**

---

## 🟡 **Full Development Setup**

### **What You Need**
```bash
✅ Java 17 or higher
✅ Node.js 16 or higher
✅ PostgreSQL 12 or higher
✅ Redis 6 or higher
✅ Maven 3.8 or higher
✅ Angular CLI
✅ Docker (optional but recommended)
```

### **Step 1: Install Java**

#### **macOS**
```bash
# Install with Homebrew
brew install openjdk@17

# Add to your shell profile (.zshrc or .bash_profile)
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"' >> ~/.zshrc

# Reload shell
source ~/.zshrc

# Verify
java -version
javac -version
```

#### **Linux (Ubuntu/Debian)**
```bash
# Update package index
sudo apt update

# Install OpenJDK 17
sudo apt install openjdk-17-jdk openjdk-17-jre

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc

# Reload shell
source ~/.bashrc

# Verify
java -version
```

#### **Windows**
```bash
# Download OpenJDK 17 from:
# https://adoptium.net/temurin/releases/

# Install the MSI package
# Add JAVA_HOME to environment variables:
# System Properties → Advanced → Environment Variables
# New system variable: JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17.0.x-hotspot
# Edit PATH variable: add %JAVA_HOME%\bin

# Verify in Command Prompt
java -version
```

### **Step 2: Install Node.js**

#### **macOS**
```bash
# Install with Homebrew
brew install node@18

# Or download from nodejs.org
open https://nodejs.org/en/download/

# Verify
node --version
npm --version
```

#### **Linux**
```bash
# Using NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

#### **Windows**
```bash
# Download installer from nodejs.org
# Run the installer and follow the wizard
# Verify in Command Prompt
node --version
npm --version
```

### **Step 3: Install Angular CLI**
```bash
# Install globally
npm install -g @angular/cli

# Verify
ng version
```

### **Step 4: Install PostgreSQL**

#### **macOS**
```bash
# Install with Homebrew
brew install postgresql@15

# Start PostgreSQL service
brew services start postgresql@15

# Create database and user
psql postgres -c "CREATE DATABASE education;"
psql postgres -c "CREATE USER eduuser WITH ENCRYPTED PASSWORD 'edupass123';"
psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE education TO eduuser;"
```

#### **Linux (Ubuntu/Debian)**
```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database and user
sudo -u postgres psql -c "CREATE DATABASE education;"
sudo -u postgres psql -c "CREATE USER eduuser WITH ENCRYPTED PASSWORD 'edupass123';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE education TO eduuser;"
```

#### **Windows**
```bash
# Download installer from postgresql.org
# Run installer and follow wizard
# Remember the password you set for postgres user

# Open SQL Shell (psql) from Start Menu
# Connect as postgres user
# Run these commands:
CREATE DATABASE education;
CREATE USER eduuser WITH ENCRYPTED PASSWORD 'edupass123';
GRANT ALL PRIVILEGES ON DATABASE education TO eduuser;
```

### **Step 5: Install Redis**

#### **macOS**
```bash
# Install with Homebrew
brew install redis

# Start Redis service
brew services start redis

# Test connection
redis-cli ping
# Expected: PONG
```

#### **Linux (Ubuntu/Debian)**
```bash
# Install Redis
sudo apt update
sudo apt install redis-server

# Start service
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Test connection
redis-cli ping
# Expected: PONG
```

#### **Windows**
```bash
# Redis doesn't have official Windows support
# Use Docker instead:
docker run -d --name redis -p 6379:6379 redis:7-alpine

# Or use WSL with Linux installation
```

### **Step 6: Configure Application**
```bash
# Navigate to project
cd educational-platform

# Copy environment template
cp backend/src/main/resources/application-dev.properties.template backend/src/main/resources/application-dev.properties

# Edit configuration file
# application-dev.properties
spring.datasource.url=jdbc:postgresql://localhost:5432/education
spring.datasource.username=eduuser
spring.datasource.password=edupass123
spring.redis.host=localhost
spring.redis.port=6379
```

### **Step 7: Start Backend**
```bash
# Navigate to backend
cd backend

# Install dependencies
mvn clean install

# Run application
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Wait for startup (30-60 seconds)
# Expected: "Started EducationalPlatformApplication in X seconds"

# Test in another terminal
curl http://localhost:8080/actuator/health
# Expected: {"status":"UP"}
```

### **Step 8: Start Frontend**
```bash
# Navigate to frontend (in new terminal)
cd frontend

# Install dependencies
npm install

# Start development server
ng serve

# Wait for compilation (1-2 minutes)
# Expected: "Application bundle generation complete"

# Open browser
open http://localhost:4200
```

**🎉 Full development environment is ready!**

---

## 🔴 **Enterprise Development Setup**

### **Additional Requirements**
```bash
✅ Kubernetes (minikube or Docker Desktop)
✅ kubectl CLI
✅ Helm 3
✅ Prometheus
✅ Grafana
✅ Elasticsearch (optional)
✅ 8GB RAM recommended
✅ 20GB disk space
```

### **Step 1: Install Kubernetes**

#### **Docker Desktop (Recommended)**
```bash
# Enable Kubernetes in Docker Desktop
# 1. Open Docker Desktop
# 2. Go to Settings → Kubernetes
# 3. Check "Enable Kubernetes"
# 4. Click "Apply & Restart"
# 5. Wait for Kubernetes to start (green indicator)

# Verify
kubectl version --client
kubectl cluster-info
```

#### **Minikube (Alternative)**
```bash
# macOS
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start minikube
minikube start --driver=docker --memory=4096 --cpus=2

# Verify
kubectl get nodes
```

### **Step 2: Install Helm**
```bash
# macOS
brew install helm

# Linux
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
sudo mv linux-amd64/helm /usr/local/bin/helm

# Windows (PowerShell)
# Download from https://github.com/helm/helm/releases
# Extract and add to PATH

# Verify
helm version
```

### **Step 3: Deploy to Kubernetes**
```bash
# Navigate to k8s directory
cd educational-platform/k8s

# Create namespace
kubectl create namespace educational-platform

# Deploy database
kubectl apply -f database/
kubectl wait --for=condition=ready pod -l app=postgres -n educational-platform --timeout=300s

# Deploy Redis
kubectl apply -f redis/
kubectl wait --for=condition=ready pod -l app=redis -n educational-platform --timeout=300s

# Build and deploy application
docker build -t educational-backend:latest ../backend/
docker build -t educational-frontend:latest ../frontend/

# Deploy application
kubectl apply -f application/
kubectl wait --for=condition=ready pod -l app=educational-backend -n educational-platform --timeout=300s

# Check deployment
kubectl get pods -n educational-platform
kubectl get services -n educational-platform
```

### **Step 4: Set Up Monitoring**
```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# Install Grafana (if not included)
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set adminPassword=admin123

# Get Grafana admin password
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Port forward to access services
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &
kubectl port-forward -n monitoring svc/grafana 3000:80 &

# Access monitoring
open http://localhost:9090  # Prometheus
open http://localhost:3000  # Grafana (admin/admin123)
```

### **Step 5: Set Up CI/CD Pipeline**
```bash
# Install GitHub CLI (optional)
brew install gh  # macOS
sudo apt install gh  # Linux

# Create GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/ci-cd.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    - name: Run tests
      run: |
        cd backend
        mvn test
        
  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    - name: Build and push Docker images
      run: |
        docker build -t your-registry/educational-backend:${{ github.sha }} backend/
        docker build -t your-registry/educational-frontend:${{ github.sha }} frontend/
        # Add push commands here
EOF
```

---

## 🔧 **Development Tools (Optional)**

### **VS Code Extensions**
```bash
# Install useful extensions
code --install-extension vscjava.vscode-java-pack
code --install-extension angular.ng-template
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-vscode.docker
```

### **Database Tools**
```bash
# pgAdmin (PostgreSQL GUI)
# macOS
brew install --cask pgadmin4

# Linux
sudo apt install pgadmin4

# DBeaver (Universal database tool)
# Download from https://dbeaver.io/download/

# Connect to your local database:
# Host: localhost
# Port: 5432
# Database: education
# Username: eduuser
# Password: edupass123
```

### **API Testing Tools**
```bash
# Postman
# Download from https://www.postman.com/downloads/

# Or use curl/HTTPie
brew install httpie  # macOS
sudo apt install httpie  # Linux

# Test API endpoints
http GET localhost:8080/api/courses
http POST localhost:8080/api/courses title="Test Course" description="Test"
```

---

## 🧪 **Verify Your Setup**

### **Quick Health Check**
```bash
# Run the verification script
cd educational-platform
./scripts/verify-setup.sh

# Or manually check each component:

# 1. Java
java -version
# Expected: openjdk version "17.x.x"

# 2. Node.js
node --version
npm --version
# Expected: v18.x.x and 9.x.x

# 3. Database
psql -h localhost -U eduuser -d education -c "SELECT version();"
# Expected: PostgreSQL version info

# 4. Redis
redis-cli ping
# Expected: PONG

# 5. Application
curl http://localhost:8080/actuator/health
# Expected: {"status":"UP"}

# 6. Frontend
curl http://localhost:4200
# Expected: HTML content
```

### **Load Sample Data**
```bash
# Load sample courses and students
cd backend
mvn spring-boot:run -Dspring-boot.run.arguments="--load-sample-data=true"

# Or use Docker
docker-compose exec backend java -jar app.jar --load-sample-data=true

# Verify sample data
curl http://localhost:8080/api/courses | jq length
# Expected: Number greater than 0
```

---

## 🔧 **Troubleshooting Common Issues**

### **Port Already in Use**
```bash
# Find process using port
lsof -ti:8080
lsof -ti:4200

# Kill process
kill -9 $(lsof -ti:8080)

# Or use different ports
# Backend: server.port=8081 in application.properties
# Frontend: ng serve --port 4201
```

### **Database Connection Failed**
```bash
# Check PostgreSQL is running
brew services list | grep postgresql  # macOS
sudo systemctl status postgresql      # Linux

# Check connection
psql -h localhost -p 5432 -U eduuser -d education

# Reset password if needed
sudo -u postgres psql -c "ALTER USER eduuser PASSWORD 'edupass123';"
```

### **Out of Memory**
```bash
# Increase Docker memory (Docker Desktop)
# Settings → Resources → Memory: 4GB or more

# Increase Java heap size
export JAVA_OPTS="-Xmx2g -Xms1g"
mvn spring-boot:run

# Increase Node.js memory
export NODE_OPTIONS="--max-old-space-size=4096"
ng serve
```

### **npm Install Fails**
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and package-lock.json
rm -rf node_modules package-lock.json

# Install again
npm install

# If still fails, try yarn
npm install -g yarn
yarn install
```

---

## 🎯 **Development Workflow**

### **Daily Development**
```bash
# Start your day
cd educational-platform

# Pull latest changes
git pull origin main

# Start services
docker-compose up -d db redis  # Database services
cd backend && mvn spring-boot:run -Dspring-boot.run.profiles=dev &
cd ../frontend && ng serve &

# Make changes to code
# Test your changes
# Commit and push
git add .
git commit -m "Your descriptive commit message"
git push
```

### **Testing Workflow**
```bash
# Run backend tests
cd backend
mvn test

# Run frontend tests
cd frontend
ng test

# Run integration tests
mvn integration-test

# Run e2e tests
ng e2e
```

---

## 🎉 **You're All Set!**

**✅ What you've accomplished:**
- 🚀 **Complete development environment** ready for coding
- 🛠️ **All tools installed** and configured properly
- 🔧 **Database and cache** running and accessible
- 📊 **Monitoring stack** (enterprise setup)
- 🧪 **Testing framework** ready for TDD
- 🚀 **CI/CD pipeline** configured (enterprise setup)

**🎯 Your development environment can now:**
- **Run the full application stack** locally
- **Hot reload** for rapid development
- **Debug** both frontend and backend
- **Test** with real databases and services
- **Deploy** to Kubernetes for production-like testing

**🚀 Next steps:**
- **[Quick Demo](./quick-demo.md)** - See the platform in action
- **[Architecture](./architecture.md)** - Understand the system design
- **[Production Deployment](./production-deployment.md)** - Deploy to production

**🎓 Happy coding!** You're ready to build world-class educational technology.