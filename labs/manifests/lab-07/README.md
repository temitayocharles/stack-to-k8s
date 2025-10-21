# Lab 7 · Multi-App Orchestration Overlay

Lab 7 orchestrates all six applications in the `platform` namespace with shared
monitoring. Given its complexity, leverage the application-specific manifests
from each app's `k8s/` directory.

## Quick Deploy Strategy

```bash
kubectl create namespace platform

# Deploy each app with namespace override
for app in weather-app ecommerce-app educational-platform task-management-app medical-care-system social-media-platform; do
  kubectl apply -f $app/k8s/ -n platform
done

# Verify
./scripts/validate-lab.sh 7
```

## Monitoring Stack

Install Prometheus + Grafana:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Clean up:

```bash
kubectl delete namespace platform monitoring
```
