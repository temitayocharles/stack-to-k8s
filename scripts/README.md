docker-compose up -d
# Scripts Toolkit 🛠️

Practical automation that keeps the labs reproducible and production-shaped. Everything lives directly in this folder except advanced deployment helpers inside `deployment/`.

## Quick reference

| Script | Purpose | Typical timing |
| --- | --- | --- |
| `cleanup-containers.sh` | Stop and prune leftover Docker containers, images, and volumes. | After local lab runs |
| `cleanup-workspace.sh` | Remove build artifacts and temp files created by lab steps. | Before committing or zipping the repo |
| `check-lab-prereqs.sh` | Verify CLI prerequisites (kubectl, helm, etc.) plus Rancher Desktop/kind context health. | Environment bring-up |
| `build-multiarch-images.sh` | Build workloads for amd64/arm64 using Buildx, tagging images consistently for registries. | Before publishing container updates |
| `validate-lab.sh` | Run lab-specific smoke tests to confirm manifests deploy correctly. | After editing any lab walkthrough or manifests |
| `validate-links.sh` | Scan Markdown for broken links using `markdown-link-check`. Honors `.github/markdown-link-check.json`. | Documentation changes |
| `audit-configmaps-secrets.py` | Generate an inventory of every ConfigMap/Secret declared in app manifests (TSV or Markdown). | Before/after manifest edits |
| `deployment/generate-advanced-features.sh` | Apply optional advanced Kubernetes features (HPA, network policies, PodDisruptionBudgets) across apps. | Scaling beyond the base lab setup |

All scripts are POSIX-friendly Bash and assume execution from the repository root unless noted otherwise.

## Usage patterns

### Local cleanup

```bash
./scripts/cleanup-containers.sh
./scripts/cleanup-workspace.sh
```

### Validate documentation changes

```bash
./scripts/validate-links.sh README.md docs/README.md
```

### Sanity-check a lab run

```bash
./scripts/check-lab-prereqs.sh
./scripts/validate-lab.sh lab-identifier
```

### Build multi-arch images

```bash
./scripts/build-multiarch-images.sh --app ecommerce-app --tag v1.2.0
```

### Layer on advanced platform features

```bash
./scripts/deployment/generate-advanced-features.sh --cluster local
```

Each script supports `--help` for option details when available. Always review the script before running in sensitive environments.