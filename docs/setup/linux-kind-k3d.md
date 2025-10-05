# 🐧 Linux Setup Guide · kind (Kubernetes in Docker) + Optional k3d

Build a reliable Kubernetes playground on Linux using lightweight, scriptable tools. These steps align with the lab requirements and mirror production workflows without extra GUIs.

---

## 🔍 Overview
- Install Docker Engine or an alternative container runtime.
- Install **kind** (Kubernetes-in-Docker) for fast disposable clusters.
- Optionally install **k3d** (K3s on Docker) for a production-style distribution.
- Configure `kubectl`, `k9s`, `helm`, and validate your cluster.

Estimated time: **15 minutes**.

---

## ✅ Prerequisites
- Linux distribution with kernel 5.x or newer (Ubuntu 22.04+, Fedora 39+, Debian 12+).
- sudo privileges.
- 8 GB RAM (16 GB recommended) and at least 20 GB disk space.
- Internet access to pull container images.

---

## 1️⃣ Install Container Runtime
### Option A: Docker Engine (recommended for kind/k3d)
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

### Option B: Podman (with podman-docker shim)
```bash
sudo apt-get install -y podman
sudo apt-get install -y podman-docker
```
> ⚠️ Note: kind expects Docker-compatible APIs. Podman works best on Fedora; verify with `kind version` after install.

---

## 2️⃣ Install kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Optional (managed via package manager):
```bash
sudo snap install kubectl --classic
```

Verify:
```bash
kubectl version --client
```

---

## 3️⃣ Install kind
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/kind
```

Confirm:
```bash
kind version
```

---

## 4️⃣ Create a Lab Cluster
```bash
cat <<'EOF' > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 8080
        protocol: TCP
      - containerPort: 30443
        hostPort: 8443
        protocol: TCP
  - role: worker
  - role: worker
EOF

kind create cluster --name lab --config kind-config.yaml
kubectl cluster-info --context kind-lab
kubectl get nodes
```

To delete:
```bash
kind delete cluster --name lab
```

---

## 5️⃣ Optional: Install k3d (K3s on Docker)
```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d version

# Create cluster
default_registry="docker.io"
k3d cluster create lab --agents 2 --api-port 6550 --port "80:80@loadbalancer" --port "443:443@loadbalancer" --registry-create "lab-registry:0.0.0.0:5500"

# Use context
kubectl config use-context k3d-lab
kubectl get nodes
```

Cleanup:
```bash
k3d cluster delete lab
```

---

## 6️⃣ Install Optional Tooling
```bash
# Terminal UI
curl -LO https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_Linux_amd64.tar.gz
tar -xf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# nerdctl (if using containerd standalone)
curl -LO https://github.com/containerd/nerdctl/releases/download/v2.0.0/nerdctl-2.0.0-linux-amd64.tar.gz
tar -xf nerdctl-2.0.0-linux-amd64.tar.gz
sudo mv nerdctl /usr/local/bin/
```

---

## 7️⃣ Validate with a Smoke Test
```bash
kubectl create namespace smoke-test
kubectl create deployment hello --image=registry.k8s.io/echoserver:1.4 -n smoke-test
kubectl expose deployment hello --type=NodePort --port=8080 -n smoke-test

kubectl rollout status deployment/hello -n smoke-test
kubectl get services -n smoke-test

# Access via forwarded port (if using kind config above)
curl -s localhost:8080 | head -n 5

kubectl delete namespace smoke-test
```

Expected: Pods become `Running`, NodePort accessible via mapped host ports.

---

## 8️⃣ Daily Operations Cheatsheet
| Task | kind command | k3d command |
| --- | --- | --- |
| Stop cluster | `kind delete cluster --name lab` | `k3d cluster stop lab` |
| Restart cluster | `kind delete cluster --name lab && kind create cluster --name lab --config kind-config.yaml` | `k3d cluster restart lab` |
| Switch context | `kubectl config use-context kind-lab` | `kubectl config use-context k3d-lab` |
| Load local image | `kind load docker-image <image> --name lab` | `k3d image import <image> -c lab` |
| Exec into node | `docker exec -it lab-control-plane /bin/sh` | `k3d node shell k3d-lab-server-0` |

---

## 9️⃣ Troubleshooting
| Symptom | Fix |
| --- | --- |
| `kind create cluster` fails with cgroup error | Ensure `systemd` cgroup driver is active (`systemd.unified_cgroup_hierarchy=1`). |
| Docker permission denied | Run `newgrp docker` or relog after adding user to `docker` group. |
| kube-dns pending | Wait for image pull or set HTTP proxy env vars before cluster creation. |
| Port conflicts | Adjust `extraPortMappings` in `kind-config.yaml`. |
| k3d registry unreachable | Expose registry host port (`5500`) and add entries to `/etc/hosts` if necessary. |

See also the main `docs/troubleshooting/troubleshooting.md` for runtime-specific fixes.

---

## ✅ Next Steps
1. Return to the **[Kubernetes Practice Labs README](../../README.md)** and choose your first mission.
2. Bookmark `docs/learning/LAB-PROGRESS.md` to track achievements.
3. Consider wiring these clusters into your CI sandbox by scripting `kind` or `k3d` creation inside pipelines.

Happy hacking on Linux! 🧠⚙️
