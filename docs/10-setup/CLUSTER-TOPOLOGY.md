# 🏗️ Cluster Topology: Single-Node vs Multi-Node Setup

This guide explains what type of Kubernetes cluster these labs use, and how to configure it for different learning scenarios.

---

## 📊 Quick Answer

### Rancher Desktop (macOS/Windows)
- **Default**: **Single-node cluster** (1 control-plane node)
- **Type**: Lightweight, local development cluster
- **Architecture**: Control plane + kubelet on same node

### kind (Linux)
- **Default**: **Multi-node cluster** (1 control-plane + 2 worker nodes)
- **Type**: Containerized Kubernetes cluster
- **Architecture**: Separate control-plane and worker nodes

### k3d (Linux)
- **Default**: **Multi-node cluster** (1 server + N agents)
- **Type**: K3s distribution in Docker
- **Architecture**: Server (control-plane) + agents (workers)

---

## 🔍 Understanding Cluster Topology

### Single-Node Cluster (Rancher Desktop)

```
┌─────────────────────────────────────────┐
│        Single Virtual Machine            │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │      Kubernetes Node             │  │
│  │                                  │  │
│  │  ┌────────────────────────────┐ │  │
│  │  │  Control Plane Components  │ │  │
│  │  │ • API Server               │ │  │
│  │  │ • Scheduler                │ │  │
│  │  │ • Controller Manager       │ │  │
│  │  │ • etcd                     │ │  │
│  │  └────────────────────────────┘ │  │
│  │                                  │  │
│  │  ┌────────────────────────────┐ │  │
│  │  │  Kubelet & Container Runtime│ │  │
│  │  │  (Runs pods)               │ │  │
│  │  └────────────────────────────┘ │  │
│  │                                  │  │
│  └──────────────────────────────────┘  │
│                                          │
│  Status: Ready (control-plane,worker)   │
└─────────────────────────────────────────┘
```

**What this means**:
- ✅ **All Kubernetes components run on one node**
- ✅ Perfect for learning (simple, no network issues)
- ✅ Good for local testing and development
- ⚠️ No node failure resilience
- ⚠️ Resource-constrained (everything shares one VM)

**Verify on Rancher Desktop**:
```bash
kubectl get nodes
# Output:
# NAME                 STATUS   ROLES           AGE   VERSION
# rancher-desktop      Ready    control-plane   5m    v1.29.0
```

---

### Multi-Node Cluster (kind)

```
┌──────────────────────────────────────────────────────────────────┐
│                  Docker Network (virtual)                        │
│                                                                  │
│  ┌────────────────────────┐        ┌──────────────────────────┐ │
│  │  Control-Plane Node    │        │   Worker Node 1          │ │
│  │  (lab-control-plane)   │        │   (lab-worker)           │ │
│  │                        │        │                          │ │
│  │ • API Server           │        │ • Kubelet                │ │
│  │ • Scheduler            │        │ • Container Runtime      │ │
│  │ • Controller Manager   │        │ • Pod Runs Here          │ │
│  │ • etcd                 │        │                          │ │
│  └────────────────────────┘        └──────────────────────────┘ │
│           │                                   ▲                  │
│           │         API Communication         │                  │
│           └──────────────────────────────────┘                   │
│                                                                  │
│  ┌──────────────────────────┐                                   │
│  │   Worker Node 2          │                                   │
│  │   (lab-worker2)          │                                   │
│  │                          │                                   │
│  │ • Kubelet                │                                   │
│  │ • Container Runtime      │                                   │
│  │ • Pod Runs Here          │                                   │
│  └──────────────────────────┘                                   │
│           ▲                                                      │
│           │         API Communication                           │
│           └────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────────┘
```

**What this means**:
- ✅ **Separate control-plane and worker nodes**
- ✅ Teaches node affinity and distributed scheduling
- ✅ More realistic production-like architecture
- ✅ Better pod isolation and performance
- ⚠️ Slightly more complex to debug

**Verify on kind**:
```bash
kubectl get nodes
# Output:
# NAME                  STATUS   ROLES           AGE   VERSION
# lab-control-plane     Ready    control-plane   5m    v1.29.0
# lab-worker            Ready    <none>          4m    v1.29.0
# lab-worker2           Ready    <none>          4m    v1.29.0
```

---

## 🔧 How to Check Your Cluster Type

```bash
# See all nodes and their roles
kubectl get nodes -o wide

# Get detailed node info (check for control-plane label)
kubectl get nodes --show-labels

# See node details including roles
kubectl describe nodes | grep -E "Name:|Roles:"

# Check if this is a single-node cluster
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [ $NODE_COUNT -eq 1 ]; then
  echo "Single-node cluster"
else
  echo "Multi-node cluster ($NODE_COUNT nodes)"
fi
```

---

## 🎯 Which Setup to Use for Labs?

### For Learning Kubernetes Concepts
**Recommendation**: Either is fine, but here's what each teaches:

| Cluster Type | Best For | Learning Gap |
|-------------|----------|--------------|
| **Single-Node (Rancher)** | Beginners, quick learning | No node distribution, scheduling |
| **Multi-Node (kind)** | Intermediate+, production patterns | Node affinity, pod spread, scheduling |

### For Specific Labs

| Lab | Single-Node | Multi-Node | Recommendation |
|-----|-------------|-----------|-----------------|
| **1-4** | ✅ Perfect | ✅ Perfect | Either (concepts are the same) |
| **5** (Ingress) | ✅ OK | ✅ Better | Multi-node shows node distribution |
| **6** (Security) | ✅ Perfect | ✅ Perfect | Either |
| **7** (Autoscaling) | ⚠️ Limited testing | ✅ Better | Multi-node shows real scheduling |
| **8** (Multi-App) | ⚠️ Resource tight | ✅ Better | Multi-node distributes load |
| **9** (Chaos) | ⚠️ Limited chaos | ✅ Better | Multi-node shows node-level failures |

**Verdict**: Multi-node teaches better production patterns, but single-node works for fundamentals.

---

## 🚀 Switching Between Single and Multi-Node

### From Rancher (Single-Node) to kind (Multi-Node)

**Why switch?**
- Want to learn pod distribution across nodes
- Need to test node failure scenarios
- Want more realistic production patterns

**Steps**:
```bash
# 1. Stop Rancher Desktop
# macOS: Cmd+Q in Rancher Desktop GUI
# Windows: Exit from tray

# 2. Install kind and Docker
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/kind

# 3. Create multi-node cluster
cat <<'EOF' > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

kind create cluster --name lab --config kind-config.yaml

# 4. Verify
kubectl get nodes
# Should show: control-plane, worker, worker
```

### Back to Rancher (Single-Node) from kind

**Why switch back?**
- Rancher is easier to manage GUI
- Single-node simpler for beginners
- Better on resource-constrained machines

**Steps**:
```bash
# 1. Delete kind cluster
kind delete cluster --name lab

# 2. Start Rancher Desktop
# macOS: Open Rancher Desktop
# Windows: Start from tray

# 3. Verify
kubectl get nodes
# Should show: rancher-desktop (single node)
```

---

## 🏛️ Rancher Desktop Details: Behind the Scenes

### What Rancher Desktop Actually Is

Rancher Desktop is **not a real cluster**—it's a wrapper around:
- **Virtual Machine**: Lima or WSL 2 (lightweight Linux VM)
- **Container Runtime**: containerd or Docker
- **Kubernetes**: Bundled k3s distribution (lightweight K8s)

### Architecture

```
┌─────────────────────────────────────────────┐
│         Rancher Desktop GUI                 │
│   (Settings, status, resource management)   │
└────────────────┬────────────────────────────┘
                 │
┌─────────────────┼────────────────────────────────┐
│                 ▼                                │
│   ┌───────────────────────────────────────┐    │
│   │     Lima VM (macOS) or WSL2 (Windows) │    │
│   │                                       │    │
│   │  ┌─────────────────────────────────┐ │    │
│   │  │   k3s (lightweight Kubernetes) │ │    │
│   │  │                                 │ │    │
│   │  │ • Single node                   │ │    │
│   │  │ • Container runtime: containerd │ │    │
│   │  │ • Already has kubectl access    │ │    │
│   │  └─────────────────────────────────┘ │    │
│   └───────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘
```

### Key Facts

- ✅ **k3s is Kubernetes-compatible** - All labs work unchanged
- ✅ **Single node by default** - Perfect for learning basics
- ✅ **Low resource overhead** - ~2-4GB VM depending on settings
- ✅ **Persistent storage** - Local storage class included
- ⚠️ **Only 1 node** - Can't test multi-node scenarios

---

## 🔍 kind Details: Containerized Clusters

### What kind Actually Is

kind = **K**ubernetes **in** **D**ocker

- Uses Docker containers to simulate Kubernetes nodes
- Each "node" is actually a Docker container
- Nodes communicate via Docker network

### Architecture

```
┌──────────────────────────────────────────────┐
│          Docker Daemon                       │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │   lab-control-plane (Container)        │ │
│  │   • Runs kubeadm-bootstrapped cluster │ │
│  │   • Contains real Kubernetes API       │ │
│  │   • Port: 6443 → host 6443            │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │   lab-worker (Container)               │ │
│  │   • Real kubelet                       │ │
│  │   • Can run pods                       │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │   lab-worker2 (Container)              │ │
│  │   • Real kubelet                       │ │
│  │   • Can run pods                       │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  (All communicate via Docker network)       │
└──────────────────────────────────────────────┘
```

### Key Facts

- ✅ **Real Kubernetes** - Not a simulation, actual kubeadm cluster
- ✅ **Multi-node out of the box** - Control-plane + workers
- ✅ **Fast cluster creation** - Seconds to spin up
- ✅ **Disposable** - Easy to create/delete for testing
- ✅ **Great for CI/CD** - Used by many open-source projects
- ⚠️ **Linux-native** - Works best on Linux (requires Docker Desktop on Mac/Windows)

---

## 📋 Quick Reference: Which Setup Am I Using?

```bash
# Rancher Desktop?
kubectl config current-context
# Output: rancher-desktop

# kind?
kubectl config current-context
# Output: kind-lab

# Check cluster info
kubectl cluster-info
# Rancher: Uses local API
# kind: Shows kind cluster info
```

---

## 🎓 Learning Implications

### Single-Node (Rancher Desktop)

What you **CAN'T** learn:
- ❌ Pod scheduling across multiple nodes
- ❌ Node affinity and pod anti-affinity
- ❌ Node failure scenarios
- ❌ Distributed storage patterns

What you **CAN** learn:
- ✅ All Kubernetes basics (pods, deployments, services)
- ✅ Stateful applications
- ✅ Networking and ingress
- ✅ RBAC and security
- ✅ Autoscaling (simulated on single node)

### Multi-Node (kind)

What you **CAN** learn (everything above +):
- ✅ Pod scheduling and distribution
- ✅ Node affinity patterns
- ✅ Node failure resilience
- ✅ Real-world cluster operations
- ✅ Performance under load

**Recommendation**: Start with single-node (Rancher) for Labs 1-4, switch to kind for Labs 5+ if you want production-realistic learning.

---

## 🔗 Related Documentation

- 📖 [Rancher Desktop Setup](./rancher-desktop.md)
- 🐧 [Linux kind/k3d Setup](./linux-kind-k3d.md)
- 💾 [Resource Requirements Guide](../30-reference/deep-dives/resource-requirements.md)
- ✅ [Getting Started Guide](../00-introduction/GETTING-STARTED.md)

---

**Last updated**: October 21, 2025  
**Cluster architectures covered**: Rancher Desktop (single-node), kind (multi-node), k3d (multi-node)
