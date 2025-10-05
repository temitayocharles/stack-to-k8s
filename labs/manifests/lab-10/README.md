# Lab 10 · GitOps ArgoCD Overlay

Lab 10 requires ArgoCD installation and Git repository setup. No kustomize
overlay—follow these steps:

1. Install ArgoCD:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. Access UI:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   # Get password:
   kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
   ```

3. Create Application manifests in your Git repo per lab guide

4. Verify:
   ```bash
   ./scripts/validate-lab.sh 10
   ```

Clean up:
```bash
kubectl delete namespace argocd
```
