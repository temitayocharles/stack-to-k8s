---
title: "Getting Started with Kubernetes Labs"
level: "beginner"
type: "onboarding-guide"
prerequisites: []
estimated_time: "30 minutes"
updated: "2025-10-21"
nav_prev: "./README.md"
nav_next: "../../labs/00-visual-kubernetes.md"
---

# 🚀 Getting Started with Kubernetes Labs

Welcome! This guide will take you from "I just found this repo" to "I'm deploying my first Kubernetes app" in under 30 minutes.

---

## 👋 Welcome!

You're about to learn Kubernetes by **building real applications**—not toy examples. This repository contains:

- **6 Production-Grade Apps** (Weather, E-commerce, Education, Task Management, Medical, Social)
- **14 Core Labs** (+ 6 bonus deep-dive labs)
- **3 Challenge Scenarios** (Incident response, scaling, migrations)
- **Real-World Patterns** (StatefulSets, Ingress, RBAC, GitOps, Secrets Management)

**Philosophy**: Ship first, understand later. Each lab is a hands-on mission where you deploy, break, fix, and learn.

---

> Quick tour
>
> 1) Run the interactive prerequisites checker before each lab: `./scripts/check-lab-prereqs.sh <lab-number>`
> 2) Start with Lab 0 (visual tools), then Lab 1 (your first app)
> 3) After finishing a lab’s main tasks, do its Challenge track to lock in learning

## ✅ Prerequisites

Before starting, you'll need:

### Required Knowledge
- ✅ **Basic command line** (cd, ls, copy/paste commands)
- ✅ **Docker basics** (what containers are, how images work)
- ⭐ **Curiosity** (willingness to break things and learn)

### Don't Need To Know
- ❌ Advanced networking
- ❌ Cloud platforms (AWS/GCP/Azure)
- ❌ Previous Kubernetes experience

**Total beginners welcome!** We'll teach you everything from scratch.

---

## 🛠️ Step 1: Install Required Tools

You'll need **4 essential tools**. Pick your operating system:

### Option A: macOS / Windows (Recommended for Beginners)

**Install Rancher Desktop** (all-in-one solution):
- Includes: Kubernetes cluster, kubectl, docker, helm
- GUI: Easy visual management
- Setup time: ~10 minutes

📖 **[Full Rancher Desktop Guide](../10-setup/rancher-desktop.md)**

Quick install:
```bash
# macOS
brew install rancher

# Windows
# Download from https://rancherdesktop.io
```

### Option B: Linux (Advanced Users)

**Install kind or k3d**:
- Lightweight Kubernetes clusters
- Command-line focused
- Setup time: ~5 minutes

📖 **[Full Linux Setup Guide](../10-setup/linux-kind-k3d.md)**

Quick install:
```bash
# kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

# k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

---

## 🔧 Step 2: Install Visualization Tools

These tools make Kubernetes **visible and interactive**:

### Essential Tools (15-minute setup)

1. **k9s** - Terminal UI for Kubernetes (like htop for K8s)
   ```bash
   # macOS
   brew install k9s
   
   # Linux
   curl -sS https://webinstall.dev/k9s | bash
   
   # Windows
   scoop install k9s
   ```

2. **stern** - Multi-pod log tailing
   ```bash
   # macOS
   brew install stern
   
   # Linux/Windows
   # Download from https://github.com/stern/stern/releases
   ```

3. **kubectl-tree** - Visualize resource relationships
   ```bash
   # Via krew (kubectl plugin manager)
   kubectl krew install tree
   ```

📖 **[Complete Installation Guide](../../labs/00-visual-kubernetes.md)** (Lab 0)

**Why these tools?**
- 🔍 See what's happening in your cluster
- 🐛 Debug issues 10x faster
- 📊 Understand resource relationships
- 🎯 Feel like a Kubernetes pro from day 1

---

## ✅ Step 3: Verify Your Setup

Run this quick health check:

```bash
# Check kubectl works
kubectl version --client

# Check cluster is running
kubectl cluster-info

# Check nodes are ready
kubectl get nodes

# Expected output:
# NAME                 STATUS   ROLES    AGE   VERSION
# rancher-desktop      Ready    <all>    5m    v1.28.x
```

**If you see errors**, check:
1. Is your cluster running? (Rancher Desktop GUI shows status)
2. Did kubectl install correctly? (`which kubectl`)
3. Is Docker running? (`docker ps`)

📖 **[Troubleshooting Guide](../40-troubleshooting/troubleshooting-index.md)**

> Optional: run the repo health check now
>
> ```bash
> # Validate prerequisites for Lab 1 (adjust number for other labs)
> ./scripts/check-lab-prereqs.sh 1
> ```

---

## 🧪 Step 4: Run Your First Command

Let's make sure everything works:

```bash
# Create a test pod
kubectl run test-nginx --image=nginx:alpine --port=80

# Check it's running
kubectl get pods

# View logs
kubectl logs test-nginx

# Access the app
kubectl port-forward test-nginx 8080:80 &
curl http://localhost:8080

# Clean up
kubectl delete pod test-nginx
```

**If this worked**: 🎉 Congratulations! You're ready for the labs!

**If not**: Check the [Troubleshooting Guide](../40-troubleshooting/troubleshooting-index.md) or [raise an issue](https://github.com/temitayocharles/stack-to-k8s/issues).

---

## 📚 Step 5: Start Learning!

Now you're ready to begin your Kubernetes journey:

### Your First Lab (Recommended Path)

1. **[Lab 0: Visual Kubernetes](../../labs/00-visual-kubernetes.md)** (15 min) - **START HERE**
   - Install k9s, stern, kubectl-tree
   - Learn to navigate your cluster visually
   - Set up your workspace

2. **[Lab 1: Weather App Basics](../../labs/01-weather-basics.md)** (20 min) - **FIRST APP**
   - Deploy your first real application
   - Learn pods, services, deployments
   - Master port-forwarding and logs

3. **Track Your Progress**
   - Use **[LAB-PROGRESS.md](../../labs/LAB-PROGRESS.md)** to track completion
   - Check off concepts as you master them
   - See your skill progression visually

### Optional: Coming from Docker Compose?

**[Lab 0.5: Docker Compose → Kubernetes](../../labs/00.5-docker-compose-to-kubernetes.md)** (40 min)
- Migrate docker-compose.yml to K8s manifests
- Side-by-side comparison
- Learn translation patterns

---

## 🗺️ Your Learning Path

Here's the recommended progression:

### Stage 1: Foundations (First Week)
→ [Lab 0](../../labs/00-visual-kubernetes.md) · Visual Tools  
→ [Lab 1](../../labs/01-weather-basics.md) · Weather Basics  
→ [Lab 2](../../labs/02-ecommerce-basics.md) · Multi-tier Apps  
→ [Lab 3](../../labs/03-educational-stateful.md) · Stateful Workloads  
→ [Lab 4](../../labs/04-kubernetes-fundamentals.md) · Troubleshooting Mastery  

**Time commitment**: ~5-7 hours total  
**What you'll learn**: Deploy, debug, and manage applications

### Stage 2: Production Ops (Second Week)
→ [Lab 5](../../labs/05-task-ingress.md) · Ingress & Routing  
→ [Lab 6](../../labs/06-medical-security.md) · Security (RBAC, NetworkPolicies)  
→ [Lab 7](../../labs/07-social-scaling.md) · Autoscaling & Performance  

**Time commitment**: ~4-6 hours total  
**What you'll learn**: Production-grade deployments

### Stage 3: Platform Engineering (Third Week)
→ [Lab 8](../../labs/08-multi-app.md) · Multi-App Orchestration  
→ [Lab 9](../../labs/09-chaos.md) · Chaos Engineering  
→ [Lab 10](../../labs/10-helm-package-management.md) · Helm Charts  

**Time commitment**: ~6-8 hours total  
**What you'll learn**: Enterprise patterns

### Stage 4: Automation Masters (Fourth Week)
→ [Lab 11](../../labs/11-gitops-argocd.md) · GitOps with ArgoCD  
→ [Lab 12](../../labs/12-external-secrets.md) · Secrets Management  
→ [Challenge Labs](../../labs/challenge-a-midnight-incident.md) · Test Your Skills  

**Time commitment**: ~5-7 hours total  
**What you'll learn**: Full automation, production readiness

📖 **[Complete Lab Roadmap](KUBERNETES-LABS.md)**

> Reminder before each lab
>
> - Run: `./scripts/check-lab-prereqs.sh <lab-number>`
> - After main tasks, do the lab’s Challenge track (visible near the end)

---

## 🎯 Learning Resources

### Essential Reading
- 📘 **[kubectl Cheatsheet](../30-reference/cheatsheets/kubectl-cheatsheet.md)** - Keep this open while working
- ⚠️ **[Common Mistakes](../../labs/COMMON-MISTAKES.md)** - Avoid beginner pitfalls
- 🛠️ **[Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md)** - Fix issues fast

### Assessment & Progress
- ✅ **[Self-Assessment](../../labs/SELF-ASSESSMENT.md)** - Test your knowledge before/after
- 📊 **[Lab Progress Tracker](../../labs/LAB-PROGRESS.md)** - Mark labs complete

### Reference Guides
- 🔐 **[Secrets Management](../30-reference/deep-dives/secrets-management.md)** - Handle sensitive data
- ⚙️ **[Configuration Patterns](../30-reference/deep-dives/configuration-patterns.md)** - Best practices
- 📖 **[API Keys Guide](../30-reference/cheatsheets/api-keys-guide.md)** - External service integration

---

## 🤝 Getting Help

### Stuck on a Lab?
1. Check the lab's **Troubleshooting** section (every lab has one)
2. Review **[Common Mistakes](../../labs/COMMON-MISTAKES.md)**
3. Read the **[Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md)**
4. Still stuck? [Open an issue](https://github.com/temitayocharles/stack-to-k8s/issues)

### Want to Contribute?
1. Run `./scripts/check-lab-prereqs.sh <lab>` to test
2. Run `./scripts/run-link-check-full.sh` to validate links
3. Open a PR with your improvements

---

## 💡 Pro Tips

### Maximize Your Learning
- ✅ **Do labs in order** - Each builds on previous concepts
- ✅ **Break things on purpose** - Delete pods, crash apps, experiment
- ✅ **Use k9s constantly** - Visual feedback accelerates learning
- ✅ **Read pod logs** - They tell you everything
- ✅ **Try challenge labs** - They cement knowledge 10x better

### Time Management
- 🕐 **Labs 1-4**: Can do in one sitting (~3 hours)
- 🕐 **Labs 5-7**: Spread across 2-3 days
- 🕐 **Labs 8-12**: One per day (deeper concepts)
- 🕐 **Challenges**: Save for when you feel confident

### Study Groups
Consider doing these labs with a study partner or team:
- Discuss concepts together
- Debug issues collaboratively
- Share "aha!" moments
- Keep each other accountable

---

## 🚀 Ready to Start?

You're all set! Here's your first command:

```bash
# Start with Lab 0
cd /path/to/stack-to-k8s-main
open labs/00-visual-kubernetes.md

# Or jump straight to Lab 1 if you have tools installed
open labs/01-weather-basics.md
```

**Remember**: Learning Kubernetes is a journey, not a sprint. Take breaks, experiment freely, and most importantly—have fun building! 🎉

---

## 📖 Navigation

- 🏠 [Back to Main README](../../README.md)
- 📚 [Full Lab Roadmap](../../labs/KUBERNETES-LABS.md)
- 🎯 [Start Lab 0: Visual Tools](../../labs/00-visual-kubernetes.md)
- ⚡ [Skip to Lab 1: First App](../../labs/01-weather-basics.md)

---

**Questions?** [Open an issue](https://github.com/temitayocharles/stack-to-k8s/issues) or check the [Troubleshooting Guide](../40-troubleshooting/troubleshooting-index.md).

**Let's build something amazing!** 🚀
