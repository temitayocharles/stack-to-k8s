# kubectl Cheatsheet

Quick reference for common kubectl commands used in labs.

## Cluster Info
```bash
kubectl cluster-info
kubectl get nodes
kubectl version
```

## Pods
```bash
kubectl get pods
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> -f
kubectl delete pod <pod-name>
```

## Deployments
```bash
kubectl get deployments
kubectl describe deployment <name>
kubectl scale deployment <name> --replicas=3
kubectl rollout status deployment <name>
kubectl rollout restart deployment <name>
kubectl delete deployment <name>
```

## Services
```bash
kubectl get services
kubectl describe service <name>
kubectl delete service <name>
```

## Namespaces

> 💡 **Best Practice**: Always use `-n <namespace>` (or `--namespace=<namespace>`) to avoid accidental operations on the `default` namespace. This keeps workloads isolated and makes cleanup predictable.

```bash
# List all namespaces
kubectl get namespaces

# Create a namespace
kubectl create namespace <name>

# Query resources in a specific namespace
kubectl get pods -n <namespace>
kubectl get all -n <namespace>
kubectl describe deployment <name> -n <namespace>

# Set a default namespace for your current context (optional)
kubectl config set-context --current --namespace=<namespace>
kubectl config view --minify | grep namespace  # verify

# Delete a namespace (removes all resources inside)
kubectl delete namespace <name>
```

### Lab-Specific Namespaces

| Lab | Namespace | Purpose |
| --- | --- | --- |
| 01 | `weather` | Weather app with Redis |
| 02 | `ecommerce` | Multi-tier storefront |
| 03 | `educational` | Educational platform with StatefulSet |
| 04 | `task-management` | Task manager with Ingress |
| 05 | `medical-care-system` | Medical system with RBAC |
| 06 | `social-media` | Social platform with HPA |
| 07+ | Varies | Multi-app, chaos, Helm, GitOps labs |

## Port Forwarding
```bash
kubectl port-forward pod/<pod-name> 8080:80
kubectl port-forward service/<service-name> 8080:80
```

## Apply/Delete Resources
```bash
kubectl apply -f <file.yaml>
kubectl apply -f <directory>/
kubectl delete -f <file.yaml>
```

## Resource Usage
```bash
kubectl top nodes
kubectl top pods
kubectl top pods -n <namespace>
```

## Cleanup
```bash
kubectl delete all --all -n <namespace>
kubectl delete namespace <name>
```
