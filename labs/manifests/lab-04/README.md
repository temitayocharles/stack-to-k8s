# Lab 4 · Task Manager Ingress Overlay

Complete manifests for the task manager application featuring MongoDB, Node.js
backend, Angular frontend, and an **Ingress resource** for unified routing.

## What's Included

- **Namespace** – isolated `task-lab` environment
- **Secret** – MongoDB credentials
- **MongoDB** – database deployment + service
- **Backend** – Node.js API (2 replicas)
- **Frontend** – Angular SPA
- **Ingress** – NGINX ingress routing `/` → frontend, `/api` → backend

## Prerequisites

Ensure you have an Ingress controller installed (e.g., NGINX):

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

## Usage

```bash
kubectl apply -k labs/manifests/lab-04
```

Test ingress (add to /etc/hosts if needed):

```bash
echo "127.0.0.1 task.local" | sudo tee -a /etc/hosts
curl http://task.local
```

Verify:

```bash
./scripts/validate-lab.sh 4
```

Clean up:

```bash
kubectl delete namespace task-lab
```
