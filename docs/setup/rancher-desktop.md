# 🖥️ Rancher Desktop Setup · Windows & macOS

Use Rancher Desktop to spin up a lightweight Kubernetes environment on either Windows or macOS. This guide replaces the separate OS-specific notes and keeps everything in one place for quicker onboarding.

---

## 🔍 Overview
- Install **Rancher Desktop** instead of Docker Desktop for a smaller footprint.
- Enable the bundled Kubernetes distribution backed by containerd.
- Install supporting CLIs (`kubectl`, `k9s`, optional helpers) tailored per OS.
- Validate the cluster with a smoke test before starting the labs.

Estimated time: **15 minutes** on either platform.

---

## ✅ Prerequisites
| | Windows 10/11 | macOS 12+ (Intel or Apple Silicon) |
| --- | --- | --- |
| Hardware | Virtualization enabled (BIOS/UEFI) | Virtualization enabled (automatic on Apple Silicon) |
| Resources | 8 GB RAM (16 GB ideal), 20+ GB disk | 8 GB RAM (16 GB ideal), 20+ GB disk |
| Tooling | Administrator rights, Windows Terminal or PowerShell | Administrator rights, Terminal.app or iTerm2 |
| Extras | WSL 2 enabled (`wsl --install`) | Homebrew recommended (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`) |

> 💡 Already running Docker Desktop? Fully quit it before starting Rancher Desktop to avoid port or VM conflicts.

---

## 1️⃣ Install Rancher Desktop

### Windows steps
1. Download the latest installer from **[rancherdesktop.io](https://rancherdesktop.io/)** and run `Rancher.Desktop.Setup.exe`.
2. On first launch, pick:
   - **Container Runtime** → `containerd`
   - **Kubernetes** → ✅ Enabled (version `v1.29+` recommended)
   - **WSL Distribution** → your preferred distro (e.g., `Ubuntu-22.04`).
3. Wait for the status indicator to turn green; Kubernetes is now ready.

### macOS steps
1. Download the `.dmg` from **[rancherdesktop.io](https://rancherdesktop.io/)**, drag Rancher Desktop to `Applications`, then launch it.
2. Choose:
   - **Container Runtime** → `containerd`
   - **Kubernetes** → ✅ Enabled (`v1.29+` recommended)
3. Approve the helper tool installation when prompted and wait for the green status indicator.

### Resource tuning (both platforms)
Adjust under **Settings ▸ Virtual Machine**:
- CPUs: `4` minimum (`6–8` recommended if you have headroom)
- Memory: `6 GB` minimum (`8–12 GB` recommended)
- Disk: increase to `60 GB` if you plan to build or retain larger images locally

Changes require clicking **Restart** on the same screen.

---

## 2️⃣ Install kubectl and Helper CLIs

### Windows
```powershell
# Make sure the bundled kubectl is on PATH
$env:PATH = "$env:APPDATA\rancher-desktop\bin;$env:PATH"

kubectl version --client
```
Persist the change by adding `%APPDATA%\rancher-desktop\bin` to **System Environment Variables ▸ Path**.

Optional helpers:
```powershell
winget install -e --id derailed.k9s
winget install -e --id Helm.Helm
```
`nerdctl` already lives at `%USERPROFILE%\.rd\bin\nerdctl.exe` if you need Docker-compatible commands.

### macOS
```bash
ln -sf "${HOME}/.rd/bin/kubectl" /usr/local/bin/kubectl
kubectl version --client
```
Optional helpers via Homebrew:
```bash
brew install k9s helm jq
```
`nerdctl` is shipped at `${HOME}/.rd/bin/nerdctl`.

---

## 3️⃣ Validate Your Cluster

### Windows (PowerShell)
```powershell
kubectl config use-context rancher-desktop

kubectl get nodes
kubectl get pods -A | Select-Object -First 5

kubectl create namespace smoke-test
kubectl create deployment echo --image=registry.k8s.io/echoserver:1.4 -n smoke-test
kubectl expose deployment echo --type=ClusterIP --port=8080 -n smoke-test

kubectl rollout status deployment/echo -n smoke-test
kubectl get services -n smoke-test

kubectl delete namespace smoke-test
```

### macOS (bash/zsh)
```bash
test "$(kubectl config current-context)" = "rancher-desktop" || kubectl config use-context rancher-desktop

kubectl get nodes
kubectl get pods -A | head -n 5

kubectl create namespace smoke-test
kubectl create deployment echo --image=registry.k8s.io/echoserver:1.4 -n smoke-test
kubectl expose deployment echo --type=ClusterIP --port=8080 -n smoke-test

kubectl rollout status deployment/echo -n smoke-test
kubectl get services -n smoke-test

kubectl port-forward deployment/echo 8080:8080 -n smoke-test >/tmp/echo.log 2>&1 &
sleep 3
curl -s localhost:8080 | head -n 5
kill %1

kubectl delete namespace smoke-test
```
Expected result: the node reports `Ready`, the deployment rolls out, and the echo server responds.

---

## 4️⃣ Daily Operations Cheatsheet
| Task | Windows | macOS |
| --- | --- | --- |
| Stop the cluster | `rdctl shutdown` (PowerShell) | `rdctl shutdown` |
| Restart after config change | `rdctl start` | `rdctl start` |
| Reset Kubernetes state | **Settings ▸ Kubernetes ▸ Reset Kubernetes** | **Settings ▸ Kubernetes ▸ Reset Kubernetes** |
| Switch kubectl context | `kubectl config use-context rancher-desktop` | `kubectl config use-context rancher-desktop` |
| Access container runtime | `%USERPROFILE%\.rd\bin\nerdctl.exe ps` | `${HOME}/.rd/bin/nerdctl ps` |

> ⚠️ Resetting Kubernetes removes all local pods, images, and volumes. Export anything important first.

---

## 5️⃣ Troubleshooting
| Symptom | Windows fix | macOS fix |
| --- | --- | --- |
| Kubernetes stuck on “Starting” | Toggle Kubernetes off/on under **Settings ▸ Kubernetes**, then restart. Check VPN/proxy. | Same steps; also ensure helper tool is allowed in System Preferences. |
| `kubectl` not found | Re-run the PATH command above or reinstall via `winget`. | Re-run the symlink command or add `${HOME}/.rd/bin` to `PATH`. |
| High CPU/RAM usage | Lower VM resources or run `rdctl shutdown` when idle. | Lower VM resources or run `rdctl shutdown` when idle. |
| Missing WSL distro | `wsl --list --online` then `wsl --install -d Ubuntu`. | Not applicable. |
| Need fresh start | `rdctl reset --kubernetes` followed by reinstall of CLIs if paths changed. | Same command in Terminal (requires `rdctl` symlink). |

More runtime tips live in `docs/troubleshooting/troubleshooting.md`.

---

## ✅ Next Steps
1. Return to the **[Kubernetes Practice Labs README](../../README.md)** and pick your first mission.
2. Track progress in `docs/learning/LAB-PROGRESS.md`.
3. Optional: Install the VS Code Kubernetes extension and point it at the `rancher-desktop` context for richer insight.

Happy shipping! 🚀
