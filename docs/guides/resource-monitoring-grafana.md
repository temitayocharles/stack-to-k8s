# Resource Monitoring with Grafana 📊

Track actual vs documented resource usage across all labs. Set up Grafana dashboards to monitor CPU, memory, and storage consumption in real-time.

---

## 🎯 Overview

This guide helps you set up comprehensive resource monitoring to:
- **Validate** documented resource requirements against actual usage
- **Optimize** resource allocation for cost efficiency  
- **Debug** performance issues with visual insights
- **Plan** cluster capacity for production workloads

---

## 📋 Prerequisites

- Kubernetes cluster running (Rancher Desktop, kind, or k3d)
- `kubectl` configured and working
- `helm` installed (for Prometheus + Grafana setup)
- Completed at least Lab 1-3 for baseline metrics

---

## 🚀 Quick Setup (15 minutes)

### 1. Install Monitoring Stack

```bash
# Add Prometheus community charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false

# Wait for deployment
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
```

### 2. Access Grafana Dashboard

```bash
# Port forward Grafana
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80 &

# Access Grafana
echo "Grafana: http://localhost:3000"
echo "Username: admin"
echo "Password: admin123"

# Open in browser
open http://localhost:3000
```

---

## 📊 Essential Dashboards

### Import Lab Resource Dashboards

1. **Go to Grafana** → `+` → `Import`
2. **Import these dashboard IDs**:
   - **315** - Kubernetes cluster monitoring
   - **8588** - Kubernetes pod monitoring  
   - **6417** - Kubernetes resource requests vs usage
   - **13332** - Kubernetes capacity planning

### Custom Lab Tracking Dashboard

Create a custom dashboard to track lab-specific metrics:

```json
{
  "dashboard": {
    "title": "Lab Resource Tracking",
    "panels": [
      {
        "title": "CPU Usage by Lab",
        "targets": [
          {
            "expr": "sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace)",
            "legendFormat": "{{ namespace }}"
          }
        ]
      },
      {
        "title": "Memory Usage by Lab", 
        "targets": [
          {
            "expr": "sum(container_memory_working_set_bytes) by (namespace) / 1024 / 1024 / 1024",
            "legendFormat": "{{ namespace }} GB"
          }
        ]
      }
    ]
  }
}
```

---

## 🔍 Lab-Specific Monitoring

### Lab 1: Weather App Baseline
```bash
# Check weather app resource usage
kubectl top pods -n weather-lab
kubectl describe pod -n weather-lab | grep -A5 "Requests\|Limits"

# Compare with documented requirements (from resource-requirements.md)
echo "Documented: 0.5 cores, 512MB"
echo "Actual usage shown in Grafana..."
```

### Lab 8: Multi-App Resource Analysis
```bash
# Monitor all 6 apps simultaneously  
kubectl get pods -A | grep -E "(weather|ecom|edu|task|medical|social)"

# Grafana query for total multi-app usage:
# sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace) 
# where namespace in (weather-lab, ecom-lab, edu-lab, task-lab, medical-lab, social-lab)
```

### Lab 13: AI/ML GPU Monitoring
```bash
# Check GPU utilization (if available)
kubectl get nodes -o jsonpath='{.items[*].status.allocatable.nvidia\.com/gpu}'

# GPU-specific Grafana queries:
# nvidia_gpu_duty_cycle
# nvidia_gpu_memory_used_bytes
```

---

## 📈 Key Metrics to Track

### CPU Metrics
- **`container_cpu_usage_seconds_total`** - Total CPU usage
- **`kube_pod_container_resource_requests{resource="cpu"}`** - CPU requests
- **`kube_pod_container_resource_limits{resource="cpu"}`** - CPU limits

### Memory Metrics  
- **`container_memory_working_set_bytes`** - Active memory usage
- **`kube_pod_container_resource_requests{resource="memory"}`** - Memory requests
- **`container_memory_usage_bytes`** - Total memory allocated

### Storage Metrics
- **`kubelet_volume_stats_used_bytes`** - PV disk usage
- **`kube_persistentvolume_capacity_bytes`** - PV total capacity
- **`container_fs_usage_bytes`** - Container filesystem usage

### Network Metrics
- **`container_network_receive_bytes_total`** - Ingress traffic
- **`container_network_transmit_bytes_total`** - Egress traffic

---

## 🎯 Validation Queries

### Compare Documented vs Actual Usage

```promql
# CPU: Documented vs Actual (Lab 2 E-commerce example)
# Documented: 1 core = 1000m
# Query actual usage:
sum(rate(container_cpu_usage_seconds_total{namespace="ecom-lab"}[5m])) * 1000

# Memory: Documented vs Actual
# Documented: 1GB = 1073741824 bytes  
# Query actual usage:
sum(container_memory_working_set_bytes{namespace="ecom-lab"}) / 1073741824
```

### Resource Efficiency Analysis

```promql
# CPU utilization percentage
(sum(rate(container_cpu_usage_seconds_total[5m])) by (pod) / 
 sum(kube_pod_container_resource_requests{resource="cpu"}) by (pod)) * 100

# Memory utilization percentage  
(sum(container_memory_working_set_bytes) by (pod) /
 sum(kube_pod_container_resource_requests{resource="memory"}) by (pod)) * 100
```

---

## 🚨 Alerting Rules

### Resource Threshold Alerts

```yaml
# Save as prometheus-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: lab-resource-alerts
  namespace: monitoring
spec:
  groups:
  - name: lab.rules
    rules:
    - alert: LabHighCPUUsage
      expr: sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace) > 2
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "Lab {{ $labels.namespace }} using high CPU"
        
    - alert: LabHighMemoryUsage  
      expr: sum(container_memory_working_set_bytes) by (namespace) / 1073741824 > 4
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "Lab {{ $labels.namespace }} using high memory"
```

Apply the rules:
```bash
kubectl apply -f prometheus-rules.yaml
```

---

## 🔧 Troubleshooting

### Common Issues

**Grafana shows "No data"**
```bash
# Check Prometheus is scraping
kubectl get servicemonitors -n monitoring
kubectl logs -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0

# Verify metrics endpoint
kubectl get --raw /metrics | head -10
```

**High resource usage alerts**
```bash
# Check for resource-hungry pods
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory

# Identify resource leaks
kubectl get events -A | grep -i "evicted\|oom"
```

**Missing GPU metrics**
```bash
# Install nvidia-device-plugin (for GPU nodes)
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/main/nvidia-device-plugin.yml

# Verify GPU visibility
kubectl describe nodes | grep nvidia.com/gpu
```

---

## 🎯 Lab Validation Checklist

Use this checklist after each lab to validate resource requirements:

### ✅ Lab Resource Validation
- [ ] **Grafana accessible** at http://localhost:3000
- [ ] **Lab namespace visible** in monitoring 
- [ ] **CPU usage ≤ documented requirements** (±20% acceptable)
- [ ] **Memory usage ≤ documented requirements** (±20% acceptable)  
- [ ] **No OOMKilled containers** in the last hour
- [ ] **No resource-related evictions** during lab
- [ ] **Response times acceptable** (<2s for web UIs)

### 📊 Documentation Updates
If actual usage significantly differs from documented requirements:
1. **Update** `resource-requirements.md` with actual values
2. **Add notes** about resource spikes or optimizations
3. **Create issue** for resource requirement review

---

## 📚 Advanced Monitoring

### Custom Metrics Collection

Add application-specific metrics to your apps:

```yaml
# Example: Weather app custom metrics
apiVersion: v1
kind: ConfigMap
metadata:
  name: weather-app-metrics
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'weather-app'
      static_configs:
      - targets: ['weather-app:8080']
      metrics_path: /metrics
```

### Multi-Cluster Monitoring

For production-like monitoring across multiple clusters:

```bash
# Install Thanos for multi-cluster metrics
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install thanos bitnami/thanos \
  --set query.enabled=true \
  --set queryFrontend.enabled=true \
  --set compactor.enabled=true
```

---

## 🔗 Related Resources

- **[Resource Requirements Guide](../reference/resource-requirements.md)** - Planning and requirements
- **[kubectl Cheatsheet](../reference/kubectl-cheatsheet.md)** - Resource management commands  
- **[Troubleshooting Guide](../troubleshooting/troubleshooting.md)** - Fixing resource issues
- **[Prometheus Docs](https://prometheus.io/docs/)** - Advanced Prometheus configuration
- **[Grafana Docs](https://grafana.com/docs/)** - Dashboard creation and customization

---

**💡 Pro Tip**: Set up monitoring before Lab 8 (Multi-App) to track resource consumption patterns across all applications simultaneously.