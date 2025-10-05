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
```bash
kubectl get namespaces
kubectl create namespace <name>
kubectl get pods -n <namespace>
kubectl delete namespace <name>
```

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
