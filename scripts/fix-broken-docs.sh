#!/bin/bash
# 🔧 COMPREHENSIVE DOCUMENTATION LINK FIXER
# Scans entire workspace for broken links and missing documentation files

echo "🔍 SCANNING WORKSPACE FOR BROKEN DOCUMENTATION LINKS..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BROKEN_LINKS=0
MISSING_FILES=0
FIXED_LINKS=0
CREATED_FILES=0

# Function to check if a file exists relative to the current markdown file
check_relative_link() {
    local md_file="$1"
    local link="$2"
    local md_dir=$(dirname "$md_file")
    
    # Handle relative paths
    if [[ "$link" == ./* ]] || [[ "$link" == ../* ]]; then
        local full_path="$md_dir/$link"
        if [ ! -f "$full_path" ]; then
            echo -e "${RED}❌ BROKEN LINK${NC} in $md_file: $link"
            echo "   Expected file: $full_path"
            ((BROKEN_LINKS++))
            return 1
        fi
    fi
    return 0
}

# Function to create missing standard documentation files
create_missing_docs() {
    local app_dir="$1"
    local app_name=$(basename "$app_dir")
    
    echo -e "${BLUE}📝 Creating missing documentation for $app_name...${NC}"
    
    # Standard docs that every application should have
    local required_docs=(
        "docs/quick-start.md"
        "docs/commands.md"
        "docs/troubleshooting.md"
        "docs/architecture.md"
        "docs/deployment.md"
        "docs/kubernetes-guide.md"
        "docs/helm-guide.md"
        "docs/kustomize-guide.md"
    )
    
    for doc in "${required_docs[@]}"; do
        local doc_path="$app_dir/$doc"
        if [ ! -f "$doc_path" ]; then
            echo -e "${YELLOW}📄 Creating missing: $doc${NC}"
            mkdir -p "$(dirname "$doc_path")"
            
            case "$doc" in
                "docs/quick-start.md")
                    create_quick_start_template "$doc_path" "$app_name"
                    ;;
                "docs/commands.md")
                    create_commands_template "$doc_path" "$app_name"
                    ;;
                "docs/troubleshooting.md")
                    create_troubleshooting_template "$doc_path" "$app_name"
                    ;;
                "docs/architecture.md")
                    create_architecture_template "$doc_path" "$app_name"
                    ;;
                "docs/deployment.md")
                    create_deployment_template "$doc_path" "$app_name"
                    ;;
                "docs/kubernetes-guide.md")
                    create_kubernetes_template "$doc_path" "$app_name"
                    ;;
                "docs/helm-guide.md")
                    create_helm_template "$doc_path" "$app_name"
                    ;;
                "docs/kustomize-guide.md")
                    create_kustomize_template "$doc_path" "$app_name"
                    ;;
            esac
            ((CREATED_FILES++))
        fi
    done
}

# Template functions for creating missing documentation
create_quick_start_template() {
    local file_path="$1"
    local app_name="$2"
    cat > "$file_path" << EOF
# 🚀 Quick Start Guide - $app_name

## 🎯 What You'll Learn (2 minutes)
- Deploy $app_name locally with Docker
- Access the application in your browser
- Test basic functionality

## 📋 Before You Start (1 minute)
- [ ] Docker Desktop installed and running
- [ ] Git repository cloned
- [ ] 10 minutes of time

## 🚀 Step-by-Step Deployment (5 minutes)

### Step 1: Navigate to Application (30 seconds)
\`\`\`bash
cd $app_name
\`\`\`

### Step 2: Start All Services (2 minutes)
\`\`\`bash
docker-compose up -d
\`\`\`
**You will see:** Container startup logs

### Step 3: Verify Services Are Running (1 minute)
\`\`\`bash
docker-compose ps
\`\`\`
**Expected result:** All services showing "Up" status

### Step 4: Access Application (1 minute)
Open your browser and go to:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000/health

**You should see:** Application running without errors

## ✅ Verify Success (30 seconds)
- [ ] Frontend loads in browser
- [ ] Backend health check returns "OK"
- [ ] No error messages in logs

## 🆘 Need Help?
- Check [troubleshooting guide](troubleshooting.md)
- View [common commands](commands.md)
- See [architecture overview](architecture.md)

**Next:** Try [Kubernetes deployment](kubernetes-guide.md)
EOF
}

create_commands_template() {
    local file_path="$1"
    local app_name="$2"
    cat > "$file_path" << EOF
# 🔧 Commands Reference - $app_name

## 🐳 Docker Commands

### Start Services
\`\`\`bash
# Start all services in background
docker-compose up -d

# Start and view logs
docker-compose up

# Start specific service
docker-compose up -d frontend
\`\`\`

### Stop Services
\`\`\`bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop specific service
docker-compose stop frontend
\`\`\`

### View Status and Logs
\`\`\`bash
# Check service status
docker-compose ps

# View logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View specific service logs
docker-compose logs frontend
\`\`\`

### Development Commands
\`\`\`bash
# Rebuild containers
docker-compose build

# Rebuild without cache
docker-compose build --no-cache

# Pull latest images
docker-compose pull
\`\`\`

## ☸️ Kubernetes Commands

### Deploy Application
\`\`\`bash
# Apply all manifests
kubectl apply -f k8s/

# Deploy to specific namespace
kubectl apply -f k8s/ -n $app_name
\`\`\`

### Check Status
\`\`\`bash
# View pods
kubectl get pods

# View services
kubectl get svc

# View deployments
kubectl get deployments
\`\`\`

### Troubleshooting
\`\`\`bash
# Describe pod for details
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Execute into pod
kubectl exec -it <pod-name> -- /bin/bash
\`\`\`

## 🔧 Maintenance Commands

### Cleanup
\`\`\`bash
# Remove all containers and volumes
docker-compose down -v --remove-orphans

# Clean Docker system
docker system prune -f

# Remove unused images
docker image prune -f
\`\`\`

### Health Checks
\`\`\`bash
# Test backend health
curl http://localhost:5000/health

# Test frontend accessibility
curl http://localhost:3000

# Check database connection
docker-compose exec backend npm run db:check
\`\`\`

**Need help?** Check [troubleshooting guide](troubleshooting.md)
EOF
}

create_troubleshooting_template() {
    local file_path="$1"
    local app_name="$2"
    cat > "$file_path" << EOF
# 🔧 Troubleshooting Guide - $app_name

## 🚨 Common Issues & Solutions

### Issue 1: Containers Won't Start

**Symptoms:**
- \`docker-compose up\` fails
- Error messages about ports or dependencies

**Solutions:**
1. **Check if ports are in use:**
   \`\`\`bash
   # Check what's using port 3000
   lsof -i :3000
   \`\`\`

2. **Stop conflicting services:**
   \`\`\`bash
   # Kill process using port
   kill -9 <PID>
   \`\`\`

3. **Clean Docker state:**
   \`\`\`bash
   docker-compose down -v
   docker system prune -f
   docker-compose up -d
   \`\`\`

### Issue 2: Frontend Not Loading

**Symptoms:**
- Browser shows "This site can't be reached"
- Connection timeout errors

**Solutions:**
1. **Verify frontend container is running:**
   \`\`\`bash
   docker-compose ps frontend
   \`\`\`

2. **Check frontend logs:**
   \`\`\`bash
   docker-compose logs frontend
   \`\`\`

3. **Restart frontend service:**
   \`\`\`bash
   docker-compose restart frontend
   \`\`\`

### Issue 3: Backend API Errors

**Symptoms:**
- API returns 500 errors
- Database connection failures

**Solutions:**
1. **Check backend health:**
   \`\`\`bash
   curl http://localhost:5000/health
   \`\`\`

2. **Verify database is running:**
   \`\`\`bash
   docker-compose ps database
   \`\`\`

3. **Check environment variables:**
   \`\`\`bash
   docker-compose exec backend env | grep -E "(DB_|DATABASE_)"
   \`\`\`

### Issue 4: Database Connection Problems

**Symptoms:**
- "Connection refused" errors
- Database timeout messages

**Solutions:**
1. **Wait for database startup:**
   \`\`\`bash
   # Database can take 30-60 seconds to be ready
   docker-compose logs database
   \`\`\`

2. **Restart with proper order:**
   \`\`\`bash
   docker-compose down
   docker-compose up database
   # Wait 30 seconds
   docker-compose up
   \`\`\`

3. **Reset database:**
   \`\`\`bash
   docker-compose down -v
   docker-compose up -d
   \`\`\`

## 🔍 Diagnostic Commands

### Check All Service Health
\`\`\`bash
# Quick health check script
echo "=== Service Status ==="
docker-compose ps

echo "=== Frontend Health ==="
curl -s http://localhost:3000 > /dev/null && echo "✅ OK" || echo "❌ FAIL"

echo "=== Backend Health ==="
curl -s http://localhost:5000/health && echo "✅ OK" || echo "❌ FAIL"
\`\`\`

### View All Logs
\`\`\`bash
# See all service logs
docker-compose logs --tail=50

# Follow logs in real-time
docker-compose logs -f
\`\`\`

### Resource Usage
\`\`\`bash
# Check container resource usage
docker stats

# Check system resources
docker system df
\`\`\`

## 🆘 Still Need Help?

1. **Check the logs first:**
   \`\`\`bash
   docker-compose logs [service-name]
   \`\`\`

2. **Try a clean restart:**
   \`\`\`bash
   docker-compose down -v
   docker-compose up -d
   \`\`\`

3. **Verify your environment:**
   - Docker Desktop running?
   - Sufficient disk space?
   - No port conflicts?

4. **Reset everything:**
   \`\`\`bash
   docker-compose down -v --remove-orphans
   docker system prune -f
   docker-compose build --no-cache
   docker-compose up -d
   \`\`\`

**Next:** See [commands reference](commands.md) for more utilities
EOF
}

create_architecture_template() {
    local file_path="$1"
    local app_name="$2"
    cat > "$file_path" << EOF
# 🏗️ Architecture Overview - $app_name

## 🎯 System Architecture (High Level)

\`\`\`
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │────│   Backend   │────│  Database   │
│             │    │             │    │             │
│ React/Vue/  │    │ Node.js/    │    │ MongoDB/    │
│ Angular     │    │ Python/Go   │    │ PostgreSQL  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                   ┌─────────────┐
                   │   Cache     │
                   │   Redis     │
                   └─────────────┘
\`\`\`

## 📦 Component Details

### Frontend Service
- **Technology**: React/Vue.js/Angular
- **Port**: 3000
- **Purpose**: User interface and client-side logic
- **Dependencies**: Backend API

### Backend Service
- **Technology**: Node.js/Python/Go/.NET
- **Port**: 5000
- **Purpose**: Business logic and API endpoints
- **Dependencies**: Database, Cache

### Database Service
- **Technology**: MongoDB/PostgreSQL/SQL Server
- **Port**: 27017/5432/1433
- **Purpose**: Data persistence and storage
- **Dependencies**: None

### Cache Service (Optional)
- **Technology**: Redis
- **Port**: 6379
- **Purpose**: Session storage and caching
- **Dependencies**: None

## 🔄 Data Flow

1. **User Request**: Browser → Frontend
2. **API Call**: Frontend → Backend
3. **Data Query**: Backend → Database
4. **Cache Check**: Backend → Redis (if needed)
5. **Response**: Database → Backend → Frontend → Browser

## 🛡️ Security Considerations

- **Authentication**: JWT tokens
- **Authorization**: Role-based access control
- **Data Encryption**: HTTPS in production
- **Input Validation**: All user inputs sanitized
- **Environment Variables**: Secrets not hardcoded

## 🚀 Deployment Architecture

### Docker Compose (Local Development)
\`\`\`
┌─────────────────────────────────────────┐
│            Docker Host                  │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │Frontend │ │Backend  │ │Database │   │
│  │Container│ │Container│ │Container│   │
│  └─────────┘ └─────────┘ └─────────┘   │
│       │           │           │        │
│       └───────────┼───────────┘        │
│                   │                    │
│           ┌─────────────┐               │
│           │   Network   │               │
│           │   Bridge    │               │
│           └─────────────┘               │
└─────────────────────────────────────────┘
\`\`\`

### Kubernetes (Production)
\`\`\`
┌─────────────────────────────────────────┐
│            Kubernetes Cluster           │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │Frontend │ │Backend  │ │Database │   │
│  │  Pod    │ │  Pod    │ │  Pod    │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│       │           │           │        │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │Service  │ │Service  │ │Service  │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│              │                         │
│        ┌─────────────┐                 │
│        │   Ingress   │                 │
│        └─────────────┘                 │
└─────────────────────────────────────────┘
\`\`\`

## 📊 Performance Characteristics

- **Response Time**: < 200ms for API calls
- **Throughput**: 1000+ requests/second
- **Availability**: 99.9% uptime target
- **Scalability**: Horizontal scaling supported

## 🔧 Development Workflow

1. **Local Development**: Docker Compose
2. **Testing**: Automated test suites
3. **Staging**: Kubernetes deployment
4. **Production**: Kubernetes with monitoring

**Next:** See [deployment guide](deployment.md) for setup instructions
EOF
}

create_deployment_template() {
    local file_path="$1"
    local app_name="$2"
    cat > "$file_path" << EOF
# 🚀 Deployment Guide - $app_name

## 🎯 Deployment Options

Choose your deployment method based on your needs:

| Method | Difficulty | Best For |
|--------|------------|----------|
| [Docker Compose](#docker-compose) | ⭐ Beginner | Local development |
| [Kubernetes YAML](#kubernetes-yaml) | ⭐⭐ Intermediate | Learning K8s |
| [Helm Charts](#helm-charts) | ⭐⭐⭐ Advanced | Production |

## 🐳 Docker Compose Deployment

### Prerequisites (2 minutes)
- [ ] Docker Desktop installed
- [ ] Git repository cloned
- [ ] Required environment variables set

### Quick Deployment (5 minutes)
\`\`\`bash
# Navigate to application
cd $app_name

# Start all services
docker-compose up -d

# Verify deployment
docker-compose ps
\`\`\`

**Access Points:**
- Frontend: http://localhost:3000
- Backend: http://localhost:5000
- Database: localhost:5432 (internal)

### Environment Configuration
Create \`.env\` file:
\`\`\`env
NODE_ENV=development
DATABASE_URL=postgresql://user:password@database:5432/app
REDIS_URL=redis://cache:6379
JWT_SECRET=your-secret-key
\`\`\`

## ☸️ Kubernetes YAML Deployment

### Prerequisites (5 minutes)
- [ ] Kubernetes cluster running
- [ ] kubectl configured
- [ ] Docker images built

### Deployment Steps (10 minutes)

#### Step 1: Create Namespace
\`\`\`bash
kubectl create namespace $app_name
\`\`\`

#### Step 2: Apply Secrets
\`\`\`bash
kubectl apply -f k8s/secrets.yaml -n $app_name
\`\`\`

#### Step 3: Deploy Database
\`\`\`bash
kubectl apply -f k8s/database/ -n $app_name
\`\`\`

#### Step 4: Deploy Backend
\`\`\`bash
kubectl apply -f k8s/backend/ -n $app_name
\`\`\`

#### Step 5: Deploy Frontend
\`\`\`bash
kubectl apply -f k8s/frontend/ -n $app_name
\`\`\`

#### Step 6: Verify Deployment
\`\`\`bash
kubectl get pods -n $app_name
kubectl get svc -n $app_name
\`\`\`

### Access Application
\`\`\`bash
# Port forward to access locally
kubectl port-forward svc/frontend 3000:3000 -n $app_name
\`\`\`

## ⚓ Helm Charts Deployment

### Prerequisites (5 minutes)
- [ ] Helm 3.x installed
- [ ] Kubernetes cluster running
- [ ] Values file configured

### Quick Deployment (3 minutes)
\`\`\`bash
# Add repository (if external)
helm repo add $app_name ./helm

# Install application
helm install $app_name ./helm/$app_name

# Check status
helm status $app_name
\`\`\`

### Custom Values
Create \`values.yaml\`:
\`\`\`yaml
image:
  tag: "latest"
  pullPolicy: IfNotPresent

replicaCount: 3

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: true
  host: $app_name.example.com

resources:
  limits:
    memory: 512Mi
    cpu: 500m
\`\`\`

### Deploy with Custom Values
\`\`\`bash
helm install $app_name ./helm/$app_name -f values.yaml
\`\`\`

## 🔧 Post-Deployment Verification

### Health Checks
\`\`\`bash
# Test frontend
curl http://localhost:3000

# Test backend health
curl http://localhost:5000/health

# Test database connectivity
kubectl exec -it pod/backend -- npm run db:test
\`\`\`

### Monitoring Setup
\`\`\`bash
# Deploy monitoring stack
kubectl apply -f k8s/monitoring/

# Access Grafana
kubectl port-forward svc/grafana 3001:3000
\`\`\`

## 🚨 Troubleshooting

### Common Issues

#### Pods Stuck in Pending
\`\`\`bash
# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name>
\`\`\`

#### Services Not Accessible
\`\`\`bash
# Check service endpoints
kubectl get endpoints

# Test internal connectivity
kubectl run test --image=busybox -it --rm -- wget -qO- http://service-name
\`\`\`

#### Image Pull Errors
\`\`\`bash
# Check image exists
docker pull <image-name>

# Verify image registry access
kubectl describe pod <pod-name>
\`\`\`

## 🎯 Production Deployment

### AWS EKS Deployment
See [AWS deployment guide](aws-deployment.md)

### Security Hardening
- Network policies enabled
- RBAC configured
- Secrets encrypted
- Image scanning enabled

### Monitoring & Alerts
- Prometheus metrics
- Grafana dashboards
- AlertManager rules
- Log aggregation

**Next:** Check [troubleshooting guide](troubleshooting.md) if you encounter issues
EOF
}

create_kubernetes_template() {
    local file_path="$1"
    local app_name="$2"
    cat > "$file_path" << EOF
# ☸️ Kubernetes Guide - $app_name

## 🎯 What You'll Learn (5 minutes)
- Deploy $app_name to Kubernetes
- Understand basic Kubernetes concepts
- Manage application lifecycle with kubectl

## 📋 Prerequisites (3 minutes)
- [ ] Docker Compose deployment working
- [ ] Kubernetes cluster running (Docker Desktop/Minikube/EKS)
- [ ] kubectl installed and configured
- [ ] Basic understanding of containers

## 🚀 Step-by-Step Kubernetes Deployment

### Step 1: Understand Kubernetes Concepts (5 minutes)

**What is Kubernetes?**
Think of Kubernetes like a smart manager for your containers:
- **Pods**: Your containers running together
- **Deployments**: Instructions for running multiple copies
- **Services**: Network access to your pods
- **ConfigMaps**: Configuration files
- **Secrets**: Sensitive information

### Step 2: Prepare Docker Images (3 minutes)
\`\`\`bash
# Build images (if not done already)
docker build -t $app_name-frontend ./frontend
docker build -t $app_name-backend ./backend

# Tag for registry (optional)
docker tag $app_name-frontend:latest your-registry/$app_name-frontend:latest
\`\`\`

### Step 3: Create Namespace (1 minute)
\`\`\`bash
# Create dedicated namespace
kubectl create namespace $app_name

# Set as default for convenience
kubectl config set-context --current --namespace=$app_name
\`\`\`
**You will see:** "namespace/$app_name created"

### Step 4: Deploy Database First (5 minutes)
\`\`\`bash
# Deploy database
kubectl apply -f k8s/database/

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=database --timeout=300s
\`\`\`
**You will see:** Database pod in "Running" status

### Step 5: Deploy Backend (3 minutes)
\`\`\`bash
# Deploy backend
kubectl apply -f k8s/backend/

# Check backend status
kubectl get pods -l app=backend
\`\`\`
**Expected result:** Backend pods running and ready

### Step 6: Deploy Frontend (3 minutes)
\`\`\`bash
# Deploy frontend
kubectl apply -f k8s/frontend/

# Check all pods
kubectl get pods
\`\`\`
**You should see:** All pods in "Running" status

### Step 7: Access Your Application (2 minutes)
\`\`\`bash
# Port forward to access locally
kubectl port-forward svc/frontend 3000:3000 &
kubectl port-forward svc/backend 5000:5000 &

# Test access
curl http://localhost:3000
curl http://localhost:5000/health
\`\`\`

## ✅ Verify Success (2 minutes)

### Check All Resources
\`\`\`bash
# View all resources
kubectl get all

# Check service endpoints
kubectl get endpoints

# View resource details
kubectl describe deployment backend
\`\`\`

### Test Application Functionality
- [ ] Frontend loads at http://localhost:3000
- [ ] Backend health check at http://localhost:5000/health
- [ ] Database connection working
- [ ] All pods show "Running" status

## 🔧 Common Kubernetes Operations

### Scaling Applications
\`\`\`bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas=3

# Check scaling
kubectl get pods -l app=backend
\`\`\`

### Updating Applications
\`\`\`bash
# Update image
kubectl set image deployment/backend backend=new-image:tag

# Check rollout status
kubectl rollout status deployment/backend
\`\`\`

### Viewing Logs
\`\`\`bash
# View pod logs
kubectl logs -l app=backend

# Follow logs in real-time
kubectl logs -f deployment/backend
\`\`\`

### Troubleshooting
\`\`\`bash
# Describe problematic pod
kubectl describe pod <pod-name>

# Execute into pod
kubectl exec -it <pod-name> -- /bin/bash

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
\`\`\`

## 🎯 Understanding What Happened

### Kubernetes vs Docker Compose
| Docker Compose | Kubernetes |
|---------------|------------|
| Single machine | Multiple machines |
| Basic scaling | Advanced scaling |
| Limited networking | Advanced networking |
| No health monitoring | Built-in health checks |
| Manual updates | Rolling updates |

### Key Benefits You Just Used
- **Self-healing**: Kubernetes restarts failed pods
- **Scaling**: Easy to run multiple copies
- **Service discovery**: Services find each other automatically
- **Load balancing**: Traffic distributed across pods
- **Rolling updates**: Zero-downtime deployments

## 🚨 Troubleshooting Common Issues

### Pods Not Starting
\`\`\`bash
# Check pod status
kubectl get pods

# If status is "Pending" or "ImagePullBackOff"
kubectl describe pod <pod-name>

# Common fixes:
# 1. Check image name is correct
# 2. Ensure cluster has enough resources
# 3. Verify image registry access
\`\`\`

### Services Not Accessible
\`\`\`bash
# Check service configuration
kubectl get svc

# Verify endpoints
kubectl get endpoints

# Test internal connectivity
kubectl run test --image=busybox -it --rm -- wget -qO- http://service-name:port
\`\`\`

### Database Connection Issues
\`\`\`bash
# Check database pod logs
kubectl logs -l app=database

# Verify database service
kubectl get svc database

# Test connection from backend
kubectl exec -it deployment/backend -- nc -zv database 5432
\`\`\`

## 🎉 Next Steps

Congratulations! You've successfully deployed to Kubernetes. Next try:

1. **[Helm Charts](helm-guide.md)** - Package your application
2. **[Advanced Features](../k8s/advanced-features/README.md)** - Auto-scaling, monitoring
3. **[Production Deployment](deployment.md)** - AWS/Azure deployment

**Remember:** You can always go back to Docker Compose for development:
\`\`\`bash
# Clean up Kubernetes
kubectl delete namespace $app_name

# Return to Docker Compose
cd .. && docker-compose up -d
\`\`\`
EOF
}

create_helm_template() {
    local file_path="$1"
    local app_name="$2"
    cat > "$file_path" << EOF
# ⚓ Helm Guide - $app_name

## 🎯 What You'll Learn (5 minutes)
- Package your Kubernetes application with Helm
- Use templates to customize deployments
- Deploy to different environments easily

## 📋 Prerequisites (2 minutes)
- [ ] Kubernetes deployment working
- [ ] Helm 3.x installed
- [ ] Understanding of Kubernetes basics

## 🤔 What is Helm? (For Beginners)

**Simple Explanation:** Helm is like a "recipe book" for Kubernetes

### Think of it this way:
- **Raw Kubernetes YAML** = Writing a recipe from scratch every time
- **Helm Charts** = Using a recipe template you can customize

### Why use Helm?
✅ **Reusability**: One chart, multiple environments (dev/staging/prod)  
✅ **Templating**: Change values without rewriting YAML  
✅ **Versioning**: Track changes and rollback if needed  
✅ **Dependencies**: Automatically install required components  
✅ **Packaging**: Share applications easily  

### Example: Instead of this complexity...
\`\`\`bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml  
kubectl apply -f ingress.yaml
kubectl apply -f configmap.yaml
# ...20 more files with different values for each environment
\`\`\`

### Do this simple command:
\`\`\`bash
helm install my-app ./my-chart
\`\`\`

## 🚀 Step-by-Step Helm Implementation

### Step 1: Install Helm (2 minutes)
\`\`\`bash
# macOS
brew install helm

# Or download directly
curl https://get.helm.sh/helm-v3.12.0-darwin-amd64.tar.gz | tar xz
sudo mv darwin-amd64/helm /usr/local/bin/

# Verify installation
helm version
\`\`\`
**You will see:** Helm version information

### Step 2: Create Your First Chart (3 minutes)
\`\`\`bash
# Create chart structure
helm create $app_name-chart

# Look at what was created
ls $app_name-chart/
\`\`\`
**You will see:** Chart structure with templates and values

### Step 3: Understand Chart Structure (5 minutes)
\`\`\`
$app_name-chart/
├── Chart.yaml          # Chart information
├── values.yaml         # Default configuration values  
├── templates/          # Kubernetes YAML templates
│   ├── deployment.yaml # Your app deployment
│   ├── service.yaml    # Your app service
│   ├── ingress.yaml    # External access
│   └── _helpers.tpl    # Template helpers
└── charts/             # Dependencies
\`\`\`

### Step 4: Customize Your Chart (10 minutes)

#### Update Chart.yaml
\`\`\`yaml
# Chart.yaml
apiVersion: v2
name: $app_name
description: A Helm chart for $app_name
version: 0.1.0
appVersion: "1.0"
\`\`\`

#### Configure values.yaml
\`\`\`yaml
# values.yaml - Your customization file
frontend:
  image:
    repository: $app_name-frontend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  service:
    type: ClusterIP
    port: 3000

backend:
  image:
    repository: $app_name-backend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 3
  service:
    type: ClusterIP
    port: 5000

database:
  enabled: true
  service:
    port: 5432

ingress:
  enabled: true
  host: $app_name.local
\`\`\`

### Step 5: Create Templates (15 minutes)

#### Frontend Deployment Template
\`\`\`yaml
# templates/frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "$app_name.fullname" . }}-frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: "{{ .Values.frontend.image.repository }}:{{ .Values.frontend.image.tag }}"
        ports:
        - containerPort: {{ .Values.frontend.service.port }}
\`\`\`

#### Backend Service Template
\`\`\`yaml
# templates/backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "$app_name.fullname" . }}-backend
spec:
  selector:
    app: backend
  ports:
  - port: {{ .Values.backend.service.port }}
    targetPort: {{ .Values.backend.service.port }}
  type: {{ .Values.backend.service.type }}
\`\`\`

### Step 6: Deploy with Helm (5 minutes)
\`\`\`bash
# Deploy your application
helm install $app_name ./$app_name-chart

# Check what was deployed
helm list

# Check Kubernetes resources
kubectl get all -l app.kubernetes.io/instance=$app_name
\`\`\`
**You will see:** All your application components deployed

### Step 7: Test Deployment (3 minutes)
\`\`\`bash
# Port forward to access
kubectl port-forward svc/$app_name-frontend 3000:3000 &

# Test access
curl http://localhost:3000
\`\`\`

## ✅ Verify Success (2 minutes)

### Check Helm Release
\`\`\`bash
# View release status
helm status $app_name

# List all releases
helm list

# View release history
helm history $app_name
\`\`\`

### Verify Application
- [ ] All pods running: \`kubectl get pods\`
- [ ] Services created: \`kubectl get svc\`
- [ ] Application accessible via port-forward
- [ ] Helm release shows "deployed" status

## 🔧 Advanced Helm Operations

### Upgrade Application
\`\`\`bash
# Update values and upgrade
helm upgrade $app_name ./$app_name-chart --set frontend.replicaCount=5

# Check upgrade status
helm status $app_name
\`\`\`

### Rollback Changes
\`\`\`bash
# View release history
helm history $app_name

# Rollback to previous version
helm rollback $app_name 1
\`\`\`

### Different Environments
\`\`\`bash
# Development environment
helm install $app_name-dev ./$app_name-chart -f values-dev.yaml

# Production environment  
helm install $app_name-prod ./$app_name-chart -f values-prod.yaml
\`\`\`

### Debug Templates
\`\`\`bash
# See what templates will generate
helm template $app_name ./$app_name-chart

# Debug specific values
helm template $app_name ./$app_name-chart --debug
\`\`\`

## 🎯 Environment-Specific Deployments

### Development Values (values-dev.yaml)
\`\`\`yaml
frontend:
  replicaCount: 1
  image:
    tag: "dev"

backend:
  replicaCount: 1
  
database:
  persistence: false
\`\`\`

### Production Values (values-prod.yaml)
\`\`\`yaml
frontend:
  replicaCount: 5
  image:
    tag: "v1.0.0"

backend:
  replicaCount: 10
  
ingress:
  enabled: true
  host: $app_name.company.com
  tls: true
\`\`\`

## 🚨 Troubleshooting

### Template Errors
\`\`\`bash
# Check template syntax
helm template $app_name ./$app_name-chart --debug

# Validate chart
helm lint ./$app_name-chart
\`\`\`

### Deployment Issues
\`\`\`bash
# Check release status
helm status $app_name

# View generated manifests
helm get manifest $app_name

# Check pod issues
kubectl describe pod -l app.kubernetes.io/instance=$app_name
\`\`\`

### Values Problems
\`\`\`bash
# See actual values being used
helm get values $app_name

# Test with specific values
helm template $app_name ./$app_name-chart --set frontend.replicaCount=1
\`\`\`

## 🎉 What You've Achieved

Congratulations! You now understand:
- ✅ How Helm simplifies Kubernetes deployments
- ✅ Template-based configuration management
- ✅ Environment-specific customization
- ✅ Application lifecycle management
- ✅ Easy upgrades and rollbacks

## 🚀 Next Steps

1. **[Kustomize Guide](kustomize-guide.md)** - Alternative to Helm
2. **[Production Deployment](deployment.md)** - Deploy to cloud
3. **[Monitoring](../k8s/monitoring/README.md)** - Add observability

**Quick Commands Summary:**
\`\`\`bash
# Install
helm install $app_name ./chart

# Upgrade  
helm upgrade $app_name ./chart

# Rollback
helm rollback $app_name 1

# Uninstall
helm uninstall $app_name
\`\`\`
EOF
}

create_kustomize_template() {
    local file_path="$1"
    local app_name="$2"
    cat > "$file_path" << EOF
# 🔧 Kustomize Guide - $app_name

## 🎯 What You'll Learn (5 minutes)
- Use Kustomize for Kubernetes configuration management
- Understand base + overlays pattern
- Deploy to multiple environments without templates

## 📋 Prerequisites (2 minutes)
- [ ] Kubernetes YAML deployment working
- [ ] kubectl with Kustomize (built-in since 1.14)
- [ ] Understanding of Kubernetes manifests

## 🤔 What is Kustomize? (For Beginners)

**Simple Explanation:** Kustomize is like "stickers" for your Kubernetes YAML

### Think of it this way:
- **Base**: Your core application (like a phone)
- **Overlays**: Customizations for different environments (like phone cases)

### Kustomize vs Helm:
| Kustomize | Helm |
|-----------|------|
| Patches existing YAML | Templates from scratch |
| No templating language | Uses Go templates |
| Built into kubectl | Separate tool |
| Good for existing apps | Good for new packages |

### Why use Kustomize?
✅ **Simpler**: No templating language to learn  
✅ **Patches**: Modify existing YAML without rewriting  
✅ **Inheritance**: Base + Overlays = Customized deployment  
✅ **Native**: Built into kubectl (\`kubectl apply -k\`)  

## 🚀 Step-by-Step Kustomize Implementation

### Step 1: Understand the Structure (3 minutes)
\`\`\`
$app_name/
├── base/                    # Core application
│   ├── kustomization.yaml   # Base configuration
│   ├── deployment.yaml      # Base deployment
│   ├── service.yaml         # Base service
│   └── configmap.yaml       # Base config
└── overlays/                # Environment-specific changes
    ├── development/
    │   ├── kustomization.yaml
    │   └── replica-patch.yaml
    ├── staging/
    │   ├── kustomization.yaml
    │   └── resource-patch.yaml
    └── production/
        ├── kustomization.yaml
        ├── ingress.yaml
        └── scaling-patch.yaml
\`\`\`

### Step 2: Create Base Configuration (10 minutes)

#### Base Kustomization
\`\`\`yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- configmap.yaml

commonLabels:
  app: $app_name
  version: v1

namePrefix: $app_name-
\`\`\`

#### Base Deployment
\`\`\`yaml
# base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: $app_name-backend:latest
        ports:
        - containerPort: 5000
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: node-env
\`\`\`

#### Base Service
\`\`\`yaml
# base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
  - port: 5000
    targetPort: 5000
  type: ClusterIP
\`\`\`

#### Base ConfigMap
\`\`\`yaml
# base/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  node-env: "production"
  log-level: "info"
\`\`\`

### Step 3: Create Development Overlay (8 minutes)

#### Development Kustomization
\`\`\`yaml
# overlays/development/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namePrefix: dev-

patchesStrategicMerge:
- replica-patch.yaml

configMapGenerator:
- name: app-config
  behavior: merge
  literals:
  - node-env=development
  - log-level=debug

images:
- name: $app_name-backend
  newTag: dev-latest
\`\`\`

#### Development Replica Patch
\`\`\`yaml
# overlays/development/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 1
\`\`\`

### Step 4: Create Production Overlay (10 minutes)

#### Production Kustomization
\`\`\`yaml
# overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namePrefix: prod-

patchesStrategicMerge:
- scaling-patch.yaml

resources:
- ingress.yaml

configMapGenerator:
- name: app-config
  behavior: merge
  literals:
  - node-env=production
  - log-level=warn

images:
- name: $app_name-backend
  newTag: v1.0.0
\`\`\`

#### Production Scaling Patch
\`\`\`yaml
# overlays/production/scaling-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 10
  template:
    spec:
      containers:
      - name: backend
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
\`\`\`

#### Production Ingress
\`\`\`yaml
# overlays/production/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
spec:
  rules:
  - host: $app_name.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 5000
\`\`\`

### Step 5: Deploy with Kustomize (5 minutes)

#### Preview Changes
\`\`\`bash
# See what will be applied (development)
kubectl kustomize overlays/development/

# See what will be applied (production)
kubectl kustomize overlays/production/
\`\`\`

#### Deploy to Development
\`\`\`bash
# Apply development configuration
kubectl apply -k overlays/development/

# Check deployment
kubectl get all -l app=$app_name
\`\`\`
**You will see:** Development deployment with 1 replica

#### Deploy to Production
\`\`\`bash
# Apply production configuration
kubectl apply -k overlays/production/

# Check deployment
kubectl get all -l app=$app_name
\`\`\`
**You will see:** Production deployment with 10 replicas and ingress

### Step 6: Verify Deployments (3 minutes)
\`\`\`bash
# Check development resources
kubectl get all -l app=$app_name,version=v1 -n development

# Check production resources  
kubectl get all -l app=$app_name,version=v1 -n production

# Compare configurations
kubectl kustomize overlays/development/ > dev-config.yaml
kubectl kustomize overlays/production/ > prod-config.yaml
diff dev-config.yaml prod-config.yaml
\`\`\`

## ✅ Verify Success (2 minutes)

### Check Different Environments
\`\`\`bash
# Development deployment
kubectl get deployment dev-$app_name-backend
# Should show: 1 replica

# Production deployment
kubectl get deployment prod-$app_name-backend  
# Should show: 10 replicas

# Check configuration differences
kubectl get configmap dev-$app_name-app-config -o yaml
kubectl get configmap prod-$app_name-app-config -o yaml
\`\`\`

## 🔧 Advanced Kustomize Operations

### JSON Patches for Precise Changes
\`\`\`yaml
# Use JSON patches for complex modifications
patchesJson6902:
- target:
    group: apps
    version: v1
    kind: Deployment
    name: backend
  path: json-patch.yaml
\`\`\`

\`\`\`yaml
# json-patch.yaml
- op: replace
  path: /spec/template/spec/containers/0/image
  value: new-image:v2.0.0
\`\`\`

### Generate Resources
\`\`\`yaml
# Generate secrets and configmaps
secretGenerator:
- name: app-secrets
  literals:
  - username=admin
  - password=secret123

configMapGenerator:
- name: app-config
  files:
  - config.properties
\`\`\`

### Cross-Environment Patches
\`\`\`bash
# Apply staging patches to development
kubectl kustomize overlays/development/ | \
  kubectl patch -f - --patch="$(kubectl kustomize overlays/staging/)"
\`\`\`

## 🎯 Real-World Example

### Managing Multiple Services
\`\`\`
microservices-app/
├── base/
│   ├── frontend/
│   ├── backend/
│   ├── database/
│   └── kustomization.yaml
├── overlays/
│   ├── development/
│   │   ├── kustomization.yaml
│   │   └── scaling-down.yaml
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── staging-ingress.yaml
│   └── production/
│       ├── kustomization.yaml
│       ├── production-ingress.yaml
│       ├── hpa.yaml
│       └── network-policy.yaml
\`\`\`

### Deploy All Services
\`\`\`bash
# Deploy entire microservices stack to production
kubectl apply -k overlays/production/

# Update just the frontend in staging
kubectl apply -k overlays/staging/ --selector=app=frontend
\`\`\`

## 🚨 Troubleshooting

### Build Errors
\`\`\`bash
# Validate kustomization
kubectl kustomize overlays/development/ --enable-alpha-plugins

# Check for syntax errors
kustomize build overlays/production/
\`\`\`

### Patch Issues
\`\`\`bash
# Debug patch application
kubectl kustomize overlays/development/ --enable-helm | kubectl apply --dry-run=client -f -

# Validate strategic merge patches
kubectl explain deployment.spec.template.spec.containers --recursive
\`\`\`

### Resource Conflicts
\`\`\`bash
# Check for naming conflicts
kubectl kustomize overlays/production/ | grep "name:"

# Validate unique resource names
kubectl apply -k overlays/production/ --dry-run=server
\`\`\`

## 🎉 What You've Achieved

Congratulations! You now understand:
- ✅ Base + overlay architecture pattern
- ✅ Environment-specific configuration management
- ✅ Patching existing YAML without templates
- ✅ Native kubectl integration
- ✅ Advanced patching techniques

## 🚀 Next Steps

1. **[Advanced Features](../k8s/advanced-features/README.md)** - HPA, network policies
2. **[GitOps](../ci-cd/gitops-guide.md)** - Automated deployments
3. **[Monitoring](../k8s/monitoring/README.md)** - Observability stack

## 📚 Quick Reference

### Common Commands
\`\`\`bash
# Build and preview
kubectl kustomize overlays/environment/

# Apply
kubectl apply -k overlays/environment/

# Delete
kubectl delete -k overlays/environment/

# Diff environments
diff <(kubectl kustomize overlays/dev/) <(kubectl kustomize overlays/prod/)
\`\`\`

### File Structure Best Practices
- Keep base minimal and reusable
- Use overlays for environment differences
- Prefer strategic merge over JSON patches
- Group related resources in subdirectories
- Use descriptive patch file names
EOF
}

# Main execution
echo -e "${BLUE}🔍 SCANNING FOR BROKEN DOCUMENTATION LINKS...${NC}"

# Find all applications
for app_dir in ecommerce-app educational-platform medical-care-system task-management-app weather-app social-media-platform; do
    if [ -d "$app_dir" ]; then
        echo -e "${GREEN}📂 Processing $app_dir...${NC}"
        create_missing_docs "$app_dir"
    fi
done

# Check for broken links in existing documentation
echo -e "${BLUE}🔗 CHECKING EXISTING DOCUMENTATION LINKS...${NC}"
find . -name "*.md" -type f | while read md_file; do
    # Skip certain files
    if [[ "$md_file" == *"SESSION_LOG.md"* ]] || [[ "$md_file" == *"node_modules"* ]]; then
        continue
    fi
    
    # Extract and check links
    grep -o "\[.*\]([^)]*)" "$md_file" 2>/dev/null | while read link; do
        url=$(echo "$link" | sed 's/.*(\([^)]*\)).*/\1/')
        
        # Check relative file links
        if [[ "$url" == ./* ]] || [[ "$url" == ../* ]] || [[ "$url" == docs/* ]]; then
            md_dir=$(dirname "$md_file")
            if [[ "$url" == docs/* ]] && [[ "$md_file" != */docs/* ]]; then
                # Handle docs/ links from root level
                full_path="$md_dir/$url"
            else
                full_path="$md_dir/$url"
            fi
            
            if [ ! -f "$full_path" ]; then
                echo -e "${RED}❌ BROKEN LINK${NC} in $md_file: $url"
                echo "   Expected file: $full_path"
                ((BROKEN_LINKS++))
            fi
        fi
    done
done

# Summary
echo -e "\n${BLUE}📊 DOCUMENTATION ANALYSIS SUMMARY${NC}"
echo -e "${GREEN}✅ Created files: $CREATED_FILES${NC}"
echo -e "${RED}❌ Broken links found: $BROKEN_LINKS${NC}"

if [ $BROKEN_LINKS -gt 0 ]; then
    echo -e "\n${YELLOW}⚠️  ACTION REQUIRED:${NC}"
    echo "Run this script again after creating missing files to validate fixes"
    exit 1
else
    echo -e "\n${GREEN}🎉 ALL DOCUMENTATION LINKS VALIDATED SUCCESSFULLY!${NC}"
    exit 0
fi