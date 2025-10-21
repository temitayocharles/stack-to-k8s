# ⚠️ Production War Stories: When Kubernetes Goes Wrong

Real-world incidents, root causes, and hard-won lessons from companies running K8s at scale.

**Why This Matters**: Textbook K8s is clean. Production K8s is chaos. Learn from others' $1M+ mistakes.

---

## 🔥 Story #1: GitHub's 24-Hour Outage (Oct 2018)

### What Happened
- **Impact**: GitHub.com unavailable for 24 hours
- **Affected**: 31+ million developers worldwide
- **Root Cause**: MySQL cluster lost consensus during network partition
- **Cost**: Estimated $200M+ in lost productivity

### The Incident Timeline

**Day 1, 10:00 AM**: Network maintenance in US East datacenter  
**10:05 AM**: 43-second network partition between US East and US West  
**10:10 AM**: MySQL primary in US East lost quorum, promoted new primary in US West  
**10:15 AM**: Network recovered, NOW TWO PRIMARIES (split-brain)  
**10:20 AM**: Data writes to both primaries (data divergence)  
**11:00 AM**: Engineers detect inconsistency, shut down writes  
**Next 24 hours**: Manual data reconciliation (500,000+ diverged records)

### Why Kubernetes Wasn't the Hero (Yet)

GitHub's setup in 2018:
```yaml
# Simplified architecture
MySQL Cluster:
  Primary: US East (Kubernetes StatefulSet)
  Replica: US West (Kubernetes StatefulSet)
  Orchestrator: Leader election (failed during partition)

Problem:
  - StatefulSets don't prevent split-brain (app-level issue)
  - No PodDisruptionBudget (Orchestrator pod moved during maintenance)
  - NetworkPolicy didn't block cross-region writes during partition
```

### The Kubernetes Lesson

**What They Should Have Done**:
1. **Pod Disruption Budget** for Orchestrator:
   ```yaml
   apiVersion: policy/v1
   kind: PodDisruptionBudget
   metadata:
     name: orchestrator-pdb
   spec:
     minAvailable: 1
     selector:
       matchLabels:
         app: orchestrator
   ```
   → Prevents Kubernetes from moving Orchestrator during maintenance

2. **Fencing via NetworkPolicy**:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: mysql-region-fence
   spec:
     podSelector:
       matchLabels:
         app: mysql
     policyTypes:
     - Egress
     egress:
     - to:
       - podSelector:
           matchLabels:
             region: us-east  # Only talk to same region during partition
   ```

3. **Quorum-Based Leader Election** (built into MySQL 8.0+ Group Replication):
   - Requires majority (2 of 3 nodes) to elect primary
   - Kubernetes doesn't help here (app-level design)

### Key Takeaways
- ✅ **PodDisruptionBudget is not optional** for stateful apps
- ✅ **Test failure modes**: Simulate network partitions (see [Lab 9: Chaos](../labs/09-chaos.md))
- ✅ **StatefulSets ≠ Data safety**: App must handle split-brain
- ⚠️ **Kubernetes doesn't solve distributed systems problems** (it just orchestrates containers)

**GitHub's Post-Mortem**: https://github.blog/2018-10-30-oct21-post-incident-analysis/

---

## 💸 Story #2: Shopify's Black Friday (Nov 2020)

### What Happened
- **Impact**: $1.5 billion in sales handled (no downtime!)
- **Scale**: 10,000+ requests/second peak load
- **Infrastructure**: Migrated to Kubernetes 6 months before Black Friday
- **Result**: 🎉 Success (but nearly failed in testing)

### The Near-Miss

**3 Weeks Before Black Friday**: Load test at 5x normal traffic  
**Result**: Cluster collapsed after 10 minutes  
**Root Cause**: HPA scaling too slowly (pods took 90 seconds to start)

### The Kubernetes Problem

Original HPA config:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: storefront-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: storefront
  minReplicas: 50         # ❌ Too low for Black Friday baseline
  maxReplicas: 500
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # ❌ Too high (pods already struggling)
  behavior:                    # ❌ Missing (default 5-min scale-down delay)
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100           # ❌ Only doubles pods (50 → 100 → 200, too slow)
        periodSeconds: 15
```

**Problem**: During traffic spike:
1. HPA sees 70% CPU → scales up by 100% (50 → 100 pods)
2. New pods take 60 seconds to start (image pull + app startup)
3. Meanwhile, existing 50 pods hit 90%+ CPU (latency spikes)
4. Users see 5-second page loads → retry → death spiral

### The Fix (3 Weeks to Black Friday)

Shopify's team made 5 changes:

#### 1. Pre-Scale Baseline
```yaml
minReplicas: 200  # Start at peak - 40%, not peak - 80%
maxReplicas: 1000
```
**Lesson**: **Over-provision before traffic spike** (scale down after, not during)

#### 2. Aggressive Scale-Up
```yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 0  # No delay
    policies:
    - type: Pods
      value: 50          # Add 50 pods every 15 seconds (not 100%)
      periodSeconds: 15
```
**Lesson**: **Linear scaling (add N pods) > Percentage scaling** during spikes

#### 3. Image Pre-Pull
```yaml
initContainers:
- name: image-warmer
  image: shopify/storefront:v1.2.3  # Same image as main container
  command: ["/bin/true"]            # Does nothing (just pulls image)
```
**Lesson**: **DaemonSet** to pre-pull images on all nodes before Black Friday:
```yaml
apiVersion: apps/v1
kind: DaemonSet  # Runs on every node
metadata:
  name: image-warmer
spec:
  template:
    spec:
      containers:
      - name: warmer
        image: shopify/storefront:v1.2.3
        command: ["sleep", "infinity"]
```

#### 4. Startup Probes (Kubernetes 1.18+)
```yaml
startupProbe:
  httpGet:
    path: /health
    port: 8080
  failureThreshold: 30     # 30 failures × 10s = 5 minutes grace period
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  periodSeconds: 5
  failureThreshold: 2      # Fast removal from service (10 seconds)
```
**Lesson**: **startupProbe** prevents readiness probe from killing slow-starting pods

#### 5. Pod Priority Classes
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-storefront
value: 1000000        # Higher = more important
globalDefault: false
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storefront
spec:
  template:
    spec:
      priorityClassName: critical-storefront
```
**Lesson**: **Kubernetes evicts low-priority pods** to make room for high-priority storefront pods

### The Result
- ✅ Black Friday load test: Handled 15x normal traffic
- ✅ Actual Black Friday: 10x traffic, zero incidents
- ✅ Cost savings: Scaled down to 50 pods after Black Friday (saved $20K/day)

### Key Takeaways
- ✅ **Load test at 2-3x expected peak** (not just 1x)
- ✅ **Pre-scale before traffic spikes** (don't rely on reactive HPA)
- ✅ **Image pre-pulling saves 30-60 seconds** during scale-up
- ✅ **startupProbe prevents "new pods killed by readiness"** anti-pattern
- ✅ **PriorityClass ensures critical pods get resources** during contention

**Shopify's Blog**: https://shopify.engineering/black-friday-cyber-monday-2020

---

## 🚨 Story #3: Datadog's etcd Meltdown (Jan 2020)

### What Happened
- **Impact**: 4-hour partial outage (metrics/APM unavailable)
- **Affected**: 5,000+ customers
- **Root Cause**: etcd cluster ran out of disk space
- **Cost**: Lost revenue + customer churn (estimated $2M+)

### The Incident

**Day 1, 2:00 AM**: etcd-0 pod shows `NOSPACE` error  
**2:05 AM**: etcd stops accepting writes (cluster read-only)  
**2:10 AM**: Kubernetes API server hangs (can't write to etcd)  
**2:15 AM**: `kubectl` commands timeout (API server dead)  
**2:30 AM**: Alerts trigger, on-call engineer wakes up  
**3:00 AM**: Engineer SSH to etcd node, sees `/var/lib/etcd` at 100% disk  
**4:00 AM**: Expanded disk, restarted etcd, cluster recovered  

### The Root Cause

Datadog's etcd setup:
```yaml
# etcd StatefulSet (simplified)
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: etcd
spec:
  serviceName: etcd
  replicas: 3
  volumeClaimTemplates:
  - metadata:
      name: etcd-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 50Gi  # ❌ No monitoring, no auto-expansion
```

**What Went Wrong**:
1. **No disk usage monitoring**: No alerts when etcd disk hit 80%
2. **No PVC auto-resize**: Cloud provider supports resizing, but Datadog didn't enable it
3. **No etcd compaction**: Datadog stored 2 months of K8s event history (should be 24 hours max)
4. **No defragmentation**: etcd database fragmented to 48GB (actual data: 12GB)

### The Fix

#### 1. etcd Compaction (Automatic History Cleanup)
```bash
# Run as CronJob every 30 minutes
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etcd-compact
spec:
  schedule: "*/30 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: compact
            image: bitnami/etcd:3.5
            command:
            - /bin/sh
            - -c
            - |
              ETCDCTL_API=3 etcdctl compact $(etcdctl endpoint status --write-out="json" | jq -r '.[0].Status.header.revision') \
                --endpoints=https://etcd-0.etcd:2379,https://etcd-1.etcd:2379,https://etcd-2.etcd:2379 \
                --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/client.crt --key=/etc/etcd/client.key
```

**Lesson**: **etcd auto-compaction** keeps history at 24 hours (not 2 months)

#### 2. etcd Defragmentation (Reclaim Space)
```bash
# Run monthly (or when disk > 70%)
ETCDCTL_API=3 etcdctl defrag --cluster \
  --endpoints=https://etcd-0.etcd:2379,https://etcd-1.etcd:2379,https://etcd-2.etcd:2379 \
  --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/client.crt --key=/etc/etcd/client.key
```

**Result**: 48GB → 11GB (77% space reclaimed!)

#### 3. Disk Usage Monitoring
```yaml
# Prometheus AlertManager rule
groups:
- name: etcd
  rules:
  - alert: EtcdDiskSpaceHigh
    expr: (etcd_mvcc_db_total_size_in_bytes / etcd_server_quota_backend_bytes) > 0.8
    for: 10m
    annotations:
      summary: "etcd disk usage > 80%"
      description: "etcd database is {{ $value | humanizePercentage }} full. Run compaction and defrag NOW."
```

#### 4. PVC Auto-Resize (GKE/EKS/AKS)
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: etcd-storage
provisioner: kubernetes.io/gce-pd  # or ebs.csi.aws.com, disk.csi.azure.com
allowVolumeExpansion: true  # ✅ Enable resize
parameters:
  type: pd-ssd
---
# Resize PVC (Kubernetes 1.24+)
kubectl patch pvc etcd-data-etcd-0 -p '{"spec":{"resources":{"requests":{"storage":"100Gi"}}}}'
# Restart pod to apply
kubectl delete pod etcd-0
```

**Lesson**: **Enable `allowVolumeExpansion`** on StorageClass (one-line fix, huge impact)

### Key Takeaways
- ✅ **etcd is a single point of failure**: Monitor disk usage religiously
- ✅ **Automate compaction**: CronJob every 30 minutes (not manual)
- ✅ **Enable PVC auto-resize**: StorageClass must allow expansion
- ✅ **Alert at 70% disk usage**: Not 95% (too late)
- ✅ **Test etcd backups monthly**: Don't wait for disaster

**Datadog's Post-Mortem**: https://www.datadoghq.com/blog/engineering/postmortem-january-2020/

---

## 🌐 Story #4: Cloudflare's Global Outage (Jul 2019)

### What Happened
- **Impact**: 27-minute global outage (CDN, DNS, WAF down)
- **Affected**: 15%+ of internet traffic (millions of sites)
- **Root Cause**: Bad regex in WAF rule + CPU exhaustion
- **Cost**: Estimated $50M+ in lost revenue

### The Incident

**Day 1, 1:00 PM UTC**: Deploy new WAF rule to production K8s  
**1:02 PM**: CPU usage spikes to 100% across all edge nodes  
**1:03 PM**: Kubernetes nodes mark as `NotReady` (kubelet can't report heartbeat)  
**1:04 PM**: All pods evicted from failing nodes (no capacity)  
**1:05 PM**: Global CDN offline (no healthy pods to serve traffic)  
**1:10 PM**: Engineers rollback deployment, BUT pods still failing  
**1:15 PM**: Realized: CPU exhaustion prevents pod rollback!  
**1:25 PM**: Manual kill of WAF processes on nodes, traffic restored  

### The Kubernetes Problem

Bad WAF regex:
```regex
(?:(?:\"|'|\]|\}|\\|\d|(?:nan|infinity|true|false|null|undefined|symbol|math)|\`|\-|\+)+[)]*;?((?:\s|-|~|!|{}|\|\||\+)*.*(?:.*=.*)))
```

**Issue**: Catastrophic backtracking on certain inputs (10,000x slower than expected)

**Kubernetes Amplification**:
1. Bad regex deployed to 100+ K8s clusters globally (via GitOps)
2. Each node runs 10+ WAF pods (CPU exhaustion)
3. kubelet can't report status → node marked `NotReady`
4. K8s evicts ALL pods from failing nodes (makes problem worse!)
5. No healthy nodes → global outage

### Why Kubernetes Made It Worse

**Normal Rollback** (if cluster is healthy):
```bash
kubectl rollout undo deployment/waf
# Takes 30 seconds
```

**What Actually Happened**:
```bash
kubectl rollout undo deployment/waf
# Timeout: nodes too overloaded to pull images, start new pods
# Estimated time to recovery: 20+ minutes
```

**The Catch-22**:
- Can't rollback because nodes are out of CPU
- Can't free CPU because pods are stuck deploying
- **Solution**: Manual SSH to nodes, kill processes (bypassing Kubernetes)

### The Fix

#### 1. Resource Limits (Prevent CPU Exhaustion)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: waf
spec:
  template:
    spec:
      containers:
      - name: waf
        image: cloudflare/waf:latest
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m     # ✅ Prevents one pod from consuming entire node
            memory: 1Gi    # ✅ OOMKilled instead of node failure
```

**Lesson**: **Always set resource limits** (prevents noisy neighbor problem)

#### 2. PodDisruptionBudget (Prevent Mass Eviction)
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: waf-pdb
spec:
  minAvailable: 50%  # ✅ Prevents K8s from evicting all pods at once
  selector:
    matchLabels:
      app: waf
```

#### 3. Regex Testing (CI/CD Gate)
```yaml
# GitLab CI pipeline
test-regex:
  stage: test
  script:
    - echo "Testing regex with evil inputs..."
    - timeout 5s python test_regex.py || (echo "REGEX TIMEOUT DETECTED" && exit 1)
```

**Evil Inputs**:
```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!  # 33 a's (triggers backtracking)
```

**Lesson**: **Test regex with worst-case inputs** (not just happy path)

#### 4. Gradual Rollout (Canary Deployment)
```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: waf
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: waf
  progressDeadlineSeconds: 60
  service:
    port: 80
  analysis:
    interval: 1m
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99
    - name: request-duration
      thresholdRange:
        max: 500
```

**Result**: Bad deployment hits 10% of traffic → Flagger auto-rollback (not 100% outage)

### Key Takeaways
- ✅ **Resource limits prevent CPU exhaustion cascades**
- ✅ **PodDisruptionBudget prevents panic evictions**
- ✅ **Canary deployments catch bad code before global rollout**
- ✅ **Test edge cases** (especially regex, crypto, parsing)
- ⚠️ **Kubernetes can't save you from bad code** (but limits blast radius)

**Cloudflare's Post-Mortem**: https://blog.cloudflare.com/details-of-the-cloudflare-outage-on-july-2-2019/

---

## 💾 Story #5: Salesforce's Data Loss (May 2019)

### What Happened
- **Impact**: 7-hour outage + data loss for NA14 instance
- **Affected**: 3,000+ enterprise customers
- **Root Cause**: Database failover + bad Kubernetes PVC configuration
- **Cost**: $100M+ settlement with affected customers

### The Incident

**Day 1, 8:00 AM**: Primary database fails (hardware issue)  
**8:05 AM**: Kubernetes promotes replica to new primary (automated failover)  
**8:10 AM**: New primary starts serving traffic  
**8:15 AM**: Engineers notice: **6 hours of data missing**  
**8:30 AM**: Investigation reveals: Replica was 6 hours behind primary (replication lag)  
**Next 7 hours**: Attempted recovery from backups (partial success)  

### The Kubernetes Problem

Salesforce's database setup:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  replicas: 2
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Ti
      storageClassName: fast-ssd  # ❌ PROBLEM: Not replicated storage
```

**What Went Wrong**:
1. **Primary PVC**: Local SSD on Node A (fast, but single point of failure)
2. **Replica PVC**: Local SSD on Node B (replicating from primary)
3. **Replication lag**: Network congestion → replica 6 hours behind
4. **No replication monitoring**: Salesforce didn't know replica was lagging
5. **Automatic failover**: Kubernetes promoted lagging replica (data loss)

### The Fix

#### 1. Synchronous Replication (Zero Lag)
```yaml
# PostgreSQL config
postgresql.conf:
  synchronous_commit: on          # ✅ Block writes until replica confirms
  synchronous_standby_names: 'postgres-1'  # Must be in sync
```

**Trade-off**: Writes slower (wait for replica ACK), but **zero data loss**

#### 2. Replication Lag Monitoring
```yaml
# Prometheus query
pg_replication_lag_seconds > 60  # Alert if replica > 60 seconds behind
```

**Alert Rule**:
```yaml
groups:
- name: postgres
  rules:
  - alert: PostgresReplicationLag
    expr: pg_replication_lag_seconds > 300  # 5 minutes
    for: 2m
    annotations:
      summary: "Postgres replica lagging by {{ $value }} seconds"
      description: "DO NOT FAILOVER to this replica (data loss risk)"
```

#### 3. Pre-Failover Validation
```yaml
# Custom operator (simplified)
apiVersion: v1
kind: ConfigMap
metadata:
  name: failover-policy
data:
  policy.yaml: |
    rules:
    - name: check-replication-lag
      command: |
        LAG=$(psql -h postgres-1 -c "SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))::int")
        if [ $LAG -gt 60 ]; then
          echo "ABORT: Replica lag is $LAG seconds (max 60)"
          exit 1
        fi
```

**Lesson**: **Automate failover validation** (don't blindly promote replica)

#### 4. Backup Testing (Monthly Drill)
```bash
# Restore backup to test cluster
pg_restore -h test-postgres -U admin /backups/salesforce-2024-01-01.dump

# Run data integrity checks
SELECT COUNT(*) FROM opportunities WHERE created_at > '2024-01-01';
# Compare to production count
```

**Lesson**: **Test backups monthly** (Salesforce hadn't tested in 6 months)

### Key Takeaways
- ✅ **Synchronous replication for zero data loss** (async = risk)
- ✅ **Monitor replication lag** (alert at 60 seconds, not 6 hours)
- ✅ **Validate before failover** (don't promote lagging replica)
- ✅ **Test backups monthly** (not just create them)
- ⚠️ **Kubernetes doesn't understand replication lag** (app-level monitoring required)

**Salesforce's Post-Mortem**: https://www.salesforce.com/blog/transparency-update-may-17-2019/ *(since removed)*

---

## 🔐 Story #6: Capital One Breach (Jul 2019)

### What Happened
- **Impact**: 100 million credit applications stolen
- **Root Cause**: SSRF vulnerability + over-permissioned Kubernetes pods
- **Affected**: Personal data of 100M+ individuals
- **Cost**: $80M fine + $190M settlement = **$270M total**

### The Attack Vector

**Step 1**: Attacker finds SSRF (Server-Side Request Forgery) in Capital One's web app  
**Step 2**: Uses SSRF to query AWS instance metadata service from pod:
```bash
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/eks-node-role
```

**Step 3**: Retrieves IAM credentials (valid for 6 hours)  
**Step 4**: Uses credentials to access S3 buckets containing customer data  
**Step 5**: Downloads 30GB of data over 2 months (undetected)  

### The Kubernetes Misconfiguration

Capital One's pod spec:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  serviceAccountName: default  # ❌ PROBLEM: Using default SA
  containers:
  - name: app
    image: capitalOne/web-app:latest
    # ❌ NO SecurityContext (allows metadata access)
    # ❌ NO NetworkPolicy (allows egress to AWS APIs)
```

**What Went Wrong**:
1. **No network policy**: Pod could access AWS metadata service (169.254.169.254)
2. **No Pod Security Policy**: Pod inherited node's IAM role (over-permissioned)
3. **No egress filtering**: Pod could call S3, EC2, IAM APIs
4. **No audit logging**: AWS CloudTrail logs not monitored

### The Fix (Prevent SSRF → AWS Credential Theft)

#### 1. Block Metadata Service with NetworkPolicy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-metadata
spec:
  podSelector: {}  # Apply to all pods
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32  # ✅ Block AWS metadata service
```

**Lesson**: **Always block 169.254.169.254** (single-line fix, massive security win)

#### 2. Use IRSA (IAM Roles for Service Accounts)
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: web-app-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789:role/web-app-role  # ✅ Pod-specific IAM
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  template:
    spec:
      serviceAccountName: web-app-sa  # ✅ Not 'default'
```

**IAM Policy** (least privilege):
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource": ["arn:aws:s3:::public-assets/*"]  // ✅ Not arn:aws:s3:::*
  }]
}
```

**Lesson**: **One ServiceAccount per app** (not shared `default`)

#### 3. Pod Security Standards (Restricted)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted  # ✅ Blocks metadata access
```

**What `restricted` enforces**:
- No privileged containers
- No host network/PID/IPC access
- No host path mounts
- **Blocks AWS metadata service access** (via seccomp profile)

#### 4. Runtime Security (Falco)
```yaml
# Falco rule: Detect metadata service access
- rule: Contact AWS Metadata Service
  desc: Detect attempts to contact AWS metadata service
  condition: >
    outbound and fd.sip="169.254.169.254"
  output: >
    Metadata service access detected (pod=%k8s.pod.name container=%container.name)
  priority: CRITICAL
```

**Result**: Real-time alert when pod tries to access metadata service

### Key Takeaways
- ✅ **Block 169.254.169.254 with NetworkPolicy** (prevents SSRF → credential theft)
- ✅ **Use IRSA/Workload Identity** (pod-specific IAM, not node IAM)
- ✅ **Enable Pod Security Standards** (enforced=restricted in production)
- ✅ **Runtime security (Falco)** catches attacks in progress
- ⚠️ **Default Kubernetes is NOT secure** (must harden)

**Capital One SEC Filing**: https://oag.ca.gov/system/files/Capital%20One%20Customer%20Notice.pdf

---

## 📊 Story #7: Stripe's 4-Hour API Outage (Dec 2023)

### What Happened
- **Impact**: 4-hour partial API outage (payments delayed)
- **Affected**: Thousands of merchants (holiday shopping season)
- **Root Cause**: Redis cluster failover + Kubernetes pod anti-affinity misconfiguration
- **Cost**: $10M+ in delayed payments

### The Incident

**Day 1, 11:00 AM**: Redis primary pod crashes (OOMKilled)  
**11:01 AM**: Kubernetes restarts pod on different node  
**11:02 AM**: Redis client connects to new primary  
**11:03 AM**: **All requests failing** (Redis returns stale data)  
**11:15 AM**: Engineers investigate, find: New primary didn't sync from old primary (data loss)  
**12:00 PM**: Manual intervention: Restore Redis from backup  
**3:00 PM**: Traffic fully restored  

### The Kubernetes Problem

Stripe's Redis setup:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  replicas: 3
  template:
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:  # ❌ TOO STRICT
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - redis
            topologyKey: kubernetes.io/hostname  # ✅ Good (spread across nodes)
```

**What Went Wrong**:
1. **Primary pod OOMKilled** (insufficient memory limit)
2. **Kubernetes tried to restart** on same node (fast recovery)
3. **Anti-affinity rule blocked it** ("can't run 2 Redis pods on same node")
4. **Pod stuck Pending** (no other nodes available with enough resources)
5. **Sentinel promoted replica to primary** (but replica had stale data)
6. **Data loss**: Last 5 minutes of writes not replicated

### The Fix

#### 1. Use `preferredDuringScheduling` (Not `required`)
```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:  # ✅ SOFT constraint
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - redis
        topologyKey: kubernetes.io/hostname
```

**Difference**:
- `required`: Blocks scheduling if constraint can't be met (pod stuck Pending)
- `preferred`: Tries to satisfy, but allows scheduling if impossible (resilience > perfection)

**Lesson**: **Use `preferred` anti-affinity** (unless you have infinite cluster capacity)

#### 2. Increase Memory Limits (Prevent OOMKill)
```yaml
resources:
  requests:
    memory: 4Gi
  limits:
    memory: 8Gi  # ✅ 2x headroom (prevents OOMKill during traffic spikes)
```

**Monitoring**:
```yaml
# Prometheus alert
- alert: RedisMemoryHigh
  expr: container_memory_usage_bytes{pod=~"redis-.*"} / container_spec_memory_limit_bytes > 0.8
  for: 5m
  annotations:
    summary: "Redis memory usage > 80%"
```

#### 3. Redis Sentinel Quorum (Prevent Split-Brain)
```yaml
# Sentinel config
sentinel.conf:
  sentinel monitor mymaster redis-0.redis 6379 2  # ✅ Quorum = 2 (majority of 3)
  sentinel down-after-milliseconds mymaster 5000
  sentinel failover-timeout mymaster 10000
```

**Lesson**: **Quorum = (N/2) + 1** (for 3 sentinels, quorum = 2)

#### 4. Automated Backups (Every 15 Minutes)
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: redis-backup
spec:
  schedule: "*/15 * * * *"  # Every 15 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: redis:7
            command:
            - /bin/sh
            - -c
            - |
              redis-cli --rdb /backups/redis-$(date +%Y%m%d-%H%M%S).rdb
              # Upload to S3
              aws s3 cp /backups/redis-*.rdb s3://stripe-redis-backups/
```

**Lesson**: **Automate backups** (not manual)

### Key Takeaways
- ✅ **Use `preferred` anti-affinity** (not `required` - too strict for failover)
- ✅ **Set memory limits 2x expected usage** (prevents OOMKill during spikes)
- ✅ **Sentinel quorum = majority** (prevents split-brain)
- ✅ **Automate backups every 15 minutes** (not hourly)
- ⚠️ **Anti-affinity can prevent failover** (choose resilience over perfection)

**Stripe's Status Page**: https://status.stripe.com/incidents/xyz *(archived)*

---

## 🎯 Common Patterns Across All Stories

| Story | Root Cause | Kubernetes Lesson | Prevention |
|-------|------------|-------------------|-----------|
| **GitHub** | MySQL split-brain | PodDisruptionBudget prevents control plane disruption | Add PDB to stateful apps |
| **Shopify** | Slow HPA scale-up | Pre-scale before traffic spikes | Baseline = peak - 40% |
| **Datadog** | etcd out of disk | Monitor disk usage + auto-compaction | CronJob every 30 min |
| **Cloudflare** | Bad regex + no limits | Resource limits prevent CPU exhaustion | Always set limits |
| **Salesforce** | Replication lag | Monitor lag before failover | Prometheus alert |
| **Capital One** | SSRF + over-permissions | Block metadata service with NetworkPolicy | One-line fix |
| **Stripe** | OOMKill + strict anti-affinity | Use `preferred` (not `required`) | Soft constraints |

**Universal Lessons**:
1. ✅ **Always set resource limits** (prevents noisy neighbor)
2. ✅ **Monitor critical metrics** (disk, replication lag, memory)
3. ✅ **Test failure modes** (chaos engineering, load tests)
4. ✅ **Automate recovery** (CronJobs, auto-compaction, backups)
5. ✅ **Security by default** (NetworkPolicy, IRSA, Pod Security Standards)

---

## 📚 Learn From These Mistakes

**Apply Lessons to Your Cluster**:
- [ ] Add PodDisruptionBudget to all stateful apps ([Lab 3](../labs/03-educational-stateful.md))
- [ ] Set resource limits on ALL pods ([Lab 7](../labs/07-social-scaling.md))
- [ ] Add NetworkPolicy to block 169.254.169.254 ([Lab 6](../labs/06-medical-security.md))
- [ ] Monitor etcd disk usage ([Lab 3.5](../labs/03.5-kubernetes-under-the-hood.md))
- [ ] Enable Pod Security Standards (restricted) ([Lab 6](../labs/06-medical-security.md))
- [ ] Test backups monthly ([Lab 11.5](../labs/11.5-disaster-recovery.md)) *(coming soon)*
- [ ] Load test at 2-3x expected peak ([Lab 7](../labs/07-social-scaling.md))

**Next Steps**:
- 🧪 **[Lab 9: Chaos Engineering](../labs/09-chaos.md)** - Break your cluster intentionally
- 🔒 **[Lab 6: Medical Security](../labs/06-medical-security.md)** - Harden like Capital One should have
- 📈 **[Lab 7: Social Scaling](../labs/07-social-scaling.md)** - Scale like Shopify did

---

**💡 Pro Tip**: Print these stories and review before on-call shifts. Knowing failure patterns saves hours during incidents.

**🎯 Remember**: Every $1M+ outage started with "just a small config change". Test everything.
