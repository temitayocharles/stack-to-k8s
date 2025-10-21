# 🚀 Master Kubernetes: From Zero to Production Hero

Six real-world apps. Twenty hands-on labs. One rigorous journey to production-grade Kubernetes.

---

## 🎯 New here? Start here

**→ [📖 GETTING STARTED GUIDE](docs/00-introduction/GETTING-STARTED.md) ← START HERE**

Complete onboarding in ~30 minutes:
- ✅ Tool installation (Rancher Desktop or kind/k3d)
- ✅ Verification steps
- ✅ Your first kubectl command
- ✅ Clear learning path from beginner → expert

---

## 🏁 Quick start (If you already have tools installed)

1. **Install Visualization Tools** → [Lab 0: Visual Kubernetes](labs/00-visual-kubernetes.md) (k9s, stern, kubectl-tree)
2. **Deploy Your First App** → [Lab 1: Weather Basics](labs/01-weather-basics.md)
3. **Track Your Journey** → [LAB-PROGRESS.md](docs/20-labs/LAB-PROGRESS.md)

**Don't have Kubernetes yet?** → [GETTING STARTED Guide](docs/00-introduction/GETTING-STARTED.md) sets you up in 10 minutes

## 🧭 Lab roadmap
See the full progression (difficulty, prerequisites, success criteria) in:
- [KUBERNETES-LABS.md](docs/20-labs/KUBERNETES-LABS.md)

Each lab includes: story-driven steps, validation checks, troubleshooting, and challenge mode.

## 🧱 Application portfolio & Lab progression

| Lab | App | Stack | Difficulty | Time | Expert Badge (Optional) |
|-----|-----|------|------------|------|-------------------------|
| **Setup** | 👀 **Visual Tools** | k9s, stern, kubectl-tree | ⭐ | **15m** | |
| [Lab 0](labs/00-visual-kubernetes.md) | | Install essential K8s visualization tools | | | |
| [Lab 0.5](labs/00.5-docker-compose-to-kubernetes.md) | 🐳 **Docker → K8s Migration** | Compose to manifests | ⭐ | **40m** | |
| | | | | | |
| **Foundations** | | | | | |
| [Lab 1](labs/01-weather-basics.md) | 🌦️ Weather App | Vue + Python + Redis | ⭐ | **20m** | 🔬 Forensic Investigator (+20m) |
| [Lab 2](labs/02-ecommerce-basics.md) | 🛒 E-commerce | React + Node + MongoDB | ⭐⭐ | **30m** | |
| [Lab 3](labs/03-educational-stateful.md) | 🎓 Educational | Angular + Java + Postgres | ⭐⭐⭐ | **40m** | 💾 Data Recovery (+15m) |
| [Lab 3.5](labs/03.5-kubernetes-under-the-hood.md) | 🔧 **K8s Internals** | etcd, controllers, API | ⭐⭐⭐⭐ | **50m** | ⚙️ Control Plane Architect (+25m) |
| [Lab 4](labs/04-kubernetes-fundamentals.md) | 🏷️ **Fundamentals** | Labels, troubleshooting | ⭐⭐ | **75m** | |
| | | | | | |
| **Production Ops** | | | | | |
| [Lab 5](labs/05-task-ingress.md) | ✅ Task Manager | Svelte + Go + Postgres | ⭐⭐⭐ | **45m** | |
| [Lab 6](labs/06-medical-security.md) | 🏥 Medical Care | Blazor + .NET + Postgres | ⭐⭐⭐⭐ | **60m** | |
| [Lab 7](labs/07-social-scaling.md) | 📱 Social Media | React Native + Ruby + Postgres | ⭐⭐⭐⭐⭐ | **90m** | 📈 Scaling Architect (+20m) |
| | | | | | |
| **Platform Engineering** | | | | | |
| [Lab 8](labs/08-multi-app.md) | 🧩 **Multi-App** | All 6 apps orchestration | ⭐⭐⭐⭐⭐ | **120m** | 🕸️ Mesh Performance (+30m) |
| [Lab 8 Lite](docs/10-setup/LAB-8-LITE.md) | 🧩 **Multi-App Lite** | 3 apps orchestration | ⭐⭐⭐⭐ | **45m** | 💡 For 8GB RAM machines |
| [Lab 8.5](labs/08.5-multi-tenancy.md) | 🏢 **Multi-Tenancy** | Namespaces, isolation | ⭐⭐⭐⭐ | **60m** | |
| [Lab 9](labs/09-chaos.md) | ⚡ **Chaos** | Resilience testing | ⭐⭐⭐⭐ | **90m** | 🔍 Network Detective (+25m) |
| [Lab 9.5](labs/09.5-complex-microservices.md) | 🔀 **Microservices** | Service mesh patterns | ⭐⭐⭐⭐⭐ | **75m** | |
| | | | | | |
| **Automation Masters** | | | | | |
| [Lab 10](labs/10-helm-package-management.md) | 🪄 **Helm** | Charts, templating | ⭐⭐⭐⭐ | **75m** | |
| [Lab 11](labs/11-gitops-argocd.md) | 🤖 **GitOps** | ArgoCD, automation | ⭐⭐⭐⭐⭐ | **90m** | |
| [Lab 11.5](labs/11.5-disaster-recovery.md) | 🚨 **Disaster Recovery** | Backup, restore | ⭐⭐⭐⭐ | **60m** | |
| [Lab 12](labs/12-external-secrets.md) | 🔐 **Secrets** | External Secrets Operator | ⭐⭐⭐⭐ | **60m** | 🌉 Hybrid Cloud Architect (+30m) |
| [Lab 12.5](labs/12.5-multi-cloud-secrets.md) | ☁️ **Multi-Cloud** | Cross-cloud secrets | ⭐⭐⭐⭐⭐ | **75m** | |
| [Lab 13](labs/13-ai-ml-gpu.md) | 🤖 **AI/ML** | GPU workloads | ⭐⭐⭐⭐⭐ | **90m** | |
| | | | | |
| **🔥 Challenges** | | | | |
| [Challenge A](labs/challenge-a-midnight-incident.md) | 🚨 **Midnight Incident** | Troubleshooting drill | ⭐⭐⭐ | **45m** | |
| [Challenge B](labs/challenge-b-black-friday.md) | 🛍️ **Black Friday** | Scaling under pressure | ⭐⭐⭐⭐ | **60m** | |
| [Challenge C](labs/challenge-c-platform-migration.md) | 🏗️ **Platform Migration** | Zero-downtime migration | ⭐⭐⭐⭐⭐ | **90m** | |

> 💡 **Expert Badges are 100% optional!** They're inline advanced challenges for senior-level debugging, performance tuning, and production troubleshooting. Perfect for leveling up to senior SRE/Platform Engineer roles. Track your progress in [LAB-PROGRESS.md](docs/20-labs/LAB-PROGRESS.md#expert-badge-system-optional-advanced-challenges).

## 🎒 Learning toolkit
- ✅ [Self-Assessment](docs/20-labs/SELF-ASSESSMENT.md)
- ⚠️ [Common Mistakes](docs/20-labs/COMMON-MISTAKES.md)
- 📘 [kubectl Cheatsheet](docs/30-reference/cheatsheets/kubectl-cheatsheet.md)
- 🛠️ [Troubleshooting Hub](docs/40-troubleshooting/troubleshooting-index.md)
- 🔐 [Secrets Management](docs/30-reference/deep-dives/secrets-management.md)
- 🗂️ [Markdown Inventory](docs/00-introduction/MARKDOWN-INDEX.md)

## 📋 Planning & Optimization Guides
- 💾 **[Resource Estimation](README.md#-resource-estimation-which-labs-fit-your-machine)** — Machine specs vs lab requirements
- 🧩 **[Lab 8 Lite](docs/10-setup/LAB-8-LITE.md)** — 82% resource reduction (3 apps instead of 6)
- ✅ **[Lab 8 Lite Validation](docs/10-setup/LAB-8-LITE-VALIDATION.md)** — 8-phase validation checklist with success criteria
- 📹 **[Lab 8 Lite Video Script](docs/LAB-8-LITE-VIDEO-SCRIPT.md)** — 15-minute video demo walkthrough
- 📡 **[Port Management](docs/10-setup/PORT-MANAGEMENT.md)** — Run multiple labs, avoid port conflicts
- 🏗️ **[Cluster Topology](docs/10-setup/CLUSTER-TOPOLOGY.md)** — Single-node vs multi-node explained

## ✅ Automation & quality checks
- `scripts/check-lab-prereqs.sh` — Verify tools and cluster readiness for each lab
- `scripts/run-link-check-full.sh` — Validate all markdown links
- `scripts/cleanup-workspace.sh` — Clean up Docker/K8s resources between labs
- `scripts/test-lab-8-lite.sh` — Automated validation for Lab 8 Lite (11 test phases)
- `.github/workflows/test-lab-8-lite.yml` — CI/CD pipeline for Lab 8 Lite (kind + k3d testing)

Example:
```bash
# Check if you're ready for Lab 3
./scripts/check-lab-prereqs.sh 3

# Validate all documentation links
./scripts/run-link-check-full.sh

# Clean up resources
./scripts/cleanup-workspace.sh

# Test Lab 8 Lite on your system
./scripts/test-lab-8-lite.sh

# Watch GitHub Actions test Lab 8 Lite on kind/k3d
# (See .github/workflows/test-lab-8-lite.yml)
```

## 🧭 How to use this repo (quick tour)

1) Start at the docs hub → Read the [Getting Started guide](docs/00-introduction/GETTING-STARTED.md). It walks you through installing tools (Rancher Desktop/kind/k3d) and verifying your cluster.
2) Let the script help → Run `./scripts/check-lab-prereqs.sh <lab>` to verify your setup. It's interactive: it can prompt to install missing tools, start Docker/Kubernetes, and optionally clean up resources.
3) Begin with Lab 0 → Install visualization tools (k9s, stern, kubectl-tree) in [Lab 0](labs/00-visual-kubernetes.md). Seeing the cluster makes every lab easier.
4) Ship your first app → Do [Lab 1: Weather Basics](labs/01-weather-basics.md). Every lab includes validation, troubleshooting, and an advanced track.
5) Climb the challenge track → After each core lab's main steps, follow the sequence: Quick check → Break & Fix → Troubleshooting → Observability → Expert mode → Test your knowledge → Next lab.
6) Need credentials? → App READMEs link to the centralized [Secrets management guide](docs/30-reference/deep-dives/secrets-management.md) and each lab shows exactly where to set required keys via Kubernetes Secrets.
7) Keep going → Follow the [Lab roadmap](docs/20-labs/KUBERNETES-LABS.md) for the full progression and optional deep dives (3.5, 8.5, 9.5, 11.5, 12.5).

Tip: Prefer small, focused code blocks and collapsible details in docs. Use k9s during labs for fast feedback.

## 🗺️ Repository map

**Complete file inventory**: [REPOSITORY-STRUCTURE.md](docs/00-introduction/REPOSITORY-STRUCTURE.md) — Detailed map of all documentation files  
**Resource planning**: [Resource Requirements Guide](docs/30-reference/deep-dives/resource-requirements.md) — CPU, memory, disk, and port allocation for all labs

---

## 💾 Resource Estimation: Which Labs Fit Your Machine?

Before you start, check what your setup can handle:

### 🖥️ Minimum Machine (2 CPU / 4GB RAM)
```
✅ Labs 1-4: Foundation concepts (basics to fundamentals)
⚠️  Lab 5: Possible, but tight resource allocation
❌ Labs 6+: Not recommended (high risk of OOM kills)
```
**Best for**: Learning Kubernetes fundamentals without infrastructure stress.  
**Estimated time**: ~5-7 hours to complete Labs 1-4 sequentially.

### 💻 Development Laptop (8 CPU / 8-16GB RAM) - RECOMMENDED
```
✅ Labs 1-7: All foundation + production ops labs comfortably
✅ Labs 8-12: Run one at a time (sequential execution)
⚠️  Lab 8 (Multi-App): Requires cleanup from Lab 7 + resource tuning
❌ Lab 13 (AI/ML): Needs GPU or cloud cluster
```
**Best for**: Learning production-grade patterns without cloud costs.  
**Strategy**:
- Run Labs 1-4 back-to-back (foundations)
- Clean up → Run Labs 5-7 one at a time
- Clean up → Run Labs 10-12 sequentially
- Skip Lab 8 or run it on [Lab 8 Lite](#-lab-8-lite-reduced-resource-option)

**Estimated time**: ~20-25 hours total (spread across several weeks).

### 🚀 Workstation / Cloud (12+ CPU / 16GB+ RAM)
```
✅ All Labs 1-13 sequentially or in small groups
✅ Parallel labs possible (2-3 concurrent with careful planning)
✅ Lab 13 (AI/ML) doable with GPU or TPU
```
**Best for**: Comprehensive production simulation, working through all content, team learning.  
**Estimated time**: ~30-40 hours (all labs + challenges).

---

## 🧩 Lab 8 Lite: Reduced-Resource Option

**Standard Lab 8** deploys all 6 apps (~3 CPU / 4GB+ RAM needed). For machines with **8-12 CPU / 8-16GB RAM**, use **Lab 8 Lite** instead:

### Lab 8 Lite Configuration
- **Apps**: Weather + E-commerce + Task Manager (3 instead of 6)
- **Resource requirement**: ~2 CPU / 3GB RAM (vs. 3 CPU / 4GB)
- **Learning outcome**: Same multi-app orchestration concepts, minus medical/educational/social apps

**Which apps to skip**:
- ❌ Educational Platform (stateful + heavy)
- ❌ Medical Care System (security policies + complex)
- ❌ Social Media (autoscaling + cache layers)

**Apply Lab 8 Lite**:
```bash
# Instead of all 6 apps
kustomize build labs/manifests/lab-08 | kubectl apply -f -

# Run this instead:
kubectl apply -f weather-app/k8s/*.yaml -n lab-multi
kubectl apply -f ecommerce-app/k8s/*.yaml -n lab-multi
kubectl apply -f task-management-app/k8s/*.yaml -n lab-multi
```

**Resource usage with Lab 8 Lite**:
| Component | Replicas | CPU | Memory |
|-----------|----------|-----|--------|
| Weather App | 2 | 200m | 256Mi |
| E-commerce App | 2 | 350m | 512Mi |
| Task Manager | 2 | 300m | 384Mi |
| **Total** | **6** | **850m** | **1.2Gi** |

**Validation**: Run `./scripts/calculate-lab-resources.sh 1 2 4` to verify 3-app footprint.

---

## 📡 Port Remapping: Running Multiple Labs Concurrently

By default, labs use the same ports and conflict when run together. Use **kubectl port-forward** to remap:

### Port Usage by Lab

| Lab | Apps Used | Primary Ports | Conflict Risk |
|-----|-----------|---------------|----------------|
| **1** | Weather | 8080, 5000 | ✅ None |
| **2** | E-commerce | 3000, 5000, 27017 | ✅ None |
| **3** | Educational | 4200, 8080, 5432 | ⚠️ 8080 (conflict with Lab 1) |
| **4** | Fundamentals | 8080, 8081, 8082 | ⚠️ 8080 series |
| **5** | Task Manager + Ingress | 80, 443, 3000, 8000 | ⚠️ 3000 (conflict with Lab 2) |
| **6** | Medical + Security | 8080, 5000, 5432 | ⚠️ Multiple conflicts |
| **7** | Social Media + HPA | 3000, 8080, 5432, 6379 | ⚠️ Heavy conflicts |
| **8** | Multi-App (All 6) | 3000-8080 range | 🔴 **MAJOR CONFLICTS** |

### ✅ Safe Concurrent Lab Strategy

**Option A: Sequential (Recommended for 8GB RAM)**
```bash
# Run Lab 1, complete, cleanup
./scripts/cleanup-workspace.sh
# Run Lab 2, complete, cleanup
./scripts/cleanup-workspace.sh
# Continue...
```

**Option B: Port Remapping (For parallel execution)**

Run Lab 1 in namespace `lab-1`, Lab 2 in namespace `lab-2`:
```bash
# Terminal 1: Lab 1 (ports 8080-8090)
kubectl apply -f weather-app/k8s/ -n lab-1
kubectl port-forward -n lab-1 svc/frontend 8080:80 &

# Terminal 2: Lab 2 (ports 3000-3090)  
kubectl apply -f ecommerce-app/k8s/ -n lab-2
kubectl port-forward -n lab-2 svc/frontend 3000:80 &

# Terminal 3: Lab 3 (ports 4200-4290)
kubectl apply -f educational-platform/k8s/ -n lab-3
kubectl port-forward -n lab-3 svc/frontend 4200:80 &

# Now access:
curl localhost:8080   # Lab 1 (Weather)
curl localhost:3000   # Lab 2 (E-commerce)
curl localhost:4200   # Lab 3 (Educational)
```

### 🔍 Find Current Port Usage

```bash
# See what's already port-forwarding
lsof -i :8080      # macOS/Linux
netstat -ano | findstr :8080  # Windows

# List all K8s services and their ports
kubectl get svc -A
```

### 🛑 Kill Port-Forward Sessions

```bash
# Kill a specific port-forward
kill %1  # If backgrounded with &

# Kill all port-forwards in one go
pkill -f "kubectl port-forward"
```

---

```
├── docs/            # organized into numbered folders
│   ├── 00-introduction/  # Hub, setup guides, onboarding
│   ├── 10-setup/         # Installation guides
│   ├── 20-labs/          # Lab support materials (progress, assessment)
│   ├── 30-reference/     # Guides & reference docs
│   ├── 40-troubleshooting/ # Problem-solving playbook
│   └── 99-appendix/      # Future expansion
├── labs/            # 23 hands-on labs + 3 challenges + manifests/
├── scripts/         # validators and utilities
├── ecommerce-app/   # React + Node + MongoDB
├── educational-platform/  # Angular + Java + PostgreSQL
├── medical-care-system/   # Blazor + .NET + PostgreSQL
├── social-media-platform/ # React Native + Ruby + PostgreSQL
├── task-management-app/   # Svelte + Go + PostgreSQL
└── weather-app/     # Vue + Python + Redis
```

## 🤝 Contributing
1) Validate links → `./scripts/run-link-check-full.sh`  
2) Test lab prerequisites → `./scripts/check-lab-prereqs.sh <lab-number>`  
3) Clean up workspace → `./scripts/cleanup-workspace.sh`
4) Open a PR with changes and test output

## 💡 Credits
Created by Temitayo Charles Akinniranye — Docker Hub: https://hub.docker.com/u/temitayocharles — Built with ❤️ for engineers who learn by doing.

👉 Start now → [Lab 1: Weather Basics](labs/01-weather-basics.md)