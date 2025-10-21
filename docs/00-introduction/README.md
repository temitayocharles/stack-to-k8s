---
title: "Kubernetes Labs & Reference Documentation Hub"
level: "beginner-to-advanced"
type: "documentation-hub"
prerequisites: []
updated: "2025-10-21"
nav_prev: null
nav_next: "./GETTING-STARTED.md"
---

# Kubernetes Labs & Reference Documentation

Welcome to the **Kubernetes Learning & Reference Docs** — a comprehensive, enterprise-grade knowledge base for mastering Kubernetes from fundamentals to production operations.

This repository provides everything you need: from local setup and hands-on labs to advanced debugging, security patterns, and real-world case studies.

---

## 📘 Documentation Overview

| Section | Description |
|----------|--------------|
| **[Getting Started](./GETTING-STARTED.md)** | Environment setup, tools installation, first lab walkthrough |
| **[Labs](../20-labs/KUBERNETES-LABS.md)** | 14 practical hands-on exercises with challenge tracks |
| **[Reference](../30-reference/deep-dives/)** | In-depth guides on configuration, secrets, debugging, and production patterns |
| **[Troubleshooting](../40-troubleshooting/troubleshooting-index.md)** | Common issues, diagnostics, and solutions |
| **[Style Guide](./STYLE-GUIDE.md)** | How to contribute and maintain consistency |

---

## 🧭 Quick Navigation

👤 **New to Kubernetes?**  
→ Start with [Getting Started](./GETTING-STARTED.md)  
→ Then move to [Lab 0: Visual Kubernetes](../20-labs/KUBERNETES-LABS.md)

🔄 **Returning learners?**  
→ Check [Lab Progress Tracker](../20-labs/LAB-PROGRESS.md)  
→ Resume where you left off

🚀 **Operators / Admins?**  
→ Jump to [Troubleshooting Index](../40-troubleshooting/troubleshooting-index.md)  
→ Or browse [Production War Stories](../30-reference/deep-dives/production-war-stories.md)

📖 **Looking for quick reference?**  
→ [kubectl Cheatsheet](../30-reference/cheatsheets/kubectl-cheatsheet.md)  
→ [Decision Trees](../30-reference/cheatsheets/decision-trees.md)  
→ [Resource Requirements Guide](../30-reference/deep-dives/resource-requirements.md)

---

## 🔄 Repository Structure

This documentation is organized by **learning progression and operational depth**:

```
docs/
├── 00-introduction/        # Entry points, onboarding, style guide
├── 10-setup/              # Environment setup guides
├── 20-labs/               # Hands-on exercises and learning materials
├── 30-reference/          # Technical deep-dives and quick references
│   ├── cheatsheets/       # Copy-paste-ready commands and flowcharts
│   ├── deep-dives/        # Long-form conceptual guides
│   └── monitoring/        # Observability and metrics setup
├── 40-troubleshooting/    # Problem-solving and diagnostics
└── 99-appendix/           # Glossary, changelog, roadmap
```

For a complete inventory, see [REPOSITORY-STRUCTURE.md](./REPOSITORY-STRUCTURE.md).

---

## 🎯 Learning Path

### Beginner Path (Labs 0-3)
1. **Lab 0** — Visual Kubernetes (k9s, stern, visualization tools)
2. **Lab 0.5** — Docker Compose → Kubernetes migration
3. **Lab 1** — Your first app: Weather service (Pods, Services, ConfigMaps)
4. **Lab 2** — Multi-tier app: E-commerce (Deployments, StatefulSets, Secrets)
5. **Lab 3** — Stateful applications: Educational platform (PersistentVolumes, PVCs)

### Intermediate Path (Labs 4-7)
6. **Lab 4** — Kubernetes fundamentals: Labels, selectors, troubleshooting
7. **Lab 5** — Ingress & routing: Task management app
8. **Lab 6** — Security: RBAC, NetworkPolicies, secrets management
9. **Lab 7** — Autoscaling & performance: Social media platform

### Advanced Path (Labs 8-13)
10. **Lab 8** — Multi-app orchestration and service mesh basics
11. **Lab 9** — Chaos engineering and resilience testing
12. **Lab 10** — Helm: Package management and templating
13. **Lab 11** — GitOps with ArgoCD: Declarative deployments
14. **Lab 12** — External Secrets: Enterprise secret management
15. **Lab 13** — AI/ML GPU workloads: Distributed training and serving

### Challenge Tracks (Optional but Recommended)
- **Challenge A** — Midnight incident: Incident response drill
- **Challenge B** — Black Friday: Scaling under pressure
- **Challenge C** — Platform migration: Zero-downtime deployment

---

## ⚡ Quick Start (5 minutes)

```bash
# 1. Install Rancher Desktop or kind/k3d
# See: docs/10-setup/rancher-desktop.md or docs/10-setup/linux-kind-k3d.md

# 2. Check prerequisites before each lab
./scripts/check-lab-prereqs.sh 1

# 3. Run first lab
cd labs && cat 01-weather-basics.md
```

---

## 🛠️ Key Resources

| Need | Link |
|------|------|
| Quick kubectl commands | [kubectl Cheatsheet](../30-reference/cheatsheets/kubectl-cheatsheet.md) |
| API keys & credentials | [API Keys Guide](../30-reference/cheatsheets/api-keys-guide.md) |
| Secrets management | [Secrets Management Guide](../30-reference/deep-dives/secrets-management.md) |
| Resource sizing | [Resource Requirements](../30-reference/deep-dives/resource-requirements.md) |
| Configuration patterns | [Configuration Patterns](../30-reference/deep-dives/configuration-patterns.md) |
| CKA/CKAD prep | [Certification Guide](../30-reference/deep-dives/certification-guide.md) |
| Advanced debugging | [Senior K8s Debugging](../30-reference/deep-dives/senior-k8s-debugging.md) |
| Real-world lessons | [Production War Stories](../30-reference/deep-dives/production-war-stories.md) |

---

## 🤝 Contributing

We welcome improvements! Before submitting:

1. Follow [STYLE-GUIDE.md](./STYLE-GUIDE.md) for formatting and tone
2. Validate links: `../scripts/run-link-check-full.sh`
3. Test any technical steps before committing
4. Add yourself to the contributors list if significant

---

## 📞 Support

- **Stuck on a lab?** → Check [COMMON-MISTAKES.md](../20-labs/COMMON-MISTAKES.md)
- **Errors during setup?** → See [Troubleshooting Index](../40-troubleshooting/troubleshooting-index.md)
- **Questions about resources?** → [Resource Requirements](../30-reference/deep-dives/resource-requirements.md) has answers

---

**Next Step →** [Getting Started Guide](./GETTING-STARTED.md)

---

**Last Updated**: October 21, 2025  
**Documentation Version**: 2.0 (Enterprise Restructure)
