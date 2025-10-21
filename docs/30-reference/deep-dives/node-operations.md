---
title: "Production Node Operations Guide"
level: "intermediate-to-advanced"
type: "deep-dive"
prerequisites: ["Lab 4: Fundamentals", "Understanding of Kubernetes nodes"]
topics: ["Node Drain", "Node Cordon", "Node Upgrades", "Node Maintenance", "Pod Disruption Budgets"]
estimated_time: "40-50 minutes"
updated: "2025-10-21"
nav_prev: "./database-operations.md"
nav_next: "./storage-operations.md"
---

# 🖥️ Production Node Operations: Maintenance, Upgrades & Repairs

Managing Kubernetes nodes in production requires careful orchestration to maintain availability while performing maintenance. This guide covers critical node operations every SRE needs.

---

## 📋 Quick Navigation

- [Understanding Node States](#understanding-node-states)
- [Cordoning Nodes](#cordoning-nodes-marking-unavailable)
- [Draining Nodes](#draining-nodes-graceful-evacuation)
- [Node Upgrades](#node-upgrades-in-place-updates)
- [Maintenance Windows](#maintenance-windows-planning)
- [Pod Disruption Budgets (PDBs)](#pod-disruption-budgets-protecting-availability)
- [Emergency Procedures](#emergency-procedures)

---

## 🔍 Understanding Node States

### Node Conditions

```bash
# View node status
kubectl describe node <node-name>

# Look for:
# - Ready: Node is healthy and can accept pods
# - DiskPressure: Node disk is full
# - MemoryPressure: Node memory is low
# - PIDPressure: Too many processes
# - NetworkUnavailable: Network not ready
```

### Example Output:
```
Name: worker-1
Status: Ready
Conditions:
  Type                 Status  LastHeartbeatTime          LastTransitionTime
  Ready                True    2025-10-21T15:30:00Z       2025-10-21T10:00:00Z
  MemoryPressure       False   2025-10-21T15:30:00Z       2025-10-21T10:00:00Z
  DiskPressure         False   2025-10-21T15:30:00Z       2025-10-21T10:00:00Z
  PIDPressure          False   2025-10-21T15:30:00Z       2025-10-21T10:00:00Z
  NetworkUnavailable   False   2025-10-21T15:30:00Z       2025-10-21T10:00:00Z
```

---

## 🚫 Cordoning Nodes: Marking Unavailable

**Cordon** marks a node as unavailable for NEW pod scheduling, but allows existing pods to keep running.

### When to Cordon

- Quick maintenance expected to finish soon
- Testing without removing workloads
- Temporary capacity reduction

### Cordon a Node

```bash
# Mark node as unschedulable
kubectl cordon <node-name>

# Verify it's cordoned
kubectl get nodes
# STATUS will show "Ready,SchedulingDisabled"

# Remove cordon when ready
kubectl uncordon <node-name>
```

### Example Workflow

```bash
# Before maintenance
kubectl cordon worker-2
kubectl get nodes
# NAME       STATUS                     ROLES   AGE
# worker-1   Ready                      <none>  30d
# worker-2   Ready,SchedulingDisabled   <none>  30d

# Perform maintenance (updates, patches, etc.)
# ...

# Resume scheduling
kubectl uncordon worker-2
```

**Key Point**: Cordon does NOT remove running pods. Use drain for that.

---

## 💨 Draining Nodes: Graceful Evacuation

**Drain** cordons a node AND gracefully evicts all pods, allowing them to reschedule on other nodes.

### When to Drain

- Upgrading node OS/kubelet
- Replacing failed hardware
- Scaling down cluster
- Network maintenance

### Drain a Node

```bash
# Gracefully drain (wait for pods to move)
kubectl drain <node-name> \
  --ignore-daemonsets \
  --delete-emptydir-data

# --ignore-daemonsets: Don't evict DaemonSet pods (they restart anyway)
# --delete-emptydir-data: Remove pods with emptyDir volumes
```

### Drain with Timeout

```bash
# Set timeout to prevent hanging
kubectl drain <node-name> \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --timeout=5m \
  --grace-period=30

# --grace-period: Wait 30s for pods to shut down gracefully
# --timeout: Max wait time for entire drain operation
```

### Force Drain (Use with Caution!)

```bash
# Skip PodDisruptionBudgets check (may cause downtime!)
kubectl drain <node-name> \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force

# Only use if you know what you're doing!
```

### Example: Full Node Lifecycle

```bash
# 1. Before upgrade
kubectl get nodes
# worker-1: Ready, 50 pods running

# 2. Cordon + Drain
kubectl drain worker-1 \
  --ignore-daemonsets \
  --delete-emptydir-data

# Pods evicted:
# - StatefulSet pods → rescheduled to worker-2 and worker-3
# - Deployment pods → rescheduled
# - DaemonSet pods → killed but kubelet respawns them immediately
# - Pods with PDB → respected (won't evict if would violate PDB)

# 3. Upgrade kubelet
ssh worker-1
sudo apt-get upgrade kubelet kubernetes-cni
sudo systemctl restart kubelet
ssh exit

# 4. Verify node is healthy
kubectl describe node worker-1
# Should show Ready again

# 5. Resume scheduling
kubectl uncordon worker-1

# 6. Verify pods are back
kubectl get pods -o wide | grep worker-1
# Pods gradually rescheduled back
```

---

## 🔄 Node Upgrades: In-Place Updates

### Rolling Upgrade Strategy

```bash
#!/bin/bash
# upgrade-nodes.sh - Safe rolling node upgrade

set -e

NODES=$(kubectl get nodes -o name | cut -d'/' -f2)
UPGRADE_FAILED=0

for NODE in $NODES; do
  echo "🔄 Upgrading $NODE..."
  
  # 1. Cordon
  kubectl cordon "$NODE"
  
  # 2. Drain gracefully
  if ! kubectl drain "$NODE" \
    --ignore-daemonsets \
    --delete-emptydir-data \
    --timeout=10m; then
    echo "❌ Drain failed for $NODE"
    UPGRADE_FAILED=$((UPGRADE_FAILED + 1))
    continue
  fi
  
  # 3. SSH to node and upgrade
  echo "Upgrading kubelet on $NODE..."
  ssh "node@$NODE" << 'EOF'
    sudo apt-get update
    sudo apt-get install -y --only-upgrade kubelet kubernetes-cni
    sudo systemctl restart kubelet
    sleep 30  # Wait for kubelet to restart
EOF
  
  # 4. Wait for node to be healthy again
  echo "Waiting for $NODE to become Ready..."
  for i in {1..60}; do
    if kubectl get node "$NODE" | grep -q "Ready"; then
      echo "✅ $NODE is Ready"
      break
    fi
    sleep 10
  done
  
  # 5. Uncordon
  kubectl uncordon "$NODE"
  
  # 6. Wait for pods to reschedule
  sleep 30
done

if [ $UPGRADE_FAILED -eq 0 ]; then
  echo "✅ All nodes upgraded successfully"
else
  echo "❌ $UPGRADE_FAILED nodes failed to upgrade"
  exit 1
fi
```

### Safe Upgrade Process

```bash
# Upgrade strategy for production:

# 1. Backup etcd (if you value your data!)
kubectl exec -it -n kube-system etcd-control-plane -- \
  etcdctl snapshot save /tmp/etcd-backup.db

# 2. Upgrade control plane nodes first
for CONTROL_PLANE in control-1 control-2 control-3; do
  kubectl drain "$CONTROL_PLANE" --ignore-daemonsets
  # Perform upgrade
  kubectl uncordon "$CONTROL_PLANE"
  sleep 60  # Wait for API server to come back
done

# 3. Upgrade worker nodes in batches
for WORKER in worker-1 worker-2 worker-3 worker-4; do
  kubectl drain "$WORKER" --ignore-daemonsets --delete-emptydir-data
  # Perform upgrade
  kubectl uncordon "$WORKER"
  sleep 30  # Wait for pod rescheduling
done
```

---

## 📅 Maintenance Windows: Planning

### Notification Strategy

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: maintenance-schedule
  namespace: kube-system
data:
  schedule.txt: |
    Maintenance Window: Tuesdays 2-4 AM UTC
    - OS security patches
    - Kubelet updates
    - Node hardware repairs
    
    Expected impact:
    - Temporary pod rescheduling
    - No service downtime (if PDBs configured)
    - 30 second latency spike during cordon
```

### Communication Checklist

- [ ] Announce maintenance 1 week in advance
- [ ] Send reminder 1 day before
- [ ] Notify SLAs may be affected
- [ ] Have runbook ready
- [ ] Have rollback plan ready
- [ ] Post-maintenance report to team

---

## 🛡️ Pod Disruption Budgets: Protecting Availability

**PDB** ensures minimum availability during node maintenance.

### Why PDBs Matter

```bash
# Without PDB: Drain might evict all pods of an app
# With PDB: Drain respects minimum availability

# Example: 3 replicas
# - Without PDB: All 3 might be evicted at once (downtime!)
# - With PDB (minAvailable=2): Only 1 can be evicted (safe)
```

### Setting Up PDBs

**PDB: Minimum Available**

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb-min-available
spec:
  minAvailable: 2  # Keep at least 2 pods running
  selector:
    matchLabels:
      app: my-app
```

**PDB: Maximum Unavailable**

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb-max-unavailable
spec:
  maxUnavailable: 1  # Evict at most 1 pod at a time
  selector:
    matchLabels:
      app: my-app
```

**PDB with Percentage**

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb-percentage
spec:
  minAvailable: "50%"  # Keep 50% of pods running
  selector:
    matchLabels:
      app: my-app
```

### PDB Examples by Workload Type

| Workload | PDB Config | Reasoning |
|----------|-----------|-----------|
| Web Frontend (3 replicas) | `minAvailable: 2` | Need 2+ to serve users |
| Cache Layer (5 replicas) | `maxUnavailable: 2` | Tolerate 2 concurrent evictions |
| Background Job (10 replicas) | `minAvailable: "30%"` | Job throughput degrades gracefully |
| Single Replica (1 pod) | None needed | Already handles downtime |
| Critical Service (5 replicas) | `minAvailable: 3` | Strict availability requirement |

### Verifying PDB Respected

```bash
# Check what drain would do
kubectl drain <node-name> --dry-run=client

# Eviction will respect PDBs if configured
# If you see "error: cannot drain node as there are daemonset managed pods"
# that's expected (use --ignore-daemonsets)

# If you see "error: disruption budget" 
# then PDB is preventing eviction (which is good!)
```

---

## 🚨 Emergency Procedures

### Scenario 1: Node is Unresponsive

```bash
# Check node status
kubectl describe node <node-name>
# Look for "NotReady" status

# If node is unresponsive but kubelet can't evict pods:
# Force delete pods (they'll restart on other nodes)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Or delete all pods on node at once:
kubectl get pods -o wide | grep <node-name> | awk '{print $1,$2}' | \
  xargs -n2 bash -c 'kubectl delete pod $0 -n $1 --force --grace-period=0'
```

### Scenario 2: Node Has Memory Leak

```bash
# Monitor memory growth
kubectl top node <node-name>
# If memory keeps increasing despite no new pods:

# Option 1: Restart kubelet
ssh <node-ip>
sudo systemctl restart kubelet
# Monitor: kubectl top node <node-name>

# Option 2: Full node restart (if available)
ssh <node-ip>
sudo reboot
# Nodes will rejoin cluster automatically
```

### Scenario 3: Network Issues

```bash
# Node shows "NotReady,NetworkUnavailable"
# Check network plugin:
kubectl get daemonset -n kube-system
# Look for CNI daemon (flannel, calico, weave, etc.)

# Restart CNI plugin
kubectl delete pod -n kube-system -l k8s-app=calico-node

# Monitor nodes:
kubectl get nodes
# Should show Ready again in ~60s
```

### Scenario 4: Disk Full

```bash
# Check disk usage
df -h

# If full, find what's using space:
du -sh /var/lib/kubelet/*  # Check pod volumes
du -sh /var/lib/docker/*   # Check image cache

# Clean up:
# - Delete unused pods
# - Prune docker images: docker image prune -a
# - Expand disk (cloud provider specific)

# In Kubernetes:
kubectl delete pod --all --grace-period=0 -n <namespace>  # Last resort!
```

---

## 📊 Node Maintenance Runbook

```markdown
## Node Maintenance Runbook

### Before Starting
- [ ] Notify team (chat/email)
- [ ] Check current pod distribution
- [ ] Verify PDBs are in place
- [ ] Have fallback plan

### During Maintenance

1. **Identify the node**
   ```bash
   NODE=worker-1
   kubectl get nodes | grep $NODE
   ```

2. **Cordon the node**
   ```bash
   kubectl cordon $NODE
   kubectl get nodes  # Verify SchedulingDisabled
   ```

3. **Drain the node**
   ```bash
   kubectl drain $NODE --ignore-daemonsets --delete-emptydir-data --timeout=10m
   kubectl get pods -o wide | grep -v $NODE  # Verify pods moved
   ```

4. **Perform maintenance**
   ```bash
   ssh node@$NODE
   # ... do your work ...
   exit
   ```

5. **Verify node is healthy**
   ```bash
   kubectl describe node $NODE
   # Should show: Ready True
   ```

6. **Uncordon the node**
   ```bash
   kubectl uncordon $NODE
   ```

7. **Monitor pod rescheduling**
   ```bash
   kubectl get pods -o wide | grep $NODE  # Monitor progress
   ```

8. **Verify services are up**
   ```bash
   kubectl get svc
   kubectl get endpoints  # Check endpoints are repopulated
   ```

9. **Post-maintenance**
   - [ ] Verify no pod restart storms
   - [ ] Check application logs for errors
   - [ ] Notify team maintenance is complete
   - [ ] Document any issues

### Rollback (if something went wrong)
```bash
# Immediately uncordon to resume scheduling
kubectl uncordon $NODE
```

### Metrics to Monitor
- Pod count per node
- Resource utilization (CPU/memory)
- Network latency
- Application error rates
```

---

## 📚 Related Resources

- [Lab 4: Kubernetes Fundamentals](../../labs/04-kubernetes-fundamentals.md) — Node basics
- [Lab 7: Scaling](../../labs/07-social-scaling.md) — HPA and cluster scaling
- [Storage Operations](./storage-operations.md) — Data persistence during node operations
- [Disaster Recovery](../../labs/11.5-disaster-recovery.md) — Complete failure scenarios

---

**Questions?** [Open an issue](https://github.com/temitayocharles/stack-to-k8s/issues) or check the [Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md).

