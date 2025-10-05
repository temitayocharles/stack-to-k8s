# Kubernetes Practice Lab## Application portfolio 🧱 🚀## Learning toolkit 🎒

- ✅ **[SELF-ASSESSMENT.md](docs/learning/SELF-ASSESSMENT.md)** — Gauge skills after every milestone.
- ⚠️ **[COMMON-MISTAKES.md](docs/learning/COMMON-MISTAKES.md)** — Skip the top gotchas we see in reviews.
- 📘 **[kubectl cheatsheet](docs/reference/kubectl-cheatsheet.md)** — Commands plus namespace best practices.
- 🛠️ **[Troubleshooting hub](docs/troubleshooting/troubleshooting.md)** — Rapid response playbook with deep-dive drills.
- 🔐 **[Secrets management guide](docs/reference/secrets-management.md)** — Vault patterns and rotation strategies.
- 🗂️ **[Markdown inventory](docs/MARKDOWN-INDEX.md)** — Quick glance at every guide, lab, and reference in the repo.e aboard—six production-grade apps and twelve narrative labs that take you from curious engineer to confident Kubernetes operator.LF-ASSESSMENT.md](docs/learning/SELF-ASSESSMENT.md)** — Gauge skills after every milestone.
- ⚠️ **[COMMON-MISTAKES.md](docs/learning/COMMON-MISTAKES.md)** — Skip the top gotchas we see in reviews.
- 📘 **[kubectl cheatsheet](docs/reference/kubectl-cheatsheet.md)** — Copy/paste-ready commands.
- 🏷️ **[Namespace best practices](docs/reference/namespace-best-practices.md)** — Why and how to always scope operations with `-n`.
- �️ **[Troubleshooting hub](docs/troubleshooting/troubleshooting.md)** — Rapid response playbook with deep-dive drills.
- 🔐 **[Secrets management guide](docs/reference/secrets-management.md)** — Vault patterns and rotation strategies.
- 🗂️ **[Markdown inventory](docs/MARKDOWN-INDEX.md)** — Quick glance at every guide, lab, and reference in the repo.Welcome aboard—six production-grade apps and twelve narrative labs that take you from curious engineer to confident Kubernetes operator.

## Quick start 🏁

1. Provision a local Kubernetes cluster with [Rancher Desktop](docs/setup/rancher-desktop.md) or [kind/k3d](docs/setup/linux-kind-k3d.md).
2. Complete **[Lab 1: Deploy Your First App](labs/01-weather-basics.md)** to see the full toolchain in action.
3. Track what you finish in **[LAB-PROGRESS.md](docs/learning/LAB-PROGRESS.md)** so you always know the next move.

## Lab roadmap 🧭

The complete progression—including difficulty, prerequisites, and success criteria—lives in **[KUBERNETES-LABS.md](docs/KUBERNETES-LABS.md)**. Each lab links to its story-driven walkthrough plus supporting runbooks, troubleshooting checklists, and validation scripts.

## Application portfolio �

- 🌦️ **Weather App** — Vue.js + Python + Redis
- 🛒 **E-commerce Platform** — React + Node.js + MongoDB
- 🎓 **Educational Platform** — Angular + Java + PostgreSQL
- ✅ **Task Management** — Svelte + Go + PostgreSQL
- 🏥 **Medical Care System** — Blazor + .NET + PostgreSQL
- 📱 **Social Media Platform** — React Native + Ruby + PostgreSQL

## Learning toolkit 🎒

- ✅ **[SELF-ASSESSMENT.md](docs/learning/SELF-ASSESSMENT.md)** — Gauge skills after every milestone.
- ⚠️ **[COMMON-MISTAKES.md](docs/learning/COMMON-MISTAKES.md)** — Skip the top gotchas we see in reviews.
- � **[kubectl cheatsheet](docs/reference/kubectl-cheatsheet.md)** — Copy/paste-ready commands.
- 🛠️ **[Troubleshooting hub](docs/troubleshooting/troubleshooting.md)** — Rapid response playbook with deep-dive drills.
- 🔐 **[Secrets management guide](docs/reference/secrets-management.md)** — Vault patterns and rotation strategies.
- 🗂️ **[Markdown inventory](docs/MARKDOWN-INDEX.md)** — Quick glance at every guide, lab, and reference in the repo.

## Automation & quality checks ✅

- `scripts/validate-lab.sh` runs smoke tests tailored to each lab’s acceptance criteria.
- `scripts/validate-links.sh` verifies Markdown links using `markdown-link-check` with sensible retry and ignore defaults.
- `.github/markdown-link-check.json` centralises link-check behaviour so CI and local runs stay consistent.

## Writing & style guide ✍️

We keep docs fast to skim: one emoji per heading, imperative voice, and consistent section order. See **[STYLE-GUIDE.md](docs/STYLE-GUIDE.md)** before adding or refreshing lab content.

## Repository map 🗺️

- `applications/` — Boilerplates and templates shared by multiple labs.
- `docs/` — Lab narratives, setup guides, troubleshooting references, and learning aids.
- `scripts/` — Automation for validation, builds, monitoring, and clean-up.
- `<app>/` — Production-style source, infrastructure, and CI/CD for each platform.

## Contributing 🤝

1. Run `scripts/validate-links.sh` (or pass specific Markdown files) to confirm outbound references.
2. Execute `scripts/validate-lab.sh <lab>` for any lab you modify.
3. Submit a PR with a summary of changes, test evidence, and any new playbook entries.

## Credits 💡

Created by Temitayo Charles Akinniranye — [Docker Hub](https://hub.docker.com/u/temitayocharles) — Built with ❤️ for curious engineers.
