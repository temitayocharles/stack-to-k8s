# 🎓 Kubernetes Learning Labs

Practice Kubernetes with 6 real applications across 12 progressively spicy labs. 🌶️

**Mindset**: Less "read the docs", more "ship to cluster". Each lab is a guided mission with validation, troubleshooting, and real-world fire drills.

---

## 🧭 Lab Map

### ⭐ Level 1 — Lift-off (Foundations)
1. 🌦️ **[Lab 1: Weather App Basics](../labs/01-weather-basics.md)** (20 min)  
   Deploy your first app. Master pods, services, port-forwarding.
2. 🛒 **[Lab 2: E-commerce Multi-tier](../labs/02-ecommerce-basics.md)** (30 min)  
   Frontend + backend + database. Understand multi-service communication.

### ⚙️ Stage 2: Production Ops (3 labs)
3. 🎓 **[Lab 3: Educational Stateful](../labs/03-educational-stateful.md)** (40 min)  
   Persistent volumes, StatefulSets, data retention.
4. ✅ **[Lab 4: Task Manager Ingress](../labs/04-task-ingress.md)** (45 min)  
   Expose apps with Ingress (NGINX), manage external traffic.

### 🛡️ Stage 3: Platform Wizards (2 labs)
5. 🏥 **[Lab 5: Medical Security](../labs/05-medical-security.md)** (60 min)  
   RBAC, NetworkPolicies, secrets, TLS. Secure apps like a pro.
6. 📈 **[Lab 6: Social Scaling](../labs/06-social-scaling.md)** (90 min)  
   HPA, resource limits, multi-replica deployments, caching.

### 🤖 Stage 4: Automation Legends (5 labs)
7. 🧩 **[Lab 7: Multi-App Orchestration](../labs/07-multi-app.md)** (120 min)  
   Deploy all 6 apps with shared configs (ConfigMaps).
8. ⚡ **[Lab 8: Chaos Engineering](../labs/08-chaos.md)** (90 min)  
   Break pods, test self-healing, resilience patterns.

### � Stage 5: Tooling Masters (3 labs)
9. 🪄 **[Lab 9: Helm Package Management](../labs/09-helm-package-management.md)** (75 min)  
   Build charts, templating, versioned releases.
10. 🤖 **[Lab 10: GitOps with ArgoCD](../labs/10-gitops-argocd.md)** (90 min)  
    Git as source of truth, automated sync, rollback workflows.
11. 🔐 **[Lab 11: External Secrets Management](../labs/11-external-secrets.md)** (60 min)  
    External secrets operator, Vault integration.
12. 🧠 **[Lab 12: Kubernetes Fundamentals Deep Dive](../labs/12-kubernetes-fundamentals.md)** (75 min)

---

## 🚀 Quick Start

### Prerequisites (smoke checks)
```bash
# Verify K8s cluster
kubectl cluster-info

# Verify Docker
docker --version
```

### Start Learning
```bash
# Clone repo
git clone https://github.com/temitayocharles/full-stack-apps.git
cd full-stack-apps

# Start with Lab 1
open labs/01-weather-basics.md
```

---

## 📦 Pre-Built Images
All apps have multi-arch images on Docker Hub: `temitayocharles/*`

No building required - focus on **Kubernetes**, not Docker.

---

## 🆘 Stuck?
- **[Common Issues](troubleshooting/troubleshooting.md)** - Quick fixes
- **[kubectl Cheat Sheet](reference/kubectl-cheatsheet.md)** - Essential commands
(debugging guidance consolidated into the Troubleshooting Hub)

---

## 🎯 Learning Objectives

By completing these labs, you'll master:

**Core Concepts**:
- Pods, Deployments, Services
- ConfigMaps, Secrets
- Namespaces, Labels, Selectors

**Storage**:
- PersistentVolumes
- PersistentVolumeClaims  
- StatefulSets

**Networking**:
- ClusterIP, NodePort, LoadBalancer
- Ingress controllers
- Network policies
- Service mesh basics

**Operations**:
- Rolling updates
- Rollbacks
- Scaling (HPA, VPA)
- Resource management
- Health checks

**Security**:
- RBAC
- Pod security policies
- Secrets management
- Network isolation

**Observability**:
- Logging aggregation
- Metrics collection
- Distributed tracing
- Alerting

**Package Management**:
- Helm charts and repositories
- Chart templating and values
- Release lifecycle management
- Chart dependencies and best practices

**GitOps & Automation**:
- GitOps principles and workflows
- ArgoCD deployment and management
- Multi-environment automation
- Git-driven continuous deployment

---

**Ready to master Kubernetes?**

👉 Start with **[Lab 1: Weather App Basics](../labs/01-weather-basics.md)**
