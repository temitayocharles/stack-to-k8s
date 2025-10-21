# 🎮 Challenge Lab A: The Midnight Incident

**Time**: 45 minutes  
**Difficulty**: ⭐⭐⭐ Expert  
**Prerequisites**: Completed Labs 1-3  

---

## 🚨 SCENARIO

**It's 2:47 AM. Your phone buzzes.**

```
PagerDuty Alert: Weather App DOWN
Users affected: 100%
Last successful request: 9 minutes ago
You are the on-call engineer.
```

Your manager is awake. Customers are tweeting complaints. The clock is ticking.

**SLA**: Restore service in < 30 minutes or face incident review.

---

## 🎯 Your Mission

1. **Find the root cause** (Why is it broken?)
2. **Fix the immediate issue** (Get it working NOW)
3. **Prevent it from happening again** (Root cause fix)
4. **Document what happened** (For the post-mortem)

---

## 📦 Deploy the Broken System

```bash
# Clone the incident scenario
kubectl create namespace incident-lab

# Deploy the broken weather app (intentionally misconfigured for troubleshooting practice)
kubectl apply -f https://raw.githubusercontent.com/temitayocharles/stack-to-k8s/main/labs/challenge-a-broken.yaml -n incident-lab

# Wait a moment before checking status
sleep 5

# Try to access the app
kubectl port-forward -n incident-lab svc/weather-frontend 8080:80 &
curl http://localhost:8080
# You should get: Connection refused or 503 error
```

---

## 🔍 Phase 1: Triage (10 minutes)

**Your tools**:
```bash
# Use what you learned in Labs 1-3
kubectl get all -n incident-lab
kubectl get events -n incident-lab --sort-by='.lastTimestamp'
kubectl describe pods -n incident-lab
kubectl logs <pod-name> -n incident-lab
k9s -n incident-lab
stern . -n incident-lab
```

### 🎯 Checkpoint 1: Answer These

1. **How many pods are running?** ____
2. **Are any pods in CrashLoopBackOff?** Yes / No
3. **What error appears in the logs?** ____
4. **Is the database accessible?** Yes / No

<details>
<summary>🆘 Hint #1 (Open after 5 min if stuck)</summary>

Check the backend pods. Look for environment variable issues.
```bash
kubectl get pods -n incident-lab -l app=weather-backend
kubectl logs <backend-pod> -n incident-lab
```

Look for "connection refused" or "cannot resolve" errors.
</details>

---

## 🔧 Phase 2: Fix It NOW (15 minutes)

**You found the issue. Now fix it.**

Common issues you might find:
- ❌ Service selector mismatch (labels don't match)
- ❌ ConfigMap missing (environment variables broken)
- ❌ Image pull error (wrong image tag)
- ❌ Resource limits too low (OOMKilled)
- ❌ Database connection string wrong

### 🎯 Checkpoint 2: Verify Fix

```bash
# After your fix, verify:
kubectl get pods -n incident-lab
# All pods should be Running

# Test the endpoint
curl http://localhost:8080
# Should return: {"status": "healthy", "temperature": "72°F"}

# Check logs
stern weather -n incident-lab --since 2m
# Should see successful HTTP 200 responses
```

<details>
<summary>🆘 Hint #2 (Open after 10 min if still stuck)</summary>

The issue is a **Service selector mismatch**. 

Check:
```bash
kubectl get svc weather-backend -n incident-lab -o yaml | grep -A5 selector
kubectl get pods -n incident-lab --show-labels | grep weather-backend
```

The service selector is looking for `app: weather-backend` but pods have `app: weather-backed` (typo!).

Fix:
```bash
kubectl patch deployment weather-backend -n incident-lab -p '{"spec":{"template":{"metadata":{"labels":{"app":"weather-backend"}}}}}'
```
</details>

---

## 🛡️ Phase 3: Prevent Recurrence (15 minutes)

**Fixing it once isn't enough. Make sure it never happens again.**

### Implement These Safeguards:

#### 1. **Add Readiness Probes** (Prevents bad pods from receiving traffic)

```yaml
# Edit deployment
kubectl edit deployment weather-backend -n incident-lab

# Add under containers:
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

#### 2. **Add Resource Limits** (Prevents OOMKilled)

```yaml
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
```

#### 3. **Validate Labels Match Selectors**

```bash
# Create a validation script
cat > validate-labels.sh << 'EOF'
#!/bin/bash
SVC_SELECTOR=$(kubectl get svc weather-backend -n incident-lab -o jsonpath='{.spec.selector.app}')
POD_LABEL=$(kubectl get pods -n incident-lab -l app=weather-backend -o jsonpath='{.items[0].metadata.labels.app}')

if [ "$SVC_SELECTOR" != "$POD_LABEL" ]; then
  echo "❌ MISMATCH! Service selector: $SVC_SELECTOR | Pod label: $POD_LABEL"
  exit 1
else
  echo "✅ Labels match: $SVC_SELECTOR"
fi
EOF

chmod +x validate-labels.sh
./validate-labels.sh
```

### 🎯 Checkpoint 3: Verify Safeguards

```bash
# Kill a pod and verify it recovers gracefully
kubectl delete pod -n incident-lab -l app=weather-backend --force
sleep 10
kubectl get pods -n incident-lab
# New pod should be Running with readiness check passing

# Verify resource limits exist
kubectl describe deployment weather-backend -n incident-lab | grep -A4 Limits
```

---

## 📝 Phase 4: Incident Report (5 minutes)

**Document what happened for the team.**

Create `incident-report.md`:

```markdown
# Incident Report: Weather App Outage

**Date**: 2025-10-20 02:47 AM  
**Duration**: 27 minutes  
**Impact**: 100% of users (complete outage)

## Root Cause
Service selector `app: weather-backend` did not match pod label `app: weather-backed` (typo in deployment).

## Timeline
- 02:47 - PagerDuty alert triggered
- 02:50 - On-call engineer began investigation
- 02:55 - Identified selector mismatch using `kubectl get pods --show-labels`
- 03:02 - Patched deployment with correct label
- 03:05 - Service restored, all pods healthy
- 03:14 - Added safeguards (readiness probes, validation script)

## Lessons Learned
1. Label/selector mismatches are silent failures
2. Need CI/CD validation to catch this before deployment
3. Readiness probes would have prevented bad pods from receiving traffic

## Action Items
- [ ] Add label validation to CI/CD pipeline
- [ ] Implement admission webhook to block mismatched labels
- [ ] Add monitoring alert for pods not receiving traffic
```

---

## 🏆 Success Criteria

You've completed this challenge if:

✅ **App is healthy**: All pods Running, curl returns 200 OK  
✅ **Safeguards added**: Readiness probes + resource limits configured  
✅ **Validation script**: Can detect label mismatches automatically  
✅ **Incident report**: Documented root cause and prevention steps  

---

## 💰 Cost of This Incident

**Real-world impact**:
- 27 minutes downtime × 10,000 users = 4,500 user-hours lost
- At $50/hour average revenue per user = **$225,000 lost**
- Plus: damaged reputation, support tickets, engineering time

**Prevention cost**: 15 minutes to add validation = **$0 future incidents**

---

## 🎓 What You Mastered

✅ **Incident response**: Triage → Fix → Prevent → Document  
✅ **Label debugging**: Using `--show-labels` to find mismatches  
✅ **Readiness probes**: Preventing bad pods from receiving traffic  
✅ **Validation scripts**: Automating checks to prevent future issues  

---

## 🚀 Next Challenge

Continue with **Labs 4-7**, then return for:

**[Challenge Lab B: Black Friday Rush](challenge-b-black-friday.md)** (After Lab 7)

Test your scaling, security, and performance tuning skills under pressure!

---

## 🆘 Solution (Only Open After Completing!)

<details>
<summary>Full Solution Walkthrough</summary>

### The Bug
The deployment had `app: weather-backed` (typo) while Service selector looked for `app: weather-backend`.

### Complete Fix
```bash
# 1. Find the issue
kubectl get svc weather-backend -n incident-lab -o yaml | grep selector
kubectl get pods -n incident-lab --show-labels

# 2. Fix the label
kubectl patch deployment weather-backend -n incident-lab \
  -p '{"spec":{"template":{"metadata":{"labels":{"app":"weather-backend"}}}}}'

# 3. Add readiness probe
kubectl patch deployment weather-backend -n incident-lab --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/readinessProbe", "value": {"httpGet": {"path": "/health", "port": 8000}, "initialDelaySeconds": 5, "periodSeconds": 5}}]'

# 4. Add resources
kubectl set resources deployment weather-backend -n incident-lab \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi

# 5. Verify
kubectl get pods -n incident-lab
curl http://localhost:8080
```
</details>
