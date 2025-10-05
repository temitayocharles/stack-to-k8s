# 🎓 Kubernetes Learning Labs

## Purpose
**Practice Kubernetes with 6 real applications.** This is NOT about the apps - it's about mastering K8s deployment, scaling, debugging, and operations.

**Think**: KodeKloud-style hands-on labs, not production documentation.

---

## 📚 Learning Path

### Level 1: Beginner (⭐)
**Goal**: Deploy your first app to Kubernetes

1. **[Lab 1: Weather App](labs/01-weather-basics.md)** (20 min)
   - Deploy pods, services, deployments
   - Port forward and test
   - Scale replicas

2. **[Lab 2: E-commerce](labs/02-ecommerce-basics.md)** (30 min)
   - Multi-service deployment
   - Service discovery
   - Health checks

### Level 2: Intermediate (⭐⭐)
**Goal**: Manage stateful applications

3. **[Lab 3: Educational Platform](labs/03-educational-stateful.md)** (40 min)
   - Persistent volumes
   - StatefulSets
   - Database backups

4. **[Lab 4: Task Manager](labs/04-task-ingress.md)** (45 min)
   - Ingress controllers
   - TLS certificates
   - Domain routing

### Level 3: Advanced (⭐⭐⭐)
**Goal**: Production-grade operations

5. **[Lab 5: Medical System](labs/05-medical-security.md)** (60 min)
   - RBAC and security
   - Network policies
   - Secrets management
   - HIPAA compliance basics

6. **[Lab 6: Social Media](labs/06-social-scaling.md)** (90 min)
   - Horizontal pod autoscaling
   - Resource limits
   - Multi-region deployment
   - Load testing

### Level 4: Expert (⭐⭐⭐⭐)
**Goal**: Advanced Kubernetes patterns

7. **[Lab 7: Multi-App Orchestration](labs/07-multi-app.md)** (120 min)
   - Deploy all 6 apps
   - Service mesh (Istio basics)
   - Centralized logging
   - Monitoring with Prometheus

8. **[Lab 8: Chaos Engineering](labs/08-chaos.md)** (90 min)
   - Pod failures
   - Network delays
   - Resource exhaustion
   - Recovery strategies

9. **[Lab 9: Helm Package Management](labs/09-helm-package-management.md)** (75 min)
   - Helm charts and repositories
   - Values customization
   - Creating custom charts
   - Chart dependencies and templating

10. **[Lab 10: GitOps with ArgoCD](labs/10-gitops-argocd.md)** (90 min)
    - GitOps principles and workflows
    - ArgoCD setup and configuration
    - Multi-environment deployments
    - Git-driven automation

---

## 🚀 Quick Start

### Prerequisites
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
- **[Debug Guide](troubleshooting/debugging.md)** - When things break

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

👉 Start with **[Lab 1: Weather App Basics](labs/01-weather-basics.md)**
