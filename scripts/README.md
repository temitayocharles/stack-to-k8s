docker-compose up -d
# Scripts Toolkit 🛠️

Practical automation that keeps the labs reproducible and production-ready. All scripts live directly in this folder.

## Quick reference

| Script | Purpose | Typical timing |
| --- | --- | --- |
| `calculate-lab-resources.sh` | Calculate aggregate resource requirements for any combination of labs (CPU, memory, disk, pods). Shows cluster sizing recommendations and port conflicts. | Before planning lab sequence |
| `check-lab-prereqs.sh` | Verify CLI prerequisites (kubectl, helm, etc.) plus cluster health. Pass lab number to check specific requirements. | Before starting any lab |
| `cleanup-containers.sh` | Stop and prune leftover Docker containers, images, and volumes. | After local lab runs |
| `cleanup-workspace.sh` | Remove build artifacts and temp files created by lab steps. | Before committing or zipping the repo |
| `build-multiarch-images.sh` | Build workloads for amd64/arm64 using Buildx, tagging images consistently for registries. | Before publishing container updates |
| `run-link-check-full.sh` | Validate all markdown links in the repository. | Before commits, PR submissions |
| `_run-link-check-per-file.sh` | Internal helper for link checking (called by run-link-check-full.sh). | Internal use only |
| `regenerate-markdown-index.py` | Rebuild the complete markdown file inventory (excludes node_modules, .venv, build artifacts). | After adding/removing documentation |

All scripts are POSIX-friendly Bash (or Python 3) and assume execution from the repository root unless noted otherwise.

## Usage patterns

### Plan your lab sequence

```bash
# List all available labs
./scripts/calculate-lab-resources.sh --list

# Calculate resources for specific labs
./scripts/calculate-lab-resources.sh 1 2 3

# Verbose mode with per-lab breakdown
./scripts/calculate-lab-resources.sh -v 1 2 3

# Calculate all labs (Lab 8 scenario)
./scripts/calculate-lab-resources.sh --all

# Show help
./scripts/calculate-lab-resources.sh --help
```

**Output includes**:
- Aggregate CPU, memory, disk requirements
- Pod count totals
- Minimum vs recommended cluster sizing
- Compatibility with common dev machines
- Cloud cost estimates (to emphasize FREE local option)
- Port conflict warnings for multi-lab setups

### Before starting a lab

```bash
# Check if you're ready for Lab 3
./scripts/check-lab-prereqs.sh 3

# Or check general prerequisites
./scripts/check-lab-prereqs.sh
```

### Local cleanup

```bash
./scripts/cleanup-containers.sh
./scripts/cleanup-workspace.sh
```

### Validate documentation changes

```bash
./scripts/run-link-check-full.sh
```

### Build multi-arch images

```bash
./scripts/build-multiarch-images.sh --app ecommerce-app --tag v1.2.0
```

### Regenerate markdown index

```bash
python3 ./scripts/regenerate-markdown-index.py
```

Each script supports `--help` or `-h` for option details when available. Always review scripts before running in sensitive environments.