# 💻 Resource Requirements & Port Allocation Guide

Complete resource planning for all labs to help you optimize your local cluster setup.

---

## 🎯 Quick Reference

**Minimum cluster requirements**: 4 CPU cores, 8GB RAM, 20GB disk  
**Recommended**: 8 CPU cores, 16GB RAM, 50GB disk  
**Optimal for all labs**: 12+ CPU cores, 32GB RAM, 100GB disk

---

## 📊 Per-Lab Resource Requirements

### Lab 1: Weather App (Basics)
**Time**: 20 minutes  
**Pods**: 4 total (1 Redis, 1 backend, 2 frontend)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| Redis | 50m | 200m | 64Mi | 256Mi | 1 |
| Backend | 100m | 500m | 128Mi | 512Mi | 1 |
| Frontend | 50m | 250m | 64Mi | 256Mi | 2 |
| **Total** | **300m** | **1.45 CPU** | **384Mi** | **1.5Gi** | 4 pods |

**Ports Used**: 
- Frontend: 80 (service), 8080 (port-forward)
- Backend: 5000 (service & port-forward)
- Redis: 6379 (internal)

**Disk**: ~200MB for images

---

### Lab 2: E-commerce (Multi-Service)
**Time**: 30 minutes  
**Pods**: 7 total (1 MongoDB, 1 Redis, 2 backend, 3 frontend)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| MongoDB | 250m | 1000m | 256Mi | 1Gi | 1 |
| Redis | 50m | 200m | 64Mi | 256Mi | 1 |
| Backend | 100m | 500m | 128Mi | 512Mi | 2 |
| Frontend | 50m | 250m | 64Mi | 256Mi | 3 |
| **Total** | **650m** | **3.2 CPU** | **832Mi** | **3.25Gi** | 7 pods |

**Ports Used**:
- Frontend: 80 (service), 3000 (port-forward)
- Backend: 5000 (service & port-forward), 8000 (alt)
- MongoDB: 27017 (internal)
- Redis: 6379 (internal)

**Disk**: ~500MB for images + MongoDB storage

---

### Lab 3: Educational Platform (Stateful)
**Time**: 35 minutes  
**Pods**: 5 total (1 PostgreSQL, 2 backend, 2 frontend)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| PostgreSQL | 250m | 1000m | 256Mi | 1Gi | 1 |
| Backend (Java) | 500m | 2000m | 512Mi | 2Gi | 2 |
| Frontend | 50m | 250m | 64Mi | 256Mi | 2 |
| **Total** | **1.4 CPU** | **5.5 CPU** | **1.4Gi** | **5.5Gi** | 5 pods |

**Ports Used**:
- Frontend: 80 (service), 8080 (port-forward)
- Backend: 8080 (service & port-forward)
- PostgreSQL: 5432 (internal)

**Disk**: ~800MB for images + 5Gi PVC for database

---

### Lab 4: Task Manager (Ingress)
**Time**: 25 minutes  
**Pods**: 4 total (1 PostgreSQL, 2 backend, 1 frontend) + Ingress controller

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| PostgreSQL | 250m | 1000m | 256Mi | 1Gi | 1 |
| Backend (Go) | 100m | 500m | 128Mi | 512Mi | 2 |
| Frontend | 50m | 250m | 64Mi | 256Mi | 1 |
| NGINX Ingress | 100m | 500m | 90Mi | 384Mi | 1 |
| **Total** | **650m** | **2.75 CPU** | **730Mi** | **2.6Gi** | 5 pods |

**Ports Used**:
- Ingress: 80, 443 (LoadBalancer), 8080 (port-forward fallback)
- Backend: 8080 (internal)
- Frontend: 80 (internal)
- PostgreSQL: 5432 (internal)

**Disk**: ~600MB for images + 2Gi PVC for database

---

### Lab 5: Medical System (Security)
**Time**: 40 minutes  
**Pods**: 5 total (1 PostgreSQL, 2 backend, 2 frontend)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| PostgreSQL | 250m | 1000m | 256Mi | 1Gi | 1 |
| Backend (.NET) | 250m | 1000m | 256Mi | 1Gi | 2 |
| Frontend (Blazor) | 100m | 500m | 128Mi | 512Mi | 2 |
| **Total** | **1 CPU** | **5 CPU** | **1.28Gi** | **5Gi** | 5 pods |

**Ports Used**:
- Frontend: 80 (service)
- Backend: 5000, 8080 (service)
- PostgreSQL: 5432 (internal)

**Disk**: ~1GB for images + 5Gi PVC for database

---

### Lab 6: Social Media (Autoscaling)
**Time**: 45 minutes  
**Pods**: 3-10 total (1 PostgreSQL, 2 Redis, 1-5 backend HPA, 2 frontend)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Min/Max Replicas |
|-----------|-------------|-----------|----------------|--------------|------------------|
| PostgreSQL | 250m | 1000m | 256Mi | 1Gi | 1 |
| Redis | 50m | 200m | 64Mi | 256Mi | 2 |
| Backend (Ruby) | 200m | 800m | 256Mi | 1Gi | 1-5 (HPA) |
| Frontend | 50m | 250m | 64Mi | 256Mi | 2 |
| Metrics Server | 100m | 200m | 200Mi | 400Mi | 1 |
| **Total** | **0.9-1.7 CPU** | **3.4-7 CPU** | **1.16-2.4Gi** | **4.4-8Gi** | 8-12 pods |

**Ports Used**:
- Frontend: 80 (service), 3000 (port-forward)
- Backend: 3000, 8000 (service & port-forward)
- PostgreSQL: 5432 (internal)
- Redis: 6379 (internal)

**Disk**: ~1.2GB for images + 10Gi PVC for database

---

### Lab 7: Multi-App Orchestration
**Time**: 60 minutes  
**Pods**: 24 total (4 databases, 6 backends, 8 frontends, 6 supporting services)

| Namespace | CPU Request | CPU Limit | Memory Request | Memory Limit | Pods |
|-----------|-------------|-----------|----------------|--------------|------|
| Weather | 300m | 1.45 CPU | 384Mi | 1.5Gi | 4 |
| E-commerce | 650m | 3.2 CPU | 832Mi | 3.25Gi | 7 |
| Educational | 1.4 CPU | 5.5 CPU | 1.4Gi | 5.5Gi | 5 |
| Task Manager | 500m | 2.25 CPU | 602Mi | 2.4Gi | 4 |
| Medical | 1 CPU | 5 CPU | 1.28Gi | 5Gi | 5 |
| Social | 900m | 3.4 CPU | 1.16Gi | 4.4Gi | 8 |
| **Total** | **4.75 CPU** | **20.8 CPU** | **5.66Gi** | **22Gi** | 33 pods |

**Additional Infrastructure**:
- Monitoring (Prometheus/Grafana): 2 CPU, 6GB RAM
- Istio Service Mesh: 1.5 CPU, 2GB RAM

**Ports Used**: All ports from Labs 1-6 simultaneously
- Unique port-forwards required (see Port Allocation Matrix below)

**Disk**: ~5GB for images + 30Gi PVC total

---

### Lab 8: Chaos Engineering
**Time**: 50 minutes  
**Pods**: 12 total (Social Media app + Chaos Mesh)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| Social Media App | 900m | 3.4 CPU | 1.16Gi | 4.4Gi | 8 |
| Chaos Mesh Controller | 500m | 1000m | 512Mi | 1Gi | 1 |
| Chaos Daemon | 100m | 500m | 128Mi | 512Mi | 3 (DaemonSet) |
| **Total** | **1.8 CPU** | **6.4 CPU** | **2.04Gi** | **7.4Gi** | 12 pods |

**Ports Used**:
- Social Backend: 8000 (port-forward)
- Chaos Dashboard: 2333 (port-forward), 8080 (alt)

**Disk**: ~1.5GB for images

---

### Lab 9: Helm Package Management
**Time**: 40 minutes  
**Pods**: 4 total (Weather app via Helm)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| Weather App | 300m | 1.45 CPU | 384Mi | 1.5Gi | 4 |
| **Total** | **300m** | **1.45 CPU** | **384Mi** | **1.5Gi** | 4 pods |

**Ports Used**:
- Frontend: 3000 (port-forward)

**Disk**: ~200MB for images

---

### Lab 10: GitOps with ArgoCD
**Time**: 60 minutes  
**Pods**: 7 total (ArgoCD + Weather app)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| ArgoCD Server | 250m | 500m | 256Mi | 512Mi | 1 |
| ArgoCD Repo Server | 250m | 500m | 256Mi | 512Mi | 1 |
| ArgoCD Controller | 250m | 1000m | 256Mi | 1Gi | 1 |
| Weather App | 300m | 1.45 CPU | 384Mi | 1.5Gi | 4 |
| **Total** | **1.05 CPU** | **3.45 CPU** | **1.15Gi** | **3.5Gi** | 7 pods |

**Ports Used**:
- ArgoCD UI: 443 (service), 8080 (port-forward)
- Weather App: same as Lab 1

**Disk**: ~800MB for images + Git repository clone

---

### Lab 11: External Secrets Operator
**Time**: 60 minutes  
**Pods**: 8 total (ESO + Vault + App)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| External Secrets Operator | 100m | 200m | 128Mi | 256Mi | 1 |
| HashiCorp Vault | 250m | 500m | 256Mi | 512Mi | 1 |
| Test App (E-commerce) | 650m | 3.2 CPU | 832Mi | 3.25Gi | 6 |
| **Total** | **1 CPU** | **3.9 CPU** | **1.22Gi** | **4Gi** | 8 pods |

**Ports Used**:
- Vault UI: 8200 (port-forward)
- ESO Webhook: 9443 (internal)
- E-commerce: same as Lab 2

**Disk**: ~700MB for images + 1Gi PVC for Vault persistence

---

### Lab 12: Kubernetes Fundamentals
**Time**: 45 minutes  
**Pods**: Variable (5-15 for practice)

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| Practice Workloads | 500m | 2 CPU | 512Mi | 2Gi | 5-15 |
| **Total** | **500m** | **2 CPU** | **512Mi** | **2Gi** | 5-15 pods |

**Ports Used**: Variable for testing

**Disk**: ~300MB for images

---

## 🔌 Port Allocation Matrix

### Standard Service Ports (Internal ClusterIP)
| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| Redis | 6379 | TCP | Cache layer |
| MongoDB | 27017 | TCP | NoSQL database |
| PostgreSQL | 5432 | TCP | Relational database |
| MySQL | 3306 | TCP | Relational database (if used) |

### Application Service Ports (ClusterIP)
| App | Service | Port | Description |
|-----|---------|------|-------------|
| Weather | Backend | 5000 | Python Flask API |
| Weather | Frontend | 80 | Vue.js static site |
| E-commerce | Backend | 5000 | Node.js API |
| E-commerce | Frontend | 80 | React SPA |
| Educational | Backend | 8080 | Spring Boot API |
| Educational | Frontend | 80 | Angular SPA |
| Task Manager | Backend | 8080 | Go API |
| Task Manager | Frontend | 80 | Svelte SPA |
| Medical | Backend | 5000/8080 | .NET API |
| Medical | Frontend | 80 | Blazor WASM |
| Social Media | Backend | 3000/8000 | Ruby on Rails API |
| Social Media | Frontend | 80 | React Native Web |

### Port-Forward Usage (Localhost Access)
| Lab | Service | Local Port | Remote Port | Usage |
|-----|---------|-----------|-------------|-------|
| Lab 1 | Weather Frontend | 8080 | 80 | Browser access |
| Lab 1 | Weather Backend | 5000 | 5000 | API testing |
| Lab 2 | E-commerce Frontend | 3000 | 80 | Browser access |
| Lab 2 | E-commerce Backend | 5000 | 5000 | API testing |
| Lab 3 | Educational Frontend | 8080 | 80 | Browser access |
| Lab 4 | Ingress Controller | 8080 | 80 | Multi-app access |
| Lab 6 | Social Backend | 8000 | 8000 | Load testing |
| Lab 8 | Chaos Dashboard | 2333 | 2333 | Chaos UI |
| Lab 8 | Chaos Dashboard (alt) | 8080 | 2333 | If 2333 busy |
| Lab 8 | Monitoring Grafana | 3000 | 80 | Metrics UI |
| Lab 8 | Kiali | 20001 | 20001 | Service mesh UI |
| Lab 9 | Weather Helm | 3000 | 3000 | Helm deployment test |
| Lab 10 | ArgoCD UI | 8080 | 443 | GitOps dashboard |
| Lab 11 | Vault UI | 8200 | 8200 | Secrets management |

### Infrastructure Ports
| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| NGINX Ingress | 80 | TCP | HTTP traffic |
| NGINX Ingress | 443 | TCP | HTTPS traffic |
| Istio Ingress Gateway | 80, 443 | TCP | Service mesh ingress |
| Prometheus | 9090 | TCP | Metrics scraping |
| Grafana | 3000/80 | TCP | Dashboards |
| AlertManager | 9093 | TCP | Alert routing |
| Node Exporter | 9100 | TCP | Node metrics |
| Metrics Server | 443 | TCP | Resource metrics API |
| ArgoCD Server | 443/8080 | TCP | GitOps UI |
| Vault | 8200 | TCP | Secrets API/UI |
| External Secrets Webhook | 9443 | TCP | Webhook validation |
| Chaos Mesh Dashboard | 2333 | TCP | Chaos engineering UI |
| Kiali | 20001 | TCP | Istio service graph |

---

## 🚨 Port Conflict Prevention

### When Running Multiple Labs Simultaneously

If you're running Lab 8 (Multi-App) where all apps run together, **port-forward conflicts** can occur. Use these strategies:

**Strategy 1: Use Different Local Ports**
```bash
# Lab 1 Weather
kubectl port-forward -n weather-lab svc/weather-frontend 8081:80 &

# Lab 2 E-commerce  
kubectl port-forward -n ecommerce-lab svc/ecommerce-frontend 8082:80 &

# Lab 3 Educational
kubectl port-forward -n educational-lab svc/educational-frontend 8083:80 &
```

**Strategy 2: Use Ingress Instead**
```bash
# Install NGINX Ingress (Lab 4)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Access via paths instead of ports
curl http://localhost/weather
curl http://localhost/ecommerce
curl http://localhost/educational
```

**Strategy 3: Kill Unused Port-Forwards**
```bash
# List active port-forwards
ps aux | grep port-forward

# Kill all port-forwards
pkill -f "port-forward"

# Kill specific port-forward by PID
kill <PID>
```

### Port-Forward Best Practices

1. **Always add `&` for background process**
   ```bash
   kubectl port-forward svc/myapp 8080:80 &
   ```

2. **Add sleep after port-forward**
   ```bash
   kubectl port-forward svc/myapp 8080:80 &
   sleep 2  # Wait for port-forward to establish
   ```

3. **Clean up when done**
   ```bash
   # At end of lab
   pkill -f "port-forward.*myapp"
   ```

4. **Check for conflicts before starting**
   ```bash
   lsof -i :8080  # Check if port 8080 is in use
   ```

---

## 🧮 Cumulative Resource Calculation

### Running All Labs Sequentially (One at a Time)
- **Peak requirement**: Lab 8 Multi-App
- **CPU**: 8 cores minimum, 12 cores recommended
- **Memory**: 16GB minimum, 32GB recommended
- **Disk**: 50GB minimum

### Running Labs Concurrently (Learning Path)
- **Labs 1-3** (Foundation): 3 CPU, 4GB RAM
- **Labs 4-6** (Operations): 5 CPU, 8GB RAM  
- **Labs 7-9** (Platform): 12 CPU, 24GB RAM
- **Labs 10-12** (Automation): 6 CPU, 10GB RAM

### Cloud Instance Recommendations

**AWS EKS**:
- Node Type: `t3.xlarge` (4 vCPU, 16GB)
- Count: 3 nodes (for HA)
- Total: 12 vCPU, 48GB RAM
- Cost: ~$0.67/hr = ~$480/month

**GCP GKE**:
- Node Type: `n1-standard-4` (4 vCPU, 15GB)
- Count: 3 nodes
- Total: 12 vCPU, 45GB RAM
- Cost: ~$0.62/hr = ~$450/month

**Azure AKS**:
- Node Type: `Standard_D4s_v3` (4 vCPU, 16GB)
- Count: 3 nodes
- Total: 12 vCPU, 48GB RAM
- Cost: ~$0.68/hr = ~$490/month

**Local Cluster (Rancher Desktop/kind)**:
- **FREE** ✅
- Runs on your machine
- Recommended specs: MacBook Pro M1/M2 with 16GB+ RAM
- Or: Windows/Linux desktop with 16GB+ RAM, 4+ cores

---

## 💡 Resource Optimization Tips

### 1. Reduce Replica Counts for Learning
```yaml
# Instead of
replicas: 3

# Use
replicas: 1  # For local learning
```

### 2. Lower Resource Limits
```yaml
resources:
  requests:
    memory: "64Mi"   # Instead of 128Mi
    cpu: "50m"       # Instead of 100m
  limits:
    memory: "256Mi"  # Instead of 512Mi
    cpu: "250m"      # Instead of 500m
```

### 3. Clean Up Between Labs
```bash
# Delete completed lab namespace
kubectl delete namespace weather-lab

# Prune unused images
docker system prune -a

# Clean up PVCs
kubectl delete pvc --all -n old-namespace
```

### 4. Use Resource Quotas
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: lab-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    pods: "20"
```

### 5. Monitor Resource Usage
```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -A

# Check resource quotas
kubectl describe quota -n <namespace>

# Use k9s for visual monitoring
k9s
```

---

## 🔍 Troubleshooting Resource Issues

### Pods Stuck in Pending
```bash
# Check why pod is pending
kubectl describe pod <pod-name> -n <namespace>

# Common causes:
# 1. Insufficient CPU/memory
# 2. No nodes match nodeSelector
# 3. PVC not bound
```

### Out of Memory (OOMKilled)
```bash
# Pod killed due to memory limit
kubectl get pods -A | grep OOMKilled

# Solution: Increase memory limits
resources:
  limits:
    memory: "1Gi"  # Increase from 512Mi
```

### CPU Throttling
```bash
# Check if pods are throttled
kubectl top pods -A

# If CPU is at limit, increase:
resources:
  limits:
    cpu: "1000m"  # Increase from 500m
```

### Disk Pressure
```bash
# Check node disk usage
kubectl describe node <node-name> | grep -A 5 Conditions

# Clean up
docker system prune -a -f
kubectl delete pods --field-selector status.phase=Failed -A
```

---

## 📋 Pre-Lab Checklist

Before starting any lab, run this checklist:

```bash
# 1. Check available resources
kubectl top nodes

# 2. Verify sufficient capacity
# Nodes should show < 80% CPU/memory used

# 3. Check disk space
df -h

# 4. Ensure port is free (if port-forwarding)
lsof -i :8080

# 5. Run lab prerequisites
./scripts/check-lab-prereqs.sh <lab-number>

# 6. Clean up previous labs if needed
kubectl get namespaces
kubectl delete namespace <old-lab>
```

---

## 🎯 Resource Planning Examples

### Example 1: Running Lab 8 (Multi-App)
```
Needed: 4.75 CPU requests, 20.8 CPU limits, 5.66Gi RAM requests, 22Gi RAM limits
Your cluster: MacBook Pro M1 with 16GB RAM

✅ Can run with reduced replicas:
- Set all apps to 1 replica instead of 2-3
- Reduce Java apps memory to 512Mi instead of 2Gi
- Result: ~3 CPU, 8GB RAM needed
```

### Example 2: Running Multiple Labs Concurrently
```
Scenario: Testing Lab 1 & Lab 2 together

Lab 1: 300m CPU, 384Mi RAM
Lab 2: 650m CPU, 832Mi RAM
Total: 950m CPU, 1.2GB RAM

✅ No conflicts! Different namespaces, different services
⚠️ Port conflicts: Both use 5000 for backend
Solution: Use different local ports for port-forward
```

---

## 📚 Additional Resources

- [Kubernetes Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [kubectl top Command](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#top)
- [k9s Terminal UI](https://k9scli.io/)
- [Managing Compute Resources](https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/)

---

**Navigation**: [Back to Labs](../../README.md) | [Documentation Hub](../README.md) | [kubectl Cheat Sheet](kubectl-cheatsheet.md)

**Last updated**: October 20, 2025
