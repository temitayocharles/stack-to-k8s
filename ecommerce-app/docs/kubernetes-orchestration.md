# 🚢 **Kubernetes Orchestration Guide**
## **From Docker to Kubernetes - Step by Step**

> **✨ Ready for Production Scale?** Move from Docker Compose to Kubernetes  
> **🎯 Goal**: Deploy and manage your app with enterprise-grade orchestration  
> **⏰ Time Needed**: 2-4 hours depending on your chosen path  

---

## 📋 **Before You Start**

**Make sure you have:**
- [ ] Working Docker Compose setup (completed [Quick Start](./quick-start.md))
- [ ] Kubernetes cluster access (local or cloud)
- [ ] kubectl installed and configured
- [ ] Basic understanding of containers

**New to Kubernetes?** [Start with our Docker setup](./quick-start.md) first!

---

## 🛤️ **Choose Your Kubernetes Path**

### **🟢 Option 1: Raw YAML (Learn the Basics)**
**Perfect for: Understanding Kubernetes fundamentals**

**What you'll deploy:**
- Individual YAML manifests
- Step-by-step explanations
- Direct kubectl commands
- Easy to understand and modify

**Time: 2-3 hours**  
**Difficulty: Beginner** ⭐⭐⭐☆☆

**👆 Start here:** [Raw YAML Deployment](#raw-yaml-deployment)

---

### **🟡 Option 2: Helm Charts (Package Manager)**
**Perfect for: Production deployments and reusability**

**What you'll use:**
- Helm package manager
- Templated configurations
- Easy upgrades and rollbacks
- Industry standard approach

**Time: 1-2 hours**  
**Difficulty: Intermediate** ⭐⭐⭐⭐☆

**👆 Start here:** [Helm Deployment](#helm-deployment)

---

### **🔴 Option 3: Kustomize (Advanced Configuration)**
**Perfect for: Multiple environments and advanced customization**

**What you'll learn:**
- Configuration overlays
- Environment-specific settings
- Advanced Kubernetes patterns
- GitOps workflows

**Time: 3-4 hours**  
**Difficulty: Advanced** ⭐⭐⭐⭐⭐

**👆 Start here:** [Kustomize Deployment](#kustomize-deployment)

---

## 🔧 **Raw YAML Deployment**

### **Step 1: Prepare Your Cluster**
```bash
# Check your cluster is ready:
kubectl cluster-info

# Create namespace for our app:
kubectl create namespace ecommerce

# Set as default namespace:
kubectl config set-context --current --namespace=ecommerce
```

### **Step 2: Deploy Database First**
```bash
# Apply database manifests:
kubectl apply -f k8s/base/mongodb-deployment.yaml
kubectl apply -f k8s/base/mongodb-service.yaml

# Wait for database to be ready:
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s
```

### **Step 3: Deploy Cache**
```bash
# Apply Redis manifests:
kubectl apply -f k8s/base/redis-deployment.yaml
kubectl apply -f k8s/base/redis-service.yaml

# Check Redis is running:
kubectl get pods -l app=redis
```

### **Step 4: Deploy Backend API**
```bash
# Apply backend manifests:
kubectl apply -f k8s/base/backend-deployment.yaml
kubectl apply -f k8s/base/backend-service.yaml

# Check backend is ready:
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s
```

### **Step 5: Deploy Frontend**
```bash
# Apply frontend manifests:
kubectl apply -f k8s/base/frontend-deployment.yaml
kubectl apply -f k8s/base/frontend-service.yaml

# Expose frontend with LoadBalancer:
kubectl apply -f k8s/base/frontend-ingress.yaml
```

### **Step 6: Verify Deployment**
```bash
# Check all pods are running:
kubectl get pods

# Check services:
kubectl get services

# Get external IP (if using cloud):
kubectl get service frontend-service

# Test the application:
kubectl port-forward service/frontend-service 8080:80
open http://localhost:8080
```

---

## ⚙️ **Helm Deployment**

### **What is Helm?**
Helm is like a **package manager for Kubernetes** (think npm for Node.js or pip for Python). It:
- **Packages** your app into reusable charts
- **Templates** configurations for different environments
- **Manages** upgrades and rollbacks
- **Shares** apps through repositories

### **Step 1: Install Helm**
```bash
# Install Helm (Mac):
brew install helm

# Install Helm (Linux):
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation:
helm version
```

### **Step 2: Deploy with Helm**
```bash
# Add our chart repository:
helm repo add ecommerce ./k8s/helm

# Install the application:
helm install my-ecommerce ecommerce/ecommerce-chart

# Check deployment status:
helm status my-ecommerce

# List all releases:
helm list
```

### **Step 3: Customize Your Deployment**
```bash
# Create custom values file:
cat > my-values.yaml << EOF
frontend:
  replicas: 3
  image:
    tag: "v2.0"

backend:
  replicas: 2
  resources:
    requests:
      memory: "512Mi"
      cpu: "500m"

database:
  persistence:
    size: "20Gi"
EOF

# Deploy with custom values:
helm upgrade my-ecommerce ecommerce/ecommerce-chart -f my-values.yaml
```

### **Step 4: Manage Your Application**
```bash
# Upgrade to new version:
helm upgrade my-ecommerce ecommerce/ecommerce-chart --set frontend.image.tag=v2.1

# Rollback if something goes wrong:
helm rollback my-ecommerce 1

# Uninstall (removes everything):
helm uninstall my-ecommerce
```

---

## 🎨 **Kustomize Deployment**

### **What is Kustomize?**
Kustomize is a **configuration management tool** built into kubectl. It:
- **Organizes** configurations into base + overlays
- **Customizes** apps for different environments (dev/staging/prod)
- **Avoids** template hell with patches and transformations
- **Works** natively with kubectl (no extra tools needed)

### **Understanding the Structure**
```
k8s/
├── base/                 # Common configuration
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/            # Environment-specific
    ├── development/
    │   ├── kustomization.yaml
    │   └── resource-limits.yaml
    ├── staging/
    │   ├── kustomization.yaml
    │   └── replicas.yaml
    └── production/
        ├── kustomization.yaml
        ├── replicas.yaml
        └── monitoring.yaml
```

### **Step 1: Deploy to Development**
```bash
# Deploy base configuration:
kubectl apply -k k8s/base

# Deploy development overlay:
kubectl apply -k k8s/overlays/development

# Check what was deployed:
kubectl get all -l app=ecommerce
```

### **Step 2: Deploy to Staging**
```bash
# Create staging namespace:
kubectl create namespace staging

# Deploy to staging:
kubectl apply -k k8s/overlays/staging -n staging

# Compare environments:
kubectl get pods -n default
kubectl get pods -n staging
```

### **Step 3: Deploy to Production**
```bash
# Preview what will be deployed:
kubectl kustomize k8s/overlays/production

# Deploy to production:
kubectl apply -k k8s/overlays/production -n production

# Monitor the deployment:
kubectl rollout status deployment/frontend -n production
```

### **Step 4: Customize for Your Needs**
```bash
# Create your own overlay:
mkdir k8s/overlays/my-environment

# Create kustomization file:
cat > k8s/overlays/my-environment/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- resource-limits.yaml

images:
- name: ecommerce-frontend
  newTag: v2.0
- name: ecommerce-backend
  newTag: v2.0
EOF

# Deploy your custom environment:
kubectl apply -k k8s/overlays/my-environment
```

---

## 🎯 **Comparison: Which Option to Choose?**

| Feature | Raw YAML | Helm | Kustomize |
|---------|----------|------|-----------|
| **Learning Curve** | Easy | Medium | Hard |
| **Best For** | Learning | Production | Multi-env |
| **Reusability** | Low | High | Medium |
| **Flexibility** | Medium | High | Very High |
| **Community** | Built-in | Large | Growing |
| **Complexity** | Simple | Medium | Complex |

### **Choose Raw YAML if:**
- You're new to Kubernetes
- You want to understand the basics
- You have simple applications
- You prefer explicit configurations

### **Choose Helm if:**
- You want industry-standard approach
- You need to share applications
- You want easy upgrades/rollbacks
- You prefer mature ecosystem

### **Choose Kustomize if:**
- You have multiple environments
- You need advanced customization
- You prefer GitOps workflows
- You want built-in kubectl integration

---

## 🔄 **Advanced Operations**

### **Scaling Your Application**
```bash
# Raw YAML approach:
kubectl scale deployment frontend --replicas=5

# Helm approach:
helm upgrade my-ecommerce ecommerce/ecommerce-chart --set frontend.replicas=5

# Kustomize approach:
# Edit k8s/overlays/production/replicas.yaml then:
kubectl apply -k k8s/overlays/production
```

### **Rolling Updates**
```bash
# Update image version:
kubectl set image deployment/frontend frontend=ecommerce-frontend:v2.0

# Monitor rollout:
kubectl rollout status deployment/frontend

# Rollback if needed:
kubectl rollout undo deployment/frontend
```

### **Monitoring and Debugging**
```bash
# Check pod logs:
kubectl logs -f deployment/frontend

# Get shell access:
kubectl exec -it deployment/backend -- /bin/bash

# Check resource usage:
kubectl top pods

# Describe issues:
kubectl describe pod <pod-name>
```

---

## 🆘 **Troubleshooting Kubernetes**

### **Common Issues**
**Pods won't start:**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Services not accessible:**
```bash
kubectl get endpoints
kubectl port-forward service/frontend-service 8080:80
```

**Out of resources:**
```bash
kubectl top nodes
kubectl describe nodes
```

---

## 🎉 **What You've Accomplished**

**After completing this guide, you have:**
- ✅ **Production-ready** Kubernetes deployment
- ✅ **Scalable** application architecture
- ✅ **Industry-standard** deployment practices
- ✅ **Multiple deployment** strategies
- ✅ **Enterprise-level** skills

**This is what employers want to see!**

---

## 📚 **Next Steps**

**Ready for more advanced topics?**
- [Production Deployment](./production-deployment.md) - Cloud deployment
- [Monitoring Setup](../monitoring/README.md) - Prometheus + Grafana
- [CI/CD Pipelines](../ci-cd/README.md) - Automated deployments

**Want to practice more?** Try deploying other applications in this workspace!

---

**🎯 Kubernetes mastery takes time - you're on the right path!**