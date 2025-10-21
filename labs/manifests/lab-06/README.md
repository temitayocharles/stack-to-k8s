# Lab 6 · Social Media Autoscaling Overlay

Manifests with **HorizontalPodAutoscaler** configuration for automatic scaling
based on CPU/memory utilization.

## Usage

```bash
# Ensure metrics-server is installed
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl apply -k labs/manifests/lab-06
./scripts/validate-lab.sh 6
```

Watch HPA in action:

```bash
kubectl get hpa -n social-lab --watch
```

Clean up:

```bash
kubectl delete namespace social-lab
```
