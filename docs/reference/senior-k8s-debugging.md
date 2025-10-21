# Senior Kubernetes Engineer: Advanced Debugging & Performance

> 🎯 **Prerequisites**: Complete Labs 1-12 first. These techniques assume you're comfortable with basic Kubernetes operations.
> 
> 💡 **Purpose**: This guide consolidates advanced debugging patterns, performance tuning, and architectural solutions from real senior-level Kubernetes interviews and production incidents.

---

## 📖 How to Use This Guide

**Two Learning Paths**:

1. **Standard Path** (Recommended for first-time learners)
   - Complete all labs 1-12 without Expert Mode sections
   - Build solid foundation in Kubernetes fundamentals
   - Achievement: 🥉 **Kubernetes Practitioner**

2. **Expert Path** (For those seeking mastery)
   - Complete labs 1-12 + unlock Expert Mode challenges
   - Practice advanced debugging and performance tuning
   - Achievement: 🥇 **Kubernetes Expert** (7 badges)

**Navigation**: Each section below links to the lab where you can practice hands-on. Theory here, practice there.

---

## 🔬 Part 1: Deep Debugging (Beyond kubectl logs/describe)

### 1.1 Pod Stuck in CrashLoopBackOff - No Logs, No Errors

**Practice in**: [Lab 1 Expert Mode](../../labs/01-weather-basics.md#expert-mode-advanced-crashloopbackoff-debugging)

**Scenario**: `kubectl logs` shows nothing. `kubectl describe` shows no obvious errors. Pod keeps restarting.

#### Why This Happens
- Application crashes before logging framework initializes
- Segmentation fault in compiled binary
- Missing shared library (ldd dependencies)
- Container entrypoint misconfiguration

#### Advanced Debugging Techniques

**1. Ephemeral Debug Containers (Kubernetes 1.23+)**

```bash
# Attach debug container to running (or crashing) pod
kubectl debug mypod -it --image=busybox:1.28 --target=mycontainer

# Inside debug container, inspect filesystem
ls -la /app
cat /proc/1/environ  # Check environment variables
ldd /app/binary      # Check shared library dependencies
```

**Real Example**:
```bash
# Pod crashes immediately, no logs
kubectl debug weather-backend-abc123 -it \
  --image=nicolaka/netshoot \
  --target=backend

# Inside debug container
ps aux  # See what process tried to run
cat /proc/1/cmdline  # See exact command
ls -la /app  # Check file permissions (common issue!)
```

**2. Container Runtime Inspection (crictl)**

```bash
# SSH to node where pod is running
kubectl get pod mypod -o wide  # Find node

# On node, use crictl (bypasses kubectl)
sudo crictl ps -a | grep mypod
sudo crictl logs <container-id>
sudo crictl inspect <container-id>  # Full container metadata
```

**3. Core Dumps & Memory Analysis**

```bash
# Enable core dumps in pod
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    securityContext:
      capabilities:
        add: ["SYS_PTRACE"]
    volumeMounts:
    - name: core-dumps
      mountPath: /tmp/cores
  volumes:
  - name: core-dumps
    hostPath:
      path: /var/cores
      
# Configure core dump pattern
ulimit -c unlimited
echo "/tmp/cores/core.%e.%p" > /proc/sys/kernel/core_pattern
```

**4. Image Inspection (Before Deployment)**

```bash
# Inspect image layers for issues
docker history myimage:latest
dive myimage:latest  # Interactive layer explorer

# Check what actually runs
docker inspect myimage:latest | jq '.[0].Config.Cmd'
docker run --rm --entrypoint sh myimage:latest -c 'ls -la /app'
```

#### Decision Tree

```
Pod CrashLoopBackOff, no logs?
│
├─ Exit code 137 (OOMKilled) → Increase memory limits
├─ Exit code 1 + no logs → Use ephemeral debug container
├─ Exit code 139 (SIGSEGV) → Core dump analysis
└─ Exit code 0 but restarts → Check livenessProbe timing
```

#### Interview Answer Template

> "First, I check the exit code in `kubectl describe`. If it's 137, that's OOMKill—easy fix. For exit code 1 with no logs, the app crashed before logging. I'd use `kubectl debug` with a debug container to inspect the filesystem and check file permissions—I've seen `/app` owned by root when it should be `app:app`. If that doesn't reveal it, I'd SSH to the node and use `crictl logs` to bypass kubectl's caching. For compiled binaries, I'd check shared library dependencies with `ldd`. Finally, I'd pull the image locally and run `docker history` to see if something's missing in the layers."

---

### 1.2 StatefulSet Pod Won't Reattach PVC After Node Crash

**Practice in**: [Lab 3 Expert Mode](../../labs/03-educational-stateful.md#expert-mode-pvc-recovery-after-node-crash)

**Scenario**: Node crashes. Kubernetes reschedules StatefulSet pod, but it stays `Pending` because PVC is still bound to dead node.

#### Why This Happens
- PVC has node affinity to crashed node
- Volume is still attached to old node (CSI driver stuck)
- Pod is waiting for graceful termination timeout (default: 30s)

#### Recovery Techniques

**1. Force Delete Stale Pod**

```bash
# Pod stuck terminating
kubectl get pod mongodb-0 -n db
# STATUS: Terminating (for 10+ minutes)

# Force delete (removes finalizers)
kubectl delete pod mongodb-0 --grace-period=0 --force -n db

# New pod should schedule immediately
kubectl get pod mongodb-0 -n db -w
```

**2. Check PVC/PV Affinity**

```bash
# Check PVC status
kubectl get pvc data-mongodb-0 -n db -o yaml

# Look for nodeAffinity in PV
kubectl get pv <pv-name> -o yaml | grep -A10 nodeAffinity

# If PV is stuck on dead node, patch it
kubectl patch pv <pv-name> -p '{"spec":{"nodeAffinity":null}}'
```

**3. CSI Driver Stuck Volume**

```bash
# Check VolumeAttachment objects
kubectl get volumeattachment
# Look for attachments referencing dead node

# Delete stuck attachment
kubectl delete volumeattachment <name>

# Verify CSI driver pods are healthy
kubectl get pods -n kube-system | grep csi
```

**4. Manual PVC/PV Rebinding**

```bash
# If PVC is stuck "Lost", manually rebind

# 1. Delete PVC (data still safe in PV)
kubectl delete pvc data-mongodb-0 -n db

# 2. Edit PV reclaim policy
kubectl patch pv <pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'

# 3. Remove claimRef from PV
kubectl patch pv <pv-name> --type json -p '[{"op":"remove","path":"/spec/claimRef"}]'

# 4. Recreate PVC with same name (re-binds to PV)
kubectl apply -f pvc.yaml
```

#### Prevention Strategies

```yaml
# Use Pod Disruption Budget
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: mongodb-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: mongodb

# Use faster termination for StatefulSets
apiVersion: apps/v1
kind: StatefulSet
spec:
  template:
    spec:
      terminationGracePeriodSeconds: 10  # Down from 30s default
```

#### Interview Answer Template

> "StatefulSet PVC issues after node crashes are tricky. First, I check if the pod is stuck terminating—if so, force delete with `--grace-period=0 --force`. Then I verify the PVC status and PV nodeAffinity. If the PV is locked to the dead node, I patch it to remove nodeAffinity. I also check VolumeAttachment objects—sometimes the CSI driver thinks the volume is still attached. In production, I prevent this with PodDisruptionBudgets and shorter termination grace periods. The key is understanding that Kubernetes won't reschedule until it's sure the old pod is gone."

---

### 1.3 Pods Pending - Cluster Autoscaler Won't Scale

**Practice in**: [Lab 7 Expert Mode](../../labs/07-social-scaling.md#expert-mode-cluster-autoscaler-debugging)

**Scenario**: Pods stuck `Pending`. Cluster Autoscaler is installed but not adding nodes.

#### Top 3 Debugging Steps

**Step 1: Check Autoscaler Logs**

```bash
# Find autoscaler pod
kubectl get pods -n kube-system | grep cluster-autoscaler

# Check logs for errors
kubectl logs -n kube-system cluster-autoscaler-abc123 --tail=50

# Common errors:
# - "failed to increase node group: max size reached"
# - "scale up failed: cloud provider error"
# - "pod cannot be scheduled on any node: node selector doesn't match"
```

**Step 2: Verify Node Group Limits**

```bash
# Check autoscaler config
kubectl get configmap cluster-autoscaler-status -n kube-system -o yaml

# AWS example: check ASG limits
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names my-node-group \
  | jq '.AutoScalingGroups[0] | {Min, Max, Desired}'

# If Max = Desired, you've hit the limit!
```

**Step 3: Inspect PodDisruptionBudget**

```bash
# PDBs can block scale-down, causing quota issues
kubectl get pdb --all-namespaces

# Check if any PDBs are violated
kubectl describe pdb my-app-pdb -n production

# Output shows:
# Current: 2 allowed: 1 minimum: 2  ← BLOCKING!
```

#### Common Root Causes

| Symptom | Root Cause | Fix |
|---------|-----------|------|
| Logs: "max size reached" | Hit node group limit | Increase ASG max size |
| Logs: "cloud provider error" | IAM permissions issue | Add `autoscaling:SetDesiredCapacity` |
| Logs: "pod cannot be scheduled" | Node selector mismatch | Remove restrictive selectors |
| No logs, no scale-up | Pod has PVC with zone affinity | Add multi-zone node groups |
| Scales up, pods still pending | Resource requests too large | Right-size requests or add bigger nodes |

#### Advanced: Pod Unschedulable Events

```bash
# See why scheduler can't place pod
kubectl get events --field-selector involvedObject.name=mypod -n myns

# Common reasons:
# - "0/5 nodes available: insufficient cpu"
# - "0/5 nodes match node selector"
# - "1 node(s) had volume node affinity conflict"
```

#### Interview Answer Template

> "When pods are pending and autoscaler isn't scaling, I follow a three-step process. First, check the autoscaler logs for obvious errors like hitting max node count or cloud provider failures. Second, verify the node group limits—I've seen teams hit ASG max without realizing it. Third, check PodDisruptionBudgets, which can create weird quota situations. Beyond that, I inspect the pod's events to see the scheduler's reason. A common gotcha is PVC zone affinity—if your PV is in us-east-1a but your node group only launches in us-east-1b, the autoscaler will scale up nodes that can't help. The fix is multi-zone node groups or regional PVs."

---

### 1.4 NetworkPolicy Blocks Cross-Namespace Traffic

**Practice in**: [Lab 6 Expert Mode](../../labs/06-medical-security.md#expert-mode-least-privilege-networkpolicy-design)

**Scenario**: After applying NetworkPolicy, services in namespace A can't reach namespace B.

#### Designing Least-Privilege Rules

**1. Start with Default-Deny**

```yaml
# Block all traffic by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

**2. Allow Specific Cross-Namespace Traffic**

```yaml
# Allow frontend (ns: web) → backend (ns: api)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-web-ns
  namespace: api
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: web
    - podSelector:
        matchLabels:
          app: frontend
```

**3. Always Allow DNS + Monitoring**

```yaml
# Allow DNS resolution (CoreDNS)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: production
spec:
  podSelector: {}
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53

---
# Allow Prometheus scraping
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus
  namespace: production
spec:
  podSelector:
    matchLabels:
      metrics: "true"
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 8080
```

#### Testing NetworkPolicies Safely

```bash
# 1. Apply in audit mode first (if CNI supports)
kubectl label namespace production policy-mode=audit

# 2. Test connectivity before/after
kubectl run test -it --rm --image=nicolaka/netshoot -n web -- bash
# Inside pod:
curl backend.api.svc.cluster.local

# 3. Check denied connections
kubectl logs -n kube-system <cni-pod> | grep -i deny
```

#### Common Mistakes

```yaml
# ❌ WRONG: This allows ALL pods from web namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
spec:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: web
    # Missing podSelector!

# ✅ CORRECT: Restrict to specific pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
spec:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: web
      podSelector:  # AND condition
        matchLabels:
          app: frontend
```

#### Interview Answer Template

> "Designing least-privilege NetworkPolicies requires a layered approach. I start with a default-deny-all policy in each namespace, then explicitly allow required traffic. For cross-namespace communication, I use both namespaceSelector AND podSelector to ensure only specific pods can connect. Common gotcha: forgetting DNS—pods need egress to kube-system on port 53. I also always allow Prometheus scraping by labeling pods with `metrics: true`. Before deploying, I test with a netshoot pod and check CNI logs for denied connections. In production, we roll out policies gradually—audit mode first, then enforce—to avoid breaking live traffic."

---

## ⚙️ Part 2: Control Plane & Performance Tuning

### 2.1 etcd Performance Bottlenecks

**Practice in**: [Lab 3.5 Expert Mode](../../labs/03.5-kubernetes-under-the-hood.md#expert-mode-control-plane-performance-tuning)

**Scenario**: API server requests timing out. `kubectl get pods` taking 5+ seconds. etcd disk latency high.

#### Root Cause Analysis

**1. Check etcd Metrics**

```bash
# Port-forward to etcd metrics endpoint
kubectl port-forward -n kube-system etcd-master-0 2379:2379

# Check critical metrics
curl http://localhost:2379/metrics | grep -E 'etcd_(disk|request)_duration'

# Key metrics:
# - etcd_disk_wal_fsync_duration_seconds > 10ms = SLOW DISK
# - etcd_disk_backend_commit_duration_seconds > 25ms = COMPACTION NEEDED
# - etcd_server_slow_apply_total increasing = API SERVER OVERLOAD
```

**2. Check etcd Database Size**

```bash
# SSH to etcd node
ETCDCTL_API=3 etcdctl --endpoints=localhost:2379 endpoint status --write-out=table

# Output:
# +-------------------+------------------+---------+---------+-----------+
# |     ENDPOINT      |        ID        | DB SIZE | IS LEAD | RAFT TERM |
# +-------------------+------------------+---------+---------+-----------+
# | localhost:2379    | 8e9e05c52164694d | 8.0 GB  | true    |         3 |

# If DB > 2GB, compaction needed
```

#### Tuning Strategies

**1. Compaction**

```bash
# Compact old revisions (keep last 1000)
ETCDCTL_API=3 etcdctl compact $(etcdctl endpoint status --write-out="json" | jq -r '.[0].Status.raftIndex - 1000')

# Defragment to reclaim space
ETCDCTL_API=3 etcdctl defrag --cluster

# Check size after
ETCDCTL_API=3 etcdctl endpoint status --write-out=table
```

**2. Snapshot Optimization**

```bash
# Take snapshot (for backup)
ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-$(date +%Y%m%d).db

# Check snapshot size
ls -lh /backup/etcd-*.db

# Rotate snapshots (keep last 7 days)
find /backup -name 'etcd-*.db' -mtime +7 -delete
```

**3. Auto-Compaction Configuration**

```yaml
# etcd pod manifest: /etc/kubernetes/manifests/etcd.yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: etcd
    command:
    - etcd
    - --auto-compaction-retention=5m  # Compact every 5 minutes
    - --quota-backend-bytes=8589934592  # 8GB max (default 2GB)
```

**4. Disk I/O Optimization**

```bash
# Check disk performance
fio --name=random-write --ioengine=libaio --iodepth=1 --rw=randwrite --bs=4k --direct=1 --size=128m --numjobs=1 --runtime=60 --group_reporting

# Should see: 
# - >500 IOPS = Minimum acceptable
# - >3000 IOPS = Good (AWS gp3, Azure Premium SSD)
# - <500 IOPS = UPGRADE DISK NOW

# AWS: Migrate to gp3 with higher IOPS
aws ec2 modify-volume --volume-id vol-xxx --iops 3000

# Kubernetes: Use dedicated disk for etcd
volumeMounts:
- name: etcd-data
  mountPath: /var/lib/etcd
volumes:
- name: etcd-data
  hostPath:
    path: /mnt/fast-ssd/etcd  # Dedicated SSD
```

#### Monitoring Dashboard

```promql
# Prometheus queries for etcd health

# Disk fsync latency (should be < 10ms)
histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket[5m]))

# Backend commit latency (should be < 25ms)
histogram_quantile(0.99, rate(etcd_disk_backend_commit_duration_seconds_bucket[5m]))

# Database size trend
etcd_mvcc_db_total_size_in_bytes

# Leader changes (should be 0)
rate(etcd_server_leader_changes_seen_total[5m])
```

#### Interview Answer Template

> "When etcd slows down, I first check disk latency—etcd is extremely sensitive to slow storage. I look at `etcd_disk_wal_fsync_duration`; if it's over 10ms, that's a disk issue, not etcd. For database size, anything over 2GB needs compaction. I'd run `etcdctl compact` and `defrag` to reclaim space. In production, we enable auto-compaction every 5 minutes and set quota-backend-bytes to 8GB. I also monitor leader changes—if leaders are flipping frequently, that indicates network instability or overload. Finally, etcd should always be on dedicated SSDs with >3000 IOPS. I've seen teams run etcd on spinning disks and wonder why everything is slow."

---

### 2.2 Istio Sidecar CPU Overhead

**Practice in**: [Lab 8 Expert Mode](../../labs/08-multi-app.md#expert-mode-service-mesh-performance-profiling)

**Scenario**: After enabling Istio, sidecar proxies consume more CPU than application containers.

#### Profiling Envoy Performance

**1. Check Resource Usage**

```bash
# Compare app vs sidecar CPU
kubectl top pod -n production

# Output:
# NAME                     CPU(cores)   MEMORY(bytes)
# backend-abc-123          50m          128Mi
# backend-abc-123-istio    200m         256Mi  ← PROBLEM!

# Get detailed metrics
kubectl exec -it backend-abc-123 -c istio-proxy -- curl localhost:15000/stats/prometheus | grep cpu
```

**2. Envoy Admin Interface**

```bash
# Port-forward to Envoy admin
kubectl port-forward backend-abc-123 15000:15000

# Check active connections
curl localhost:15000/stats | grep downstream_cx_active

# Check circuit breaker status
curl localhost:15000/clusters | grep outlier_detection

# Dump config
curl localhost:15000/config_dump > envoy-config.json
```

#### Optimization Techniques

**1. Tune Resource Limits**

```yaml
# Reduce sidecar resources for low-traffic services
apiVersion: v1
kind: Pod
metadata:
  annotations:
    sidecar.istio.io/proxyCPU: "100m"
    sidecar.istio.io/proxyCPULimit: "500m"
    sidecar.istio.io/proxyMemory: "128Mi"
    sidecar.istio.io/proxyMemoryLimit: "256Mi"
spec:
  containers:
  - name: app
    # ...
```

**2. Configure Connection Pooling**

```yaml
# Reduce Envoy overhead with connection pooling
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend-pool
spec:
  host: backend.production.svc.cluster.local
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100  # Down from 1024 default
      http:
        http1MaxPendingRequests: 50
        http2MaxRequests: 100
        maxRequestsPerConnection: 10  # Reuse connections
```

**3. Circuit Breaker Tuning**

```yaml
# Prevent Envoy from retrying forever
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend-circuit-breaker
spec:
  host: backend.production.svc.cluster.local
  trafficPolicy:
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
```

**4. Disable Unnecessary Features**

```yaml
# Turn off features you don't use
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  meshConfig:
    # Disable Mixer telemetry (use Prometheus directly)
    disableMixerHttpReports: true
    
    # Reduce tracing overhead
    defaultConfig:
      tracing:
        sampling: 1.0  # 1% sampling instead of 100%
```

#### Monitoring Queries

```promql
# Envoy CPU usage by service
sum(rate(container_cpu_usage_seconds_total{container="istio-proxy"}[5m])) by (pod)

# Envoy memory usage
container_memory_working_set_bytes{container="istio-proxy"}

# Request latency introduced by Envoy
histogram_quantile(0.99, rate(istio_request_duration_milliseconds_bucket[5m]))
```

#### Interview Answer Template

> "High Envoy CPU is common in Istio. First, I check if the sidecar has proper resource limits—many teams use default `requests: 100m, limits: 2000m`, which is overkill for low-traffic services. I'd tune that based on actual usage. Second, connection pooling—Envoy defaults to 1024 max connections, but most services need far fewer. Setting `maxConnections: 100` and `maxRequestsPerConnection: 10` reduces overhead significantly. Third, I'd check circuit breaker config; aggressive retries can cause CPU spikes. Finally, reduce tracing sampling from 100% to 1-5%—full tracing is expensive. In one case, we cut sidecar CPU by 60% just by tuning connection pools and disabling unused telemetry."

---

## 🛡️ Part 3: Security & Policy Enforcement

### 3.1 Enforce Trusted Image Registries

**Practice in**: [Lab 6 Expert Mode](../../labs/06-medical-security.md#expert-mode-admission-control-policies)

**Scenario**: Must block images from Docker Hub. Only allow internal registry.

#### Option 1: OPA Gatekeeper

```yaml
# Install Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml

# Create constraint template
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sallowedrepos
spec:
  crd:
    spec:
      names:
        kind: K8sAllowedRepos
      validation:
        openAPIV3Schema:
          properties:
            repos:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8sallowedrepos
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not strings.any_prefix_match(container.image, input.parameters.repos)
          msg := sprintf("Image '%v' not from approved registry", [container.image])
        }

---
# Apply constraint
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sAllowedRepos
metadata:
  name: allowed-repos
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces: ["production"]
  parameters:
    repos:
      - "123456789.dkr.ecr.us-east-1.amazonaws.com/"
      - "mycompany.azurecr.io/"
```

#### Option 2: Kyverno

```yaml
# Install Kyverno
kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/install.yaml

# Create policy
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-image-registries
spec:
  validationFailureAction: enforce  # Block violating pods
  rules:
  - name: validate-registries
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Images must come from approved registries"
      pattern:
        spec:
          containers:
          - image: "123456789.dkr.ecr.us-east-1.amazonaws.com/* | mycompany.azurecr.io/*"
```

#### Option 3: Custom Admission Webhook

```go
// Simple webhook that blocks unapproved registries
func validatePod(ar v1.AdmissionReview) *v1.AdmissionResponse {
    pod := ar.Request.Object
    
    allowedRegistries := []string{
        "123456789.dkr.ecr.us-east-1.amazonaws.com",
        "mycompany.azurecr.io",
    }
    
    for _, container := range pod.Spec.Containers {
        if !hasAllowedRegistry(container.Image, allowedRegistries) {
            return &v1.AdmissionResponse{
                Allowed: false,
                Result: &metav1.Status{
                    Message: fmt.Sprintf("Image %s not from approved registry", container.Image),
                },
            }
        }
    }
    
    return &v1.AdmissionResponse{Allowed: true}
}
```

#### Testing

```bash
# Try to deploy unapproved image
kubectl run test --image=nginx:latest -n production

# Should fail with:
# Error: admission webhook denied the request: Image 'nginx:latest' not from approved registry

# Deploy approved image
kubectl run test --image=123456789.dkr.ecr.us-east-1.amazonaws.com/nginx:latest -n production
# Success!
```

#### Interview Answer Template

> "For enforcing image registries, I prefer OPA Gatekeeper or Kyverno over custom webhooks—they're battle-tested and easier to maintain. With Gatekeeper, I create a ConstraintTemplate with Rego policy that checks image prefixes against an allowlist. The key is using `strings.any_prefix_match` to handle both registry URL and image name. I set `validationFailureAction: enforce` to block violating pods, and apply constraints per-namespace for flexibility. In production, we also scan images in CI before pushing to the allowed registry, so this is defense-in-depth. One gotcha: init containers and ephemeral containers must also be validated, not just main containers. I've seen teams forget that and have a security hole."

---

## 🌐 Part 4: Network Deep Debugging

### 4.1 Pods Stuck in ContainerCreating - CNI Issues

**Practice in**: [Lab 9 Expert Mode](../../labs/09-chaos.md#scenario-8-the-impossible-debug)

**Scenario**: Pod stuck `ContainerCreating` for 5+ minutes. No obvious errors.

#### Investigation Process

**Step 1: Check Pod Events**

```bash
# Get detailed events
kubectl describe pod mypod -n myns

# Look for:
# - "Failed to create pod sandbox: network plugin is not ready"
# - "CNI failed to setup network for pod"
# - "error getting ClusterInformation: connection refused"
```

**Step 2: Check CNI Plugin Logs**

```bash
# Find CNI pods (depends on CNI: Calico, Cilium, Weave, etc.)
kubectl get pods -n kube-system | grep -E 'calico|cilium|weave|flannel'

# Check logs
kubectl logs -n kube-system calico-node-abc123 -c calico-node --tail=100

# Common errors:
# - "IPAM: Address pool exhausted"
# - "failed to configure network namespace"
# - "OverlayFS error: no space left on device"
```

**Step 3: SSH to Node & Inspect**

```bash
# SSH to node where pod is stuck
kubectl get pod mypod -o wide  # Get node name

# On node, check CNI logs
sudo tail -f /var/log/pods/kube-system_calico-node-*/calico-node/*.log

# Check network namespace
sudo ip netns list
# Should see entries like: cni-XXXXXXXX-XXXX-XXXX

# If pod is stuck, namespace might not exist
sudo ls /var/run/netns/
```

**Step 4: IPAM Debugging**

```bash
# Check IP address allocation
kubectl get ippool -o yaml  # Calico
kubectl get ciliumnodes -o yaml  # Cilium

# Look for exhaustion:
# Capacity: 256
# Allocated: 256  ← PROBLEM!

# Expand IP pool
kubectl patch ippool default-ipv4-ippool -p '{"spec":{"cidr":"10.244.0.0/16"}}'  # Calico
```

#### Common Root Causes

| Symptom | Root Cause | Fix |
|---------|-----------|------|
| "network plugin not ready" | CNI pod crashed | Restart CNI DaemonSet |
| "IPAM address exhausted" | IP pool too small | Expand CIDR range |
| "OverlayFS error" | Node disk full | Clean up images: `docker system prune` |
| "failed to setup sandbox" | Corrupted network namespace | Delete pod, restart kubelet |
| "connection refused" | CNI can't reach API server | Check NetworkPolicy blocking kube-system |

#### Advanced: Manual Network Namespace Inspection

```bash
# On node, find container's network namespace
CONTAINER_ID=$(sudo crictl ps | grep mypod | awk '{print $1}')
PID=$(sudo crictl inspect $CONTAINER_ID | jq -r '.info.pid')

# Enter network namespace
sudo nsenter -t $PID -n ip addr show
sudo nsenter -t $PID -n ip route show

# Check if veth pair exists
sudo ip link | grep veth
```

#### Interview Answer Template

> "Pods stuck in ContainerCreating usually means CNI issues. I start by checking pod events for CNI errors. If it says 'network plugin not ready,' I check if the CNI pods are running—they're typically a DaemonSet in kube-system. Next, I check CNI logs for IPAM errors; exhausted IP pools are common in small clusters. If the pod has been stuck for a while, I SSH to the node and check `/var/log/pods` for CNI logs, and use `ip netns list` to see if the network namespace was created. A common gotcha is disk space—CNI plugins fail silently when `/var/lib/cni` is full. In one incident, we traced it to a NetworkPolicy accidentally blocking CNI pods from reaching the API server. The fix was adding an egress rule for `kube-system` namespace."

---

### 4.2 Random DNS Failures in Pods

**Practice in**: [Lab 9 Expert Mode](../../labs/09-chaos.md#scenario-8-the-impossible-debug)

**Scenario**: DNS works 90% of the time. Occasional `nslookup: can't resolve` errors.

#### Debugging Steps

**Step 1: Check CoreDNS Health**

```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check logs for errors
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50

# Common errors:
# - "Timeout waiting for connection"
# - "SERVFAIL for query"
# - "Too many open files"
```

**Step 2: Test DNS from Pod**

```bash
# Create test pod
kubectl run dnstest --image=nicolaka/netshoot -it --rm -- bash

# Inside pod, test DNS
nslookup kubernetes.default
nslookup backend.production.svc.cluster.local

# Check /etc/resolv.conf
cat /etc/resolv.conf
# Should show:
# nameserver 10.96.0.10
# search production.svc.cluster.local svc.cluster.local cluster.local
# options ndots:5
```

**Step 3: Check kube-proxy & Service**

```bash
# Verify kube-dns Service exists
kubectl get svc -n kube-system kube-dns

# Should have ClusterIP
# NAME       TYPE        CLUSTER-IP    PORT
# kube-dns   ClusterIP   10.96.0.10    53/UDP,53/TCP

# Check kube-proxy logs
kubectl logs -n kube-system -l k8s-app=kube-proxy --tail=50

# Test connectivity to DNS service
kubectl run netshoot --image=nicolaka/netshoot -it --rm -- bash
nc -zvu 10.96.0.10 53  # Should connect
```

**Step 4: conntrack Table Exhaustion**

```bash
# SSH to node experiencing DNS failures

# Check conntrack table usage
sudo sysctl net.netfilter.nf_conntrack_count
sudo sysctl net.netfilter.nf_conntrack_max

# If count is near max, that's your problem!
# count: 262000
# max:   262144  ← EXHAUSTED

# Increase limit
sudo sysctl -w net.netfilter.nf_conntrack_max=1048576
echo "net.netfilter.nf_conntrack_max = 1048576" | sudo tee -a /etc/sysctl.conf
```

#### Root Causes & Fixes

**1. CoreDNS Overload**

```yaml
# Increase CoreDNS resources
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - name: coredns
        resources:
          requests:
            cpu: 200m      # Up from 100m
            memory: 256Mi  # Up from 70Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

**2. ndots=5 Causes Excess Queries**

```yaml
# Reduce ndots to avoid extra lookups
apiVersion: v1
kind: Pod
spec:
  dnsConfig:
    options:
    - name: ndots
      value: "2"  # Down from default 5
```

**3. Enable DNS Caching**

```yaml
# Add NodeLocal DNSCache
kubectl apply -f https://k8s.io/examples/admin/dns/nodelocaldns.yaml

# Reduces latency and CoreDNS load
# Caches DNS responses on each node
```

#### Monitoring

```promql
# DNS query rate
rate(coredns_dns_request_count_total[5m])

# DNS query latency
histogram_quantile(0.99, rate(coredns_dns_request_duration_seconds_bucket[5m]))

# DNS errors
rate(coredns_dns_responses_total{rcode="SERVFAIL"}[5m])
```

#### Interview Answer Template

> "Intermittent DNS failures are tricky. I start by checking CoreDNS pod health and logs. If I see 'Too many open files,' that's a resource limit issue—fix with higher limits. Next, I test DNS from a pod and check `/etc/resolv.conf`—specifically the `ndots` setting. Default `ndots:5` means queries like `backend` generate 5 lookups before trying the short name. That's wasteful. I reduce it to 2 in most cases. Another common issue is conntrack table exhaustion on nodes—if `nf_conntrack_count` equals `nf_conntrack_max`, DNS (and all UDP) will fail randomly. I increase the limit to 1M. Finally, I deploy NodeLocal DNSCache to reduce CoreDNS load. In one production incident, we traced random DNS failures to a misconfigured NetworkPolicy blocking pod egress to CoreDNS. Always check policies."

---

## 🌉 Part 5: Hybrid & Advanced Architecture

### 5.1 External Database via VPN (HA Architecture)

**Practice in**: [Lab 12 Expert Mode](../../labs/12-external-secrets.md#expert-mode-hybrid-architecture-vpn-patterns)

**Scenario**: Services in Kubernetes need HA connection to on-prem database via VPN.

#### Architecture Patterns

**Pattern 1: VPN Sidecar**

```yaml
# WireGuard VPN sidecar pattern
apiVersion: v1
kind: Pod
metadata:
  name: app-with-vpn
spec:
  containers:
  # Application container
  - name: app
    image: myapp:v1
    env:
    - name: DB_HOST
      value: "10.0.1.50"  # On-prem database IP
    - name: DB_PORT
      value: "5432"
  
  # VPN sidecar
  - name: wireguard
    image: linuxserver/wireguard
    securityContext:
      capabilities:
        add: ["NET_ADMIN"]
    volumeMounts:
    - name: vpn-config
      mountPath: /config
  
  volumes:
  - name: vpn-config
    secret:
      secretName: wireguard-config
```

**Pattern 2: Service Mesh Egress Gateway**

```yaml
# Istio egress gateway for on-prem DB
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: external-db
spec:
  hosts:
  - db.onprem.company.com
  addresses:
  - 10.0.1.50/32
  ports:
  - number: 5432
    name: tcp
    protocol: TCP
  location: MESH_EXTERNAL
  resolution: STATIC
  endpoints:
  - address: 10.0.1.50

---
# Route through egress gateway
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: egress-gateway
spec:
  selector:
    istio: egressgateway
  servers:
  - port:
      number: 5432
      name: tcp
      protocol: TCP
    hosts:
    - db.onprem.company.com

---
# VirtualService for routing
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: external-db
spec:
  hosts:
  - db.onprem.company.com
  gateways:
  - mesh
  - egress-gateway
  tcp:
  - match:
    - gateways:
      - mesh
      port: 5432
    route:
    - destination:
        host: istio-egressgateway.istio-system.svc.cluster.local
        port:
          number: 5432
  - match:
    - gateways:
      - egress-gateway
      port: 5432
    route:
    - destination:
        host: db.onprem.company.com
        port:
          number: 5432
```

#### HA & Failover Strategies

**1. Multiple VPN Endpoints**

```yaml
# Kubernetes Service with multiple VPN endpoints
apiVersion: v1
kind: Service
metadata:
  name: onprem-db
spec:
  type: ExternalName
  externalName: db-primary.onprem.company.com

---
# Fallback service for secondary
apiVersion: v1
kind: Service
metadata:
  name: onprem-db-secondary
spec:
  type: ExternalName
  externalName: db-secondary.onprem.company.com

---
# App uses connection pool with failover
DB_HOSTS=db-primary.onprem.company.com,db-secondary.onprem.company.com
```

**2. Health Checks & Circuit Breakers**

```yaml
# Istio DestinationRule with health checks
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: external-db-circuit-breaker
spec:
  host: db.onprem.company.com
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
    outlierDetection:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 60s
```

**3. Connection Pooling**

```python
# Application-level connection pool with failover
from sqlalchemy import create_engine, pool

# Primary connection
engine_primary = create_engine(
    "postgresql://user:pass@db-primary.onprem.company.com:5432/db",
    poolclass=pool.QueuePool,
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,  # Health check
    pool_recycle=3600
)

# Fallback connection
engine_secondary = create_engine(
    "postgresql://user:pass@db-secondary.onprem.company.com:5432/db",
    poolclass=pool.QueuePool,
    pool_size=10,
    pool_pre_ping=True
)

def get_connection():
    try:
        return engine_primary.connect()
    except Exception:
        logger.warning("Primary DB unreachable, using secondary")
        return engine_secondary.connect()
```

#### Security Considerations

```yaml
# 1. Restrict egress with NetworkPolicy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-vpn-egress
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Egress
  egress:
  # Allow VPN endpoint only
  - to:
    - ipBlock:
        cidr: 203.0.113.10/32  # VPN gateway IP
    ports:
    - protocol: UDP
      port: 51820  # WireGuard port

---
# 2. Rotate VPN credentials automatically
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vpn-credentials
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
  target:
    name: wireguard-config
  data:
  - secretKey: config
    remoteRef:
      key: vpn/wireguard/config
```

#### Interview Answer Template

> "For HA connectivity to external databases via VPN, I use a layered approach. At the pod level, a WireGuard sidecar provides the VPN tunnel with `NET_ADMIN` capability. For larger deployments, I prefer an Istio egress gateway—it centralizes VPN connections and provides observability. HA is achieved through multiple VPN endpoints configured in the connection string, plus circuit breakers in Istio to detect failures quickly. Application code uses connection pooling with `pool_pre_ping` to validate connections before use. Security-wise, NetworkPolicies restrict egress to only the VPN gateway IP, and we rotate VPN credentials via External Secrets Operator. A common mistake is not handling VPN reconnection—if the tunnel drops, sidecars must retry automatically. We monitor tunnel health with Prometheus and alert if down for >60 seconds."

---

## 🏆 Achievement System

### Standard Path Completion

Complete Labs 1-12 to earn:
- **🥉 Kubernetes Practitioner** (All labs completed)
- **🥈 Challenge Conqueror** (+3 challenge labs)
- **🥇 Platform Engineer** (+Lab 13 AI/ML)

### Expert Path Badges

Unlock advanced badges by completing Expert Mode challenges:

| Badge | Lab | Challenge | Time | Difficulty |
|-------|-----|-----------|------|-----------|
| 🔬 **Forensic Investigator** | Lab 1 | Debug CrashLoopBackOff with no logs | +20min | ⭐⭐⭐⭐ |
| 💾 **Data Recovery Specialist** | Lab 3 | Recover PVC after node crash | +15min | ⭐⭐⭐⭐ |
| ⚙️ **Control Plane Architect** | Lab 3.5 | Tune etcd performance | +25min | ⭐⭐⭐⭐⭐ |
| 📈 **Scaling Architect** | Lab 7 | Debug autoscaler failures | +20min | ⭐⭐⭐⭐ |
| 🕸️ **Mesh Performance Engineer** | Lab 8 | Optimize Istio sidecar CPU | +30min | ⭐⭐⭐⭐⭐ |
| 🔍 **Network Detective** | Lab 9 | Solve impossible CNI debug | +25min | ⭐⭐⭐⭐⭐ |
| 🌉 **Hybrid Cloud Architect** | Lab 12 | External DB via VPN | +30min | ⭐⭐⭐⭐ |

### Achievement Tiers

- **0-2 badges**: 🥉 Advanced Practitioner
- **3-5 badges**: 🥈 Senior Engineer
- **6-7 badges**: 🥇 Kubernetes Expert
- **All badges + 3 challenges**: 👑 **Kubernetes Master**

---

## 📚 Further Learning

### Interview Preparation

This guide covers the most common senior-level Kubernetes interview questions. For comprehensive interview prep:

- **[CKA Exam Guide](certification-guide.md)** - Certified Kubernetes Administrator prep
- **[Production War Stories](production-war-stories.md)** - Real incident case studies
- **[Decision Trees](decision-trees.md)** - Architecture pattern selection

### Advanced Topics

- **Multi-tenancy**: [Lab 8.5](../../labs/08.5-multi-tenancy.md)
- **Disaster Recovery**: [Lab 11.5](../../labs/11.5-disaster-recovery.md) *(coming soon)*
- **GPU Workloads**: [Lab 13](../../labs/13-ai-ml-gpu.md)
- **Complex Microservices**: [Lab 9.5](../../labs/09.5-complex-microservices.md) *(coming soon)*

---

## 🎓 Credits

This guide consolidates debugging patterns and performance tuning techniques from:
- Real production incidents (see [Production War Stories](production-war-stories.md))
- Senior Kubernetes engineer interviews (LinkedIn "Deep Dive Debugging" series)
- Official Kubernetes troubleshooting documentation
- Cloud provider best practices (AWS EKS, GCP GKE, Azure AKS)

**Maintainers**: If you find errors or have suggestions, please open an issue or PR!

---

**Next Steps**:
1. ✅ Complete Labs 1-12 (Standard Path)
2. 🎖️ Attempt Expert Mode challenges (Optional but valuable!)
3. 🏆 Track your progress in [LAB-PROGRESS.md](../learning/LAB-PROGRESS.md)
4. 📝 Practice explaining solutions out loud (interview prep!)

**Good luck on your Kubernetes mastery journey!** 🚀
