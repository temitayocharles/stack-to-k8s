# Lab 9 · Helm Package Management Overlay

Lab 9 focuses on Helm chart creation and management. No kustomize overlay is
needed—follow the lab instructions to:

1. Install Bitnami PostgreSQL chart:
   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm install my-postgres bitnami/postgresql -n helm-demo --create-namespace
   ```

2. Create a custom chart:
   ```bash
   helm create my-weather-app
   # Edit templates and values per lab guide
   helm install weather-release ./my-weather-app -n helm-demo
   ```

3. Verify:
   ```bash
   ./scripts/validate-lab.sh 9
   ```

Clean up:
```bash
helm uninstall my-postgres weather-release -n helm-demo
kubectl delete namespace helm-demo
```
