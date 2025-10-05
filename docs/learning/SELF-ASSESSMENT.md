# 🎓 Kubernetes Knowledge Self-Assessment

Test your understanding after completing labs. Be honest with yourself!

---

## 📝 Lab 1: Weather App Basics (⭐)

### Questions

1. **What command creates a deployment?**
   - [ ] A) `kubectl deploy weather-app --image=weather-app:latest`
   - [ ] B) `kubectl create deployment weather-app --image=weather-app:latest`
   - [ ] C) `kubectl apply -f deployment.yaml`
   - [ ] D) Both B and C

2. **What does "replicas: 3" mean in a Deployment?**
   - [ ] A) Create 3 different deployments
   - [ ] B) Run 3 identical pods
   - [ ] C) Create 3 services
   - [ ] D) Scale to 3 nodes

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

5. **A pod is in "CrashLoopBackOff". First debugging step?**
   - [ ] A) Delete and recreate it
   - [ ] B) Check pod logs: `kubectl logs <pod-name>`
   - [ ] C) Restart the cluster
   - [ ] D) Change the image

<details>
<summary><b>Show Answers</b></summary>

1. **D** - Both B and C work (create imperative, apply declarative)
2. **B** - Maintains 3 identical pod copies for HA
3. **B** - LoadBalancer + minikube tunnel for local external access
4. **A** - `--watch` shows real-time updates
5. **B** - Always check logs first to understand why it's crashing

**Scoring**: 
- 5/5: ⭐ Excellent! Move to Lab 2
- 3-4/5: ⭐ Good, review concepts then proceed
- 0-2/5: 🔄 Redo Lab 1 and study docs/reference/kubectl-cheatsheet.md

</details>

---

## 📝 Lab 2: E-commerce Multi-Tier (⭐⭐)

### Questions

1. **How do backend pods discover PostgreSQL service?**
   - [ ] A) Hardcoded IP address
   - [ ] B) DNS: `postgres.ecommerce-app.svc.cluster.local`
   - [ ] C) Environment variable only
   - [ ] D) They can't communicate

2. **What ConfigMap provides?**
   - [ ] A) Sensitive password storage
   - [ ] B) Non-sensitive configuration data
   - [ ] C) Container images
   - [ ] D) Pod replicas

3. **Frontend connects to backend via?**
   - [ ] A) Pod IP directly
   - [ ] B) Service name (backend-service)
   - [ ] C) Node IP
   - [ ] D) External URL

4. **Why use multiple services?**
   - [ ] A) Each tier needs its own load balancer
   - [ ] B) Separate concerns (frontend/backend/database)
   - [ ] C) Required by Kubernetes
   - [ ] D) No reason

5. **Command to check service endpoints?**
   - [ ] A) `kubectl get services`
   - [ ] B) `kubectl get endpoints`
   - [ ] C) `kubectl describe service <name>`
   - [ ] D) Both B and C

<details>
<summary><b>Show Answers</b></summary>

1. **B** - Kubernetes DNS auto-resolves service names
2. **B** - ConfigMaps for non-sensitive config (use Secrets for passwords)
3. **B** - Services abstract pod IPs with stable DNS names
4. **B** - Service separation follows microservice architecture
5. **D** - Both show endpoints (pod IPs behind service)

**Scoring**:
- 5/5: ⭐⭐ Excellent! Multi-tier mastered
- 3-4/5: ⭐ Good, review service networking
- 0-2/5: 🔄 Redo Lab 2, study service discovery

</details>

---

## 📝 Lab 3: Educational Stateful (⭐⭐)

### Questions

1. **Difference between Deployment and StatefulSet?**
   - [ ] A) StatefulSet maintains pod identity/order, Deployment doesn't
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

<details>
<summary><b>Show Answers</b></summary>

1. **A** - StatefulSet: stable identity, ordered ops; Deployment: stateless
2. **A** - PVC is a storage request (PV is actual storage)
3. **D** - All are benefits of StatefulSet for databases
4. **B** - PVC ensures data persists across pod lifecycles
5. **C** - Check both PV (cluster resource) and PVC (namespace resource)

**Scoring**:
- 5/5: ⭐⭐ Excellent! Data persistence mastered
- 3-4/5: ⭐ Good, review StatefulSet concepts
- 0-2/5: 🔄 Redo Lab 3, study persistence

</details>

---

## 📝 Lab 4: Task Ingress (⭐⭐⭐)

### Questions

1. **What is Ingress?**
   - [ ] A) A type of service
   - [ ] B) HTTP/HTTPS routing to services
   - [ ] C) Firewall rules
   - [ ] D) Pod security

2. **Ingress requires what to work?**
   - [ ] A) Nothing, built into Kubernetes
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

<details>
<summary><b>Show Answers</b></summary>

1. **B** - Ingress routes external HTTP(S) to internal services
2. **B** - Ingress resource needs a controller to function
3. **B** - TLS terminates SSL/HTTPS at ingress layer
4. **A** - Path-based routing sends different paths to different services
5. **D** - All commands help verify ingress configuration

**Scoring**:
- 5/5: ⭐⭐⭐ Excellent! External access mastered
- 3-4/5: ⭐⭐ Good, review ingress concepts
- 0-2/5: 🔄 Redo Lab 4, study ingress patterns

</details>

---

## 📝 Lab 5: Medical Security (⭐⭐⭐)

### Questions

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

5. **NetworkPolicy "Ingress" means?**
   - [ ] A) HTTP ingress controller
   - [ ] B) Incoming traffic TO the pod
   - [ ] C) Outgoing traffic FROM the pod
   - [ ] D) External traffic only

<details>
<summary><b>Show Answers</b></summary>

1. **B** - RBAC assigns permissions based on roles
2. **B** - NetworkPolicy controls which pods can communicate
3. **D** - Secrets are base64 encoded AND meant for sensitive data
4. **B** - ServiceAccount provides identity for pods to access K8s resources
5. **B** - Ingress = incoming TO pod; Egress = outgoing FROM pod

**Scoring**:
- 5/5: ⭐⭐⭐ Excellent! Security concepts mastered
- 3-4/5: ⭐⭐ Good, review RBAC and NetworkPolicy
- 0-2/5: 🔄 Redo Lab 5, study security

</details>

---

## 📝 Lab 6: Social Scaling (⭐⭐⭐⭐)

### Questions

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
   - [ ] A) HPA calculates percentage of requested resources
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
   - [ ] C) `kubectl top pods` (verify metrics)
   - [ ] D) All of the above

<details>
<summary><b>Show Answers</b></summary>

1. **B** - HPA adds/removes pod replicas based on CPU/memory
2. **B** - Metrics Server provides resource usage data to HPA
3. **A** - HPA scales at 50% of requested resources (default target)
4. **B** - VPA adjusts CPU/memory; HPA adjusts replica count
5. **D** - All commands help monitor autoscaling behavior

**Scoring**:
- 5/5: ⭐⭐⭐⭐ Excellent! Autoscaling mastered
- 3-4/5: ⭐⭐⭐ Good, review HPA mechanics
- 0-2/5: 🔄 Redo Lab 6, study autoscaling

</details>

---

## 📝 Lab 7: Multi-App Orchestration (⭐⭐⭐⭐)

### Questions

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

<details>
<summary><b>Show Answers</b></summary>

1. **B** - Service mesh manages inter-service networking, security, observability
2. **A** - Istio provides traffic management, mTLS, and observability
3. **A** - Sidecar container (Envoy) proxies all network traffic
4. **B** - Prometheus scrapes and stores time-series metrics
5. **B** - Grafana visualizes Prometheus metrics in dashboards

**Scoring**:
- 5/5: ⭐⭐⭐⭐ Excellent! Advanced orchestration mastered
- 3-4/5: ⭐⭐⭐ Good, review service mesh concepts
- 0-2/5: 🔄 Redo Lab 7, study Istio

</details>

---

## 📝 Lab 8: Chaos Engineering (⭐⭐⭐⭐)

### Questions

1. **What is Chaos Engineering?**
   - [ ] A) Breaking things randomly
   - [ ] B) Controlled experiments to test system resilience
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

4. **What is "blast radius" in chaos experiments?**
   - [ ] A) Scope of impact (pods, namespaces affected)
   - [ ] B) Server explosion
   - [ ] C) Network distance
   - [ ] D) Pod count

5. **Good chaos experiment practices?**
   - [ ] A) Start small (1 pod), expand gradually
   - [ ] B) Have rollback plan
   - [ ] C) Monitor during experiments
   - [ ] D) All of the above

<details>
<summary><b>Show Answers</b></summary>

1. **B** - Controlled failure injection to test resilience
2. **A** - Chaos Mesh simulates various infrastructure failures
3. **D** - All benefits: find issues, test recovery, validate monitoring
4. **A** - Blast radius = how many resources are affected
5. **D** - All are chaos engineering best practices

**Scoring**:
- 5/5: ⭐⭐⭐⭐ Excellent! Chaos engineering mastered
- 3-4/5: ⭐⭐⭐ Good, review chaos principles
- 0-2/5: 🔄 Redo Lab 8, study resilience testing

</details>

---

## 📝 Lab 9: Helm Package Management (⭐⭐⭐⭐)

### Questions

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

3. **What is the purpose of values.yaml?**
   - [ ] A) Store secrets
   - [ ] B) Define default configuration parameters
   - [ ] C) List dependencies
   - [ ] D) Template helpers

4. **How do you customize a chart during installation?**
   - [ ] A) Edit the chart directly
   - [ ] B) Use --set flag or --values file
   - [ ] C) Modify templates
   - [ ] D) Change Chart.yaml

5. **What does helm upgrade do?**
   - [ ] A) Updates Helm itself
   - [ ] B) Updates an existing release with new values/chart
   - [ ] C) Upgrades Kubernetes
   - [ ] D) Installs new chart

<details>
<summary><b>Show Answers</b></summary>

1. **B** - Helm is the package manager for Kubernetes
2. **B** - Chart contains templated K8s resources with metadata
3. **B** - values.yaml provides configurable parameters for charts
4. **B** - Use --set key=value or --values custom-values.yaml
5. **B** - helm upgrade updates existing release with changes

**Scoring**:
- 5/5: ⭐⭐⭐⭐ Excellent! Package management mastered
- 3-4/5: ⭐⭐⭐ Good, review Helm concepts
- 0-2/5: 🔄 Redo Lab 9, study Helm basics

</details>

---

## 📝 Lab 10: GitOps with ArgoCD (⭐⭐⭐⭐)

### Questions

1. **What is GitOps?**
   - [ ] A) Git hosting service
   - [ ] B) Operational model where Git is single source of truth
   - [ ] C) Code deployment tool
   - [ ] D) Container registry

2. **What does ArgoCD do?**
   - [ ] A) Manages Git repositories
   - [ ] B) Continuously syncs K8s cluster with Git state
   - [ ] C) Builds container images
   - [ ] D) Monitors applications

3. **What triggers a deployment in GitOps?**
   - [ ] A) Manual kubectl commands
   - [ ] B) CI pipeline push
   - [ ] C) Git commit to repository
   - [ ] D) Webhook calls

4. **What is the main benefit of pull-based deployments?**
   - [ ] A) Faster deployments
   - [ ] B) No cluster credentials needed in CI
   - [ ] C) Smaller images
   - [ ] D) Better monitoring

5. **How do you rollback in GitOps?**
   - [ ] A) kubectl rollout undo
   - [ ] B) Git revert + ArgoCD sync
   - [ ] C) Delete pods
   - [ ] D) Redeploy manually

<details>
<summary><b>Show Answers</b></summary>

1. **B** - GitOps uses Git as the single source of truth for operations
2. **B** - ArgoCD continuously syncs cluster state with Git repository
3. **C** - Git commits trigger ArgoCD to sync changes to cluster
4. **B** - Pull-based means no cluster credentials in CI/CD pipelines
5. **B** - Rollback by reverting Git commit, ArgoCD syncs the change

**Scoring**:
- 5/5: ⭐⭐⭐⭐ Excellent! GitOps mastered
- 3-4/5: ⭐⭐⭐ Good, review GitOps principles
- 0-2/5: 🔄 Redo Lab 10, study ArgoCD concepts

</details>

---

## 🎯 Overall Assessment

### Scoring Guide

**Count your total correct answers across all completed labs:**

- **45-50 correct** (90%+): 🏆 **Kubernetes Expert**
  - You're ready for CKA/CKAD certification
  - Consider contributing to Kubernetes projects
  - Help others learn!

- **36-44 correct** (72-88%): 🌟 **Advanced Practitioner**
  - Strong Kubernetes understanding
  - Ready for production deployments
  - Review missed concepts

- **25-35 correct** (50-70%): 📚 **Intermediate Learner**
  - Good foundation, needs practice
  - Redo challenging labs
  - Focus on weak areas

- **Below 25** (<50%): 🔄 **Needs Review**
  - Redo labs slowly
  - Study ../reference/kubectl-cheatsheet.md
  - Read COMMON-MISTAKES.md
  - Ask questions!

---

## 📈 Skills Matrix

After completing all labs, you should be able to:

| Skill | Lab | Confidence (1-5) |
|-------|-----|------------------|
| Deploy pods/deployments | Lab 1 | ☐☐☐☐☐ |
| Create services | Lab 1 | ☐☐☐☐☐ |
| Scale applications | Lab 1 | ☐☐☐☐☐ |
| Multi-tier architecture | Lab 2 | ☐☐☐☐☐ |
| Service discovery | Lab 2 | ☐☐☐☐☐ |
| StatefulSets | Lab 3 | ☐☐☐☐☐ |
| Persistent storage | Lab 3 | ☐☐☐☐☐ |
| Ingress configuration | Lab 4 | ☐☐☐☐☐ |
| TLS/HTTPS | Lab 4 | ☐☐☐☐☐ |
| RBAC | Lab 5 | ☐☐☐☐☐ |
| NetworkPolicies | Lab 5 | ☐☐☐☐☐ |
| Secrets management | Lab 5 | ☐☐☐☐☐ |
| HorizontalPodAutoscaler | Lab 6 | ☐☐☐☐☐ |
| Load testing | Lab 6 | ☐☐☐☐☐ |
| Service mesh (Istio) | Lab 7 | ☐☐☐☐☐ |
| Monitoring (Prometheus) | Lab 7 | ☐☐☐☐☐ |
| Chaos engineering | Lab 8 | ☐☐☐☐☐ |
| Resilience testing | Lab 8 | ☐☐☐☐☐ |
| Helm charts | Lab 9 | ☐☐☐☐☐ |
| Chart templating | Lab 9 | ☐☐☐☐☐ |
| Package management | Lab 9 | ☐☐☐☐☐ |
| GitOps principles | Lab 10 | ☐☐☐☐☐ |
| ArgoCD deployment | Lab 10 | ☐☐☐☐☐ |
| Multi-environment automation | Lab 10 | ☐☐☐☐☐ |

**Goal**: Score 4-5 in each skill before moving to real projects!

**Total Skills**: 24 comprehensive Kubernetes competencies

---

## 🚀 Next Steps Based on Your Score

### If you scored 88%+:
1. ✅ Deploy your own application using these patterns
2. ✅ Prepare for CKA/CKAD certification
3. ✅ Contribute to open-source Kubernetes projects
4. ✅ Mentor others learning Kubernetes

### If you scored 70-87%:
1. 🔄 Redo challenging labs
2. 📖 Read official Kubernetes documentation
3. 🛠️ Experiment with variations
4. 💬 Explain concepts to others (teaching = mastery)

### If you scored below 70%:
1. 🔄 Redo ALL labs at your own pace
2. 📚 Study ../reference/kubectl-cheatsheet.md thoroughly
3. 🚨 Read COMMON-MISTAKES.md
4. 💡 Take notes while doing labs
5. ❓ Ask questions in Kubernetes communities

---

**Remember**: This assessment measures understanding, not speed. Take your time!
