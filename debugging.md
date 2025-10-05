# Kubernetes Debugging Guide

Common debugging techniques for Kubernetes issues.

## Pod Not Starting

### Check Pod Status
```bash
kubectl get pods
kubectl describe pod <pod-name>
```

**Look for:**
- ImagePullBackOff: Wrong image name or no access
- CrashLoopBackOff: Application crashes on start
- Pending: Resource constraints or scheduling issues

### Check Logs
```bash
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous crashed container
```

## Service Connection Issues

### Check Service
```bash
kubectl get services
kubectl describe service <service-name>
```

### Test DNS
```bash
kubectl run test --image=busybox -it --rm -- nslookup <service-name>
```

### Check Endpoints
```bash
kubectl get endpoints <service-name>
```

## Resource Issues

### Check Resource Usage
```bash
kubectl top nodes
kubectl top pods
```

### Check Events
```bash
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

## Common Fixes

### Restart Deployment
```bash
kubectl rollout restart deployment <name>
```

### Force Delete Pod
```bash
kubectl delete pod <name> --force --grace-period=0
```

### Clean and Retry
```bash
kubectl delete -f <file.yaml>
kubectl apply -f <file.yaml>
```

## Debugging Inside Pod
```bash
kubectl exec -it <pod-name> -- /bin/sh
kubectl exec -it <pod-name> -- /bin/bash
```

## Network Debugging
```bash
# Test connectivity
kubectl run netshoot --image=nicolaka/netshoot -it --rm -- bash

# Inside netshoot pod:
curl <service-name>:port
ping <service-name>
nslookup <service-name>
```
