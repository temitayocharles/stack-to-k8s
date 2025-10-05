# Lab 2 · E-commerce Multi-Service Overlay

Complete Kubernetes manifests for the e-commerce application lab featuring
Postgres database, Node.js backend API, and Vue.js frontend.

## What's Included

- **Namespace** – isolated `ecommerce-lab` environment
- **ConfigMap** – shared configuration for database connection and API URLs
- **Secret** – Postgres credentials
- **Postgres** – database deployment + service
- **Backend** – Node.js API with health checks (2 replicas)
- **Frontend** – Vue.js SPA exposed via LoadBalancer

All container images pin to stable versions and get retagged to `:latest` at
apply-time via kustomize.

## Usage

```bash
kubectl apply -k labs/manifests/lab-02
```

Verify deployment:

```bash
./scripts/validate-lab.sh 2
```

Clean up:

```bash
kubectl delete namespace ecommerce-lab
```

## Customization

- Adjust replica counts in `backend.yaml` and `frontend.yaml`
- Override ConfigMap values for different environments
- Change service type from LoadBalancer to NodePort if needed For now, use the manifests under `ecommerce-app/k8s` as you
follow the lab instructions. The curated overlay will be added in an upcoming
update.
