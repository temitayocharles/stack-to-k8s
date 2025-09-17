# Weather App Deployment Guide

This guide provides comprehensive instructions for deploying the Weather App in various environments with both automated and manual options.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Automated Deployment](#automated-deployment)
4. [Manual Deployment](#manual-deployment)
5. [Monitoring Setup](#monitoring-setup)
6. [Troubleshooting](#troubleshooting)
7. [Security Considerations](#security-considerations)

## Prerequisites

### System Requirements
- **Kubernetes Cluster**: Version 1.24+
- **Docker**: Version 20.10+
- **kubectl**: Version 1.24+
- **Helm**: Version 3.0+ (optional)
- **AWS CLI**: Version 2.0+ (for AWS deployments)

### Cloud Resources
- **AWS Account** with EKS permissions
- **Domain Name** (optional, for production)
- **SSL Certificate** (Let's Encrypt or custom)

### Required Services
- **Container Registry**: Docker Hub, ECR, or GitHub Container Registry
- **Database**: PostgreSQL 13+
- **Cache**: Redis 6+
- **Monitoring**: Prometheus and Grafana (included)

## Environment Setup

### 1. Clone Repository
```bash
git clone https://github.com/your-username/weather-app.git
cd weather-app
```

### 2. Configure Environment Variables

Copy and customize environment files:
```bash
cp config/development.env config/custom.env
```

Edit `config/custom.env` with your values:
```bash
# Application Settings
FLASK_ENV=production
SECRET_KEY=your-super-secret-key-here
LOG_LEVEL=INFO

# API Keys
OPENWEATHER_API_KEY=your-openweather-api-key
WEATHER_API_KEY=your-weather-api-key

# Database
DATABASE_URL=postgresql://user:password@host:5432/weather_db

# Redis
REDIS_URL=redis://redis:6379/0

# External Services
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### 3. Set Up Kubernetes Cluster

#### Option A: AWS EKS
```bash
# Configure AWS CLI
aws configure

# Create EKS cluster
eksctl create cluster \
  --name weather-app-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed
```

#### Option B: Local Kubernetes (Minikube)
```bash
# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start --driver=docker

# Enable ingress
minikube addons enable ingress
```

## Automated Deployment

### GitHub Actions Deployment

1. **Set up Secrets in GitHub**:
   - Go to Repository Settings → Secrets and variables → Actions
   - Add the following secrets:
     ```
     AWS_ACCESS_KEY_ID
     AWS_SECRET_ACCESS_KEY
     AWS_REGION
     EKS_CLUSTER_NAME
     DOCKER_USERNAME
     DOCKER_PASSWORD
     OPENWEATHER_API_KEY
     DATABASE_URL
     REDIS_URL
     ```

2. **Deploy to Staging**:
   ```bash
   git checkout develop
   git push origin develop
   ```

3. **Deploy to Production**:
   ```bash
   git checkout main
   git push origin main
   ```

### Jenkins Deployment

1. **Install Required Plugins**:
   - Docker Pipeline
   - Kubernetes CLI
   - AWS Credentials
   - Git

2. **Configure Jenkins Credentials**:
   - Add AWS credentials
   - Add Docker registry credentials
   - Add Kubernetes config

3. **Create Pipeline Job**:
   - New Item → Pipeline
   - Copy content from `Jenkinsfile`
   - Configure build triggers

4. **Run Deployment**:
   - Click "Build Now" or set up webhooks

### GitLab CI Deployment

1. **Set up CI/CD Variables**:
   - Go to Settings → CI/CD → Variables
   - Add the following variables:
     ```
     KUBE_CONFIG_STAGING
     KUBE_CONFIG_PRODUCTION
     DOCKER_USERNAME
     DOCKER_PASSWORD
     OPENWEATHER_API_KEY
     ```

2. **Configure Runner**:
   - Ensure GitLab Runner has Docker and Kubernetes access
   - Tag runner for deployment jobs

3. **Deploy Automatically**:
   - Push to `develop` branch for staging
   - Push to `main` branch for production
   - Manual approval required for production

## Manual Deployment

### Step 1: Build Docker Images

```bash
# Build backend image
cd backend
docker build -t weather-app/backend:latest \
  --build-arg ENV_FILE=../config/production.env .

# Build frontend image
cd ../frontend
docker build -t weather-app/frontend:latest \
  --build-arg ENV_FILE=../config/production.env .

# Push to registry
docker push weather-app/backend:latest
docker push weather-app/frontend:latest
```

### Step 2: Deploy to Kubernetes

#### Base Deployment
```bash
# Create namespace
kubectl create namespace weather

# Apply base manifests
kubectl apply -f k8s/base/
```

#### Production Deployment with Advanced Features
```bash
# Apply production manifests
kubectl apply -f k8s/production/

# Apply monitoring stack
kubectl apply -f k8s/monitoring/
```

### Step 3: Configure Ingress

```bash
# Update ingress host in k8s/base/04-ingress.yaml
kubectl apply -f k8s/base/04-ingress.yaml
```

### Step 4: Set Up SSL Certificate

#### Using Let's Encrypt (cert-manager)
```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# Create ClusterIssuer
kubectl apply -f k8s/cert-manager/cluster-issuer.yaml

# Update ingress with TLS
kubectl apply -f k8s/base/04-ingress.yaml
```

## Monitoring Setup

### Access Monitoring Dashboards

1. **Port Forward Prometheus**:
   ```bash
   kubectl port-forward -n monitoring svc/prometheus 9090:9090
   # Access: http://localhost:9090
   ```

2. **Port Forward Grafana**:
   ```bash
   kubectl port-forward -n monitoring svc/grafana 3000:3000
   # Access: http://localhost:3000 (admin/admin123)
   ```

### Configure Alerts

1. **Set up AlertManager**:
   ```bash
   kubectl apply -f k8s/monitoring/alertmanager.yaml
   ```

2. **Configure Alert Rules**:
   - Edit `k8s/monitoring/prometheus.yaml`
   - Add custom alert rules

### Key Metrics to Monitor

- **Application Metrics**:
  - Response times
  - Error rates
  - Throughput

- **System Metrics**:
  - CPU usage
  - Memory usage
  - Disk I/O

- **Kubernetes Metrics**:
  - Pod health
  - Node status
  - Network traffic

## Troubleshooting

### Common Issues

#### 1. Pod Startup Failures
```bash
# Check pod status
kubectl get pods -n weather

# View pod logs
kubectl logs -n weather <pod-name>

# Describe pod for events
kubectl describe pod -n weather <pod-name>
```

#### 2. Service Connectivity Issues
```bash
# Check service endpoints
kubectl get endpoints -n weather

# Test service connectivity
kubectl run test --image=curlimages/curl --rm -it -- \
  curl http://weather-backend.weather.svc.cluster.local/api/health
```

#### 3. Database Connection Issues
```bash
# Check database pod
kubectl logs -n weather <database-pod>

# Test database connectivity
kubectl exec -n weather <backend-pod> -- \
  python -c "import psycopg2; psycopg2.connect(os.environ['DATABASE_URL'])"
```

#### 4. Image Pull Failures
```bash
# Check image pull secrets
kubectl get secrets -n weather

# Verify registry credentials
kubectl describe secret <registry-secret> -n weather
```

### Debug Commands

```bash
# Get cluster status
kubectl cluster-info

# Check node status
kubectl get nodes

# View all resources
kubectl get all -n weather

# Check resource usage
kubectl top pods -n weather
kubectl top nodes
```

## Security Considerations

### 1. Network Security

#### Network Policies
```bash
# Apply network policies
kubectl apply -f k8s/production/network-policies.yaml
```

#### Service Mesh (Optional)
```bash
# Install Istio
istioctl install

# Enable sidecar injection
kubectl label namespace weather istio-injection=enabled
```

### 2. Secret Management

#### Kubernetes Secrets
```bash
# Create secrets from environment file
kubectl create secret generic weather-secrets \
  --from-env-file=config/production.env \
  -n weather
```

#### External Secret Management
- AWS Secrets Manager
- HashiCorp Vault
- Azure Key Vault

### 3. Access Control

#### RBAC Configuration
```bash
# Apply RBAC rules
kubectl apply -f k8s/production/rbac.yaml
```

#### Pod Security Standards
```bash
# Apply security context
kubectl apply -f k8s/production/security-context.yaml
```

### 4. Image Security

#### Vulnerability Scanning
```bash
# Scan images with Trivy
trivy image weather-app/backend:latest
trivy image weather-app/frontend:latest
```

#### Image Signing (Optional)
```bash
# Sign images with Cosign
cosign sign weather-app/backend:latest
cosign verify weather-app/backend:latest
```

## Performance Optimization

### 1. Resource Limits
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### 2. Horizontal Pod Autoscaling
```bash
# Apply HPA
kubectl apply -f k8s/production/hpa.yaml
```

### 3. Database Optimization
- Connection pooling
- Query optimization
- Index management

### 4. Caching Strategy
- Redis for session data
- CDN for static assets
- Application-level caching

## Backup and Recovery

### Database Backup
```bash
# Create backup job
kubectl apply -f k8s/backup/database-backup.yaml

# Manual backup
kubectl exec -n weather <postgres-pod> -- \
  pg_dump -U postgres weather_db > backup.sql
```

### Application Backup
```bash
# Backup configurations
kubectl get all -n weather -o yaml > backup.yaml

# Backup persistent volumes
kubectl get pvc -n weather
```

### Disaster Recovery
1. **Cluster Failure**:
   - Use multi-zone deployment
   - Implement backup clusters

2. **Data Loss**:
   - Regular database backups
   - Point-in-time recovery

3. **Application Failure**:
   - Rolling updates
   - Health checks and probes

## Support and Maintenance

### Regular Maintenance Tasks

1. **Update Dependencies**:
   ```bash
   # Update Python packages
   cd backend && pip list --outdated

   # Update Node packages
   cd frontend && npm outdated
   ```

2. **Security Updates**:
   ```bash
   # Scan for vulnerabilities
   trivy fs .
   kubesec scan k8s/
   ```

3. **Performance Monitoring**:
   - Review Grafana dashboards
   - Analyze application logs
   - Monitor resource usage

### Getting Help

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/your-username/weather-app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/weather-app/discussions)
- **Email**: support@weather-app.com

---

## Quick Reference

### Useful Commands

```bash
# Deployment
kubectl apply -f k8s/base/              # Base deployment
kubectl apply -f k8s/production/        # Production deployment
kubectl apply -f k8s/monitoring/        # Monitoring stack

# Monitoring
kubectl port-forward svc/prometheus -n monitoring 9090:9090
kubectl port-forward svc/grafana -n monitoring 3000:3000

# Troubleshooting
kubectl get pods -n weather              # Check pod status
kubectl logs <pod-name> -n weather       # View logs
kubectl describe pod <pod-name> -n weather  # Pod details

# Scaling
kubectl scale deployment weather-backend --replicas=3 -n weather
kubectl autoscale deployment weather-backend --cpu-percent=70 --min=1 --max=5 -n weather
```

### Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `FLASK_ENV` | Yes | development | Flask environment |
| `SECRET_KEY` | Yes | - | JWT secret key |
| `OPENWEATHER_API_KEY` | Yes | - | Weather API key |
| `DATABASE_URL` | Yes | - | PostgreSQL URL |
| `REDIS_URL` | No | redis://redis:6379 | Redis URL |
| `LOG_LEVEL` | No | INFO | Logging level |

This deployment guide provides both automated and manual options to fit different operational preferences and requirements.
