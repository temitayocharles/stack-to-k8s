# 🧩 Lab 8 Lite: Multi-App Orchestration (Reduced Resources)

> 🚀 **[⚡ Quick Reference Guide](LAB-8-LITE-QUICK-REFERENCE.md)** — Jump to key metrics, file locations, and getting started in 2 minutes

## Overview

**Lab 8 Standard** requires significant resources (~3 CPU / 4GB RAM) and deploys all 6 applications. For developers with **8-12 CPU / 8-16GB RAM machines**, use **Lab 8 Lite** instead.

### What's Included in Lab 8 Lite?

| Component | Standard Lab 8 | Lab 8 Lite | Status |
|-----------|----------------|-----------|--------|
| Weather App | ✅ | ✅ | Core (kept) |
| E-commerce App | ✅ | ✅ | Core (kept) |
| Educational Platform | ✅ | ❌ | Skipped |
| Task Manager | ✅ | ✅ | Core (kept) |
| Medical Care System | ✅ | ❌ | Skipped |
| Social Media Platform | ✅ | ❌ | Skipped |
| **Total Apps** | **6** | **3** | **50% reduction** |

---

## 📊 Resource Comparison

### Standard Lab 8 (All 6 Apps)
```
CPU Request:  4.75 cores
CPU Limit:    20.8 cores
Memory:       5.8Gi
Pods:         33 total
```

### Lab 8 Lite (3 Apps)
```
CPU Request:  850m (0.85 cores)
CPU Limit:    2.7 cores  
Memory:       1.2Gi
Pods:         6 total
```

### Resource Savings
```
CPU Request:  82% reduction ⬇️
CPU Limit:    87% reduction ⬇️
Memory:       79% reduction ⬇️
Pods:         82% reduction ⬇️
```

---

## ✅ Learning Outcomes (Still Complete)

You'll still learn all core multi-app orchestration concepts:

- ✅ **Deploying multiple independent services** in one cluster
- ✅ **Inter-service communication** (services discovering each other)
- ✅ **Shared infrastructure** (namespaces, storage, networking)
- ✅ **Resource allocation** across multiple apps
- ✅ **Service routing** and load balancing
- ✅ **Observability patterns** across apps
- ✅ **Health checks** and readiness probes
- ✅ **ConfigMaps and Secrets** shared across services

**What you won't practice**:
- ❌ Extreme resource constraints
- ❌ All architectural patterns from 6 apps
- ❌ Complex stateful application orchestration

---

## 🚀 Quick Start: Lab 8 Lite

### Prerequisites Check
```bash
./scripts/check-lab-prereqs.sh 8

# Expected output:
# ✅ Kubernetes cluster accessible
# ✅ kubectl, helm, docker available
# ⚠️ Recommended 7+ CPU / 8GB RAM
# ℹ️  Lab 8 Lite available for 8-12 CPU machines
```

### Setup: Option A (Simplest - Manual)

**Step 1: Create namespace**
```bash
kubectl create namespace lab-multi
```

**Step 2: Deploy 3 apps**
```bash
# Weather App
kubectl apply -f weather-app/k8s/namespace.yaml
kubectl apply -f weather-app/k8s/redis-deployment.yaml -n lab-multi
kubectl apply -f weather-app/k8s/backend-deployment.yaml -n lab-multi
kubectl apply -f weather-app/k8s/frontend-deployment.yaml -n lab-multi
kubectl apply -f weather-app/k8s/services.yaml -n lab-multi

# E-commerce App
kubectl apply -f ecommerce-app/k8s/mongodb-deployment.yaml -n lab-multi
kubectl apply -f ecommerce-app/k8s/backend-deployment.yaml -n lab-multi
kubectl apply -f ecommerce-app/k8s/frontend-deployment.yaml -n lab-multi
kubectl apply -f ecommerce-app/k8s/services.yaml -n lab-multi

# Task Manager App
kubectl apply -f task-management-app/k8s/postgres-deployment.yaml -n lab-multi
kubectl apply -f task-management-app/k8s/backend-deployment.yaml -n lab-multi
kubectl apply -f task-management-app/k8s/frontend-deployment.yaml -n lab-multi
kubectl apply -f task-management-app/k8s/services.yaml -n lab-multi
```

**Step 3: Verify all pods running**
```bash
kubectl get pods -n lab-multi -w

# Wait for all to show Running + Ready
# Expected: ~6 pods (2 per app: frontend + backend)
```

### Setup: Option B (Kustomize - Cleaner)

If manifests support overlays:
```bash
kustomize build labs/manifests/lab-08-lite | kubectl apply -f -

# Or create a custom kustomization.yaml:
cat > kustomization.yaml <<'EOF'
resources:
  - weather-app/k8s/
  - ecommerce-app/k8s/
  - task-management-app/k8s/

namespace: lab-multi

commonLabels:
  app: multi-orchestration
  scenario: lab-8-lite
EOF

kustomize build . | kubectl apply -f -
```

### Setup: Option C (Docker Compose Approach)

If you prefer a template:
```bash
cat > docker-compose-lab8-lite.yml <<'EOF'
version: '3.8'
services:
  # Weather
  weather-backend:
    image: temitayocharles/weather-backend:latest
    environment:
      REDIS_HOST: weather-redis
  
  weather-frontend:
    image: temitayocharles/weather-frontend:latest
    ports:
      - "8080:80"
  
  weather-redis:
    image: redis:7-alpine
  
  # E-commerce
  ecommerce-backend:
    image: temitayocharles/ecommerce-backend:latest
    environment:
      MONGO_URI: mongodb://ecommerce-db
  
  ecommerce-frontend:
    image: temitayocharles/ecommerce-frontend:latest
    ports:
      - "3000:80"
  
  ecommerce-db:
    image: mongo:6
  
  # Task Manager
  task-backend:
    image: temitayocharles/task-backend:latest
    environment:
      DB_HOST: task-db
  
  task-frontend:
    image: temitayocharles/task-frontend:latest
    ports:
      - "4200:80"
  
  task-db:
    image: postgres:15
EOF

# Deploy (local testing only)
docker-compose -f docker-compose-lab8-lite.yml up
```

---

## 🔍 Verification: Did Lab 8 Lite Deploy Successfully?

### Check Resources
```bash
# View all pods
kubectl get pods -n lab-multi

# Expected output:
# NAME                                READY   STATUS    RESTARTS   AGE
# weather-backend-7c4d5b...           1/1     Running   0          2m
# weather-frontend-8f3a2d...          1/1     Running   0          2m
# redis-7d2f1c...                     1/1     Running   0          2m
# ecommerce-backend-6b8d4a...         1/1     Running   0          1m
# ecommerce-frontend-9c5e3b...        1/1     Running   0          1m
# mongodb-5a1c2b...                   1/1     Running   0          1m
# task-backend-4f3b1a...              1/1     Running   0          1m
# task-frontend-2c8d9f...             1/1     Running   0          1m
# postgres-1a2b3c...                  1/1     Running   0          1m
```

### Check Services
```bash
kubectl get svc -n lab-multi

# Expected:
# weather-backend, weather-frontend, redis-svc
# ecommerce-backend, ecommerce-frontend, mongodb-svc
# task-backend, task-frontend, postgres-svc
```

### Check Resource Usage
```bash
# CPU and memory usage
kubectl top pods -n lab-multi

# Expected: ~850m CPU, 1.2Gi memory total
```

### Test Connectivity
```bash
# Port-forward to test each app
kubectl port-forward -n lab-multi svc/weather-frontend 8080:80 &
curl localhost:8080  # Should show Weather frontend

kubectl port-forward -n lab-multi svc/ecommerce-frontend 3000:80 &
curl localhost:3000  # Should show E-commerce frontend

kubectl port-forward -n lab-multi svc/task-frontend 4200:80 &
curl localhost:4200  # Should show Task Manager frontend
```

---

## 🎯 Challenge Tasks (Lab 8 Lite)

After successfully deploying all 3 apps:

### Challenge 1: Service Discovery
```bash
# Inside weather-backend pod, can you resolve ecommerce-frontend?
kubectl exec -it -n lab-multi deployment/weather-backend -- \
  nslookup ecommerce-frontend

# Expected: Should resolve to cluster IP
```

### Challenge 2: Cross-App Communication
```bash
# Test: Weather app calls E-commerce API
kubectl exec -it -n lab-multi deployment/weather-backend -- \
  curl http://ecommerce-backend:5000/api/products

# Expected: 200 response (or expected error, not connection error)
```

### Challenge 3: Resource Monitoring
```bash
# Using k9s, watch all pods scale/restart
k9s -n lab-multi

# Try these in separate terminals:
# 1. Scale weather-backend to 3 replicas
kubectl scale deployment weather-backend -n lab-multi --replicas=3

# 2. Watch pod distribution using k9s

# 3. Check: Are pods spread across nodes? (kind/k3d)
kubectl get pods -n lab-multi -o wide
```

### Challenge 4: Failure Resilience
```bash
# Delete a pod and watch it auto-recover
kubectl delete pod -n lab-multi $(kubectl get pods -n lab-multi | grep weather-backend | head -1 | awk '{print $1}')

# Watch in another terminal
watch kubectl get pods -n lab-multi

# Expected: Pod automatically recreated in <5s
```

### Challenge 5: Namespace Isolation
```bash
# Can weather-backend reach pods in default namespace?
kubectl exec -it -n lab-multi deployment/weather-backend -- \
  nslookup kubernetes.default

# Try reaching a non-existent service in different namespace
kubectl exec -it -n lab-multi deployment/weather-backend -- \
  curl http://some-service.default.svc.cluster.local

# Expected: DNS resolution works (namespace isolation is transparent within cluster)
```

---

## 📈 Scaling Lab 8 Lite

### Horizontal Scaling (More Replicas)
```bash
# Scale each app
kubectl scale deployment weather-backend -n lab-multi --replicas=3
kubectl scale deployment weather-frontend -n lab-multi --replicas=2
kubectl scale deployment ecommerce-backend -n lab-multi --replicas=3
kubectl scale deployment ecommerce-frontend -n lab-multi --replicas=2
kubectl scale deployment task-backend -n lab-multi --replicas=3
kubectl scale deployment task-frontend -n lab-multi --replicas=2

# Monitor resource usage
kubectl top pods -n lab-multi
# CPU should increase proportionally
```

### Vertical Scaling (More Resources Per Pod)
```bash
# Increase resource limits for a deployment
kubectl set resources deployment weather-backend -n lab-multi \
  --limits=cpu=500m,memory=512Mi \
  --requests=cpu=250m,memory=256Mi
```

---

## 🔗 Cleanup: Removing Lab 8 Lite

```bash
# Option 1: Delete entire namespace (removes all resources)
kubectl delete namespace lab-multi

# Option 2: Delete only specific apps
kubectl delete deployment weather-backend -n lab-multi
kubectl delete deployment weather-frontend -n lab-multi
kubectl delete deployment ecommerce-backend -n lab-multi
kubectl delete deployment ecommerce-frontend -n lab-multi
kubectl delete deployment task-backend -n lab-multi
kubectl delete deployment task-frontend -n lab-multi

# Option 3: Use cleanup script
./scripts/cleanup-workspace.sh
```

---

## ⚠️ Why Skip These 3 Apps?

### Educational Platform ❌ (Stateful + Heavy)
- Requires StatefulSet (PostgreSQL with persistence)
- More resource-intensive (~600m CPU, 640Mi memory)
- Learning in Lab 8 Lite: Can learn statefulness from Task Manager + PostgreSQL
- **Alternative**: Do Lab 3 separately to learn StatefulSets

### Medical Care System ❌ (Security + Complex)
- Requires RBAC + NetworkPolicies
- Complex deployment patterns
- Learning in Lab 8 Lite: Can learn security patterns in Lab 6
- **Alternative**: Do Lab 6 separately to learn security

### Social Media Platform ❌ (HPA + Cache Layers)
- Requires Horizontal Pod Autoscaler
- Complex caching infrastructure (Redis, multiple layers)
- Learning in Lab 8 Lite: Can learn autoscaling in Lab 7
- **Alternative**: Do Lab 7 separately to learn HPA

---

## 🚀 After Lab 8 Lite: Next Steps

### Option 1: Continue to Lab 9+ (Recommended)
```bash
# Clean up Lab 8 Lite
kubectl delete namespace lab-multi

# Move to next lab
./scripts/check-lab-prereqs.sh 9
# Lab 9: Chaos Engineering
```

### Option 2: Upgrade to Full Lab 8
If your machine now has more resources:
```bash
# Add the 3 missing apps
kubectl apply -f educational-platform/k8s/ -n lab-multi
kubectl apply -f medical-care-system/k8s/ -n lab-multi
kubectl apply -f social-media-platform/k8s/ -n lab-multi

# Monitor
kubectl top pods -n lab-multi
```

### Option 3: Deep Dive into Specific Labs
Each skipped app has a dedicated lab:
- Lab 3: Educational Platform (Stateful applications)
- Lab 6: Medical Care System (Security & RBAC)
- Lab 7: Social Media (Autoscaling & Performance)

---

## 📋 Lab 8 Lite Checklist

- [ ] Prerequisites checked: `./scripts/check-lab-prereqs.sh 8`
- [ ] Namespace created: `kubectl create namespace lab-multi`
- [ ] Weather App deployed
- [ ] E-commerce App deployed
- [ ] Task Manager deployed
- [ ] All pods running: `kubectl get pods -n lab-multi | grep Running`
- [ ] All services created: `kubectl get svc -n lab-multi`
- [ ] Port-forward tests successful
- [ ] Challenge 1: Service Discovery ✅
- [ ] Challenge 2: Cross-app Communication ✅
- [ ] Challenge 3: Resource Monitoring ✅
- [ ] Challenge 4: Failure Resilience ✅
- [ ] Challenge 5: Namespace Isolation ✅
- [ ] Resources cleaned up

---

## 🔗 Related Documentation

- 📖 [Lab 8: Full Multi-App Orchestration](../../labs/08-multi-app.md)
- 💾 [Resource Requirements Guide](../30-reference/deep-dives/resource-requirements.md)
- 🧩 [Resource Estimation Section](../../README.md#-resource-estimation-which-labs-fit-your-machine)
- 🏗️ [Cluster Topology Guide](./CLUSTER-TOPOLOGY.md)
- 🧪 [Test Breakdown & Analysis](./LAB-8-LITE-TEST-BREAKDOWN.md)
- ✅ [Lab Progress Tracker](../../labs/LAB-PROGRESS.md)

---

**Last updated**: October 21, 2025  
**Difficulty**: ⭐⭐⭐⭐ (Advanced multi-service orchestration)  
**Estimated time**: 45-60 minutes (vs. 120 minutes for full Lab 8)  
**Machine requirement**: 8-12 CPU / 8-16GB RAM
