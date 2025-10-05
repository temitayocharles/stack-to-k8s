# Lab 11 · External Secrets Overlay

Lab 11 requires External Secrets Operator and cloud credentials. No kustomize
overlay—follow these steps:

1. Install ESO:
   ```bash
   helm repo add external-secrets https://charts.external-secrets.io
   helm install external-secrets external-secrets/external-secrets \
     -n external-secrets-system --create-namespace --set installCRDs=true
   ```

2. Configure AWS credentials and create SecretStore/ExternalSecret resources per
   lab guide

3. Verify:
   ```bash
   ./scripts/validate-lab.sh 11
   ```

Clean up:
```bash
helm uninstall external-secrets -n external-secrets-system
kubectl delete namespace external-secrets-system ecommerce
```
