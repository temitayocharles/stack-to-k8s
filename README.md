# 🚀 Master Kubernetes: From Zero to Production Hero

Six real-world apps. Twelve hands-on labs. One rigorous journey to production-grade Kubernetes.

## 🏁 Quick start
1. Provision a local cluster → [Rancher Desktop](docs/setup/rancher-desktop.md) (Win/macOS) or [kind/k3d](docs/setup/linux-kind-k3d.md) (Linux)
2. Deploy your first workload → [Lab 1: Weather Basics](labs/01-weather-basics.md)
3. Track your journey → [LAB-PROGRESS.md](docs/learning/LAB-PROGRESS.md)

## 🧭 Lab roadmap
See the full progression (difficulty, prerequisites, success criteria) in:
- [KUBERNETES-LABS.md](docs/KUBERNETES-LABS.md)

Each lab includes: story-driven steps, validation checks, troubleshooting, and challenge mode.

## 🧱 Application portfolio
| App | Stack | Difficulty | Time |
|-----|------|------------|------|
| 🌦️ Weather App | Vue + Python + Redis | ⭐ | ~20m |
| 🛒 E-commerce | React + Node + MongoDB | ⭐⭐ | ~30m |
| 🎓 Educational | Angular + Java + Postgres | ⭐⭐⭐ | ~40m |
| ✅ Task Manager | Svelte + Go + Postgres | ⭐⭐⭐ | ~45m |
| 🏥 Medical Care | Blazor + .NET + Postgres | ⭐⭐⭐⭐ | ~50m |
| 📱 Social Media | React Native + Ruby + Postgres | ⭐⭐⭐⭐⭐ | ~60m |

## 🎒 Learning toolkit
- ✅ [Self-Assessment](docs/learning/SELF-ASSESSMENT.md)
- ⚠️ [Common Mistakes](docs/learning/COMMON-MISTAKES.md)
- 📘 [kubectl Cheatsheet](docs/reference/kubectl-cheatsheet.md) — includes namespace best practices
- 🛠️ [Troubleshooting Hub](docs/troubleshooting/troubleshooting.md)
- 🔐 [Secrets Management](docs/reference/secrets-management.md)
- 🗂️ [Markdown Inventory](docs/MARKDOWN-INDEX.md)

## ✅ Automation & quality checks
- scripts/validate-lab.sh — lab-specific acceptance checks
- scripts/validate-links.sh — markdown link checker (uses .github/markdown-link-check.json)

Example:
```bash
./scripts/validate-lab.sh 1
./scripts/validate-links.sh
```

## 🗺️ Repository map
```
├── docs/            # setup, references, labs index
├── labs/            # 12 hands-on labs + manifests/ overlays
├── scripts/         # validators and utilities
├── ecommerce-app/   # React + Node + MongoDB
├── educational-platform/  # Angular + Java + PostgreSQL
├── medical-care-system/   # Blazor + .NET + PostgreSQL
├── social-media-platform/ # React Native + Ruby + PostgreSQL
├── task-management-app/   # Svelte + Go + PostgreSQL
└── weather-app/     # Vue + Python + Redis
```

## 🤝 Contributing
1) Validate links → `./scripts/validate-links.sh`  
2) Test labs → `./scripts/validate-lab.sh <lab>`  
3) Open a PR with changes and test output

## 💡 Credits
Created by Temitayo Charles Akinniranye — Docker Hub: https://hub.docker.com/u/temitayocharles — Built with ❤️ for engineers who learn by doing.

👉 Start now → [Lab 1: Weather Basics](labs/01-weather-basics.md)