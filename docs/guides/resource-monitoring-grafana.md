# Resource Monitoring with Grafana 📊

Track actual vs. documented resource usage across all labs using Prometheus + Grafana.

**Time**: 45 minutes  
**Prerequisites**: Helm installed, basic kubectl knowledge  
**Cluster**: Works with any local cluster (kind, k3d, Rancher Desktop, Docker Desktop)

---

## 🎯 What You'll Learn

- Deploy Prometheus + Grafana stack using kube-prometheus-stack Helm chart
- Create custom dashboards to track CPU, memory, disk usage per lab
- Set up alerts when resources exceed documented limits
- Compare actual usage vs. [documented requirements](../reference/resource-requirements.md)
- Identify resource optimization opportunities

---

## 📊 Why Monitor Lab Resources?

**The Problem**: Labs document resource requests/limits, but actual usage may differ:
- **Over-provisioned**: Lab requests 2GB RAM but uses 500MB → Wasted resources
- **Under-provisioned**: Lab requests 1GB RAM but uses 1.5GB → OOMKilled pods
- **Drift**: Code changes after documentation → Requirements become outdated

**The Solution**: Continuous monitoring shows **real usage** so you can:
1. Right-size resource requests/limits
2. Update documentation with accurate values
3. Optimize cluster capacity planning

---

## 🚀 Quick Start

### Step 1: Install kube-prometheus-stack

The `kube-prometheus-stack` Helm chart includes:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and notifications
- **Node Exporter**: Hardware and OS metrics
- **kube-state-metrics**: Kubernetes object metrics

```bash
# Add Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install kube-prometheus-stack (customized for labs)
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.retention=7d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi
```

**Wait for all pods to be Ready** (takes 2-3 minutes):
```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
```

---

### Step 2: Access Grafana

**Port-forward to Grafana**:
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

**Open in browser**: http://localhost:3000  
**Login**:
- Username: `admin`
- Password: `admin123`

---

### Step 3: Import Lab Resource Dashboard

We've created a custom dashboard JSON that tracks resources per lab namespace.

**Dashboard File**: [`shared-k8s/monitoring/grafana-lab-resources-dashboard.json`](../../shared-k8s/monitoring/grafana-lab-resources-dashboard.json)

**Import steps**:
1. In Grafana, click **+ → Import** (left sidebar)
2. Click **Upload JSON file**
3. Select `shared-k8s/monitoring/grafana-lab-resources-dashboard.json`
4. Select **Prometheus** as the data source
5. Click **Import**

**Dashboard includes**:
- **CPU Usage**: Actual usage vs. requests vs. limits (per namespace)
- **Memory Usage**: Actual usage vs. requests vs. limits (per namespace)
- **Pod Count**: Running pods per lab
- **Network I/O**: Bytes sent/received
- **Disk Usage**: PVC utilization
- **Container Restarts**: Detect crashloops

---

## 📈 Dashboard Panels Explained

### Panel 1: CPU Usage by Lab Namespace

**PromQL Query**:
```promql
sum(rate(container_cpu_usage_seconds_total{namespace=~".*-lab|monitoring"}[5m])) by (namespace)
```

**Shows**: 
- Blue line: Actual CPU usage (averaged over 5 minutes)
- Yellow threshold: CPU requests (from manifests)
- Red threshold: CPU limits (from manifests)

**What to look for**:
- ✅ Usage stays below requests → Right-sized
- ⚠️ Usage near limits → May throttle, increase limits
- 💰 Usage far below requests → Over-provisioned, reduce requests

---

### Panel 2: Memory Usage by Lab Namespace

**PromQL Query**:
```promql
sum(container_memory_working_set_bytes{namespace=~".*-lab|monitoring"}) by (namespace)
```

**Shows**:
- Blue line: Actual memory usage (working set)
- Yellow threshold: Memory requests
- Red threshold: Memory limits

**What to look for**:
- ✅ Usage between 50-80% of requests → Well-sized
- ⚠️ Usage near limits → Risk of OOMKill, increase limits
- 💰 Usage < 30% of requests → Over-provisioned

---

### Panel 3: Pod Count vs. Expected

**PromQL Query**:
```promql
count(kube_pod_info{namespace=~".*-lab"}) by (namespace)
```

**Shows**: Number of running pods per lab namespace

**Compare to documentation**:
- Lab 1: 4 pods (Weather App)
- Lab 2: 7 pods (E-commerce)
- Lab 3: 5 pods (Educational Platform)
- Lab 4: 5 pods (Fundamentals)
- Lab 5: 5 pods (Task Manager + Ingress)
- Lab 6: 5 pods (Medical System)
- Lab 7: 8 pods (Social Media + Autoscaling)
- Lab 8: 33 pods (All apps)
- Lab 9: 12 pods (Chaos Engineering)
- Lab 10: 7 pods (Helm)
- Lab 11: 8 pods (ArgoCD)
- Lab 12: 10 pods (External Secrets)

**What to look for**:
- More pods than expected → Deployments scaled up or replicas increased
- Fewer pods than expected → Pods crashlooping or not scheduled

---

### Panel 4: Network Traffic by Namespace

**PromQL Query (Transmit)**:
```promql
sum(rate(container_network_transmit_bytes_total{namespace=~".*-lab"}[5m])) by (namespace)
```

**Shows**: Network bytes sent/received per second

**Use case**: Identify chatty microservices or heavy inter-service communication

---

### Panel 5: Persistent Volume Usage

**PromQL Query**:
```promql
(kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes) * 100
```

**Shows**: PVC disk usage percentage

**What to look for**:
- > 80% → Increase PVC size or add cleanup jobs
- Rapid growth → Log/data retention issues

---

## 🔔 Setting Up Alerts

### Alert 1: Memory Near Limit

Alert when any lab uses > 90% of memory limit (risk of OOMKill).

**Create Alert Rule** (Grafana UI):
1. Go to **Alerting → Alert rules → New alert rule**
2. Name: `Lab Memory Near Limit`
3. Query:
   ```promql
   (container_memory_working_set_bytes{namespace=~".*-lab"} / 
    kube_pod_container_resource_limits{resource="memory", namespace=~".*-lab"}) > 0.9
   ```
4. Condition: When query returns > 0
5. Threshold: 0.9 (90%)
6. Evaluation: Every 1m for 5m
7. Add annotation: `Lab {{ $labels.namespace }} is using {{ $value }}% of memory limit`

**Notification Channel**: Configure email/Slack in **Alerting → Contact points**

---

### Alert 2: CPU Throttling Detected

Alert when CPU is throttled (hitting limits).

**Query**:
```promql
rate(container_cpu_cfs_throttled_seconds_total{namespace=~".*-lab"}[5m]) > 0.1
```

**Meaning**: Container is being throttled > 10% of the time

**Action**: Increase CPU limits in deployment manifests

---

### Alert 3: Pod Restart Loop

Alert when pod restarts > 5 times in 10 minutes.

**Query**:
```promql
rate(kube_pod_container_status_restarts_total{namespace=~".*-lab"}[10m]) > 0.5
```

**Action**: Check pod logs, resource limits, liveness/readiness probes

---

## 📋 Comparing Actual vs. Documented Resources

### Generate Comparison Report

Use this script to export actual usage and compare to documented values:

```bash
#!/bin/bash
# Compare actual usage vs documented requirements

echo "Lab Resource Comparison Report"
echo "=============================="
echo ""

# Get documented requirements
echo "📊 Documented Requirements:"
./scripts/calculate-lab-resources.sh --list

echo ""
echo "📈 Actual Usage (Current):"

for ns in weather-lab ecommerce-lab educational-lab task-lab medical-lab social-lab; do
  if kubectl get ns $ns &>/dev/null; then
    echo ""
    echo "Namespace: $ns"
    
    # CPU usage
    cpu=$(kubectl top pods -n $ns --no-headers | awk '{sum+=$2} END {print sum}')
    echo "  CPU: ${cpu}m"
    
    # Memory usage
    mem=$(kubectl top pods -n $ns --no-headers | awk '{sum+=$3} END {print sum}')
    echo "  Memory: ${mem}Mi"
    
    # Pod count
    pods=$(kubectl get pods -n $ns --no-headers | wc -l)
    echo "  Pods: $pods"
  fi
done
```

**Save as**: `scripts/compare-actual-vs-documented.sh`

**Run**:
```bash
chmod +x scripts/compare-actual-vs-documented.sh
./scripts/compare-actual-vs-documented.sh
```

---

## 🔍 Analyzing Resource Patterns

### Pattern 1: Morning Spike

**Observation**: CPU spikes every morning at 9 AM  
**Cause**: HPA scales up when simulating user traffic  
**Action**: Increase min replicas or pre-scale before expected load

---

### Pattern 2: Memory Leak

**Observation**: Memory usage steadily increases over hours  
**Cause**: Application bug (objects not garbage collected)  
**Action**: Fix code, add memory limit, enable automatic restarts

---

### Pattern 3: Idle Waste

**Observation**: Pods use < 10% of requested resources  
**Action**: Reduce resource requests to free up capacity

---

## 🛠️ Advanced: Custom Metrics

### Track Application-Specific Metrics

**Example**: Track "completed tasks" metric from Task Manager app

**1. Expose custom metrics** in application code (Go example):
```go
import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var tasksCompleted = prometheus.NewCounter(
    prometheus.CounterOpts{
        Name: "tasks_completed_total",
        Help: "Total number of completed tasks",
    },
)

func init() {
    prometheus.MustRegister(tasksCompleted)
}

// In your HTTP server
http.Handle("/metrics", promhttp.Handler())
```

**2. Create ServiceMonitor** to scrape metrics:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: task-manager-metrics
  namespace: task-lab
spec:
  selector:
    matchLabels:
      app: task-backend
  endpoints:
  - port: metrics
    interval: 30s
```

**3. Query in Grafana**:
```promql
rate(tasks_completed_total[5m])
```

---

## 🧹 Cleanup

### Remove Monitoring Stack

```bash
# Delete Helm release
helm uninstall kube-prometheus-stack -n monitoring

# Delete namespace (removes PVCs)
kubectl delete namespace monitoring
```

**Note**: This removes all metrics history. Export dashboards first if needed.

---

## 📚 Next Steps

- **Optimize Resources**: Use insights to right-size requests/limits in manifests
- **Update Documentation**: Refresh [resource-requirements.md](../reference/resource-requirements.md) with actual values
- **Set up CI/CD**: Automate resource validation in pre-commit hooks
- **Production Monitoring**: Add Alertmanager integrations (PagerDuty, Slack, email)

---

## 🔗 Related Resources

- [Resource Requirements Guide](../reference/resource-requirements.md) - Documented resource values
- [Resource Calculator Script](../../scripts/calculate-lab-resources.sh) - Calculate aggregate resources
- [Prometheus Documentation](https://prometheus.io/docs/) - Official Prometheus docs
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/) - Community dashboard library
- [kube-prometheus-stack Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) - Helm chart details

---

## 🐛 Troubleshooting

### Issue: Grafana pod stuck in Pending

**Cause**: Insufficient resources or PVC not bound  
**Solution**:
```bash
# Check pod events
kubectl describe pod -n monitoring -l app.kubernetes.io/name=grafana

# Check PVC
kubectl get pvc -n monitoring

# Reduce retention if disk space is limited
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set prometheus.prometheusSpec.retention=2d \
  --reuse-values
```

---

### Issue: Prometheus scrape errors

**Cause**: ServiceMonitors not created or endpoints not reachable  
**Solution**:
```bash
# Check ServiceMonitors
kubectl get servicemonitors -n monitoring

# Check Prometheus targets
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Open http://localhost:9090/targets
# Look for RED targets → Check service/pod labels match ServiceMonitor selector
```

---

### Issue: Dashboard shows "No data"

**Cause**: Prometheus not scraping namespaces or data source not configured  
**Solution**:
```bash
# Verify Prometheus data source in Grafana
# Settings → Data Sources → Prometheus → Test

# Check if metrics exist
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Query: up{namespace="weather-lab"}

# If no data, check ServiceMonitor configuration
```

---

## 💡 Pro Tips

1. **Dashboard Annotations**: Mark deployments/experiments on timeline
   ```
   Dashboard → Settings → Annotations → Add annotation query
   ```

2. **Variable Namespaces**: Create dropdown to filter by lab
   ```
   Dashboard → Settings → Variables → Add variable
   Name: namespace
   Query: label_values(kube_pod_info, namespace)
   ```

3. **Export Metrics**: Download time-series data for analysis
   ```bash
   # Query Prometheus HTTP API
   curl 'http://localhost:9090/api/v1/query_range?query=container_memory_usage_bytes&start=2024-01-01T00:00:00Z&end=2024-01-02T00:00:00Z&step=5m'
   ```

4. **Snapshot for Comparison**: Take dashboard snapshots before/after optimizations
   ```
   Dashboard → Share → Snapshot → Create Snapshot
   ```

---

**🎉 You now have full observability into lab resource usage!** Use these insights to optimize cluster capacity and keep documentation accurate.
