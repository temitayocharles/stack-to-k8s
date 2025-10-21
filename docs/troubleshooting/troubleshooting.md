# Troubleshooting Guide

Quick fixes for common issues encountered in the labs.

## Local Kubernetes Runtime Issues

### Kubernetes Engine Not Starting
- **Rancher Desktop (Windows/macOS)** → Toggle Kubernetes off/on from **Settings ▸ Kubernetes**, then restart the app.
- **Other runtimes** → Restart the service or reboot the host.

### Resetting the Cluster
- **Rancher Desktop** → `kubectl config use-context rancher-desktop` then use **Settings ▸ Kubernetes ▸ Reset Kubernetes** inside the app.
- **Kind / other CLIs** → Recreate the cluster (e.g., `kind delete cluster && kind create cluster`).

### Disk Space Full
```bash
# Docker-compatible runtimes (Docker Desktop, Rancher Desktop with moby)
docker system prune -a
docker volume prune

# Containerd-based runtimes (Rancher Desktop with nerdctl)
nerdctl system prune
nerdctl volume prune
```

## kubectl Issues

### Command Not Found
```bash
# macOS
brew install kubectl

# Verify
kubectl version --client
```

### Can't Connect to Cluster
```bash
kubectl config get-contexts
# Choose the context that matches your runtime
kubectl config use-context rancher-desktop   # Windows/macOS Rancher Desktop
kubectl config use-context kind-kind         # Example for other local clusters
```

## Image Pull Issues

### ImagePullBackOff
```bash
# Check image name is correct
kubectl describe pod <pod-name>

# For local images, ensure imagePullPolicy: Never
```

### Wrong Architecture
```bash
# Use multi-arch images or build for your platform
docker build --platform linux/amd64 -t <image> .
```

## Pod Issues

### CrashLoopBackOff
```bash
# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# Common causes:
# - Application error
# - Missing environment variables
# - Wrong command/args
```

### Pending Pods
```bash
# Check events
kubectl describe pod <pod-name>

# Common causes:
# - Insufficient resources
# - No matching node
# - PVC not bound
```

## Service Issues

### Can't Access Service
```bash
# Check service exists
kubectl get services

# Check endpoints
kubectl get endpoints <service-name>

# Port forward to test
kubectl port-forward service/<name> 8080:80
```

### Wrong Port
```bash
# Check service definition
kubectl describe service <service-name>

# Verify targetPort matches container port
```

## PersistentVolume Issues

### PVC Pending
```bash
# Check PVC status
kubectl get pvc

# Check storage class
kubectl get storageclass

# For local testing, use hostPath or local-path
```

## Cleanup Issues

### Namespace Stuck Deleting
```bash
# Force delete
kubectl delete namespace <name> --grace-period=0 --force
```

### Resources Won't Delete
```bash
# Check finalizers
kubectl get <resource> <name> -o yaml

# Remove finalizers if stuck
kubectl patch <resource> <name> -p '{"metadata":{"finalizers":null}}'
```

## General Tips

### Start Fresh
```bash
# Delete namespace and recreate
kubectl delete namespace <name>
kubectl create namespace <name>
```

### Check Everything
```bash
# Pods
kubectl get pods -A

# Services
kubectl get services -A

# Events
kubectl get events -A --sort-by='.lastTimestamp'
```

### Resource Limits
```bash
# If pods are evicted or OOMKilled
# Increase memory/CPU limits in deployment YAML
```
