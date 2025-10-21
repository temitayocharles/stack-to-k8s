# Lab 3 · Educational Platform StatefulSet Overlay

Complete manifests for the educational platform featuring a **StatefulSet** for
Postgres with persistent storage, plus Node.js backend and React frontend.

## What's Included

- **Namespace** – isolated `educational-lab` environment
- **Secret** – Postgres credentials
- **StatefulSet** – stateful Postgres database with volumeClaimTemplate
- **PVC** – persistent volume claim for database data
- **Backend** – Node.js API (2 replicas)
- **Frontend** – React SPA exposed via LoadBalancer

The StatefulSet ensures stable network identity and persistent storage across
pod restarts.

## Usage

```bash
kubectl apply -k labs/manifests/lab-03
```

Verify deployment:

```bash
./scripts/validate-lab.sh 3
```

Inspect persistent volume:

```bash
kubectl get pvc -n educational-lab
kubectl describe pvc postgres-data-postgres-0 -n educational-lab
```

Clean up:

```bash
kubectl delete namespace educational-lab
# Note: PVC will be deleted but PV may require manual cleanup depending on storage class
```
