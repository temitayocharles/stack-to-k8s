# 📂 Repository Structure & File Map

Complete inventory of all documentation and resources in this repository.

---

## 📋 Table of Contents

1. [Quick Navigation](#-quick-navigation)
2. [Main Documentation](#-main-documentation)
3. [Learning Resources](#-learning-resources)
4. [Reference Guides](#-reference-guides)
5. [Setup Guides](#-setup-guides)
6. [Troubleshooting](#-troubleshooting)
7. [Labs](#-labs)
8. [Application Folders](#-application-folders--lab-progression)
9. [Supporting Documentation](#-supporting-documentation)
10. [Summary & Statistics](#-documentation-statistics)
11. [Cross-Reference Index](#-cross-reference-index)
12. [Verification Checklist](#-verification-checklist)

---

## 🎯 Quick Navigation

**New to this repo?** → Start with [README.md](../../README.md)  
**New to Kubernetes?** → Start with [./GETTING-STARTED.md](./GETTING-STARTED.md)  
**Looking for a specific lab?** → See [../20-labs/KUBERNETES-LABS.md](../20-labs/KUBERNETES-LABS.md)  
**Need help?** → Check [../40-troubleshooting/troubleshooting-index.md](../40-troubleshooting/troubleshooting-index.md)

---

## 📚 Main Documentation

### Root Level
- **[README.md](../../README.md)** - Repository home page, quick start, lab table

### Documentation Hub (`00-introduction/`)
- **[./README.md](README.md)** - Documentation central hub
- **[./GETTING-STARTED.md](GETTING-STARTED.md)** - Complete onboarding guide (START HERE for beginners)
- **[../20-labs/KUBERNETES-LABS.md](../20-labs/KUBERNETES-LABS.md)** - Full lab roadmap with dependencies
- **[./MARKDOWN-INDEX.md](MARKDOWN-INDEX.md)** - Auto-generated file inventory
- **[./STYLE-GUIDE.md](STYLE-GUIDE.md)** - Contribution guidelines
- **REPOSITORY-STRUCTURE.md** - This file (complete inventory)

---

## 🎓 Learning Resources (`../20-labs/`)

- **[KUBERNETES-LABS.md](../20-labs/KUBERNETES-LABS.md)** - Complete lab roadmap with all 14 labs + 3 challenges
- **[COMMON-MISTAKES.md](../20-labs/COMMON-MISTAKES.md)** - Beginner pitfalls and how to avoid them
- **[LAB-PROGRESS.md](../20-labs/LAB-PROGRESS.md)** - Progress tracker checklist
- **[SELF-ASSESSMENT.md](../20-labs/SELF-ASSESSMENT.md)** - Knowledge checks after each stage
- **[CHALLENGE-SOLUTIONS-SHOWCASE.md](../20-labs/CHALLENGE-SOLUTIONS-SHOWCASE.md)** - Community solutions to challenges

---

## 🎯 Progress & Navigation

- **[PROGRESS-DASHBOARD.md](../PROGRESS-DASHBOARD.md)** - Learning progression map, skill heatmaps, self-assessment
- **[SEARCH-DISCOVERY-GUIDE.md](../SEARCH-DISCOVERY-GUIDE.md)** - How to find docs: search techniques, discovery tips

---

## 📖 Reference Guides (`../30-reference/`)

### Quick References (`../30-reference/cheatsheets/`)
- **[kubectl-cheatsheet.md](../30-reference/cheatsheets/kubectl-cheatsheet.md)** - Essential kubectl commands
- **[api-keys-guide.md](../30-reference/cheatsheets/api-keys-guide.md)** - API key management
- **[decision-trees.md](../30-reference/cheatsheets/decision-trees.md)** - Resource selection flowcharts

### Deep Dives & Conceptual Guides (`../30-reference/deep-dives/`)
- **[resource-requirements.md](../30-reference/deep-dives/resource-requirements.md)** - CPU, memory, disk, and port allocation for all labs
- **[secrets-management.md](../30-reference/deep-dives/secrets-management.md)** - Vault, ExternalSecrets patterns
- **[configuration-patterns.md](../30-reference/deep-dives/configuration-patterns.md)** - ConfigMap/Helm best practices
- **[certification-guide.md](../30-reference/deep-dives/certification-guide.md)** - CKA/CKAD exam prep
- **[senior-k8s-debugging.md](../30-reference/deep-dives/senior-k8s-debugging.md)** - Advanced debugging & performance tuning for senior engineers
- **[production-war-stories.md](../30-reference/deep-dives/production-war-stories.md)** - Real-world incidents

### Production Operations Guides (`../30-reference/deep-dives/`)
- **[database-operations.md](../30-reference/deep-dives/database-operations.md)** - Backup, restore, point-in-time recovery, migrations
- **[node-operations.md](../30-reference/deep-dives/node-operations.md)** - Drain, cordon, upgrades, maintenance windows
- **[storage-operations.md](../30-reference/deep-dives/storage-operations.md)** - Volume expansion, snapshots, migrations, capacity planning
- **[network-operations.md](../30-reference/deep-dives/network-operations.md)** - DNS debugging, service discovery, troubleshooting

---

## 🛠️ Setup Guides (`../10-setup/`)

- **[rancher-desktop.md](../10-setup/rancher-desktop.md)** - macOS/Windows setup
- **[linux-kind-k3d.md](../10-setup/linux-kind-k3d.md)** - Linux setup (kind/k3d)

---

## 🆘 Troubleshooting (`../docs/troubleshooting/`)

- **[troubleshooting.md](../40-troubleshooting/troubleshooting-index.md)** - Problem-solving playbook

---

## 🧪 Labs (`../../labs/`)

### Setup & Foundation (Labs 0-4)
- **[00-visual-kubernetes.md](../../labs/00-visual-kubernetes.md)** - k9s, stern, kubectl-tree setup
- **[00.5-docker-compose-to-kubernetes.md](../../labs/00.5-docker-compose-to-kubernetes.md)** - Migrate from Compose
- **[01-weather-basics.md](../../labs/01-weather-basics.md)** - First app: Weather (Vue+Python+Redis)
- **[02-ecommerce-basics.md](../../labs/02-ecommerce-basics.md)** - E-commerce (React+Node+MongoDB)
- **[03-educational-stateful.md](../../labs/03-educational-stateful.md)** - Stateful apps (Angular+Java+Postgres)
- **[03.5-kubernetes-under-the-hood.md](../../labs/03.5-kubernetes-under-the-hood.md)** - K8s internals deep dive
- **[04-kubernetes-fundamentals.md](../../labs/04-kubernetes-fundamentals.md)** - Labels, selectors, troubleshooting

### Production Operations (Labs 5-7)
- **[05-task-ingress.md](../../labs/05-task-ingress.md)** - Task Manager + Ingress (Svelte+Go+Postgres)
- **[06-medical-security.md](../../labs/06-medical-security.md)** - Security: RBAC, NetworkPolicies (Blazor+.NET)
- **[07-social-scaling.md](../../labs/07-social-scaling.md)** - Autoscaling HPA (React Native+Ruby+Postgres)

### Platform Engineering (Labs 8-9)
- **[08-multi-app.md](../../labs/08-multi-app.md)** - Multi-app orchestration
- **[08.5-multi-tenancy.md](../../labs/08.5-multi-tenancy.md)** - Multi-tenancy patterns
- **[09-chaos.md](../../labs/09-chaos.md)** - Chaos engineering
- **[09.5-complex-microservices.md](../../labs/09.5-complex-microservices.md)** - Service mesh

### Automation (Labs 10-13)
- **[10-helm-package-management.md](../../labs/10-helm-package-management.md)** - Helm charts
- **[11-gitops-argocd.md](../../labs/11-gitops-argocd.md)** - GitOps with ArgoCD
- **[11.5-disaster-recovery.md](../../labs/11.5-disaster-recovery.md)** - Backup & restore
- **[12-external-secrets.md](../../labs/12-external-secrets.md)** - External Secrets Operator
- **[12.5-multi-cloud-secrets.md](../../labs/12.5-multi-cloud-secrets.md)** - Multi-cloud secrets
- **[13-ai-ml-gpu.md](../../labs/13-ai-ml-gpu.md)** - AI/ML GPU workloads

### Challenge Labs
- **[challenge-a-midnight-incident.md](../../labs/challenge-a-midnight-incident.md)** - Incident response drill
- **[challenge-a-broken.yaml](../../labs/challenge-a-broken.yaml)** - Intentionally broken manifest
- **[challenge-b-black-friday.md](../../labs/challenge-b-black-friday.md)** - Scaling under pressure
- **[challenge-c-platform-migration.md](../../labs/challenge-c-platform-migration.md)** - Zero-downtime migration

---

## 📦 Lab Manifests (`../../labs/manifests/`)

- **[README.md](../../labs/manifests/README.md)** - Manifest overlays documentation
- **[ARCHITECTURE-DECISIONS.md](../../labs/manifests/ARCHITECTURE-DECISIONS.md)** - Design decisions
- **[IMAGE-TAG-UPDATES.md](../../labs/manifests/IMAGE-TAG-UPDATES.md)** - Image versioning

### Per-Lab Manifests
- **[lab-01/](../../labs/manifests/lab-01/)** - Weather app manifests (no README - uses base manifests)
- **[lab-02/README.md](../../labs/manifests/lab-02/README.md)** - E-commerce manifests
- **[lab-03/README.md](../../labs/manifests/lab-03/README.md)** - Educational app manifests
- **[lab-04/README.md](../../labs/manifests/lab-04/README.md)** - Task manager manifests
- **[lab-05/README.md](../../labs/manifests/lab-05/README.md)** - Medical care manifests
- **[lab-06/README.md](../../labs/manifests/lab-06/README.md)** - Social media manifests
- **[lab-07/README.md](../../labs/manifests/lab-07/README.md)** - Multi-app manifests
- **[lab-08/README.md](../../labs/manifests/lab-08/README.md)** - Chaos manifests
- **[lab-09/README.md](../../labs/manifests/lab-09/README.md)** - Helm manifests
- **[lab-10/README.md](../../labs/manifests/lab-10/README.md)** - ArgoCD manifests
- **[lab-11/README.md](../../labs/manifests/lab-11/README.md)** - External Secrets manifests
- **[lab-12/README.md](../../labs/manifests/lab-12/README.md)** - Fundamentals practice manifests

---

## 🏗️ Application Folders

Each app has: README, ARCHITECTURE, k8s manifests, Dockerfile(s), source code

### Weather App (`../../weather-app/`)
- **[README.md](../../weather-app/README.md)** - Points to Lab 1
- **[ARCHITECTURE.md](../../weather-app/ARCHITECTURE.md)** - System design
- **[k8s/](../../weather-app/k8s/)** - Kubernetes manifests
- **[k8s/advanced-features/README.md](../../weather-app/k8s/advanced-features/README.md)** - Advanced patterns

### E-commerce (`../../ecommerce-app/`)
- **[README.md](../../ecommerce-app/README.md)** - Points to Lab 2
- **[ARCHITECTURE.md](../../ecommerce-app/ARCHITECTURE.md)** - System design
- **[k8s/](../../ecommerce-app/k8s/)** - Kubernetes manifests
- **[k8s/advanced-features/README.md](../../ecommerce-app/k8s/advanced-features/README.md)** - Advanced patterns

### Educational Platform (`../../educational-platform/`)
- **[README.md](../../educational-platform/README.md)** - Points to Lab 3
- **[ARCHITECTURE.md](../../educational-platform/ARCHITECTURE.md)** - System design
- **[k8s/](../../educational-platform/k8s/)** - Kubernetes manifests
- **[k8s/advanced-features/README.md](../../educational-platform/k8s/advanced-features/README.md)** - Advanced patterns

### Task Management (`../../task-management-app/`)
- **[README.md](../../task-management-app/README.md)** - Points to Lab 5
- **[ARCHITECTURE.md](../../task-management-app/ARCHITECTURE.md)** - System design
- **[k8s/](../../task-management-app/k8s/)** - Kubernetes manifests
- **[k8s/advanced-features/README.md](../../task-management-app/k8s/advanced-features/README.md)** - Advanced patterns

### Medical Care System (`../../medical-care-system/`)
- **[README.md](../../medical-care-system/README.md)** - Points to Lab 6
- **[ARCHITECTURE.md](../../medical-care-system/ARCHITECTURE.md)** - System design
- **[k8s/](../../medical-care-system/k8s/)** - Kubernetes manifests
- **[k8s/advanced-features/README.md](../../medical-care-system/k8s/advanced-features/README.md)** - Advanced patterns

### Social Media Platform (`../../social-media-platform/`)
- **[README.md](../../social-media-platform/README.md)** - Points to Lab 7
- **[ARCHITECTURE.md](../../social-media-platform/ARCHITECTURE.md)** - System design
- **[backend/README.md](../../social-media-platform/backend/README.md)** - Backend specifics
- **[frontend/README.md](../../social-media-platform/frontend/README.md)** - Frontend specifics
- **[k8s/](../../social-media-platform/k8s/)** - Kubernetes manifests
- **[k8s/advanced-features/README.md](../../social-media-platform/k8s/advanced-features/README.md)** - Advanced patterns

---

## 🌐 Global Configs (`../../global-configs/`)

- **[README.md](../../global-configs/README.md)** - Docker Compose for all 6 apps (Lab 8)
- **[docker-compose.yml](../../global-configs/docker-compose.yml)** - Multi-app orchestration

---

## 🔧 Scripts (`../../scripts/`)

- **[README.md](../../scripts/README.md)** - Scripts documentation
- **check-lab-prereqs.sh** - Verify prerequisites for labs
- **cleanup-containers.sh** - Clean Docker resources
- **cleanup-workspace.sh** - Clean workspace artifacts
- **build-multiarch-images.sh** - Build multi-arch images
- **run-link-check-full.sh** - Validate all markdown links
- **_run-link-check-per-file.sh** - Internal link checker helper
- **regenerate-markdown-index.py** - Rebuild markdown inventory

---

## 🗺️ Visual Repository Map

```
stack-to-k8s-main/
├── README.md                          # → START: Main entry point
│
├── ../docs/                              # All documentation
│   ├── README.md                      # Documentation hub
│   ├── GETTING-STARTED.md             # → Onboarding guide
│   ├── KUBERNETES-LABS.md             # Full lab roadmap
│   ├── MARKDOWN-INDEX.md              # File inventory
│   ├── STYLE-GUIDE.md                 # Contribution guide
│   ├── REPOSITORY-STRUCTURE.md        # → This file (complete inventory)
│   ├── learning/                      # Learning resources
│   │   ├── COMMON-MISTAKES.md
│   │   ├── LAB-PROGRESS.md
│   │   └── SELF-ASSESSMENT.md
│   ├── reference/                     # Reference guides
│   │   ├── kubectl-cheatsheet.md
│   │   ├── resource-requirements.md   # NEW: Resource planning
│   │   ├── secrets-management.md
│   │   ├── api-keys-guide.md
│   │   ├── configuration-patterns.md
│   │   ├── decision-trees.md
│   │   ├── certification-guide.md
│   │   ├── senior-k8s-debugging.md
│   │   └── production-war-stories.md
│   ├── setup/                         # Setup guides
│   │   ├── rancher-desktop.md
│   │   └── linux-kind-k3d.md
│   └── troubleshooting/               # Problem solving
│       └── troubleshooting.md
│
├── ../../labs/                              # 23 labs + 3 challenges
│   ├── 00-visual-kubernetes.md        # Setup
│   ├── 00.5-docker-compose-to-kubernetes.md
│   ├── 01-13 (core labs)              # Main learning path
│   ├── 3.5, 8.5, 9.5, 11.5, 12.5      # Deep dive labs
│   ├── challenge-a-midnight-incident.md
│   ├── challenge-a-broken.yaml
│   ├── challenge-b-black-friday.md
│   ├── challenge-c-platform-migration.md
│   └── manifests/                     # Lab-specific manifests
│       ├── README.md
│       ├── ARCHITECTURE-DECISIONS.md
│       ├── IMAGE-TAG-UPDATES.md
│       └── lab-01/ through lab-12/
│
├── ../../scripts/                           # Automation tools
│   ├── README.md
│   ├── check-lab-prereqs.sh
│   ├── cleanup-*.sh
│   ├── build-multiarch-images.sh
│   ├── run-link-check-full.sh
│   └── regenerate-markdown-index.py
│
├── ../../global-configs/                    # Multi-app configs
│   ├── README.md
│   └── docker-compose.yml
│
└── [APP]-app/                         # 6 applications
    ├── README.md                      # Points to lab
    ├── ARCHITECTURE.md                # System design
    ├── Dockerfile
    ├── k8s/                           # K8s manifests
    │   ├── *.yaml
    │   └── advanced-features/
    │       └── README.md
    ├── backend/                       # Source code
    ├── frontend/
    └── ...
```

---

## 📊 Documentation Statistics

- **Total markdown files**: 79
- **Main documentation**: 5 files
- **Learning resources**: 3 files
- **Reference guides**: 9 files (including resource-requirements.md)
- **Setup guides**: 2 files
- **Labs**: 23 core labs + 3 challenges
- **Application docs**: 6 apps × 2-3 docs each
- **Scripts**: 7 utilities

---

## 🔗 Cross-Reference Index

### By Purpose

**Onboarding**:
- README.md → ./GETTING-STARTED.md → ../../labs/00-visual-kubernetes.md → ../../labs/01-weather-basics.md

**Learning Path**:
- ./KUBERNETES-LABS.md (master roadmap)
- ../20-labs/LAB-PROGRESS.md (track completion)
- ../20-labs/SELF-ASSESSMENT.md (test knowledge)

**Reference During Labs**:
- ../docs/reference/kubectl-cheatsheet.md
- ../40-troubleshooting/troubleshooting-index.md
- ../20-labs/COMMON-MISTAKES.md

**Advanced Topics**:
- ../docs/reference/certification-guide.md
- ../docs/reference/decision-trees.md
- ../docs/reference/production-war-stories.md

### By Audience

**Absolute Beginners**:
1. README.md
2. ./GETTING-STARTED.md
3. ../10-setup/ (rancher-desktop or linux)
4. ../../labs/00-visual-kubernetes.md
5. ../../labs/01-weather-basics.md

**Intermediate Users**:
- ./KUBERNETES-LABS.md (skip to Labs 5-7)
- ../docs/reference/ (best practices)
- Challenge labs

**Advanced Users**:
- Labs 8-13 (platform engineering, automation)
- ../docs/reference/production-war-stories.md
- Challenge C (platform migration)

**Contributors**:
- ./STYLE-GUIDE.md
- ../../scripts/README.md
- ../../labs/manifests/ARCHITECTURE-DECISIONS.md

---

## ✅ Verification Checklist

All files properly referenced:
- ✅ All 23 labs listed in README.md and KUBERNETES-LABS.md
- ✅ All 3 challenges documented
- ✅ All 7 reference guides linked in ./README.md
- ✅ All 6 apps have README + ARCHITECTURE
- ✅ All scripts documented in ../../scripts/README.md
- ✅ No broken internal links
- ✅ No orphaned documentation
- ✅ Clear navigation paths for all user types

---

## 🔄 Maintenance

This file is manually maintained. Update when:
- Adding new labs
- Adding new documentation
- Restructuring folders
- Adding new applications
- Creating new reference guides

**Last updated**: October 20, 2025

---

**Navigation**: [Back to README](../../README.md) | [Documentation Hub](README.md) | [Getting Started](GETTING-STARTED.md) | [Resource Requirements](../30-reference/deep-dives/resource-requirements.md)
