# Resource Requirements Guide 💻

Quick reference for CPU, memory, and storage requirements across all labs. Use this to plan your local cluster setup and troubleshoot resource constraints.

---

## 📊 Minimum System Requirements

### Host Machine
- **CPU**: 4 cores (8 threads recommended)
- **RAM**: 8GB (16GB recommended)
- **Disk**: 50GB free space
- **Network**: Stable internet for image pulls

### Kubernetes Cluster
- **CPU**: 2 cores allocated to k8s
- **RAM**: 4GB allocated to k8s
- **Storage**: Local storage class available

---

## 🎯 Lab-by-Lab Requirements

### Foundation Labs (1-4)
| Lab | Apps | CPU | Memory | Storage | Notes |
|-----|------|-----|---------|---------|-------|
| **Lab 1** | Weather App | 0.5 cores | 512MB | 1GB | Single app, minimal resources |
| **Lab 2** | E-commerce | 1 core | 1GB | 2GB | Frontend + Backend + MongoDB |
| **Lab 3** | Educational | 1.5 cores | 1.5GB | 5GB | StatefulSet + PostgreSQL |
| **Lab 4** | Fundamentals | 0.2 cores | 256MB | 0.5GB | Testing/troubleshooting scenarios |

### Production Ops Labs (5-7)
| Lab | Apps | CPU | Memory | Storage | Notes |
|-----|------|-----|---------|---------|-------|
| **Lab 5** | Task Manager | 1 core | 1GB | 3GB | Ingress controller overhead |
| **Lab 6** | Medical System | 1.5 cores | 2GB | 4GB | Security policies, RBAC |
| **Lab 7** | Social Media | 2 cores | 3GB | 6GB | HPA testing, multiple replicas |

### Platform Engineering Labs (8-13)
| Lab | Apps | CPU | Memory | Storage | Notes |
|-----|------|-----|---------|---------|-------|
| **Lab 8** | Multi-App | 3 cores | 4GB | 15GB | All 6 apps + monitoring stack |
| **Lab 9** | Chaos Engineering | 2 cores | 2.5GB | 8GB | Chaos Mesh + apps for testing |
| **Lab 10** | Helm | 1.5 cores | 2GB | 5GB | Chart installation + templating |
| **Lab 11** | GitOps | 2 cores | 3GB | 8GB | ArgoCD + multi-env deployments |
| **Lab 12** | External Secrets | 1.5 cores | 2GB | 4GB | Secret operators + integrations |
| **Lab 13** | AI/ML | 4 cores | 6GB | 10GB | GPU workloads, ML pipelines |

---

## 🚦 Resource Planning Scripts

### Check Available Resources
```bash
# View cluster capacity
kubectl top nodes
kubectl describe nodes

# Check resource usage by namespace
kubectl top pods -A
kubectl top pods -n <namespace>
```

### Calculate Lab Requirements
```bash
# Use the provided calculator
./scripts/calculate-lab-resources.sh 1 2 3

# Manual calculation for Labs 1-3
echo "Total CPU: 3 cores, Memory: 3GB, Storage: 8GB"
```

### Monitor During Labs
```bash
# Real-time resource monitoring
watch kubectl top nodes
watch kubectl top pods -A

# Check for resource constraints
kubectl get events -A | grep -i "insufficient\|evicted\|oom"
```

---

## ⚠️ Common Resource Issues

### Pod Evictions
**Symptom**: Pods randomly restart or get evicted
```bash
# Check events for evictions
kubectl get events -A | grep Evicted

# Solution: Increase memory limits
resources:
  limits:
    memory: "1Gi"    # Increase this
  requests:
    memory: "512Mi"  # And this
```

### Pending Pods
**Symptom**: Pods stuck in Pending state
```bash
# Check why pods can't be scheduled
kubectl describe pod <pod-name>

# Common causes:
# - Insufficient CPU/memory
# - No available nodes
# - PVC not bound
```

### OOMKilled
**Symptom**: Containers killed due to out-of-memory
```bash
# Check container restart reasons
kubectl describe pod <pod-name>

# Look for: "Reason: OOMKilled"
# Solution: Increase memory limits
```

---

## 🔧 Optimization Tips

### For Limited Resources
1. **Run labs sequentially** - Don't keep all apps running
2. **Use cleanup scripts** - `./scripts/cleanup-workspace.sh`
3. **Adjust resource requests** - Lower for development
4. **Monitor continuously** - Use `k9s` for real-time monitoring

### For Production Simulation
1. **Use recommended specs** - Don't lower limits
2. **Enable resource quotas** - Test real constraints
3. **Run stress tests** - Validate under load
4. **Monitor metrics** - Set up Prometheus + Grafana

---

## 📈 Scaling Considerations

### Horizontal Pod Autoscaler (HPA)
- **Minimum resources**: CPU requests must be set
- **Metrics server**: Required for CPU/memory metrics
- **Scale up/down**: Based on utilization thresholds

### Vertical Pod Autoscaler (VPA)
- **Right-sizing**: Automatically adjusts requests/limits
- **Resource recommendations**: Based on actual usage
- **Updates**: Requires pod restart

### Cluster Autoscaler
- **Node scaling**: Automatically adds/removes nodes
- **Cloud provider**: Required for managed clusters
- **Resource optimization**: Balances cost vs performance

---

## 🎯 Quick Reference

### Essential Commands
```bash
# Check cluster resources
kubectl top nodes
kubectl describe nodes

# Monitor pod resources
kubectl top pods -A
kubectl get pods -A -o wide

# Calculate requirements
./scripts/calculate-lab-resources.sh <lab-numbers>

# Clean up resources
./scripts/cleanup-workspace.sh
```

### Emergency Resource Recovery
```bash
# If cluster becomes unresponsive
kubectl delete pods --all -n <namespace>
docker system prune -f
kubectl get pods -A | grep Evicted | awk '{print $1, $2}' | xargs -n2 kubectl delete pod -n

# Restart cluster (kind/k3d)
kind delete cluster && kind create cluster
```

---

**💡 Pro Tip**: Always run `./scripts/check-lab-prereqs.sh <lab-number>` before starting a lab to verify you have sufficient resources.

Related: [kubectl Cheatsheet](kubectl-cheatsheet.md) · [Decision Trees](decision-trees.md) · [Troubleshooting Guide](../troubleshooting/troubleshooting.md)