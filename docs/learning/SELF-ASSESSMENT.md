# 🎓 Kubernetes Knowledge Self-Assessment (Adventure Mode)

Quick quizzes to verify mastery after each lab. Be honest, learn, repeat.

---

## 🚀 How to Play
- 🧭 **Pick your stage**: Only take quizzes for labs you’ve completed.
- ✍️ **Mark your answers**: Circle (or click) the option you believe is correct.
- 🔐 **No peeking**: Reveal the answer key in each `<details>` block only after you’ve committed.
- 📊 **Tally your score**: Use the stage scoring guidance, then update the overall scoreboard at the end.
- 🔁 **Loop for mastery**: Scores under target? Re-run the lab, review `COMMON-MISTAKES.md`, and come back stronger.

---

## 🧭 Stage 1 · Launchpad (⭐)

### 🌦️ Lab 1 · Weather App Basics
<details>
<summary>Take the quiz</summary>

1. **What command creates a deployment?**
   - [ ] A) `kubectl deploy weather-app --image=weather-app:latest`
   - [ ] B) `kubectl create deployment weather-app --image=weather-app:latest`
   - [ ] C) `kubectl apply -f deployment.yaml`
   - [ ] D) Both B and C
2. **What does `replicas: 3` mean in a Deployment?**
   - [ ] A) Create 3 different Deployments
   - [ ] B) Run 3 identical pods
   - [ ] C) Create 3 Services
   - [ ] D) Scale the cluster to 3 nodes
3. **How do you expose a deployment externally in Minikube?**
   - [ ] A) `kubectl expose deployment weather-app --type=ClusterIP`
   - [ ] B) `kubectl expose deployment weather-app --type=LoadBalancer` + `minikube tunnel`
   - [ ] C) `kubectl create service weather-app`
   - [ ] D) `kubectl port-forward`
4. **Command to see real-time pod status changes?**
   - [ ] A) `kubectl get pods --watch`
   - [ ] B) `kubectl describe pods`
   - [ ] C) `kubectl logs pods`
   - [ ] D) `kubectl status pods`
5. **A pod is in `CrashLoopBackOff`. First debugging step?**
   - [ ] A) Delete and recreate it
   - [ ] B) Check pod logs: `kubectl logs <pod-name>`
   - [ ] C) Restart the cluster
   - [ ] D) Change the image

**Answer key**: 1️⃣ D · 2️⃣ B · 3️⃣ B · 4️⃣ A · 5️⃣ B  
**Scoring**: 5/5 = ⭐⭐ Rocket ready · 3-4 = ⭐ Solid launch · ≤2 = 🔄 Re-fly Lab 1
</details>

### 🛒 Lab 2 · E-commerce Multi-Tier
<details>
<summary>Take the quiz</summary>

1. **How do backend pods discover the PostgreSQL service?**
   - [ ] A) Hardcoded IP address
   - [ ] B) DNS: `postgres.ecommerce-app.svc.cluster.local`
   - [ ] C) Environment variable only
   - [ ] D) They can’t communicate
2. **What does a ConfigMap provide?**
   - [ ] A) Sensitive password storage
   - [ ] B) Non-sensitive configuration data
   - [ ] C) Container images
   - [ ] D) Pod replicas
3. **Frontend connects to backend via?**
   - [ ] A) Pod IP directly
   - [ ] B) Service name (e.g., `backend-service`)
   - [ ] C) Node IP
   - [ ] D) External URL
4. **Why use multiple Services?**
   - [ ] A) Each tier needs its own load balancer
   - [ ] B) Separate concerns (frontend/backend/database)
   - [ ] C) Required by Kubernetes
   - [ ] D) No reason
5. **Command to check Service endpoints?**
   - [ ] A) `kubectl get services`
   - [ ] B) `kubectl get endpoints`
   - [ ] C) `kubectl describe service <name>`
   - [ ] D) Both B and C

**Answer key**: 1️⃣ B · 2️⃣ B · 3️⃣ B · 4️⃣ B · 5️⃣ D  
**Scoring**: 5/5 = ⭐⭐ Multi-tier master · 3-4 = ⭐ Keep refining · ≤2 = 🔄 Revisit Lab 2 routing
</details>

---

## 🛠️ Stage 2 · Builders Guild (⭐⭐)

### 🎓 Lab 3 · Educational Stateful
<details>
<summary>Take the quiz</summary>

1. **Difference between Deployment and StatefulSet?**
   - [ ] A) StatefulSet maintains pod identity/order; Deployment doesn’t
   - [ ] B) No difference
   - [ ] C) StatefulSet only for databases
   - [ ] D) Deployment is newer
2. **What is a PersistentVolumeClaim (PVC)?**
   - [ ] A) Request for storage by a pod
   - [ ] B) Physical disk
   - [ ] C) ConfigMap for storage
   - [ ] D) Service for volumes
3. **Why use StatefulSet for PostgreSQL?**
   - [ ] A) Data must survive pod restarts
   - [ ] B) Ordered deployment
   - [ ] C) Stable network identity
   - [ ] D) All of the above
4. **What happens to data if pod restarts?**
   - [ ] A) Lost forever
   - [ ] B) Persists if PVC attached
   - [ ] C) Automatically backed up
   - [ ] D) Duplicated
5. **Command to check persistent volumes?**
   - [ ] A) `kubectl get pv`
   - [ ] B) `kubectl get pvc`
   - [ ] C) Both A and B
   - [ ] D) `kubectl get volumes`

**Answer key**: 1️⃣ A · 2️⃣ A · 3️⃣ D · 4️⃣ B · 5️⃣ C  
**Scoring**: 5/5 = ⭐⭐⭐ Storage sage · 3-4 = ⭐⭐ Review persistence · ≤2 = 🔄 Replay Lab 3 slowly
</details>

### ✅ Lab 4 · Task Manager Ingress
<details>
<summary>Take the quiz</summary>

1. **What is Ingress?**
   - [ ] A) A type of Service
   - [ ] B) HTTP/HTTPS routing to Services
   - [ ] C) Firewall rules
   - [ ] D) Pod security
2. **Ingress requires what to work?**
   - [ ] A) Nothing—built in
   - [ ] B) Ingress Controller (nginx, traefik, etc.)
   - [ ] C) Cloud provider only
   - [ ] D) External DNS
3. **What does TLS in Ingress provide?**
   - [ ] A) Faster routing
   - [ ] B) HTTPS encryption
   - [ ] C) Load balancing
   - [ ] D) Service discovery
4. **Path-based routing example:**
   - [ ] A) `/api` → backend, `/` → frontend
   - [ ] B) Different ports
   - [ ] C) Different namespaces
   - [ ] D) Different clusters
5. **Check Ingress status:**
   - [ ] A) `kubectl get ingress`
   - [ ] B) `kubectl describe ingress <name>`
   - [ ] C) Check if ADDRESS field is populated
   - [ ] D) All of the above

**Answer key**: 1️⃣ B · 2️⃣ B · 3️⃣ B · 4️⃣ A · 5️⃣ D  
**Scoring**: 5/5 = ⭐⭐⭐ Ingress ace · 3-4 = ⭐⭐ Keep practicing · ≤2 = 🔄 Re-run Lab 4 configuration
</details>

---

## 🛡️ Stage 3 · Production Ops (⭐⭐⭐)

### 🏥 Lab 5 · Medical Security
<details>
<summary>Take the quiz</summary>

1. **What is RBAC?**
   - [ ] A) Resource-Based Access Control
   - [ ] B) Role-Based Access Control
   - [ ] C) Rule-Based Access Control
   - [ ] D) Random Access Control
2. **What does NetworkPolicy control?**
   - [ ] A) Internet access
   - [ ] B) Pod-to-pod communication
   - [ ] C) Service routing
   - [ ] D) Storage access
3. **Difference between Secret and ConfigMap?**
   - [ ] A) No difference
   - [ ] B) Secrets are base64 encoded
   - [ ] C) Secrets for sensitive data, ConfigMap for non-sensitive
   - [ ] D) Both B and C
4. **What is a ServiceAccount?**
   - [ ] A) User account
   - [ ] B) Identity for pods to access K8s API
   - [ ] C) Database account
   - [ ] D) Service configuration
5. **NetworkPolicy “Ingress” means?**
   - [ ] A) HTTP ingress controller
   - [ ] B) Incoming traffic TO the pod
   - [ ] C) Outgoing traffic FROM the pod
   - [ ] D) External traffic only

**Answer key**: 1️⃣ B · 2️⃣ B · 3️⃣ D · 4️⃣ B · 5️⃣ B  
**Scoring**: 5/5 = ⭐⭐⭐ Security sentinel · 3-4 = ⭐⭐ Review RBAC/NetworkPolicies · ≤2 = 🔄 Revisit Lab 5
</details>

### 📈 Lab 6 · Social Scaling
<details>
<summary>Take the quiz</summary>

1. **What does HorizontalPodAutoscaler (HPA) do?**
   - [ ] A) Increases pod memory
   - [ ] B) Adds more replicas based on metrics
   - [ ] C) Increases node count
   - [ ] D) Upgrades container images
2. **HPA requires what to function?**
   - [ ] A) Nothing
   - [ ] B) Metrics Server
   - [ ] C) Prometheus
   - [ ] D) Manual scaling
3. **Resource requests are needed for HPA because?**
   - [ ] A) HPA calculates % of requested resources
   - [ ] B) Security requirement
   - [ ] C) Not needed
   - [ ] D) Cost tracking
4. **What is VPA (VerticalPodAutoscaler)?**
   - [ ] A) Adds more pods
   - [ ] B) Increases CPU/memory of existing pods
   - [ ] C) Scales nodes
   - [ ] D) Same as HPA
5. **Check HPA status:**
   - [ ] A) `kubectl get hpa`
   - [ ] B) `kubectl describe hpa <name>`
   - [ ] C) `kubectl top pods`
   - [ ] D) All of the above

**Answer key**: 1️⃣ B · 2️⃣ B · 3️⃣ A · 4️⃣ B · 5️⃣ D  
**Scoring**: 5/5 = ⭐⭐⭐⭐ Scaling maestro · 3-4 = ⭐⭐⭐ Tune autoscaling · ≤2 = 🔄 Revisit Lab 6 metrics
</details>

---

## 🌐 Stage 4 · Platform Wizards (⭐⭐⭐⭐)

### 🧩 Lab 7 · Multi-App Orchestration
<details>
<summary>Take the quiz</summary>

1. **What is a Service Mesh?**
   - [ ] A) Multiple services
   - [ ] B) Infrastructure layer for service-to-service communication
   - [ ] C) Mesh network topology
   - [ ] D) Service discovery
2. **Istio provides what capabilities?**
   - [ ] A) Traffic management, security, observability
   - [ ] B) Just load balancing
   - [ ] C) Only monitoring
   - [ ] D) Container runtime
3. **What is a sidecar proxy?**
   - [ ] A) Extra container in pod handling networking
   - [ ] B) Secondary pod
   - [ ] C) Backup container
   - [ ] D) Security scanner
4. **Prometheus is used for?**
   - [ ] A) Log aggregation
   - [ ] B) Metrics collection and alerting
   - [ ] C) Container orchestration
   - [ ] D) CI/CD
5. **Grafana is used for?**
   - [ ] A) Metrics collection
   - [ ] B) Metrics visualization (dashboards)
   - [ ] C) Log storage
   - [ ] D) Container builds

**Answer key**: 1️⃣ B · 2️⃣ A · 3️⃣ A · 4️⃣ B · 5️⃣ B  
**Scoring**: 5/5 = ⭐⭐⭐⭐ Mesh mage · 3-4 = ⭐⭐⭐ Review Istio/observability · ≤2 = 🔄 Revisit Lab 7
</details>

### ⚡ Lab 8 · Chaos Engineering
<details>
<summary>Take the quiz</summary>

1. **What is Chaos Engineering?**
   - [ ] A) Breaking things randomly
   - [ ] B) Controlled experiments to test resilience
   - [ ] C) Stressing servers
   - [ ] D) Security testing
2. **Chaos Mesh can simulate what?**
   - [ ] A) Pod failures, network issues, I/O stress
   - [ ] B) Only pod deletions
   - [ ] C) Code bugs
   - [ ] D) User traffic
3. **Why practice chaos engineering?**
   - [ ] A) Find weaknesses before production incidents
   - [ ] B) Test recovery procedures
   - [ ] C) Validate monitoring/alerting
   - [ ] D) All of the above
4. **What is “blast radius” in chaos experiments?**
   - [ ] A) Scope of impact (pods, namespaces affected)
   - [ ] B) Server explosion
   - [ ] C) Network distance
   - [ ] D) Pod count
5. **Good chaos experiment practices?**
   - [ ] A) Start small (1 pod), expand gradually
   - [ ] B) Have rollback plan
   - [ ] C) Monitor during experiments
   - [ ] D) All of the above

**Answer key**: 1️⃣ B · 2️⃣ A · 3️⃣ D · 4️⃣ A · 5️⃣ D  
**Scoring**: 5/5 = ⭐⭐⭐⭐ Chaos tamer · 3-4 = ⭐⭐⭐ Keep experimenting · ≤2 = 🔄 Replay Lab 8
</details>

### 🪄 Lab 9 · Helm Package Management
<details>
<summary>Take the quiz</summary>

1. **What is Helm?**
   - [ ] A) Container runtime
   - [ ] B) Package manager for Kubernetes
   - [ ] C) Service mesh
   - [ ] D) Monitoring tool
2. **What is a Helm Chart?**
   - [ ] A) Performance graph
   - [ ] B) Package of Kubernetes resources with templates
   - [ ] C) Configuration file
   - [ ] D) Database schema
3. **Purpose of `values.yaml`?**
   - [ ] A) Store secrets
   - [ ] B) Define default configuration parameters
   - [ ] C) List dependencies
   - [ ] D) Template helpers
4. **Customize a chart during installation?**
   - [ ] A) Edit the chart directly
   - [ ] B) Use `--set` or pass a custom `--values` file
   - [ ] C) Modify templates in place
   - [ ] D) Change `Chart.yaml`
5. **What does `helm upgrade` do?**
   - [ ] A) Updates Helm CLI
   - [ ] B) Updates an existing release with new values/chart
   - [ ] C) Upgrades Kubernetes
   - [ ] D) Installs new chart

**Answer key**: 1️⃣ B · 2️⃣ B · 3️⃣ B · 4️⃣ B · 5️⃣ B  
**Scoring**: 5/5 = ⭐⭐⭐⭐ Helm hero · 3-4 = ⭐⭐⭐ Practice templating · ≤2 = 🔄 Repeat Lab 9 packaging
</details>

---

## 🤖 Stage 5 · Automation Legends (⭐⭐⭐⭐)

### 🚀 Lab 10 · GitOps with ArgoCD
<details>
<summary>Take the quiz</summary>

1. **What is GitOps?**
   - [ ] A) Git hosting service
   - [ ] B) Operational model where Git is the source of truth
   - [ ] C) Code deployment tool
   - [ ] D) Container registry
2. **What does ArgoCD do?**
   - [ ] A) Manages Git repositories
   - [ ] B) Continuously syncs the cluster with Git state
   - [ ] C) Builds container images
   - [ ] D) Monitors applications
3. **What triggers a deployment in GitOps?**
   - [ ] A) Manual `kubectl` commands
   - [ ] B) CI pipeline push
   - [ ] C) Git commit to the repository
   - [ ] D) Webhook calls only
4. **Main benefit of pull-based deployments?**
   - [ ] A) Faster deployments
   - [ ] B) No cluster credentials needed in CI
   - [ ] C) Smaller images
   - [ ] D) Better monitoring
5. **How do you rollback in GitOps?**
   - [ ] A) `kubectl rollout undo`
   - [ ] B) Git revert + ArgoCD sync
   - [ ] C) Delete pods
   - [ ] D) Redeploy manually

**Answer key**: 1️⃣ B · 2️⃣ B · 3️⃣ C · 4️⃣ B · 5️⃣ B  
**Scoring**: 5/5 = ⭐⭐⭐⭐ GitOps guru · 3-4 = ⭐⭐⭐ Review automation flow · ≤2 = 🔄 Revisit Lab 10
</details>

### 🔐 Lab 11 · External Secrets Management
<details>
<summary>Take the quiz</summary>

1. **What is External Secrets Operator (ESO)?**
   - [ ] A) Container image builder
   - [ ] B) Controller that syncs secrets from external systems
   - [ ] C) Kubernetes scheduler
   - [ ] D) Network policy manager
2. **Which CRD defines where external secrets are stored?**
   - [ ] A) ExternalSecret
   - [ ] B) SecretStore
   - [ ] C) SecretProvider
   - [ ] D) ExternalStore
3. **Main advantage of ESO over manual secret management?**
   - [ ] A) Faster pod startup
   - [ ] B) Automatic secret rotation from external sources
   - [ ] C) Smaller secret size
   - [ ] D) Better CPU performance
4. **What happens if the external secret backend becomes unavailable?**
   - [ ] A) All pods immediately fail
   - [ ] B) Existing Kubernetes secrets continue to work
   - [ ] C) Cluster stops functioning
   - [ ] D) All data is lost
5. **When would you use ClusterSecretStore vs SecretStore?**
   - [ ] A) ClusterSecretStore for single namespace; SecretStore for cluster-wide
   - [ ] B) ClusterSecretStore for cluster-wide; SecretStore for single namespace
   - [ ] C) They are identical
   - [ ] D) ClusterSecretStore is deprecated

**Answer key**: 1️⃣ B · 2️⃣ B · 3️⃣ B · 4️⃣ B · 5️⃣ B  
**Scoring**: 5/5 = ⭐⭐⭐⭐ Secrets sage · 3-4 = ⭐⭐⭐ Review ESO flows · ≤2 = 🔄 Revisit Lab 11
</details>

---

## 🧠 Stage 6 · Fundamentals Deep Dive (⭐⭐⭐⭐⭐)

### 🧠 Lab 12 · Troubleshooting Gauntlet
<details>
<summary>Take the quiz</summary>

1. **How do you filter pods by label when listing them?**
   - [ ] A) `kubectl get pods -l app=frontend`
   - [ ] B) `kubectl get pods --selector app=frontend`
   - [ ] C) Both A and B
   - [ ] D) `kubectl describe deployments`
2. **Best way to restart a deployment without deleting it manually?**
   - [ ] A) `kubectl delete pods -l app=my-app`
   - [ ] B) `kubectl rollout restart deployment my-app`
   - [ ] C) `kubectl scale deployment my-app --replicas=0`
   - [ ] D) `kubectl apply -f deployment.yaml`
3. **Command to confirm the latest rollout succeeded?**
   - [ ] A) `kubectl get deployments`
   - [ ] B) `kubectl rollout status deployment/weather-app`
   - [ ] C) `kubectl describe deployment weather-app`
   - [ ] D) `kubectl rollout history deployment/weather-app`
4. **If a Service shows no endpoints, where do you look first?**
   - [ ] A) ConfigMap definitions
   - [ ] B) Service selector vs. pod labels
   - [ ] C) ClusterRole bindings
   - [ ] D) Ingress host rules
5. **Which command helps reveal labels while listing pods?**
   - [ ] A) `kubectl get pods --show-labels`
   - [ ] B) `kubectl logs <pod>`
   - [ ] C) `kubectl edit deployment`
   - [ ] D) `kubectl port-forward deployment`

**Answer key**: 1️⃣ C · 2️⃣ B · 3️⃣ B · 4️⃣ B · 5️⃣ A  
**Scoring**: 5/5 = 🧙 Troubleshooting wizard · 3-4 = 🧠 Strong fundamentals · ≤2 = 🔄 Walk through Lab 12 drills again
</details>

---

## 📈 Scoreboard
Record your total correct answers across all labs tackled:

| Total Correct | Title | What it means |
| --- | --- | --- |
| 55-60 (91%+) | 🏆 Kubernetes Expert | Ready for real-world on-call + certification preps |
| 48-54 | 🌟 Advanced Practitioner | Production-ready, revisit any weak spots |
| 36-47 | 📚 Intermediate Learner | Solid foundation, repeat tricky labs |
| ≤35 | 🔄 Needs Review | Slow down, revisit labs, revisit `COMMON-MISTAKES.md`

_Psst: You can always retake sections and bump your score. This isn’t graded—it's growth tracking._

---

## 🧮 Skill Matrix Tracker
Check your confidence (1-5) as you progress. Update after each lab run.

| Skill | Stage | Confidence (1-5) |
| --- | --- | --- |
| Deploy pods/deployments | Launchpad | ☐ ☐ ☐ ☐ ☐ |
| Create services & expose apps | Launchpad | ☐ ☐ ☐ ☐ ☐ |
| Multi-tier service discovery | Launchpad | ☐ ☐ ☐ ☐ ☐ |
| StatefulSets & PVCs | Builders Guild | ☐ ☐ ☐ ☐ ☐ |
| Ingress + TLS routing | Builders Guild | ☐ ☐ ☐ ☐ ☐ |
| RBAC & ServiceAccounts | Production Ops | ☐ ☐ ☐ ☐ ☐ |
| NetworkPolicies | Production Ops | ☐ ☐ ☐ ☐ ☐ |
| Autoscaling (HPA/VPA) | Production Ops | ☐ ☐ ☐ ☐ ☐ |
| Service mesh & observability | Platform Wizards | ☐ ☐ ☐ ☐ ☐ |
| Chaos engineering & resilience | Platform Wizards | ☐ ☐ ☐ ☐ ☐ |
| Helm templating & releases | Platform Wizards | ☐ ☐ ☐ ☐ ☐ |
| GitOps & ArgoCD | Automation Legends | ☐ ☐ ☐ ☐ ☐ |
| External Secrets strategies | Automation Legends | ☐ ☐ ☐ ☐ ☐ |
| Troubleshooting toolkit | Fundamentals Deep Dive | ☐ ☐ ☐ ☐ ☐ |

**Aim**: Hit ≥4 in each category before you call it “production ready.”

---

## 🪜 Next Moves After Scoring
- 🥇 **Crushed it?** Mentor someone, tackle a community issue, or spin up your own side project on Kubernetes.
- 🔁 **Almost there?** Re-run targeted labs, revisit reference guides, and journal the tricky bits you uncover.
- 🧑‍🤝‍🧑 **Need a boost?** Pair with a friend, ask in Kubernetes Slack, or schedule a focused study sprint.

**Remember**: Mastery isn’t a finish line—it’s a loop. Keep roaming the cluster, keep asking "why", and keep leveling up! 🚀
