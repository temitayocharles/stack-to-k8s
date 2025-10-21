---
title: "Production Storage Operations Guide"
level: "intermediate-to-advanced"
type: "deep-dive"
prerequisites: ["Lab 3: Stateful Workloads", "Understanding of Persistent Volumes"]
topics: ["Volume Expansion", "Snapshot Management", "Storage Migration", "Capacity Planning", "Performance Tuning"]
estimated_time: "40-50 minutes"
updated: "2025-10-21"
nav_prev: "./node-operations.md"
nav_next: "./network-operations.md"
---

# 💾 Production Storage Operations: Expansion, Snapshots & Migrations

Managing Kubernetes storage in production means planning for growth, backing up critical data, and migrating workloads safely. This guide covers practical storage operations.

---

## 📋 Quick Navigation

- [Persistent Volume Lifecycle](#persistent-volume-lifecycle)
- [Volume Expansion](#volume-expansion-growing-your-storage)
- [Snapshot Management](#snapshot-management-backup-storage)
- [Storage Class Strategy](#storage-class-strategy)
- [Capacity Planning](#capacity-planning-predict-growth)
- [Storage Migration](#storage-migration-moving-data)
- [Performance Optimization](#performance-optimization)

---

## 🔄 Persistent Volume Lifecycle

### Creating Persistent Storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-storage
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd  # Must match available StorageClass
  resources:
    requests:
      storage: 100Gi
```

### Storage Classes (Provider Specific)

**AWS EBS Example**:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-optimized
provisioner: ebs.csi.aws.com
allowVolumeExpansion: true
parameters:
  type: gp3          # General purpose SSD
  iops: "3000"       # IOPS
  throughput: "125"  # MB/s
  encrypted: "true"
```

**GCP Persistent Disk Example**:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gcp-ssd
provisioner: pd.csi.storage.gke.io
allowVolumeExpansion: true
parameters:
  type: pd-ssd
  replication-type: regional-pd
```

### Viewing PVC Status

```bash
# List PVCs
kubectl get pvc -n production

# Describe PVC (full details)
kubectl describe pvc database-storage -n production

# Expected output:
# Name: database-storage
# Namespace: production
# Status: Bound
# Volume: pvc-abc123
# Capacity: 100Gi
# Access Modes: RWO
# StorageClass: fast-ssd
```

---

## 📈 Volume Expansion: Growing Your Storage

### Prerequisites

```bash
# Verify StorageClass allows expansion
kubectl get storageclass fast-ssd -o yaml | grep allowVolumeExpansion
# Should output: allowVolumeExpansion: true
```

### Expand a PVC

```bash
# 1. Check current size
kubectl get pvc database-storage -n production
# Capacity: 100Gi

# 2. Patch PVC to increase size
kubectl patch pvc database-storage -n production \
  -p '{"spec":{"resources":{"requests":{"storage":"200Gi"}}}}'

# 3. Verify expansion started
kubectl get pvc database-storage -n production
# Status should show expansion in progress

# 4. Monitor progress
kubectl describe pvc database-storage -n production
# Look for "Expansion successful" event
```

### Filesystem Expansion (Container Side)

After PVC expands, the filesystem must also be expanded:

**For ext4/ext3 filesystems**:
```bash
# 1. Execute on pod
kubectl exec -it <pod-name> -n production -- /bin/bash

# 2. Inside pod, resize filesystem
resize2fs /dev/vdx1  # or your device

# 3. Verify new size
df -h
```

**For xfs filesystems**:
```bash
# Inside pod
xfs_growfs /data  # or your mount point
```

**For LVM**:
```bash
# Inside pod
pvresize /dev/vdx1
lvextend -l +100%FREE /dev/vg0/lv_data
resize2fs /dev/vg0/lv_data
```

### Automated Volume Expansion Job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: storage-autoscale
  namespace: production
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: storage-autoscale
          containers:
          - name: autoscale
            image: bitnami/kubectl:latest
            command:
            - /bin/bash
            - -c
            - |
              # Get all PVCs
              PVCS=$(kubectl get pvc -n production -o name)
              
              for PVC in $PVCS; do
                # Get current size and usage
                CURRENT=$(kubectl get $PVC -n production -o jsonpath='{.spec.resources.requests.storage}')
                CURRENT_VALUE=${CURRENT%Gi}
                
                # Check usage (simplified - actual implementation would check actual usage)
                USAGE_PERCENT=75  # Simulate getting from kubelet metrics
                
                # If > 75% used, expand by 50%
                if [ $USAGE_PERCENT -gt 75 ]; then
                  NEW_SIZE=$((CURRENT_VALUE * 3 / 2))Gi
                  echo "Expanding $PVC from $CURRENT to $NEW_SIZE"
                  
                  kubectl patch $PVC -n production \
                    -p "{\"spec\":{\"resources\":{\"requests\":{\"storage\":\"$NEW_SIZE\"}}}}"
                fi
              done
          restartPolicy: OnFailure
          rbac:
            serviceAccountName: storage-autoscale
```

---

## 📸 Snapshot Management: Backup Storage

### Creating Snapshots

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: database-snapshot-daily
  namespace: production
spec:
  volumeSnapshotClassName: csi-snapshotter
  source:
    persistentVolumeClaimName: database-storage
```

### Listing Snapshots

```bash
# View snapshots
kubectl get volumesnapshot -n production

# Describe snapshot (check status)
kubectl describe volumesnapshot database-snapshot-daily -n production

# Expected: "readyToUse: true"
```

### Restoring from Snapshot

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-restored
  namespace: production
spec:
  dataSource:
    name: database-snapshot-daily
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 100Gi
```

### Automated Snapshot Schedule

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: storage-snapshots
  namespace: production
spec:
  schedule: "0 */6 * * *"  # Every 6 hours
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: snapshot-manager
          containers:
          - name: snapshot
            image: bitnami/kubectl:latest
            command:
            - /bin/bash
            - -c
            - |
              TIMESTAMP=$(date +%s)
              PVCS=$(kubectl get pvc -n production -o jsonpath='{.items[*].metadata.name}')
              
              for PVC in $PVCS; do
                SNAPSHOT_NAME="${PVC}-snap-${TIMESTAMP}"
                
                cat <<EOF | kubectl apply -f -
              apiVersion: snapshot.storage.k8s.io/v1
              kind: VolumeSnapshot
              metadata:
                name: $SNAPSHOT_NAME
                namespace: production
              spec:
                volumeSnapshotClassName: csi-snapshotter
                source:
                  persistentVolumeClaimName: $PVC
              EOF
                
                echo "Created snapshot: $SNAPSHOT_NAME"
              done
              
              # Delete snapshots older than 30 days
              kubectl delete volumesnapshot -n production \
                --field-selector=metadata.creationTimestamp\<$(date -d '30 days ago' -Iseconds)
          restartPolicy: OnFailure
```

---

## 🎛️ Storage Class Strategy

### Multi-Tier Storage Strategy

```yaml
---
# Tier 1: Hot (Frequent Access)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: hot-ssd
provisioner: ebs.csi.aws.com
allowVolumeExpansion: true
parameters:
  type: gp3
  iops: "4000"
  throughput: "250"

---
# Tier 2: Warm (Occasional Access)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: warm-standard
provisioner: ebs.csi.aws.com
allowVolumeExpansion: true
parameters:
  type: gp2
  iops: "1000"
  throughput: "125"

---
# Tier 3: Cold (Archival)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cold-archive
provisioner: ebs.csi.aws.com
parameters:
  type: st1  # Throughput optimized, cheaper
```

### Using Different Storage Classes

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-cache
spec:
  storageClassName: hot-ssd      # Fast for temporary data
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 50Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-database
spec:
  storageClassName: warm-standard # Balanced for databases
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 500Gi
```

---

## 📊 Capacity Planning: Predict Growth

### Storage Forecasting

```bash
#!/bin/bash
# monitor-storage-growth.sh

set -e

echo "📊 Storage Growth Report"
echo "========================"

# Get all PVCs and their current size
kubectl get pvc --all-namespaces -o custom-columns=\
NAMESPACE:.metadata.namespace,\
PVC:.metadata.name,\
STORAGE:.spec.resources.requests.storage \
| awk 'NR>1 {print $1, $2, $3}' | while read NS PVC STORAGE; do
  
  # Convert to Gi
  SIZE_BYTES=$(kubectl get pvc $PVC -n $NS -o jsonpath='{.spec.resources.requests.storage}' | sed 's/Gi//')
  
  # Calculate projected size in 30 days (assuming 10% monthly growth)
  PROJECTED=$((SIZE_BYTES * 11 / 10))Gi
  
  echo "$NS/$PVC: Current=$STORAGE, Projected (30d)=$PROJECTED"
done

# Total cluster storage
TOTAL=$(kubectl get pvc --all-namespaces -o jsonpath='{.items[*].spec.resources.requests.storage}' | \
  sed 's/Gi/ /g' | awk '{for(i=1;i<=NF;i++)s+=$i} END {print s}')

echo "========================"
echo "Total cluster storage: ${TOTAL}Gi"
echo "Projected (30d): $(echo "scale=2; $TOTAL * 1.1" | bc)Gi"

# Alert if approaching limit
LIMIT=5000  # 5TB limit
if [ $TOTAL -gt $LIMIT ]; then
  echo "⚠️  WARNING: Storage usage approaching limit!"
fi
```

### Set Alerts

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: storage-alerts
spec:
  groups:
  - name: storage.rules
    interval: 30s
    rules:
    - alert: PersistentVolumeSpaceWarning
      expr: kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes > 0.75
      for: 5m
      annotations:
        summary: "PVC {{ $labels.persistentvolumeclaim }} is 75% full"

    - alert: PersistentVolumeSpaceCritical
      expr: kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes > 0.90
      for: 1m
      annotations:
        summary: "PVC {{ $labels.persistentvolumeclaim }} is 90% full"
```

---

## 🚚 Storage Migration: Moving Data

### Migration Strategy: Copy Data

```bash
#!/bin/bash
# migrate-pvc.sh - Migrate from old to new PVC

OLD_PVC="old-database-storage"
NEW_PVC="new-database-storage"
NAMESPACE="production"
POD="migration-pod"

echo "Starting storage migration..."

# 1. Create migration pod with both volumes
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $POD
  namespace: $NAMESPACE
spec:
  containers:
  - name: migration
    image: busybox:latest
    command: ['/bin/sh']
    args: ['-c', 'while true; do sleep 3600; done']
    volumeMounts:
    - name: old
      mountPath: /old-data
    - name: new
      mountPath: /new-data
  volumes:
  - name: old
    persistentVolumeClaim:
      claimName: $OLD_PVC
  - name: new
    persistentVolumeClaim:
      claimName: $NEW_PVC
EOF

# 2. Wait for pod to be ready
kubectl wait --for=condition=Ready pod/$POD -n $NAMESPACE --timeout=300s

# 3. Copy data
echo "Copying data..."
kubectl exec $POD -n $NAMESPACE -- cp -rv /old-data/* /new-data/

# 4. Verify copy
echo "Verifying..."
kubectl exec $POD -n $NAMESPACE -- du -sh /old-data /new-data

# 5. Cleanup migration pod
kubectl delete pod $POD -n $NAMESPACE

echo "✅ Migration complete"
```

### Zero-Downtime Migration

```yaml
# Step 1: Create new PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-storage-v2
spec:
  storageClassName: new-storage-class
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 500Gi

---
# Step 2: Update StatefulSet to use new PVC
# (Do rolling update to minimize downtime)
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
spec:
  serviceName: database
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: db
        image: postgres:15
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      storageClassName: new-storage-class  # Updated
      accessModes: [ReadWriteOnce]
      resources:
        requests:
          storage: 500Gi
```

---

## ⚡ Performance Optimization

### Storage Performance Testing

```bash
# Write performance test
kubectl exec <pod-name> -- bash -c \
  "dd if=/dev/zero of=/data/test.bin bs=1M count=1000 && sync"

# Read performance test
kubectl exec <pod-name> -- bash -c \
  "dd if=/data/test.bin of=/dev/null bs=1M"

# IOPS test (AWS)
kubectl exec <pod-name> -- bash -c \
  "for i in {1..1000}; do dd if=/dev/zero of=/data/test-$i bs=4K count=1; done"
```

### Tuning for Different Workloads

| Workload | Optimization |
|----------|-------------|
| Database | High IOPS, consistent throughput |
| Cache Layer | High throughput, lower latency |
| Logging | Sequential writes, optimized for throughput |
| Archives | Cost-optimized, lower performance OK |

### Configuration Examples

```yaml
# Database Optimization
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: database-optimized
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "8000"          # High IOPS
  throughput: "250"     # High throughput
  deleteOnTermination: "false"  # Don't delete on uninstall

---
# Archive Optimization
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: archive-optimized
provisioner: ebs.csi.aws.com
parameters:
  type: st1             # Throughput-optimized, cheaper
  deleteOnTermination: "true"
```

---

## 📚 Related Resources

- [Lab 3: Stateful Workloads](../../labs/03-educational-stateful.md) — PVC fundamentals
- [Database Operations](./database-operations.md) — Backup strategies for databases
- [Resource Requirements](./resource-requirements.md) — Capacity planning
- [Disaster Recovery](../../labs/11.5-disaster-recovery.md) — Full backup strategies

---

**Questions?** [Open an issue](https://github.com/temitayocharles/stack-to-k8s/issues) or check the [Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md).

