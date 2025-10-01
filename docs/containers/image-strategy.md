# 🐳 Container Images Strategy

Production-ready Docker images with pre-built options for immediate use or educational building experience.

## 🎯 Image Strategy Overview

### Two-Path Approach
1. **🚀 Fast Track**: Use pre-built images from Docker Hub
2. **🎓 Learning Track**: Build images yourself for educational value

### Pre-built Image Repository
All images are published to Docker Hub under the organization:
**`kuberneteslearning/`**

## 📦 Available Pre-built Images

### E-commerce Application
```bash
# Frontend (React)
docker pull kuberneteslearning/ecommerce-frontend:latest
docker pull kuberneteslearning/ecommerce-frontend:v1.0.0

# Backend (Node.js/Express)
docker pull kuberneteslearning/ecommerce-backend:latest
docker pull kuberneteslearning/ecommerce-backend:v1.0.0

# Database (MongoDB with sample data)
docker pull kuberneteslearning/ecommerce-mongodb:latest
```

### Educational Platform
```bash
# Frontend (Angular)
docker pull kuberneteslearning/educational-frontend:latest

# Backend (Java Spring Boot)
docker pull kuberneteslearning/educational-backend:latest

# Database (PostgreSQL with sample data)
docker pull kuberneteslearning/educational-postgres:latest
```

### Medical Care System
```bash
# Frontend (Blazor)
docker pull kuberneteslearning/medical-frontend:latest

# Backend (.NET Core)
docker pull kuberneteslearning/medical-backend:latest

# Database (SQL Server with sample data)
docker pull kuberneteslearning/medical-sqlserver:latest
```

### Task Management App
```bash
# Frontend (Svelte)
docker pull kuberneteslearning/taskmanager-frontend:latest

# Backend (Go)
docker pull kuberneteslearning/taskmanager-backend:latest

# Database (CouchDB with sample data)
docker pull kuberneteslearning/taskmanager-couchdb:latest
```

### Weather App
```bash
# Frontend (Vue.js)
docker pull kuberneteslearning/weather-frontend:latest

# Backend (Python Flask)
docker pull kuberneteslearning/weather-backend:latest

# Cache (Redis with configuration)
docker pull kuberneteslearning/weather-redis:latest
```

### Social Media Platform
```bash
# Frontend (React Native Web)
docker pull kuberneteslearning/social-frontend:latest

# Backend (Ruby on Rails)
docker pull kuberneteslearning/social-backend:latest

# Database (PostgreSQL with sample data)
docker pull kuberneteslearning/social-postgres:latest
```

## 🚀 Quick Start with Pre-built Images

### Option 1: Docker Compose (Fastest)
```bash
# Clone and start any application
git clone https://github.com/your-org/kubernetes-learning-platform
cd ecommerce-app

# Use pre-built images
docker-compose -f docker-compose.prebuilt.yml up -d

# Access application
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend API: http://localhost:5000"
```

### Option 2: Kubernetes Deployment (Production-like)
```bash
# Deploy using pre-built images
kubectl apply -f k8s/quick-deploy/

# Check status
kubectl get pods
kubectl get services

# Access application
kubectl port-forward service/ecommerce-frontend 3000:80
```

## 🎓 Educational Building Experience

### Progressive Building Complexity

#### 🟢 **Level 1: Basic Building**
Learn fundamental Docker concepts:

```dockerfile
# Simple Dockerfile example
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

**Learning Objectives:**
- Understand Docker layers
- Learn COPY vs ADD
- Understand working directories
- Learn about exposed ports

#### 🟡 **Level 2: Multi-stage Builds**
Optimize image size and security:

```dockerfile
# Multi-stage build example
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --from=builder /app/dist ./dist
EXPOSE 3000
USER node
CMD ["npm", "start"]
```

**Learning Objectives:**
- Understand build vs runtime dependencies
- Learn security best practices
- Optimize image size
- Understand user permissions

#### 🔵 **Level 3: Security Hardening**
Implement production-grade security:

```dockerfile
# Security-hardened Dockerfile
FROM node:18-alpine AS builder
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
WORKDIR /app

# Security: Don't run as root
USER nextjs

# Security: Copy only necessary files
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

# Security: Use specific port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["npm", "start"]
```

#### 🔴 **Level 4: Production Optimization**
Enterprise-grade container images:

```dockerfile
# Production-optimized Dockerfile
FROM node:18-alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app

FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci --only=production && npm cache clean --force

FROM base AS builder
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM base AS runner
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Optimize for production
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# Security and performance
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000

# Performance: Precompile assets
RUN npm run cache-warm

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
```

## 📊 Build vs Pre-built Decision Matrix

| Factor | Pre-built Images | Build Yourself |
|--------|------------------|----------------|
| **Speed** | ⚡ Instant deployment | 🐌 5-15 minutes build time |
| **Learning** | 📚 Focus on K8s concepts | 🎓 Learn Docker + K8s |
| **Customization** | 🔒 Limited to provided config | 🛠️ Full control |
| **Storage** | 💾 No local disk usage | 💽 Local cache required |
| **Network** | 🌐 Requires internet | 📡 Offline after build |
| **CI/CD Learning** | ⏭️ Skip to deployment | 🔄 Full pipeline experience |

## 🔧 Switching Between Strategies

### Use Pre-built Images
```bash
# Switch to pre-built mode
cp docker-compose.prebuilt.yml docker-compose.yml
cp k8s/manifests-prebuilt/* k8s/manifests/

# Deploy immediately
docker-compose up -d
# or
kubectl apply -f k8s/manifests/
```

### Switch to Building Mode
```bash
# Switch to build mode
cp docker-compose.build.yml docker-compose.yml
cp k8s/manifests-build/* k8s/manifests/

# Build and deploy
docker-compose up --build -d
# or
docker build -t myapp .
kubectl apply -f k8s/manifests/
```

## 🏗️ Build Automation

### Local Build Scripts
```bash
# Build all application images
./scripts/build/build-all-images.sh

# Build specific application
./scripts/build/build-ecommerce.sh

# Build with specific tag
./scripts/build/build-ecommerce.sh v1.2.0

# Push to your registry
./scripts/build/push-images.sh your-registry.com/yourorg
```

### CI/CD Integration
```yaml
# GitHub Actions example
name: Build and Push Images
on:
  push:
    branches: [main]
    
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build and push
      run: |
        docker build -t ${{ secrets.REGISTRY }}/ecommerce-backend:${{ github.sha }} ./ecommerce-app/backend
        docker push ${{ secrets.REGISTRY }}/ecommerce-backend:${{ github.sha }}
```

## 🔍 Image Security and Scanning

### Built-in Security Features
All pre-built images include:
- ✅ Non-root user execution
- ✅ Minimal base images (Alpine/Distroless)
- ✅ No known vulnerabilities (scanned with Trivy)
- ✅ Read-only root filesystem capability
- ✅ Health checks included
- ✅ Resource limits defined

### Security Scanning
```bash
# Scan pre-built images
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image kuberneteslearning/ecommerce-backend:latest

# Scan your built images
trivy image myapp:latest

# CI/CD security scanning
docker run --rm -v $PWD:/workspace aquasec/trivy fs /workspace
```

## 📋 Image Management Best Practices

### Tagging Strategy
```bash
# Semantic versioning
kuberneteslearning/ecommerce-backend:v1.2.3    # Specific version
kuberneteslearning/ecommerce-backend:v1.2      # Minor version
kuberneteslearning/ecommerce-backend:v1        # Major version
kuberneteslearning/ecommerce-backend:latest    # Latest stable

# Environment-specific tags
kuberneteslearning/ecommerce-backend:dev-abc123
kuberneteslearning/ecommerce-backend:staging-v1.2.3
kuberneteslearning/ecommerce-backend:prod-v1.2.3
```

### Image Size Optimization
```bash
# Check image sizes
docker images kuberneteslearning/*

# Analyze layers
docker history kuberneteslearning/ecommerce-backend:latest

# Use dive for detailed analysis
dive kuberneteslearning/ecommerce-backend:latest
```

### Registry Configuration
```yaml
# Use different registries based on needs
registries:
  docker_hub:
    url: "docker.io"
    public: true
    use_case: "Learning and development"
    
  aws_ecr:
    url: "123456789.dkr.ecr.us-west-2.amazonaws.com"
    private: true
    use_case: "Production deployments"
    
  harbor:
    url: "harbor.company.com"
    private: true
    use_case: "Enterprise environments"
```

## 🎯 Learning Paths by Goal

### Path 1: Kubernetes Focus (Use Pre-built)
**Goal**: Master Kubernetes quickly
```bash
# Skip building, focus on K8s
1. Use pre-built images
2. Learn deployments, services, ingress
3. Master advanced K8s features
4. Practice cluster operations
```

### Path 2: Full DevOps (Build Everything)
**Goal**: Complete DevOps skill development
```bash
# Full experience
1. Build images from scratch
2. Implement CI/CD pipelines
3. Add security scanning
4. Deploy to production
```

### Path 3: Security Focus (Harden Images)
**Goal**: Master container security
```bash
# Security-first approach
1. Start with pre-built images
2. Analyze security posture
3. Rebuild with hardening
4. Implement security scanning
```

## 🆘 Troubleshooting

### Common Build Issues
```bash
# Build failing due to dependencies
# Solution: Check package.json/requirements.txt

# Image too large
# Solution: Use multi-stage builds and .dockerignore

# Permission issues
# Solution: Set correct USER in Dockerfile

# Network issues during build
# Solution: Configure proxy settings
```

### Runtime Issues
```bash
# Container exits immediately
docker logs container-name

# Permission denied errors
docker exec -it container-name whoami

# Health check failures
docker exec -it container-name curl localhost:3000/health
```

---

**Choose your learning path:** Start with pre-built images for quick results, or dive into building for complete understanding. Both paths lead to Kubernetes mastery! 🚀