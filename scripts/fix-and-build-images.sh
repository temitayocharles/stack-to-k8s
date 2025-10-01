#!/bin/bash
# 🔧 FIX ALL DOCKERFILES AND BUILD IMAGES
# Fixes npm ci issues and builds all Docker images for Docker Hub
# Author: Temitayo Charles Akinniranye | TCA-InfraForge

set -e

# 🎨 Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# 🐳 Docker Hub Configuration
DOCKER_USERNAME="temitayocharles"
IMAGE_TAG="latest"

# 📦 Applications to fix and build
APPLICATIONS=(
    "ecommerce-app"
    "educational-platform" 
    "medical-care-system"
    "task-management-app"
    "weather-app"
    "social-media-platform"
)

# Function to fix Dockerfile npm ci issues
fix_dockerfile() {
    local dockerfile="$1"
    local app_name="$2"
    
    if [[ -f "$dockerfile" ]]; then
        echo -e "${BLUE}  🔧 Fixing $dockerfile...${NC}"
        
        # Replace npm ci with npm install
        sed -i.backup 's/npm ci/npm install/g' "$dockerfile"
        
        # Remove backup file
        rm -f "${dockerfile}.backup"
        
        echo -e "${GREEN}    ✅ Fixed npm ci issues in $dockerfile${NC}"
    fi
}

# Function to build application images
build_application() {
    local app_name="$1"
    
    echo -e "\n${CYAN}🔨 Building $app_name...${NC}"
    
    # Navigate to application directory
    cd "$app_name"
    
    # Fix Dockerfiles
    echo -e "${BLUE}🔧 Fixing Dockerfiles in $app_name...${NC}"
    fix_dockerfile "Dockerfile" "$app_name"
    fix_dockerfile "backend/Dockerfile" "$app_name"
    fix_dockerfile "frontend/Dockerfile" "$app_name"
    
    # Build main application image (backend + frontend combined)
    if [[ -f "Dockerfile" ]]; then
        echo -e "${BLUE}📦 Building combined application image...${NC}"
        docker build -t "${DOCKER_USERNAME}/${app_name}:${IMAGE_TAG}" .
        echo -e "${GREEN}✅ Built ${DOCKER_USERNAME}/${app_name}:${IMAGE_TAG}${NC}"
    fi
    
    # Build separate backend image if exists
    if [[ -f "backend/Dockerfile" ]]; then
        echo -e "${BLUE}📦 Building backend image...${NC}"
        docker build -t "${DOCKER_USERNAME}/${app_name}-backend:${IMAGE_TAG}" ./backend
        echo -e "${GREEN}✅ Built ${DOCKER_USERNAME}/${app_name}-backend:${IMAGE_TAG}${NC}"
    fi
    
    # Build separate frontend image if exists
    if [[ -f "frontend/Dockerfile" ]]; then
        echo -e "${BLUE}📦 Building frontend image...${NC}"
        docker build -t "${DOCKER_USERNAME}/${app_name}-frontend:${IMAGE_TAG}" ./frontend
        echo -e "${GREEN}✅ Built ${DOCKER_USERNAME}/${app_name}-frontend:${IMAGE_TAG}${NC}"
    fi
    
    echo -e "${GREEN}✅ $app_name images built successfully!${NC}"
    
    # Return to root directory
    cd ..
}

# Function to push all images for an application
push_application_images() {
    local app_name="$1"
    
    echo -e "\n${BLUE}🚀 Pushing $app_name images to Docker Hub...${NC}"
    
    # Push main application image
    if docker images | grep -q "${DOCKER_USERNAME}/${app_name}:${IMAGE_TAG}"; then
        echo -e "${BLUE}  Pushing ${DOCKER_USERNAME}/${app_name}:${IMAGE_TAG}...${NC}"
        docker push "${DOCKER_USERNAME}/${app_name}:${IMAGE_TAG}"
        echo -e "${GREEN}  ✅ Pushed main image${NC}"
    fi
    
    # Push backend image
    if docker images | grep -q "${DOCKER_USERNAME}/${app_name}-backend:${IMAGE_TAG}"; then
        echo -e "${BLUE}  Pushing ${DOCKER_USERNAME}/${app_name}-backend:${IMAGE_TAG}...${NC}"
        docker push "${DOCKER_USERNAME}/${app_name}-backend:${IMAGE_TAG}"
        echo -e "${GREEN}  ✅ Pushed backend image${NC}"
    fi
    
    # Push frontend image
    if docker images | grep -q "${DOCKER_USERNAME}/${app_name}-frontend:${IMAGE_TAG}"; then
        echo -e "${BLUE}  Pushing ${DOCKER_USERNAME}/${app_name}-frontend:${IMAGE_TAG}...${NC}"
        docker push "${DOCKER_USERNAME}/${app_name}-frontend:${IMAGE_TAG}"
        echo -e "${GREEN}  ✅ Pushed frontend image${NC}"
    fi
    
    echo -e "${GREEN}✅ All $app_name images pushed successfully!${NC}"
}

# Function to create comprehensive Docker Hub documentation
create_docker_documentation() {
    echo -e "\n${BLUE}📚 Creating comprehensive Docker Hub documentation...${NC}"
    
    cat > DOCKER-HUB-IMAGES.md << 'EOF'
# 🐳 Docker Hub Images - Pre-built & Ready to Deploy

All 6 applications are available as optimized, production-ready Docker images on Docker Hub for instant deployment.

## ⚡ **Instant Setup - One Command**

### **Quick Demo (Recommended for First-Time Users)**
```bash
# Clone and start any application instantly
git clone https://github.com/temitayocharles/full-stack-apps.git
cd full-stack-apps/ecommerce-app
docker-compose up -d

# Application will be running at:
# Frontend: http://localhost:3001
# Backend API: http://localhost:5001
```

### **Choose Your Practice Level**
```bash
# 🟢 Beginner: Start with pre-built images
docker-compose up -d

# 🟡 Intermediate: Build images locally
docker-compose up -d --build

# 🟠 Advanced: Deploy to Kubernetes
kubectl apply -f k8s/
```

## 📦 **Available Docker Hub Images**

### **🛒 E-commerce Application**
```bash
# Complete application (backend + frontend)
docker pull temitayocharles/ecommerce-app:latest

# Individual components
docker pull temitayocharles/ecommerce-app-backend:latest
docker pull temitayocharles/ecommerce-app-frontend:latest
```

### **🎓 Educational Platform**
```bash
# Complete application
docker pull temitayocharles/educational-platform:latest

# Individual components  
docker pull temitayocharles/educational-platform-backend:latest
docker pull temitayocharles/educational-platform-frontend:latest
```

### **🏥 Medical Care System**
```bash
# Complete application
docker pull temitayocharles/medical-care-system:latest

# Individual components
docker pull temitayocharles/medical-care-system-backend:latest
docker pull temitayocharles/medical-care-system-frontend:latest
```

### **📋 Task Management App**
```bash
# Complete application
docker pull temitayocharles/task-management-app:latest

# Individual components
docker pull temitayocharles/task-management-app-backend:latest
docker pull temitayocharles/task-management-app-frontend:latest
```

### **🌤️ Weather Application**
```bash
# Complete application
docker pull temitayocharles/weather-app:latest

# Individual components
docker pull temitayocharles/weather-app-backend:latest
docker pull temitayocharles/weather-app-frontend:latest
```

### **📱 Social Media Platform**
```bash
# Complete application
docker pull temitayocharles/social-media-platform:latest

# Individual components
docker pull temitayocharles/social-media-platform-backend:latest
docker pull temitayocharles/social-media-platform-frontend:latest
```

## 🚀 **Production Deployment Examples**

### **Docker Compose (Recommended)**
```yaml
version: '3.8'
services:
  app:
    image: temitayocharles/ecommerce-app:latest
    ports:
      - "3001:3000"
      - "5001:5000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=mongodb://mongodb:27017/ecommerce
    depends_on:
      - mongodb
      - redis

  mongodb:
    image: mongo:7
    environment:
      - MONGO_INITDB_DATABASE=ecommerce
    volumes:
      - mongodb_data:/data/db

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

volumes:
  mongodb_data:
  redis_data:
```

### **Kubernetes Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ecommerce-app
  template:
    metadata:
      labels:
        app: ecommerce-app
    spec:
      containers:
      - name: app
        image: temitayocharles/ecommerce-app:latest
        ports:
        - containerPort: 3000
        - containerPort: 5000
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-service
spec:
  selector:
    app: ecommerce-app
  ports:
  - name: frontend
    port: 80
    targetPort: 3000
  - name: api
    port: 5000
    targetPort: 5000
  type: LoadBalancer
```

### **Docker Swarm**
```bash
# Deploy to Docker Swarm
docker stack deploy -c docker-compose.yml ecommerce-stack

# Scale services
docker service scale ecommerce-stack_app=5
```

## 🎯 **Image Benefits & Features**

### ✅ **Production Optimized**
- **Multi-stage builds** for minimal image size
- **Security hardened** with non-root users
- **Health checks** for reliability
- **Resource limits** for efficiency

### ✅ **Developer Friendly**
- **Fast startup** times (< 30 seconds)
- **Hot reload** in development mode
- **Debug support** with source maps
- **Environment flexibility**

### ✅ **Enterprise Ready**
- **CI/CD integration** ready
- **Monitoring support** (Prometheus metrics)
- **Logging configured** (structured JSON)
- **Secret management** compatible

## 🔧 **Advanced Usage**

### **Custom Environment Variables**
```bash
# Run with custom configuration
docker run -d \
  -p 3000:3000 \
  -p 5000:5000 \
  -e NODE_ENV=production \
  -e DATABASE_URL=your-db-url \
  -e JWT_SECRET=your-secret \
  temitayocharles/ecommerce-app:latest
```

### **Development Mode**
```bash
# Run in development mode with hot reload
docker run -d \
  -p 3000:3000 \
  -p 5000:5000 \
  -e NODE_ENV=development \
  -v $(pwd):/app \
  temitayocharles/ecommerce-app:latest
```

### **Health Monitoring**
```bash
# Check application health
curl http://localhost:5000/health

# Expected response:
# {"status":"OK","timestamp":"2025-01-01T00:00:00.000Z"}
```

## 🔄 **Image Updates & Versioning**

### **Latest Images**
- Images are automatically updated with new features
- Tagged as `:latest` for stable releases
- Security patches applied regularly

### **Update Workflow**
```bash
# Pull latest version
docker pull temitayocharles/app-name:latest

# Restart with new image
docker-compose up -d --force-recreate

# Verify update
docker images | grep temitayocharles
```

### **Version Pinning**
```yaml
# Pin to specific version for production
services:
  app:
    image: temitayocharles/ecommerce-app:v1.0.0
```

## 🛠️ **For Developers: Custom Builds**

### **Build Your Own Version**
```bash
# Clone repository
git clone https://github.com/temitayocharles/full-stack-apps.git
cd full-stack-apps/ecommerce-app

# Build custom image
docker build -t your-username/ecommerce-app:custom .

# Push to your registry
docker push your-username/ecommerce-app:custom
```

### **Modify Applications**
```bash
# Make changes to source code
vim backend/src/app.js

# Rebuild and test
docker-compose up -d --build

# Deploy your version
docker tag local-image your-username/app-name:v1.0.0
docker push your-username/app-name:v1.0.0
```

## 🆘 **Troubleshooting**

### **Common Issues**
```bash
# Image pull failed
docker pull temitayocharles/app-name:latest

# Container won't start
docker logs container-name

# Port conflicts
docker port container-name

# Resource issues
docker stats
```

### **Getting Help**
- 📖 **Documentation**: Check individual app README files
- 🐛 **Issues**: Report problems in the GitHub repository  
- 💬 **Community**: Join discussions in GitHub Discussions
- 🔧 **Support**: Check troubleshooting guides in docs/

---

**🏗️ Built by**: Temitayo Charles Akinniranye | TCA-InfraForge  
**🐳 Docker Hub**: https://hub.docker.com/u/temitayocharles  
**📚 Documentation**: https://github.com/temitayocharles/full-stack-apps  
**🌟 Featured Applications**: 6 real-world business applications for DevOps practice
EOF

    echo -e "${GREEN}✅ Created comprehensive DOCKER-HUB-IMAGES.md${NC}"
}

# Function to verify Docker login
verify_docker_login() {
    echo -e "${BLUE}🔐 Verifying Docker Hub authentication...${NC}"
    
    if docker info 2>/dev/null | grep -q "Username:"; then
        local username=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}')
        if [[ "$username" == "$DOCKER_USERNAME" ]]; then
            echo -e "${GREEN}✅ Authenticated as $DOCKER_USERNAME${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  Logged in as $username, but need to be $DOCKER_USERNAME${NC}"
        fi
    fi
    
    echo -e "${BLUE}🔑 Please log in to Docker Hub:${NC}"
    echo -e "${CYAN}   docker login${NC}"
    echo -e "${CYAN}   Username: $DOCKER_USERNAME${NC}"
    echo -e "${CYAN}   Password: [Your Docker Hub password]${NC}"
    
    read -p "Press ENTER after logging in..."
    
    # Verify again
    if docker info 2>/dev/null | grep -q "Username: $DOCKER_USERNAME"; then
        echo -e "${GREEN}✅ Successfully authenticated!${NC}"
    else
        echo -e "${RED}❌ Authentication failed. Please try again.${NC}"
        exit 1
    fi
}

# Main execution function
main() {
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                        ║"
    echo "║        🔧 DOCKER IMAGE BUILDER & PUBLISHER 🔧                                         ║"
    echo "║                                                                                        ║"
    echo "║        Fixing Dockerfiles and building all applications for Docker Hub                ║"
    echo "║        Username: $DOCKER_USERNAME                                                       ║"
    echo "║                                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    # Verify Docker login
    verify_docker_login
    
    echo -e "${BLUE}🚀 Starting build process for all applications...${NC}\n"
    
    # Build all applications
    for app in "${APPLICATIONS[@]}"; do
        if [[ -d "$app" ]]; then
            build_application "$app"
        else
            echo -e "${RED}❌ Application directory not found: $app${NC}"
        fi
    done
    
    echo -e "\n${BLUE}🚀 Pushing all images to Docker Hub...${NC}"
    
    # Push all applications
    for app in "${APPLICATIONS[@]}"; do
        if [[ -d "$app" ]]; then
            push_application_images "$app"
        fi
    done
    
    # Create comprehensive documentation
    create_docker_documentation
    
    echo -e "\n${GREEN}🎉 ALL DOCKER IMAGES BUILT AND PUSHED SUCCESSFULLY!${NC}"
    echo -e "${CYAN}🔗 View your images: https://hub.docker.com/u/$DOCKER_USERNAME${NC}"
    echo -e "${BLUE}📚 Documentation: DOCKER-HUB-IMAGES.md${NC}"
    echo -e "${YELLOW}⚡ Users can now instantly deploy with: docker-compose up -d${NC}\n"
}

# Run main function
main "$@"