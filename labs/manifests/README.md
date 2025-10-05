# Kubernetes Manifest Overlays

To make each lab self-contained, the table below points to curated manifest overlays
that align with the instructions. Each overlay is a lightweight Kustomize package
that references the canonical application manifests in this repository while
setting the namespaces, labels, and resource counts used in the exercises.

> 💡 **Tip:** Apply an overlay with `kustomize build` piped into `kubectl apply -f -`. Example:
> 
> ```bash
> kustomize build labs/manifests/lab-01 | kubectl apply -f -
> ```

| Lab | Title | Overlay | Notes | Status |
| --- | ----- | ------- | ----- | ------ |
| 01 | Weather App Basics | [`labs/manifests/lab-01`](lab-01/) | Backend + frontend deployments, services, namespace `weather-lab` | ✅ Ready |
| 02 | E-commerce Multi-Service | [`labs/manifests/lab-02`](lab-02/) | Database, backend, frontend, config map | 🚧 In progress |
| 03 | Educational Stateful | [`labs/manifests/lab-03`](lab-03/) | Stateful PostgreSQL, backend, frontend | 🚧 In progress |
| 04 | Task Manager Ingress | [`labs/manifests/lab-04`](lab-04/) | Backend, frontend, ingress, TLS placeholders | 🚧 In progress |
| 05 | Medical Security | [`labs/manifests/lab-05`](lab-05/) | Secrets, RBAC, network policies, API deployment | 🚧 In progress |
| 06 | Social Autoscaling | [`labs/manifests/lab-06`](lab-06/) | Backend, frontend, database, HPA seed manifests | 🚧 In progress |
| 07 | Multi-App Orchestration | [`labs/manifests/lab-07`](lab-07/) | Aggregates all six apps plus monitoring hooks | 🚧 In progress |
| 08 | Chaos Engineering | [`labs/manifests/lab-08`](lab-08/) | Social app baseline + Chaos Mesh namespace bootstrap | 🚧 In progress |
| 09 | Helm Package Management | [`labs/manifests/lab-09`](lab-09/) | PostgreSQL Helm values and chart scaffolding | 🚧 In progress |
| 10 | GitOps with ArgoCD | [`labs/manifests/lab-10`](lab-10/) | ArgoCD bootstrap manifests & app-of-apps examples | 🚧 In progress |
| 11 | External Secrets | [`labs/manifests/lab-11`](lab-11/) | External Secrets Operator overlays & sample resources | 🚧 In progress |
| 12 | Fundamentals Deep Dive | [`labs/manifests/lab-12`](lab-12/) | Broken/fixed examples for label selector practice | 🚧 In progress |

Each overlay contains:

- `namespace.yaml` – the dedicated namespace for the lab.
- Application manifests trimmed to the minimal set required to complete the lab.
- Helpful patches (labels, replica counts, resource requests) tailored to the learning outcomes.
- A `README.md` describing any variables you may want to tweak before applying.

If you prefer not to use Kustomize, you can inspect the overlays and apply the
individual YAML files with plain `kubectl apply -f` commands.

---

## 📖 Documentation

- **[Architecture Decisions](ARCHITECTURE-DECISIONS.md)** - Why Labs 7-11 use different patterns, why Labs 4-6 use consolidated files
- **[Image Tag Updates](IMAGE-TAG-UPDATES.md)** - How manifests align with Docker Hub registry state

## 🎯 Overlay Patterns

This repository uses **three distinct patterns** for different learning objectives:

| Pattern | Labs | Purpose |
|---------|------|---------|
| **Separate Files** | 1-3 | Learn individual resource types (Pods, Services, ConfigMaps) |
| **Consolidated Files** | 4-6 | Understand resource relationships (Ingress, RBAC, HPA) |
| **Installation Guides** | 7-11 | Real-world tooling (Helm, ArgoCD, Chaos Mesh, ESO) |

See [ARCHITECTURE-DECISIONS.md](ARCHITECTURE-DECISIONS.md) for detailed rationale.
