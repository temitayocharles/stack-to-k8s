# Lab 5 · Medical Security Overlay

Complete security-hardened manifests featuring **RBAC**, **NetworkPolicies**,
and **SecurityContext** configurations for a medical records application.

## What's Included

- **Namespace** – isolated `medical-lab` environment
- **Secrets** – Postgres credentials + API JWT/encryption keys
- **ServiceAccount** – dedicated identity for medical-api
- **RBAC** – Role + RoleBinding restricting secret access
- **NetworkPolicies**:
  - `default-deny-all` – block all traffic by default
  - `allow-api-to-db` – permit API → Postgres
  - `allow-frontend-to-api` – permit frontend → API
  - `allow-dns-egress` – permit DNS resolution
- **Deployments** – Postgres, API (with securityContext), frontend
- **Services** – ClusterIP for internal, LoadBalancer for frontend

## Usage

```bash
kubectl apply -k labs/manifests/lab-05
```

Test network isolation:

```bash
# Should succeed (frontend → API)
kubectl exec -n medical-lab deploy/medical-frontend -- wget -qO- http://medical-api:5000/api/health

# Should fail (blocked by NetworkPolicy)
kubectl run -n medical-lab test-pod --image=busybox:latest --rm -it -- wget -qO- http://postgres:5432
```

Verify:

```bash
./scripts/validate-lab.sh 5
```

Clean up:

```bash
kubectl delete namespace medical-lab
```
