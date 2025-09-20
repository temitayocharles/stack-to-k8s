# 🚀 COMPLETE DEPLOYMENT GUIDE

**Multi-Application Kubernetes Practice Workspace**  
**All 6 Applications - Docker & Kubernetes Ready**

---

## 📋 QUICK START GUIDE

### Prerequisites Checklist
- [ ] Docker Desktop installed and running
- [ ] kubectl installed and configured
- [ ] Git repository cloned
- [ ] 8GB+ RAM available
- [ ] Ports 80, 3003, 5002, 5170, 8080, 8082 available

### One-Command Deployment
```bash
# Deploy all applications with databases
cd /path/to/full-stack-apps
docker-compose up -d

# Verify all services are running
docker-compose ps
```

### Quick Health Check
```bash
# Test all applications are responding
curl http://localhost:80/api/health        # E-commerce
curl http://localhost:8080/actuator/health # Educational
curl http://localhost:5002/api/health      # Weather
curl http://localhost:5170/api/health      # Medical
curl http://localhost:8082/api/v1/health   # Task Management
curl http://localhost:3003/health          # Social Media
```

---

## 🎯 APPLICATION ACCESS POINTS

| Application | URL | Health Check | Admin/Demo |
|-------------|-----|--------------|------------|
| **E-commerce** | http://localhost:80 | http://localhost:80/api/health | Full catalog |
| **Educational** | http://localhost:8080 | http://localhost:8080/actuator/health | Register user |
| **Weather** | http://localhost:5002 | http://localhost:5002/api/health | ML forecasts |
| **Medical** | http://localhost:5170 | http://localhost:5170/api/health | Create patient |
| **Task Management** | http://localhost:8082 | http://localhost:8082/api/v1/health | Sample tasks |
| **Social Media** | http://localhost:3003 | http://localhost:3003/health | User profiles |

---

## 🐳 DOCKER DEPLOYMENT

### Individual Application Deployment

#### 1. E-commerce Application
```bash
cd ecommerce-app
docker-compose up -d

# Test endpoints
curl http://localhost:80/api/products
curl http://localhost:80/api/users
```

#### 2. Educational Platform
```bash
cd educational-platform
docker-compose up -d

# Create test user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Password123!",
    "confirmPassword": "Password123!",
    "firstName": "John",
    "lastName": "Student",
    "acceptTerms": true,
    "acceptPrivacy": true
  }'
```

#### 3. Weather Application
```bash
cd weather-app
docker-compose up -d

# Test ML forecast
curl "http://localhost:5002/api/weather/ml-forecast?lat=40.7128&lon=-74.0060"
```

#### 4. Medical Care System
```bash
cd medical-care-system
docker-compose up -d

# Create sample patient
curl -X POST http://localhost:5170/api/patients \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@email.com",
    "phoneNumber": "+1-555-0123",
    "dateOfBirth": "1990-01-15T00:00:00Z",
    "gender": "Male",
    "address": "123 Main St, City, State 12345",
    "emergencyContact": "Jane Doe",
    "emergencyContactPhone": "+1-555-0124",
    "bloodType": "O+",
    "allergies": "Penicillin",
    "medicalConditions": "Hypertension"
  }'
```

#### 5. Task Management App
```bash
cd task-management-app
docker-compose up -d

# Test sample data
curl http://localhost:8082/api/v1/tasks
curl http://localhost:8082/api/v1/users
```

#### 6. Social Media Platform
```bash
cd social-media-platform
docker-compose up -d

# Test user profiles
curl http://localhost:3003/api/users
curl http://localhost:3003/api/posts
```

### Global Deployment (All Applications)
```bash
# From workspace root
docker-compose up -d

# Monitor all containers
docker-compose ps
docker-compose logs -f
```

---

## ☸️ KUBERNETES DEPLOYMENT

### Prerequisites
```bash
# Ensure kubectl is configured
kubectl cluster-info

# Create namespace for applications
kubectl create namespace fullstack-apps
kubectl config set-context --current --namespace=fullstack-apps
```

### Deploy Individual Applications

#### 1. E-commerce Kubernetes Deployment
```bash
cd ecommerce-app/k8s

# Deploy base resources
kubectl apply -f base/

# Deploy production resources
kubectl apply -f production/

# Verify deployment
kubectl get pods -l app=ecommerce
kubectl get services
```

#### 2. Educational Platform Kubernetes
```bash
cd educational-platform/k8s

# Deploy all resources
kubectl apply -f . -R

# Check rollout status
kubectl rollout status deployment/educational-backend
kubectl rollout status deployment/educational-frontend
```

#### 3. Weather App Kubernetes
```bash
cd weather-app/k8s

# Deploy weather services
kubectl apply -f .

# Test weather API
kubectl port-forward service/weather-backend 5002:5002
```

#### 4. Medical Care Kubernetes
```bash
cd medical-care-system/k8s

# Deploy medical services
kubectl apply -f .

# Check SQL Server pod
kubectl get pods -l app=medical-sqlserver
```

#### 5. Task Management Kubernetes
```bash
cd task-management-app/k8s

# Deploy task management
kubectl apply -f .

# Test Go backend
kubectl port-forward service/task-backend 8082:8082
```

#### 6. Social Media Kubernetes
```bash
cd social-media-platform/k8s

# Deploy social platform
kubectl apply -f .

# Check Rails backend
kubectl get pods -l app=social-backend
```

### Deploy All Applications at Once
```bash
# From workspace root
for app in ecommerce-app educational-platform weather-app medical-care-system task-management-app social-media-platform; do
  echo "Deploying $app..."
  kubectl apply -f $app/k8s/ -R
done

# Monitor all deployments
kubectl get deployments
kubectl get services
kubectl get pods
```

### Advanced Kubernetes Features
```bash
# Deploy monitoring stack
kubectl apply -f k8s-monitoring/

# Deploy advanced features for all apps
for app in ecommerce-app educational-platform weather-app medical-care-system task-management-app social-media-platform; do
  kubectl apply -f $app/k8s/advanced-features/ -R
done

# Check HPA (Horizontal Pod Autoscaler)
kubectl get hpa

# Check Network Policies
kubectl get networkpolicies

# Check Pod Disruption Budgets
kubectl get pdb
```

---

## 🔍 VERIFICATION & TESTING

### Health Checks Script
```bash
#!/bin/bash
# health-check-all.sh

echo "🔍 Testing All Applications..."

apps=(
  "http://localhost:80/api/health:E-commerce"
  "http://localhost:8080/actuator/health:Educational"
  "http://localhost:5002/api/health:Weather"
  "http://localhost:5170/api/health:Medical"
  "http://localhost:8082/api/v1/health:Task Management"
  "http://localhost:3003/health:Social Media"
)

for app in "${apps[@]}"; do
  url=${app%:*}
  name=${app#*:}
  
  echo "Testing $name..."
  if curl -s -f "$url" > /dev/null; then
    echo "✅ $name - HEALTHY"
  else
    echo "❌ $name - UNHEALTHY"
  fi
done

echo "🎉 Health check complete!"
```

### Comprehensive Testing
```bash
# Test API endpoints
./test-all-apis.sh

# Test database connectivity
./test-databases.sh

# Test sample data creation
./create-sample-data.sh

# Performance testing
./performance-test.sh
```

---

## 📊 MONITORING & OBSERVABILITY

### Prometheus Metrics
```bash
# Access metrics endpoints
curl http://localhost:80/metrics         # E-commerce
curl http://localhost:8080/actuator/prometheus # Educational  
curl http://localhost:5002/metrics       # Weather
curl http://localhost:8082/api/v1/metrics # Task Management
```

### Grafana Dashboards
```bash
# Deploy monitoring stack
kubectl apply -f monitoring/

# Access Grafana
kubectl port-forward service/grafana 3000:3000
# Open http://localhost:3000
# Login: admin/admin
```

### Log Aggregation
```bash
# Check application logs
docker-compose logs -f [service-name]

# Kubernetes logs
kubectl logs -f deployment/[app-name]
kubectl logs -f -l app=[app-label]
```

---

## 🔧 TROUBLESHOOTING

### Common Issues & Solutions

#### Container Startup Issues
```bash
# Check container status
docker-compose ps

# View container logs
docker-compose logs [service-name]

# Restart problematic services
docker-compose restart [service-name]

# Clean restart
docker-compose down
docker-compose up -d
```

#### Port Conflicts
```bash
# Check port usage
lsof -i :80
lsof -i :8080

# Kill processes using ports
sudo kill -9 [PID]

# Use different ports
export PORT_OVERRIDE=8081
docker-compose up -d
```

#### Database Connection Issues
```bash
# Check database containers
docker-compose ps | grep -E "(postgres|mongo|redis|sqlserver)"

# Reset databases
docker-compose down -v
docker-compose up -d
```

#### Kubernetes Issues
```bash
# Check pod status
kubectl get pods
kubectl describe pod [pod-name]

# Check logs
kubectl logs [pod-name]

# Restart deployments
kubectl rollout restart deployment/[deployment-name]

# Check resource usage
kubectl top pods
kubectl top nodes
```

### Resource Requirements
```yaml
Minimum Requirements:
- RAM: 8GB
- CPU: 4 cores
- Disk: 10GB free space
- Network: Broadband internet

Recommended Requirements:
- RAM: 16GB
- CPU: 8 cores  
- Disk: 20GB free space
- Network: High-speed internet
```

---

## 🎯 PRODUCTION DEPLOYMENT

### Environment Configuration
```bash
# Set production environment variables
export NODE_ENV=production
export SPRING_PROFILES_ACTIVE=production
export FLASK_ENV=production
export ASPNETCORE_ENVIRONMENT=Production
export GIN_MODE=release
export RAILS_ENV=production

# Deploy with production settings
docker-compose -f docker-compose.prod.yml up -d
```

### Security Considerations
```bash
# Generate secure secrets
kubectl create secret generic app-secrets \
  --from-literal=jwt-secret=$(openssl rand -base64 32) \
  --from-literal=db-password=$(openssl rand -base64 32)

# Apply security policies
kubectl apply -f security/network-policies.yml
kubectl apply -f security/pod-security-policies.yml
```

### Scaling Configuration
```bash
# Horizontal scaling
kubectl scale deployment ecommerce-backend --replicas=3
kubectl scale deployment educational-backend --replicas=2

# Auto-scaling
kubectl apply -f autoscaling/hpa.yml
```

---

## 📚 ADDITIONAL RESOURCES

### Documentation Links
- [Application Architecture](./ARCHITECTURE.md)
- [API Documentation](./API_DOCUMENTATION.md)
- [Security Guide](./SECURITY.md)
- [Performance Tuning](./PERFORMANCE.md)

### Support & Troubleshooting
- [FAQ](./FAQ.md)
- [Common Issues](./TROUBLESHOOTING.md)
- [Performance Tips](./PERFORMANCE_TIPS.md)

### Development Resources
- [Local Development Setup](./DEVELOPMENT.md)
- [Contributing Guidelines](./CONTRIBUTING.md)
- [Testing Guide](./TESTING.md)

---

## 🎉 SUCCESS VERIFICATION

After deployment, verify success by:

1. **✅ All Health Checks Green**
2. **✅ Sample Data Created Successfully**  
3. **✅ API Endpoints Responding**
4. **✅ Databases Connected**
5. **✅ Frontend Applications Loading**
6. **✅ Real-time Features Working**

### Expected Results:
- 6 Applications running simultaneously
- 130+ API endpoints functional
- Multiple databases operational
- Real-time features active
- Professional-grade functionality

---

**🚀 Deployment Complete!**

Your multi-application workspace is now ready for:
- Kubernetes practice and learning
- Professional portfolio demonstration  
- Production deployment
- Technical interviews
- Client presentations

---

*Last Updated: September 19, 2025*  
*Deployment Guide Version: 1.0*  
*Applications Covered: 6/6*