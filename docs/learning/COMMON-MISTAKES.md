# 🚨 Common Kubernetes Mistakes & How to Avoid Them

Learn from common mistakes WITHOUT making them yourself!

---

## 🔥 Top 10 Mistakes Beginners Make

### 1. **Forgetting Namespaces** 
❌ **Mistake**: 
```bash
kubectl get pods  # "No resources found in default namespace"
```

✅ **Fix**:
```bash
kubectl get pods -n weather-app
# OR set context
kubectl config set-context --current --namespace=weather-app
```

**Why it matters**: Your resources are in specific namespaces, not `default`.

---

### 2. **Not Checking Pod Status**
❌ **Mistake**: Assuming deployment succeeded without checking
```bash
kubectl apply -f deployment.yaml
# Then immediately: kubectl get service  (service works but pods don't)
```

✅ **Fix**:
```bash
kubectl apply -f deployment.yaml
kubectl get pods -n weather-app --watch  # WAIT for "Running" status
kubectl logs <pod-name> -n weather-app   # Check for errors
```

**Why it matters**: Pods can be in `CrashLoopBackOff`, `ImagePullBackOff`, or `Error` state.

---

### 3. **Wrong Service Type**
❌ **Mistake**: Using `ClusterIP` and expecting external access
```yaml
spec:
  type: ClusterIP  # ❌ Only accessible inside cluster
```

✅ **Fix**:
```yaml
spec:
  type: LoadBalancer  # ✅ Accessible externally (Minikube/Kind: minikube tunnel)
```

**Why it matters**: Service types determine accessibility:
- `ClusterIP`: Internal only
- `NodePort`: External via node IP:port
- `LoadBalancer`: External via load balancer

---

### 4. **Ignoring Resource Limits**
❌ **Mistake**: No resource requests/limits
```yaml
containers:
- name: app
  image: my-app  # ❌ Can consume ALL node resources
```

✅ **Fix**:
```yaml
containers:
- name: app
  image: my-app
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "500m"
```

**Why it matters**: Prevents one app from starving others of resources.

---

### 5. **Hardcoded Configuration**
❌ **Mistake**: Secrets in deployment YAML
```yaml
env:
- name: DATABASE_PASSWORD
  value: "mysecretpassword123"  # ❌ NEVER DO THIS
```

✅ **Fix**:
```yaml
env:
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

**Why it matters**: Secrets in plain text are security vulnerabilities.

---

### 6. **Not Using Health Checks**
❌ **Mistake**: No probes defined
```yaml
containers:
- name: app
  image: my-app  # ❌ Kubernetes doesn't know if app is healthy
```

✅ **Fix**:
```yaml
containers:
- name: app
  image: my-app
  livenessProbe:
    httpGet:
      path: /health
      port: 8080
    initialDelaySeconds: 30
  readinessProbe:
    httpGet:
      path: /ready
      port: 8080
    initialDelaySeconds: 5
```

**Why it matters**: Kubernetes needs to know when to restart or route traffic.

---

### 7. **Incorrect Label Selectors**
❌ **Mistake**: Service selector doesn't match pod labels
```yaml
# Service
selector:
  app: weather-frontend  # ❌ Typo

# Deployment
labels:
  app: weather-app  # Different label!
```

✅ **Fix**: **MATCH EXACTLY**
```yaml
# Service
selector:
  app: weather-app

# Deployment
labels:
  app: weather-app
```

**Why it matters**: Selectors not matching = no traffic routing.

---

### 8. **Using `latest` Tag**
❌ **Mistake**:
```yaml
image: myapp:latest  # ❌ Unpredictable behavior
```

✅ **Fix**:
```yaml
image: myapp:v1.2.3  # ✅ Specific version
imagePullPolicy: IfNotPresent
```

**Why it matters**: `latest` can change unexpectedly; breaks reproducibility.

---

### 9. **Not Cleaning Up**
❌ **Mistake**: Leaving old resources running
```bash
kubectl apply -f deployment.yaml
# Make changes, apply again
kubectl apply -f deployment.yaml
# Never deletes old resources
```

✅ **Fix**:
```bash
kubectl delete namespace weather-app  # Clean slate
kubectl create namespace weather-app
kubectl apply -f deployment.yaml
```

**Why it matters**: Old resources consume cluster resources unnecessarily.

---

### 10. **Copy-Pasting Without Understanding**
❌ **Mistake**: Copying entire YAML files without reading
```yaml
# 500 lines of YAML you don't understand
```

✅ **Fix**: **START SMALL**
```yaml
# Start with minimal deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: weather-app
spec:
  replicas: 1  # Start with 1
  selector:
    matchLabels:
      app: weather-app
  template:
    metadata:
      labels:
        app: weather-app
    spec:
      containers:
      - name: weather-app
        image: weather-app:latest
        ports:
        - containerPort: 3000
```
**Then add complexity incrementally**: health checks → resource limits → ConfigMaps → secrets.

**Why it matters**: You learn by understanding each line, not copy-pasting.

---

## 🛠️ Debugging Checklist

When something doesn't work, check in this order:

1. **Pod Status**
   ```bash
   kubectl get pods -n <namespace>
   ```
   - `Pending`: Scheduling issue (resources, node selectors)
   - `CrashLoopBackOff`: App crashes on startup
   - `ImagePullBackOff`: Image not found or auth issue
   - `Error`: Check logs immediately

2. **Pod Logs**
   ```bash
   kubectl logs <pod-name> -n <namespace>
   kubectl logs <pod-name> -n <namespace> --previous  # Previous crash
   ```

3. **Pod Events**
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   # Look at "Events" section at bottom
   ```

4. **Service Endpoints**
   ```bash
   kubectl get endpoints -n <namespace>
   # Should list pod IPs - if empty, selector mismatch
   ```

5. **Namespace Exists**
   ```bash
   kubectl get namespace <namespace>
   ```

6. **Context/Cluster**
   ```bash
   kubectl config current-context
   kubectl cluster-info
   ```

---

## 💡 Pro Tips

### Tip 1: Use `--dry-run` Before Applying
```bash
kubectl apply -f deployment.yaml --dry-run=client
# Validates YAML without creating resources
```

### Tip 2: Generate YAML Instead of Writing
```bash
kubectl create deployment weather-app --image=weather-app:latest --dry-run=client -o yaml > deployment.yaml
# Edit the generated file
```

### Tip 3: Watch for Changes
```bash
kubectl get pods -n weather-app --watch
# Real-time updates
```

### Tip 4: Use `kubectl explain`
```bash
kubectl explain deployment.spec.template.spec.containers
# Built-in documentation
```

### Tip 5: Shell Into Running Pod
```bash
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
# Debug from inside the container
```

---

## 🎯 Best Practices Summary

✅ **DO**:
- Always specify namespace (`-n`)
- Use specific image tags (`v1.2.3`)
- Define resource requests/limits
- Add health checks (liveness/readiness)
- Use ConfigMaps for configuration
- Use Secrets for sensitive data
- Label everything consistently
- Check pod logs before assuming success
- Clean up when experimenting

❌ **DON'T**:
- Use `latest` tag in production
- Hardcode secrets in YAML
- Skip health checks
- Ignore resource limits
- Copy-paste without understanding
- Forget to check pod status
- Mix up label selectors
- Leave orphaned resources

---

## 🚀 Next Steps

After avoiding these mistakes:

1. **Practice intentionally breaking things** - Learn what each error looks like
2. **Read the Events section** - Most issues are explained there
3. **Use `kubectl describe`** - Your best debugging friend
4. **Check logs first** - Application logs reveal most issues
5. **Validate before applying** - Use `--dry-run=client`

**Remember**: Every expert was once a beginner who made these mistakes!
