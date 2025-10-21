# 🏥 Medical care system

Sample app (Blazor + .NET + Postgres) used to learn RBAC, NetworkPolicies, and secrets.

## 📍 Where to practice

- Primary: [Lab 6 · Medical security](../labs/06-medical-security.md)
- Roadmap: [Kubernetes labs](../docs/KUBERNETES-LABS.md)

## 🧱 Architecture

- Overview: [ARCHITECTURE.md](ARCHITECTURE.md)
- Kubernetes manifests: [`k8s/`](k8s/) · Advanced: [`k8s/advanced-features/README.md`](k8s/advanced-features/README.md)

## ▶️ How to run

- In Kubernetes: follow [Lab 6](../labs/06-medical-security.md)
- Locally: use `docker-compose.yml`

## � Credentials & secrets

- Secrets (DB credentials, tokens) are configured via Kubernetes Secrets in the lab.
- Guide: [Secrets management](../docs/reference/secrets-management.md)

## �🔗 Related

- Troubleshooting: [docs/troubleshooting](../docs/troubleshooting/troubleshooting.md)
- Cheat sheet: [kubectl commands](../docs/reference/kubectl-cheatsheet.md)
