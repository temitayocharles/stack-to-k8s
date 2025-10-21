# Lab 8 · Chaos Engineering Overlay

Lab 8 requires Chaos Mesh and a test application. Reuse Lab 6's social-media
overlay as the chaos target:

```bash
# Deploy test app
kubectl apply -k labs/manifests/lab-06
kubectl label namespace social-lab chaos-testing=enabled

# Install Chaos Mesh
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm install chaos-mesh chaos-mesh/chaos-mesh -n chaos-mesh --create-namespace --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock

# Verify
./scripts/validate-lab.sh 8
```

Apply chaos experiments from the lab guide, then clean up:

```bash
kubectl delete namespace social-lab chaos-mesh
```
