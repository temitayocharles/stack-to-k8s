# 📡 Port Management & Remapping Guide

## Quick Reference: Port Conflicts by Lab

| Lab | Primary Service | Ports Used | Typical Port-Forward | Notes |
|-----|-----------------|------------|----------------------|-------|
| **1** | Weather | 8080, 5000, 6379 | `8080:80` | Redis internal |
| **2** | E-commerce | 3000, 5000, 27017 | `3000:80`, `5000:5000` | MongoDB internal |
| **3** | Educational | 4200, 8080, 5432 | `4200:80`, `8080:80` | ⚠️ Conflicts with Lab 1 |
| **4** | Fundamentals | 8080, 8081, 8082 | `8080:80`, `8081:80` | ⚠️ Multiple ports |
| **5** | Task+Ingress | 80, 443, 3000, 8000 | `80:80`, `443:443` | ⚠️ Conflicts with Lab 2 |
| **6** | Medical | 8080, 5000, 5432 | `8080:80`, `5000:5000` | ⚠️ Heavy conflicts |
| **7** | Social+HPA | 3000, 8080, 5432, 6379 | `3000:80`, `8080:80` | ⚠️ **Major conflicts** |
| **8** | Multi-App | 3000-8080 range | Multiple port-forwards | 🔴 **SEVERE conflicts** |
| **9** | Chaos+Apps | 3000, 8080, 2333 | Per-app remapping | `2333` for Chaos Dashboard |
| **10** | Helm | 3000, 8080, 5432 | Per-app | Charts may use different ports |
| **11** | GitOps | 3000, 8080 | Per-app | ArgoCD typically `:8080` |
| **12** | Secrets | 3000, 8080 | Per-app | Similar to other apps |
| **13** | AI/ML | Varies (GPU) | Per-app | Model serving ports vary |

---

## 🎯 Port Collision Prevention Strategies

### Strategy 1: Sequential Lab Execution (Easiest)

**When**: Machine with 8GB RAM, want to avoid complexity

**How**:
```bash
# Run Lab 1, complete all tasks
./scripts/check-lab-prereqs.sh 1
kubectl apply -f weather-app/k8s/ -n lab-1
# ... work through Lab 1 ...

# Clean up completely
./scripts/cleanup-workspace.sh
kubectl delete namespace lab-1

# Now run Lab 2
./scripts/check-lab-prereqs.sh 2
kubectl apply -f ecommerce-app/k8s/ -n lab-2
# ... work through Lab 2 ...
```

**Pros**: ✅ Simple, no port conflicts, easy debugging  
**Cons**: ⚠️ Slower (wait for cleanup), no concurrent learning

---

### Strategy 2: Namespace + Port-Forward Remapping (Recommended)

**When**: Machine with 12+ CPU / 12GB+ RAM, want to run multiple labs

**Concept**: Each lab in separate namespace, each service on different host port

**Example: Run Labs 1-3 Concurrently**

```bash
# Terminal 1: Lab 1 (Weather on port 8080)
kubectl create namespace lab-1
kubectl apply -f weather-app/k8s/ -n lab-1

# Verify
kubectl get pods -n lab-1 -w

# Terminal 2: Lab 2 (E-commerce on port 3000)
kubectl create namespace lab-2
kubectl apply -f ecommerce-app/k8s/ -n lab-2

kubectl get pods -n lab-2 -w

# Terminal 3: Lab 3 (Educational on port 4200)
kubectl create namespace lab-3
kubectl apply -f educational-platform/k8s/ -n lab-3

kubectl get pods -n lab-3 -w

# Terminal 4: Port-forwarding script
cat > port-forward.sh <<'EOF'
#!/bin/bash

# Lab 1: Weather → 8080
kubectl port-forward -n lab-1 svc/frontend 8080:80 &
PF1=$!

# Lab 2: E-commerce → 3000
kubectl port-forward -n lab-2 svc/frontend 3000:80 &
PF2=$!

# Lab 3: Educational → 4200
kubectl port-forward -n lab-3 svc/frontend 4200:80 &
PF3=$!

echo "Port-forwards started:"
echo "  Lab 1 (Weather):     localhost:8080"
echo "  Lab 2 (E-commerce):  localhost:3000"
echo "  Lab 3 (Educational): localhost:4200"
echo ""
echo "Press Ctrl+C to stop all port-forwards"

wait $PF1 $PF2 $PF3
EOF

chmod +x port-forward.sh
./port-forward.sh
```

**Access in browser**:
```
Lab 1: http://localhost:8080
Lab 2: http://localhost:3000
Lab 3: http://localhost:4200
```

---

## 🛠️ Port-Forward Management: Deep Dive

### Understanding kubectl port-forward

```bash
# Syntax:
kubectl port-forward [resource-type]/[resource-name] [host-port]:[pod-port] -n [namespace]

# Examples:
kubectl port-forward pod/my-pod 8080:8080 -n default
kubectl port-forward svc/my-service 3000:3000 -n lab-1
kubectl port-forward deployment/my-app 5000:5000 -n production
```

### Common Port-Forward Patterns

**Pattern 1: Simple Service Forward**
```bash
# Forward service frontend port (80) to host port 8080
kubectl port-forward -n lab-1 svc/frontend 8080:80

# Access: curl http://localhost:8080
```

**Pattern 2: Non-Standard Backend Port**
```bash
# Backend runs on port 5000 in container, expose as 5000
kubectl port-forward -n lab-1 svc/backend 5000:5000

# Access: curl http://localhost:5000/api
```

**Pattern 3: Database Port Forward**
```bash
# Forward PostgreSQL
kubectl port-forward -n lab-3 svc/postgres 5432:5432

# Access from host:
psql -h localhost -U postgres -d mydb
```

**Pattern 4: Multiple Ports on Single Service**
```bash
# Forward multiple ports (if service exposes them)
kubectl port-forward -n lab-5 svc/ingress-nginx 80:80 443:443

# Now:
# HTTP: curl http://localhost:80
# HTTPS: curl https://localhost:443
```

### Backgrounding Port-Forwards

**Method 1: Background with &**
```bash
kubectl port-forward svc/frontend 8080:80 &
# Job ID shown: [1] 12345

# List background jobs
jobs -l
# Output: [1]  12345 Running  kubectl port-forward ...

# Kill by job number
kill %1
```

**Method 2: Persistent Script**
```bash
#!/bin/bash
# Save as: run-port-forwards.sh

PID_FILE="/tmp/k8s-portforward.pid"

start() {
  kubectl port-forward svc/frontend 8080:80 &
  echo $! >> $PID_FILE
}

stop() {
  if [ -f $PID_FILE ]; then
    while read pid; do
      kill $pid 2>/dev/null
    done < $PID_FILE
    rm $PID_FILE
  fi
}

case "$1" in
  start) start ;;
  stop) stop ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
```

**Method 3: Supervised with screen/tmux**
```bash
# Using tmux (better for long-running forwards)
tmux new-session -d -s portforward

tmux send-keys -t portforward "kubectl port-forward svc/frontend 8080:80" Enter
tmux send-keys -t portforward "kubectl port-forward svc/backend 5000:5000" Enter

# Later, kill all:
tmux kill-session -t portforward
```

---

## 🔍 Debugging Port Issues

### Check What's Using a Port

**macOS/Linux**:
```bash
# See what process owns a port
lsof -i :8080

# Output:
# COMMAND   PID    USER   FD TYPE DEVICE SIZE NODE NAME
# kubectl  1234 user  3u  IPv4 0x... 0t0  TCP localhost:8080 (LISTEN)

# Kill the process
kill 1234
```

**Windows**:
```powershell
# See what's on a port
netstat -ano | findstr :8080

# Kill by PID
taskkill /PID 1234 /F
```

### Verify Port-Forward is Working

```bash
# Check if port-forward is active
kubectl get portforward  # (not a real command, but checking logs:)

# View kubectl logs
kubectl logs -f deployment/my-app  # Usually shows port-forward setup

# Test connectivity
curl http://localhost:8080  # Should respond, not "connection refused"

# Check service is accessible
kubectl get svc -n lab-1
# Status should show: TYPE ClusterIP (normal for port-forward)
```

---

## 📊 Complex Scenario: Lab 8 Multi-App with Custom Port Mapping

Lab 8 runs 6 apps. Here's how to run them with custom port mapping:

```bash
# Create namespace
kubectl create namespace lab-8-lite

# Deploy 3 apps (Lab 8 Lite)
kubectl apply -f weather-app/k8s/ -n lab-8-lite
kubectl apply -f ecommerce-app/k8s/ -n lab-8-lite
kubectl apply -f task-management-app/k8s/ -n lab-8-lite

# Now create custom port mapping
cat > lab8-ports.sh <<'EOF'
#!/bin/bash

# Function to handle cleanup
cleanup() {
  echo "Stopping port-forwards..."
  pkill -f "kubectl port-forward"
  exit 0
}

trap cleanup SIGINT

# Port mapping for Lab 8 Lite
echo "Starting port-forwards for Lab 8 Lite..."

# Weather (Frontend on 8080, Backend on 8081, Redis internal)
kubectl port-forward -n lab-8-lite svc/weather-frontend 8080:80 &
kubectl port-forward -n lab-8-lite svc/weather-backend 8081:5000 &

# E-commerce (Frontend on 3000, Backend on 3001, MongoDB internal)
kubectl port-forward -n lab-8-lite svc/ecommerce-frontend 3000:80 &
kubectl port-forward -n lab-8-lite svc/ecommerce-backend 3001:5000 &

# Task Manager (Frontend on 4200, Backend on 4201, PostgreSQL on 5432)
kubectl port-forward -n lab-8-lite svc/task-frontend 4200:80 &
kubectl port-forward -n lab-8-lite svc/task-backend 4201:3000 &
kubectl port-forward -n lab-8-lite svc/postgres 5432:5432 &

echo ""
echo "==================================="
echo "  Lab 8 Lite - Port Mappings"
echo "==================================="
echo ""
echo "Weather App:"
echo "  Frontend: http://localhost:8080"
echo "  Backend:  http://localhost:8081"
echo ""
echo "E-commerce App:"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:3001"
echo ""
echo "Task Manager:"
echo "  Frontend: http://localhost:4200"
echo "  Backend:  http://localhost:4201"
echo "  Database: localhost:5432"
echo ""
echo "==================================="
echo "Press Ctrl+C to stop all forwards"
echo ""

wait
EOF

chmod +x lab8-ports.sh
./lab8-ports.sh
```

---

## 🚀 Advanced: Custom Ingress Instead of Port-Forward

For more permanent multi-app access, use Ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-app-ingress
  namespace: lab-8-lite
spec:
  ingressClassName: nginx  # Requires nginx-ingress controller
  rules:
  - host: weather.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: weather-frontend
            port:
              number: 80
  
  - host: ecommerce.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ecommerce-frontend
            port:
              number: 80
  
  - host: tasks.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: task-frontend
            port:
              number: 80
```

**Apply and configure**:
```bash
kubectl apply -f ingress.yaml

# Add to /etc/hosts (macOS/Linux)
echo "127.0.0.1 weather.local ecommerce.local tasks.local" >> /etc/hosts

# Port-forward ingress controller (once)
kubectl port-forward -n ingress-nginx svc/ingress-nginx 80:80 &

# Access via:
curl http://weather.local
curl http://ecommerce.local
curl http://tasks.local
```

---

## ✅ Port Hygiene Checklist

Before starting new lab:
- [ ] All port-forwards from previous lab stopped
- [ ] No `kubectl port-forward` processes running: `pgrep kubectl`
- [ ] No orphaned namespace port reservations
- [ ] Cleanup script run: `./scripts/cleanup-workspace.sh`
- [ ] Previous namespace deleted: `kubectl delete ns <old-lab>`

**Verify**:
```bash
# Should show no kubectl processes
pgrep -f "kubectl port-forward"

# Should show no old namespaces
kubectl get namespaces

# Should show clean ports
lsof -i :8080  # Should be empty or show only your new apps
```

---

## 🔗 Related Documentation

- 📖 [Lab 8: Multi-App Orchestration](../../labs/08-multi-app.md)
- 📖 [Lab 8 Lite: Reduced Resources](./LAB-8-LITE.md)
- 📖 [Resource Requirements Guide](../30-reference/deep-dives/resource-requirements.md)
- 💾 [Resource Estimation in README](../../README.md#-resource-estimation-which-labs-fit-your-machine)

---

## 📋 Troubleshooting Common Port Issues

### "Address already in use"
```
Error: listen tcp 127.0.0.1:8080: bind: address already in use
```

**Solution**:
```bash
# Kill existing process on port
lsof -i :8080 | grep -v COMMAND | awk '{print $2}' | xargs kill -9

# Or use different port
kubectl port-forward svc/frontend 8090:80  # Use 8090 instead
```

### "Connection refused"
```
curl: (7) Failed to connect to localhost port 8080: Connection refused
```

**Check**:
```bash
# Is port-forward running?
kubectl get pods -A | grep port-forward  # Should show kubectl process

# Is service running?
kubectl get svc -n lab-1

# Test from pod directly
kubectl exec -it pod/frontend-pod -n lab-1 -- curl localhost:80
```

### "Too many files open"
```
Too many open files in system
```

**Solution**:
```bash
# Increase file descriptor limit
ulimit -n 4096

# Kill unused port-forwards
pkill -f "kubectl port-forward"

# Cleanup namespaces
kubectl delete namespace lab-1 lab-2 lab-3  # etc
```

---

**Last updated**: October 21, 2025  
**Scope**: All labs 1-13, concurrent and sequential execution  
**Target audience**: Developers managing multiple K8s environments locally
