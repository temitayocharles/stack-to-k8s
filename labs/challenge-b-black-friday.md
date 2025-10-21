# 🎮 Challenge Lab B: Black Friday Rush

**⏱️ Time Limit**: 60 minutes | **🚨 Difficulty**: HARD | **🎯 Prerequisites**: Labs 1-7 complete

---

## 🔥 SCENARIO

**Date**: November 24, 2024 - 11:47 PM EST (13 minutes before Black Friday)  
**Alert**: PagerDuty P1 - E-commerce Platform Performance Degradation  
**Impact**: Site loading in 8+ seconds (SLA: <2 seconds), abandoned carts increasing  
**Forecast**: Traffic will increase 10x at midnight (15,000 → 150,000 concurrent users)  
**Stakeholders breathing down your neck**: CEO, CMO, entire sales team

**Slack message from CEO** (11:48 PM):
> "Team - we spent $2M on Black Friday ads. Site is already slow with current traffic. If we can't handle midnight surge, we lose $5M in sales. FIX THIS NOW. I'm staying up until this is resolved."

---

## 🎯 Your Mission

You have **60 minutes** to:
1. **Scale the system** to handle 10x traffic
2. **Optimize performance** to meet <2 second SLA
3. **Add safeguards** to prevent total collapse
4. **Verify under load** using load testing

**Success criteria**:
- ✅ Site responds in <2 seconds under 150,000 concurrent users
- ✅ No OOMKilled pods during traffic spike
- ✅ Auto-scaling configured (scales up AND down automatically)
- ✅ Resource limits protect cluster from cascading failure

---

## 📦 Deploy the "Unprepared" System

```bash
# Create namespace
kubectl create namespace black-friday

# Deploy broken e-commerce system
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-frontend
  namespace: black-friday
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecommerce-frontend
  template:
    metadata:
      labels:
        app: ecommerce-frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-frontend
  namespace: black-friday
spec:
  selector:
    app: ecommerce-frontend
  ports:
  - port: 80
  type: LoadBalancer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend
  namespace: black-friday
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ecommerce-backend
  template:
    metadata:
      labels:
        app: ecommerce-backend
    spec:
      containers:
      - name: backend
        image: hashicorp/http-echo:latest
        args:
          - "-text=Backend API"
        resources:
          requests:
            cpu: 250m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-backend
  namespace: black-friday
spec:
  selector:
    app: ecommerce-backend
  ports:
  - port: 8000
    targetPort: 5678
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
  namespace: black-friday
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:5
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        ports:
        - containerPort: 27017
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
  namespace: black-friday
spec:
  selector:
    app: mongodb
  ports:
  - port: 27017
EOF

# Wait for deployment
kubectl wait --for=condition=ready pod --all -n black-friday --timeout=120s

# Check current state
kubectl get pods -n black-friday
kubectl top pods -n black-friday
```

---

## ⏱️ Phase 1: TRIAGE (15 minutes)

**Goal**: Identify bottlenecks BEFORE the midnight surge

### Step 1: Load Test Current System

```bash
# Install hey (load testing tool)
# macOS: brew install hey
# Linux: wget https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64

# Get LoadBalancer IP
FRONTEND_IP=$(kubectl get svc ecommerce-frontend -n black-friday -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# If local cluster (no LoadBalancer)
if [ -z "$FRONTEND_IP" ]; then
  kubectl port-forward -n black-friday svc/ecommerce-frontend 8080:80 &
  FRONTEND_IP="localhost:8080"
fi

# Simulate 1,000 concurrent users (current peak traffic)
hey -n 10000 -c 1000 -q 10 http://$FRONTEND_IP/

# Observe the metrics:
# - Requests/sec
# - Response time (mean, p95, p99)
# - Error rate
```

**What to look for**:
- Response time >2 seconds? **Backend undersized**
- Error rate >1%? **Resource limits too low**
- Pods restarting? **OOMKilled or CrashLoopBackOff**

### Step 2: Identify Resource Constraints

```bash
# Check current resource usage
kubectl top pods -n black-friday

# Check HPA status (should NOT exist yet - that's the problem!)
kubectl get hpa -n black-friday
# Expected: No resources found

# Check for resource pressure
kubectl describe nodes | grep -A 5 "Allocated resources"
```

### Step 3: Analyze Pod Logs

```bash
# Check backend logs for errors
kubectl logs -n black-friday -l app=ecommerce-backend --tail=50

# Look for:
# - Connection timeouts to MongoDB
# - Out of memory errors
# - Slow query warnings
```

**Document your findings** (will be asked in Phase 4):
- What's the current response time under 1K users?
- What will happen at 10K users if we don't fix anything?
- Which component is the bottleneck: Frontend, Backend, or Database?

---

## 🔧 Phase 2: SCALE NOW (20 minutes)

**Goal**: Get system ready for 10x traffic surge

### Bug #1: No Horizontal Pod Autoscaler (CRITICAL)

**Problem**: Fixed replica count (2 frontend, 3 backend) can't handle surge.

**Fix**:
```bash
# Install metrics-server if not present
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Create HPA for frontend (scale 2-20 pods based on CPU)
kubectl autoscale deployment ecommerce-frontend -n black-friday \
  --cpu-percent=70 \
  --min=5 \
  --max=20

# Create HPA for backend (scale 3-30 pods based on CPU)
kubectl autoscale deployment ecommerce-backend -n black-friday \
  --cpu-percent=70 \
  --min=10 \
  --max=30

# Verify HPA created
kubectl get hpa -n black-friday -w
```

**Success criteria**: HPA shows `TARGETS` column with current CPU % (e.g., `45%/70%`)

---

### Bug #2: Insufficient Resource Limits (CRITICAL)

**Problem**: Memory limits too low (128Mi frontend, 256Mi backend). Will OOMKill under load.

**Fix**:
```bash
# Increase frontend resources
kubectl set resources deployment ecommerce-frontend -n black-friday \
  --requests=cpu=200m,memory=256Mi \
  --limits=cpu=500m,memory=512Mi

# Increase backend resources
kubectl set resources deployment ecommerce-backend -n black-friday \
  --requests=cpu=500m,memory=512Mi \
  --limits=cpu=1000m,memory=1Gi

# Watch rollout
kubectl rollout status deployment ecommerce-frontend -n black-friday
kubectl rollout status deployment ecommerce-backend -n black-friday
```

**Success criteria**: No OOMKilled pods after resource update

---

### Bug #3: No Caching Layer (PERFORMANCE)

**Problem**: Every request hits database. MongoDB will collapse under 10x load.

**Fix**:
```bash
# Deploy Redis cache
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: black-friday
spec:
  replicas: 3
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: black-friday
spec:
  selector:
    app: redis
  ports:
  - port: 6379
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: redis
  namespace: black-friday
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: redis
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF
```

**Success criteria**: Redis pods Running, HPA shows targets

---

## 🛡️ Phase 3: SAFEGUARDS (15 minutes)

**Goal**: Prevent total system collapse if things go wrong

### Safeguard #1: Pod Disruption Budget

**Prevents**: Auto-scaler draining all pods during scale-down.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ecommerce-frontend-pdb
  namespace: black-friday
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: ecommerce-frontend
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ecommerce-backend-pdb
  namespace: black-friday
spec:
  minAvailable: 5
  selector:
    matchLabels:
      app: ecommerce-backend
EOF
```

### Safeguard #2: Readiness Probes

**Prevents**: Sending traffic to pods that aren't ready (slow startup).

```bash
# Patch frontend with readiness probe
kubectl patch deployment ecommerce-frontend -n black-friday --type=json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/readinessProbe",
    "value": {
      "httpGet": {
        "path": "/",
        "port": 80
      },
      "initialDelaySeconds": 5,
      "periodSeconds": 5
    }
  }
]'

# Patch backend with readiness probe
kubectl patch deployment ecommerce-backend -n black-friday --type=json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/readinessProbe",
    "value": {
      "httpGet": {
        "path": "/",
        "port": 5678
      },
      "initialDelaySeconds": 3,
      "periodSeconds": 5
    }
  }
]'
```

### Safeguard #3: Resource Quotas

**Prevents**: One app consuming entire cluster during spike.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: black-friday-quota
  namespace: black-friday
spec:
  hard:
    requests.cpu: "50"
    requests.memory: "100Gi"
    limits.cpu: "100"
    limits.memory: "200Gi"
    persistentvolumeclaims: "10"
EOF

# Verify quota
kubectl describe resourcequota black-friday-quota -n black-friday
```

---

## 🧪 Phase 4: LOAD TEST (10 minutes)

**Goal**: Verify system can handle 10x traffic

### Test 1: Baseline Performance

```bash
# Run load test with 10,000 concurrent users (10x surge)
hey -n 100000 -c 10000 -q 10 http://$FRONTEND_IP/

# Monitor in separate terminal using k9s
k9s -n black-friday

# Or watch with kubectl
watch -n 2 kubectl get hpa,pods -n black-friday
```

**Success criteria**:
- Mean response time: <2 seconds ✅
- p95 response time: <3 seconds ✅
- Error rate: <0.5% ✅
- HPA scales up automatically (watch pod count increase) ✅
- No OOMKilled pods ✅

### Test 2: Sustained Load

```bash
# Run 5-minute sustained load test
hey -z 5m -c 5000 -q 10 http://$FRONTEND_IP/

# Verify auto-scaling works both ways:
# - Scales UP during load
# - Scales DOWN after 5 minutes (cooldown period)
```

### Test 3: Spike Recovery

```bash
# Simulate sudden traffic spike
hey -n 50000 -c 15000 -q 50 http://$FRONTEND_IP/

# Verify:
# - HPA scales to max replicas (20 frontend, 30 backend)
# - Response times stay <3 seconds
# - No pod crashes
```

---

## ✅ VALIDATION

Run these commands to verify success:

```bash
# 1. HPA configured and working
kubectl get hpa -n black-friday
# Expected: Shows current/target CPU, replicas scaling

# 2. All pods healthy
kubectl get pods -n black-friday
# Expected: All Running, no OOMKilled, no CrashLoopBackOff

# 3. Resource limits increased
kubectl get pods -n black-friday -o json | jq '.items[] | {name: .metadata.name, limits: .spec.containers[0].resources.limits}'
# Expected: Frontend 512Mi memory, Backend 1Gi memory

# 4. PDBs active
kubectl get pdb -n black-friday
# Expected: 2 PDBs with ALLOWED DISRUPTIONS showing safe values

# 5. Resource quota not exceeded
kubectl describe resourcequota black-friday-quota -n black-friday
# Expected: Used < Hard limits

# 6. Load test passes
hey -n 10000 -c 5000 -q 10 http://$FRONTEND_IP/
# Expected:
#   - Mean response time: <2s
#   - p95: <3s
#   - Error rate: <1%
```

**All checks pass?** 🏆 You saved Black Friday!

---

## 📊 POST-MORTEM REPORT

Document your findings (simulate real incident response):

### Incident Summary
- **Duration**: 60 minutes (11:47 PM - 12:47 AM)
- **Severity**: P1 (Revenue-impacting)
- **Root causes identified**: 3 critical issues
- **Estimated revenue saved**: $5M (prevented total outage)

### Technical Findings

**Bug #1: No Auto-Scaling**
- **Impact**: Fixed 2 frontend pods couldn't handle surge
- **Fix**: HPA with 5-20 replicas, 70% CPU target
- **Prevention**: Add HPA to deployment checklist

**Bug #2: Insufficient Resources**
- **Impact**: Pods OOMKilled under load (128Mi too low)
- **Fix**: Increased to 512Mi frontend, 1Gi backend
- **Prevention**: Load test BEFORE Black Friday (weeks in advance)

**Bug #3: No Caching**
- **Impact**: Every request hit MongoDB (would've crashed at 10x load)
- **Fix**: Redis cache layer (3-10 replicas auto-scaled)
- **Prevention**: Add caching to architecture review checklist

### Metrics

| Metric | Before Fix | After Fix | Improvement |
|--------|-----------|-----------|-------------|
| Response time (mean) | 8.2s | 1.4s | 83% faster |
| Error rate | 3.5% | 0.2% | 94% reduction |
| Max capacity | 1.5K users | 150K users | 100x increase |
| Pod count (peak) | 5 pods | 53 pods | Auto-scaled |
| Revenue protected | — | $5M | — |

### Lessons Learned

1. **Always load test before high-traffic events** (not 13 minutes before!)
2. **HPA is non-negotiable** for production services
3. **Caching reduces database load by 90%+** (Redis paid for itself 100x)
4. **Resource limits must match actual usage** (profile in staging first)
5. **Safeguards (PDBs, quotas) prevent cascading failures**

---

## 💰 Cost Impact

**Crisis Mode** (60 minutes):
- 53 pods at peak × 1 hour = $8.50 (one-time spike cost)

**Optimized Steady State**:
- 15 pods average (HPA scales down after traffic decreases)
- Monthly cost: $247/month
- Compare to: Fixed 50 pods = $413/month
- **Savings**: $166/month × 12 = **$1,992/year** from auto-scaling alone!

**ROI**: Spent 60 minutes + $8.50 spike cost. Saved $5M revenue. That's a **58,823,429% ROI**. 🚀

---

## 🏆 CONGRATULATIONS!

You've just handled a Black Friday crisis under pressure. Skills you demonstrated:

✅ **Incident triage** (identified 3 bottlenecks in 15 min)  
✅ **Rapid scaling** (HPA configuration under pressure)  
✅ **Performance optimization** (caching, resource tuning)  
✅ **Resilience engineering** (PDBs, quotas, probes)  
✅ **Load testing** (validated fixes before midnight surge)  

**Interview gold**: This is a COMPLETE incident response story. Frame it as:
- "I handled a Black Friday crisis where we had 13 minutes to scale for 10x traffic..."
- Shows: Technical skills + pressure handling + business impact quantification

---

## 🚀 Next Challenge

**[Challenge Lab C: Platform Migration](challenge-c-platform-migration.md)** (After Lab 12)

Migrate 6 applications to a new cluster with **zero downtime**. Even harder! 🔥

---

## 🧹 Cleanup

```bash
kubectl delete namespace black-friday

# Stop port-forward if running
pkill -f "port-forward.*black-friday"
```

**Keep this challenge in your portfolio!** Add to GitHub, link in resume. Demonstrates real-world incident response skills.
