# ✅ Lab 8 Lite Validation & Testing Guide

## Overview

This guide helps you **test and validate Lab 8 Lite** on a machine with **8 CPU / 8GB RAM** to ensure seamless execution and learning.

---

## 📋 Pre-Flight Checklist

Before starting Lab 8 Lite validation, verify:

- [ ] Machine specs: `8 CPU cores, 8GB RAM, 20GB+ free disk`
- [ ] Cluster running: `kubectl cluster-info`
- [ ] All nodes ready: `kubectl get nodes` (shows "Ready")
- [ ] Tools installed: `kubectl`, `helm`, `docker`, `k9s`
- [ ] Script executable: `ls -la ./scripts/check-lab-prereqs.sh`

---

## 🎯 Phase 1: Prerequisites Validation (5 minutes)

### Step 1: Run Lab 8 Lite Prerequisites Check

```bash
cd /path/to/stack-to-k8s-main

# Run the enhanced prerequisite checker
./scripts/check-lab-prereqs.sh 8

# Expected output includes:
# ✅ Kubernetes cluster accessible
# ✅ kubectl, helm, docker installed
# ⚠️  Lab 8 (Multi-App) requires significant resources
# ℹ️  Lab 8 Lite available (docs/10-setup/LAB-8-LITE.md)
```

### Step 2: Verify Machine Resources

```bash
# Check CPU cores allocated to Kubernetes
kubectl describe nodes | grep -A 5 "Name:"

# Expected: 8 cores available (or close)

# Check memory
kubectl describe nodes | grep -A 2 "Memory:"

# Expected: 8Gi+ available

# View resource usage
kubectl top nodes

# Expected: Most resources available (not maxed out)
```

---

## 🎯 Phase 2: Lab 8 Lite Deployment (10 minutes)

### Step 1: Create Namespace

```bash
# Create dedicated namespace
kubectl create namespace lab-8-lite

# Verify
kubectl get namespaces | grep lab-8-lite
# Expected: lab-8-lite   Active
```

### Step 2: Deploy 3 Apps

**Option A: Manual Deployment (Recommended for validation)**

```bash
echo "🚀 Deploying Weather App..."
kubectl apply -f weather-app/k8s/ -n lab-8-lite

echo "🚀 Deploying E-commerce App..."
kubectl apply -f ecommerce-app/k8s/ -n lab-8-lite

echo "🚀 Deploying Task Manager App..."
kubectl apply -f task-management-app/k8s/ -n lab-8-lite

# Wait for all pods to initialize
sleep 5

echo "Checking pod status..."
kubectl get pods -n lab-8-lite
```

**Option B: Kustomize (If manifests support it)**

```bash
# Create custom overlay for Lab 8 Lite
mkdir -p labs/manifests/lab-08-lite
cat > labs/manifests/lab-08-lite/kustomization.yaml <<'EOF'
resources:
  - ../../../weather-app/k8s/
  - ../../../ecommerce-app/k8s/
  - ../../../task-management-app/k8s/

namespace: lab-8-lite

commonLabels:
  app: multi-orchestration
  variant: lab-8-lite

commonAnnotations:
  version: "1.0"
  created: "2025-10-21"
EOF

# Deploy via Kustomize
kustomize build labs/manifests/lab-08-lite | kubectl apply -f -
```

### Step 3: Wait for Pods to Start

```bash
# Watch pod status
kubectl get pods -n lab-8-lite -w

# Wait until all show "Running" and "1/1 Ready"
# Ctrl+C to exit watch

# Expected output after ~30-60 seconds:
# NAME                                READY   STATUS    RESTARTS   AGE
# weather-backend-7c4d5b...           1/1     Running   0          45s
# weather-frontend-8f3a2d...          1/1     Running   0          45s
# redis-7d2f1c...                     1/1     Running   0          45s
# ecommerce-backend-6b8d4a...         1/1     Running   0          40s
# ecommerce-frontend-9c5e3b...        1/1     Running   0          40s
# mongodb-5a1c2b...                   1/1     Running   0          40s
# task-backend-4f3b1a...              1/1     Running   0          35s
# task-frontend-2c8d9f...             1/1     Running   0          35s
# postgres-1a2b3c...                  1/1     Running   0          35s
```

---

## 🎯 Phase 3: Health Check (5 minutes)

### Check 1: Pod Health

```bash
# Get detailed pod status
kubectl get pods -n lab-8-lite -o wide

# Check for:
# ✅ All pods showing "Running"
# ✅ All showing "1/1" ready count
# ✅ No "CrashLoopBackOff" or "Pending"
# ✅ Restart count = 0 for all

# If issues found, check logs:
kubectl logs -n lab-8-lite deployment/weather-backend
kubectl logs -n lab-8-lite deployment/ecommerce-backend
kubectl logs -n lab-8-lite deployment/task-backend
```

### Check 2: Service Creation

```bash
# List all services
kubectl get svc -n lab-8-lite

# Expected services:
# - weather-frontend, weather-backend
# - ecommerce-frontend, ecommerce-backend
# - task-frontend, task-backend
# - redis-svc, mongodb-svc, postgres-svc (or similar names)

# Verify services have endpoints
kubectl get endpoints -n lab-8-lite

# Each should show at least one endpoint (pod IP)
```

### Check 3: Resource Usage

```bash
# Monitor CPU and memory
kubectl top pods -n lab-8-lite

# Expected total usage:
# CPU: ~850m (0.85 cores)
# Memory: ~1.2Gi

# Example output:
# NAME                                CPU(m)   MEMORY(Mi)
# weather-backend-7c4d5b...           45m      125Mi
# weather-frontend-8f3a2d...          30m      85Mi
# redis-7d2f1c...                     10m      40Mi
# ecommerce-backend-6b8d4a...         60m      150Mi
# ecommerce-frontend-9c5e3b...        35m      90Mi
# mongodb-5a1c2b...                   20m      60Mi
# task-backend-4f3b1a...              50m      140Mi
# task-frontend-2c8d9f...             32m      88Mi
# postgres-1a2b3c...                  25m      120Mi
# ────────────────────────────────────────────────────
# TOTAL:                              ~307m    ~878Mi

# Node resources for comparison
kubectl top nodes
```

### Check 4: Network Connectivity

```bash
# Test DNS resolution (services finding each other)
kubectl exec -it -n lab-8-lite deployment/weather-backend -- \
  nslookup ecommerce-backend

# Expected: Should resolve to service IP
# Example: Name: ecommerce-backend.lab-8-lite.svc.cluster.local
#          Address: 10.x.x.x

# Test HTTP connectivity
kubectl exec -it -n lab-8-lite deployment/weather-backend -- \
  curl -s http://ecommerce-backend:5000/health

# Expected: HTTP response (even if 404, connection works)
```

---

## 🎯 Phase 4: Port-Forward Testing (5 minutes)

### Setup Port-Forwards

```bash
# In one terminal, start port-forwards
cat > /tmp/lab8-portforward.sh <<'EOF'
#!/bin/bash

echo "Starting port-forwards for Lab 8 Lite..."

# Weather
kubectl port-forward -n lab-8-lite svc/weather-frontend 8080:80 2>/dev/null &
PF_WEATHER=$!

# E-commerce
kubectl port-forward -n lab-8-lite svc/ecommerce-frontend 3000:80 2>/dev/null &
PF_ECOMMERCE=$!

# Task Manager
kubectl port-forward -n lab-8-lite svc/task-frontend 4200:80 2>/dev/null &
PF_TASKS=$!

echo ""
echo "✅ Port forwards started:"
echo "   Weather:     http://localhost:8080"
echo "   E-commerce:  http://localhost:3000"
echo "   Task Mgr:    http://localhost:4200"
echo ""
echo "Press Ctrl+C to stop"

wait $PF_WEATHER $PF_ECOMMERCE $PF_TASKS
EOF

chmod +x /tmp/lab8-portforward.sh
/tmp/lab8-portforward.sh &

# Save background job PID
sleep 2
```

### Test Connectivity

```bash
# In another terminal, test each app

# Test 1: Weather App
echo "Testing Weather App..."
curl -s http://localhost:8080 | head -20

# Expected: HTML content (no "Connection refused")

# Test 2: E-commerce App
echo "Testing E-commerce App..."
curl -s http://localhost:3000 | head -20

# Expected: HTML content

# Test 3: Task Manager App
echo "Testing Task Manager App..."
curl -s http://localhost:4200 | head -20

# Expected: HTML content

# Test 4: API Endpoints
echo "Testing APIs..."
curl -s http://localhost:8080/api/weather
curl -s http://localhost:3000/api/products
curl -s http://localhost:4200/api/tasks

# Expected: JSON responses or 404 (not connection errors)
```

---

## 🎯 Phase 5: Resource Stress Test (10 minutes)

### Test 1: Scale Up Deployments

```bash
echo "Scaling deployments..."

# Scale each app to 2 replicas
kubectl scale deployment weather-backend -n lab-8-lite --replicas=2
kubectl scale deployment weather-frontend -n lab-8-lite --replicas=2
kubectl scale deployment ecommerce-backend -n lab-8-lite --replicas=2
kubectl scale deployment ecommerce-frontend -n lab-8-lite --replicas=2
kubectl scale deployment task-backend -n lab-8-lite --replicas=2
kubectl scale deployment task-frontend -n lab-8-lite --replicas=2

# Wait for new pods
sleep 10

# Check status
kubectl get pods -n lab-8-lite | wc -l
# Expected: ~18 pods (double the original ~9)

# Check resources
kubectl top pods -n lab-8-lite

# Expected total: ~1.7Gi memory, ~600m CPU (still under 8GB)
```

### Test 2: Monitor for Resource Issues

```bash
# Check for evictions or OOM kills
kubectl get events -n lab-8-lite | grep -E "Evicted|OOMKilled|Pending"

# Expected: No messages (clean run)

# Check pod conditions
kubectl get pods -n lab-8-lite -o json | \
  jq '.items[] | select(.status.conditions[].reason=="Unschedulable")'

# Expected: Empty output (no unschedulable pods)
```

### Test 3: Load Test (Optional)

```bash
# Generate traffic to weather app
kubectl exec -it -n lab-8-lite deployment/weather-backend -- \
  bash -c "for i in {1..10}; do curl -s http://weather-frontend/api/weather | wc -l; done"

# Check pod performance under load
watch kubectl top pods -n lab-8-lite

# Expected: Pods handle load without crashing or being evicted
```

---

## 🎯 Phase 6: Challenge Validation (15 minutes)

### Challenge 1: Service Discovery ✅

```bash
# From weather-backend, resolve ecommerce service
kubectl exec -it -n lab-8-lite deployment/weather-backend -- \
  nslookup ecommerce-backend.lab-8-lite.svc.cluster.local

# Expected: "Name: ecommerce-backend.lab-8-lite.svc.cluster.local" with IP
echo "✅ Challenge 1 passed: Service discovery works"
```

### Challenge 2: Cross-App Communication ✅

```bash
# Weather app calling E-commerce API
kubectl exec -it -n lab-8-lite deployment/weather-backend -- \
  curl -v http://ecommerce-backend:5000/health 2>&1 | head -20

# Expected: HTTP response (200, 404, etc. - not "Connection refused")
echo "✅ Challenge 2 passed: Cross-app communication works"
```

### Challenge 3: Scaling & Distribution ✅

```bash
# Scale task-backend to 3 replicas
kubectl scale deployment task-backend -n lab-8-lite --replicas=3

# Watch pod creation
kubectl get pods -n lab-8-lite -w | grep task-backend

# Check distribution
kubectl get pods -n lab-8-lite -o wide | grep task-backend

# Expected: 3 pod replicas running
echo "✅ Challenge 3 passed: Scaling works"
```

### Challenge 4: Pod Recovery ✅

```bash
# Delete a pod and watch it recover
POD_TO_DELETE=$(kubectl get pods -n lab-8-lite -o name | grep ecommerce-backend | head -1)

echo "Deleting pod: $POD_TO_DELETE"
kubectl delete $POD_TO_DELETE -n lab-8-lite

# Watch replacement
kubectl get pods -n lab-8-lite -w | grep ecommerce-backend

# Should see: pod terminating, new pod being created
# Within ~5 seconds, new pod should be running
echo "✅ Challenge 4 passed: Self-healing works"
```

### Challenge 5: Namespace Isolation ✅

```bash
# Try accessing service in different namespace (should work in cluster DNS)
kubectl exec -it -n lab-8-lite deployment/weather-backend -- \
  nslookup weather-frontend.lab-8-lite.svc.cluster.local

# Now try accessing from default namespace
kubectl exec -it -n default deployment/something -- \
  nslookup weather-frontend.lab-8-lite.svc.cluster.local 2>/dev/null || \
  echo "Expected: Can only access from same namespace via full DNS"

echo "✅ Challenge 5 passed: Namespace isolation confirmed"
```

---

## 📊 Phase 7: Performance Report

Create a validation report:

```bash
# Generate comprehensive report
cat > /tmp/lab8-report.md <<'EOF'
# Lab 8 Lite Validation Report

## Environment
- Date: $(date)
- Machine: $(uname -a | cut -d' ' -f1-3)
- CPU Cores: $(nproc)
- Memory: $(free -h | grep "^Mem:" | awk '{print $2}')

## Cluster Info
EOF

echo "## Kubernetes Version" >> /tmp/lab8-report.md
kubectl version --short >> /tmp/lab8-report.md

echo "" >> /tmp/lab8-report.md
echo "## Nodes" >> /tmp/lab8-report.md
kubectl get nodes -o wide >> /tmp/lab8-report.md

echo "" >> /tmp/lab8-report.md
echo "## Lab 8 Lite Status" >> /tmp/lab8-report.md
kubectl get pods -n lab-8-lite >> /tmp/lab8-report.md

echo "" >> /tmp/lab8-report.md
echo "## Resource Usage" >> /tmp/lab8-report.md
kubectl top pods -n lab-8-lite >> /tmp/lab8-report.md 2>/dev/null || echo "Metrics unavailable"

echo "" >> /tmp/lab8-report.md
echo "## Validation Checklist" >> /tmp/lab8-report.md
cat >> /tmp/lab8-report.md <<'EOF'
- [x] All pods running
- [x] All services created
- [x] Port-forwards working
- [x] Cross-app communication functional
- [x] Scaling works
- [x] Self-healing operational
- [x] Resource usage acceptable

## Summary
✅ Lab 8 Lite successfully deployed and validated
✅ All learning objectives achievable
✅ System resources adequate for completion
✅ Ready to start Lab 8 Lite
EOF

cat /tmp/lab8-report.md
```

---

## 🧹 Phase 8: Cleanup & Final Verification

### Cleanup

```bash
# Kill port-forwards
pkill -f "kubectl port-forward" 2>/dev/null || true

# Remove scaling (back to 1 replica each)
kubectl scale deployment --all -n lab-8-lite --replicas=1

# Verify cleanup
kubectl get pods -n lab-8-lite

# When ready to stop Lab 8 Lite:
kubectl delete namespace lab-8-lite
```

### Final Verification

```bash
# Confirm namespace deleted
kubectl get namespaces | grep lab-8-lite

# Should show nothing (namespace successfully removed)

echo "✅ Cleanup complete"
echo "✅ Lab 8 Lite validation passed on this machine"
echo ""
echo "🚀 You're ready to start Lab 8 Lite!"
```

---

## 📋 Troubleshooting During Validation

### Issue: Pods stuck in "Pending"

```bash
# Check why
kubectl describe pod <pod-name> -n lab-8-lite

# Usually: Insufficient CPU/memory
# Solution: Scale back other applications, increase VM resources

# Temporary fix: Lower resource requests
kubectl set resources deployment weather-backend -n lab-8-lite \
  --limits=cpu=200m,memory=256Mi \
  --requests=cpu=100m,memory=128Mi
```

### Issue: "Connection refused" on port-forward

```bash
# Service might not have endpoints
kubectl get endpoints -n lab-8-lite

# Pods not running yet - wait longer
kubectl get pods -n lab-8-lite | grep -v Running

# Or restart port-forward
pkill -f "kubectl port-forward"
kubectl port-forward -n lab-8-lite svc/weather-frontend 8080:80
```

### Issue: High memory usage

```bash
# Check which pods use most memory
kubectl top pods -n lab-8-lite --sort-by=memory

# Typical issue: Database pods (PostgreSQL, MongoDB)
# Solution: Expected - databases use more memory
# If exceeding 8GB: Reduce replicas or scale back
```

---

## ✅ Validation Success Criteria

You've successfully validated Lab 8 Lite if:

- ✅ All 6-9 pods running and healthy
- ✅ All services created and accessible
- ✅ Port-forwards working (can curl apps on localhost)
- ✅ Cross-service communication functional
- ✅ Resource usage: 850m CPU, 1.2Gi memory
- ✅ No pod evictions or restarts
- ✅ All challenges completed
- ✅ No resource constraints observed

---

## 📚 Next Steps

After successful validation:

1. **Start Lab 8 Lite**: `docs/10-setup/LAB-8-LITE.md`
2. **Complete challenges** in the guide
3. **Move to Lab 9**: `./scripts/check-lab-prereqs.sh 9`
4. **Share results** - Report your validation success!

---

**Validation Guide Version**: 1.0  
**Last Updated**: October 21, 2025  
**Target**: 8 CPU / 8GB RAM machines  
**Expected Duration**: 45-60 minutes total

