# 🚨 Common Kubernetes Mistakes (Boss Fight Edition)

You made it this far—now dodge the traps that trip up even seasoned cluster wranglers. Keep this guide nearby while you lab and treat every mistake as an XP boost waiting to happen.

---

## 🎯 Quick-Use Cheat Sheet
- 📍 Always call out your namespace (`-n <namespace>`) before you change anything.
- 🛰️ Watch pods and logs before declaring victory.
- 🔁 Know which Service type you really need (internal vs. external).
- 🛡️ Lock down resource usage, configs, and secrets like a pro.
- 🧪 Add probes, labels, and cleanups to your daily ritual.

Ready? Let’s clear these stages one at a time.

---

## 🧭 Stage 1 · Cluster Orientation (⭐)

### 1. 🗺️ Forgetting Your Namespace
- ❌ **Facepalm moment**:
  ```bash
  kubectl get pods  # "No resources found in default namespace"
  ```
- ✅ **Pro move**:
  ```bash
  kubectl get pods -n weather-app
  kubectl config set-context --current --namespace=weather-app
  ```
- 🧠 **Why it matters**: Most labs ship resources outside `default`. If you don’t switch gears, you’ll think everything vanished.

### 2. 👀 Not Checking Pod Status
- ❌ **Hope-driven deployment**:
  ```bash
  kubectl apply -f deployment.yaml
  # Then immediately: kubectl get service
  ```
- ✅ **Reality check**:
  ```bash
  kubectl apply -f deployment.yaml
  kubectl get pods -n weather-app --watch
  kubectl logs <pod-name> -n weather-app
  ```
- 🧠 **Why it matters**: Celebrate only when those pods show `Running`. `CrashLoopBackOff` is a badge of debugging honor, not failure.

### 3. 🌉 Wrong Service Type
- ❌ **Invisible app**:
  ```yaml
  spec:
    type: ClusterIP  # ❌ Internal only
  ```
- ✅ **Choose wisely**:
  ```yaml
  spec:
    type: LoadBalancer  # ✅ External access (use `minikube tunnel` or port-forwarding when local)
  ```
- 🧠 **Why it matters**: Service types decide who can reach your app—cluster buddies only, node IP fans, or the whole world.

---

## 🧱 Stage 2 · Resource Mastery (⭐⭐)

### 4. ⚖️ Ignoring Resource Limits
- ❌ **Hungry pod**:
  ```yaml
  containers:
  - name: app
    image: my-app
  ```
- ✅ **Budget like Ops**:
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
- 🧠 **Why it matters**: One greedy container can starve the node. Guardrails keep the whole squad healthy.

### 5. 🔐 Hardcoding Secrets
- ❌ **YAML confession**:
  ```yaml
  env:
  - name: DATABASE_PASSWORD
    value: "mysecretpassword123"
  ```
- ✅ **Secret vaulting**:
  ```yaml
  env:
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
  ```
- 🧠 **Why it matters**: Secrets in plain text leak faster than you can say `git push`.

### 6. 🫀 Skipping Probes
- ❌ **Blind trust**:
  ```yaml
  containers:
  - name: app
    image: my-app
  ```
- ✅ **Health HUD**:
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
- 🧠 **Why it matters**: Readiness controls traffic, liveness keeps restarts from zombie apps. Don’t ship without them.

---

## 🕸️ Stage 3 · Traffic & Identity (⭐⭐⭐)

### 7. 🎯 Misaligned Label Selectors
- ❌ **Silent Service**:
  ```yaml
  # Service selector
  selector:
    app: weather-frontend

  # Deployment labels
  labels:
    app: weather-app
  ```
- ✅ **Perfect match**:
  ```yaml
  selector:
    app: weather-app
  ```
- 🧠 **Why it matters**: Services route by labels. Miss even one character and traffic stops flowing.

### 8. 🌀 Using `latest`
- ❌ **Mystery builds**:
  ```yaml
  image: myapp:latest
  ```
- ✅ **Versioned destiny**:
  ```yaml
  image: myapp:v1.2.3
  imagePullPolicy: IfNotPresent
  ```
- 🧠 **Why it matters**: Reproducibility is everything. Pin versions or future-you will be on-call at 3 a.m.

---

## 🧼 Stage 4 · Operational Hygiene (⭐⭐⭐⭐)

### 9. 🧟‍♂️ Not Cleaning Up
- ❌ **Zombie namespace**:
  ```bash
  kubectl apply -f deployment.yaml
  # tweak, apply, tweak, apply... never delete
  ```
- ✅ **Fresh start**:
  ```bash
  kubectl delete namespace weather-app
  kubectl create namespace weather-app
  kubectl apply -f deployment.yaml
  ```
- 🧠 **Why it matters**: Ghost resources steal IPs, ports, and sanity.

### 10. 🧩 Copy-Pasting Without Understanding
- ❌ **Mystery YAML**:
  ```yaml
  # 500 lines you’ve never read
  ```
- ✅ **Incremental mastery**:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: weather-app
  spec:
    replicas: 1
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
- 🧠 **Why it matters**: Build muscle memory one field at a time. Layer in probes, limits, ConfigMaps, and secrets as you understand them.

---

## 🛠️ Debugging Flight Checklist
Work this list top-to-bottom whenever something feels off:

1. 🔍 **Pod Status**
   ```bash
   kubectl get pods -n <namespace>
   ```
   - `Pending`: scheduling/resources
   - `CrashLoopBackOff`: app crash
   - `ImagePullBackOff`: registry/auth

2. 🪵 **Logs**
   ```bash
   kubectl logs <pod> -n <namespace>
   kubectl logs <pod> -n <namespace> --previous
   ```

3. 🗞️ **Events**
   ```bash
   kubectl describe pod <pod> -n <namespace>
   ```

4. 🌐 **Service Endpoints**
   ```bash
   kubectl get endpoints -n <namespace>
   ```
   Empty list? Label mismatch.

5. 🧭 **Namespace Exists**
   ```bash
   kubectl get namespace <namespace>
   ```

6. 🛰️ **Context & Cluster**
   ```bash
   kubectl config current-context
   kubectl cluster-info
   ```

---

## 💡 Power-Ups
- 🧪 **Dry run everything**:
  ```bash
  kubectl apply -f deployment.yaml --dry-run=client
  ```
- 🧱 **Generate YAML first**:
  ```bash
  kubectl create deployment weather-app --image=weather-app:latest --dry-run=client -o yaml > deployment.yaml
  ```
- 👀 **Watch stuff move**:
  ```bash
  kubectl get pods -n weather-app --watch
  ```
- 📚 **Use `kubectl explain`**:
  ```bash
  kubectl explain deployment.spec.template.spec.containers
  ```
- 🕵️ **Shell into pods**:
  ```bash
  kubectl exec -it <pod> -n <namespace> -- /bin/sh
  ```

---

## 🎯 Golden Rules Recap

| ✅ Do This | 🚫 Skip This |
| --- | --- |
| Set your namespace every time | Assuming `default` always works |
| Pin image tags | Shipping `latest` to prod |
| Add resource requests/limits | Letting apps consume the node |
| Wire probes, labels, ConfigMaps, Secrets | Blind deployments with mystery labels |
| Clean up namespaces after experiments | Leaving zombie resources around |

---

## 🚀 Next Steps
1. 🎯 **Break something on purpose** and use the checklist to recover it.
2. 🧭 **Read Events like a detective**—they tell the honest story.
3. 🧠 **Teach what you just fixed** to a teammate or rubber duck.
4. 🔁 **Repeat labs with new constraints** (limited CPU, chaos tests) to level up faster.

**Remember**: Every “oops” becomes a power-up once you document the lesson. Keep experimenting! 💥
