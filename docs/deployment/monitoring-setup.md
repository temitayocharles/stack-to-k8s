# 📊 Monitoring & Observability - Enterprise-Grade Insights

**Goal**: Set up comprehensive monitoring like Netflix, Uber, and other tech giants.

> **Perfect for**: "I want to monitor my applications like a pro"

## 🎯 What You'll Build
- ✅ **Prometheus** for metrics collection (50+ application metrics)
- ✅ **Grafana** for beautiful dashboards and visualization
- ✅ **AlertManager** for intelligent alerting and notifications
- ✅ **Application performance monitoring** with custom metrics
- ✅ **Infrastructure monitoring** for nodes, pods, and services

## 📋 Before You Start
**Required time**: 2-3 hours  
**Prerequisites**: Kubernetes cluster running with your applications  
**Skills needed**: Basic kubectl knowledge

## 🚀 Phase 1: Prometheus Setup (45 minutes)

### Step 1: Install Prometheus Operator
```bash
# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install kube-prometheus-stack (includes Prometheus, Grafana, AlertManager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.retention=30d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
  --set grafana.adminPassword=admin123 \
  --set alertmanager.enabled=true
```

### Step 2: Verify Installation
```bash
# Check if all components are running
kubectl get pods -n monitoring

# You should see:
# ✅ prometheus-prometheus-kube-prometheus-prometheus-0
# ✅ prometheus-grafana-xxx
# ✅ prometheus-kube-prometheus-operator-xxx
# ✅ alertmanager-prometheus-kube-prometheus-alertmanager-0
```

### Step 3: Access Prometheus
```bash
# Port forward to access Prometheus UI
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open browser: http://localhost:9090
# You'll see Prometheus Query interface
```

## 📈 Phase 2: Grafana Dashboard Setup (30 minutes)

### Step 1: Access Grafana
```bash
# Port forward to access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Open browser: http://localhost:3000
# Login: admin / admin123
```

### Step 2: Import Application Dashboard
Create custom dashboard for your applications:

1. **Click "+"** → **"Import"**
2. **Paste this JSON configuration**:

```json
{
  "dashboard": {
    "id": null,
    "title": "Application Performance Dashboard",
    "tags": ["application"],
    "timezone": "browser",
    "panels": [
      {
        "title": "HTTP Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ],
        "yAxes": [
          {
            "label": "Requests per second"
          }
        ]
      },
      {
        "title": "Response Time (95th percentile)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "singlestat",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m]) / rate(http_requests_total[5m])"
          }
        ],
        "format": "percent"
      },
      {
        "title": "Active Users",
        "type": "singlestat",
        "targets": [
          {
            "expr": "active_users_total"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
```

### Step 3: Create Node Monitoring Dashboard
1. **Click "+"** → **"Import"**
2. **Enter dashboard ID**: `1860` (Node Exporter Full)
3. **Click "Load"** → **"Import"**

You'll now see comprehensive node metrics including:
- ✅ CPU usage across all cores
- ✅ Memory utilization and available RAM
- ✅ Disk I/O and storage usage
- ✅ Network traffic and packet rates

## ⚡ Phase 3: Application Metrics Integration (60 minutes)

### Step 1: Add Metrics to Your Application

**For Node.js applications** (in your backend code):
```javascript
// Install prometheus client
// npm install prom-client

const client = require('prom-client');

// Create metrics
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'status', 'route']
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const activeUsers = new client.Gauge({
  name: 'active_users_total',
  help: 'Number of active users'
});

// Middleware to collect metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration.observe({ method: req.method, route: req.route?.path || req.path }, duration);
    httpRequestsTotal.inc({ method: req.method, status: res.statusCode, route: req.route?.path || req.path });
  });
  
  next();
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(client.register.metrics());
});

// Update active users (example)
setInterval(() => {
  // Your logic to count active users
  const activeUserCount = getActiveUserCount();
  activeUsers.set(activeUserCount);
}, 30000);
```

**For Python applications**:
```python
# pip install prometheus_client

from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
from flask import Flask, Response
import time

app = Flask(__name__)

# Create metrics
http_requests_total = Counter('http_requests_total', 'Total HTTP requests', ['method', 'status', 'route'])
http_request_duration = Histogram('http_request_duration_seconds', 'HTTP request duration', ['method', 'route'])
active_users = Gauge('active_users_total', 'Number of active users')

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    duration = time.time() - request.start_time
    http_request_duration.labels(method=request.method, route=request.endpoint).observe(duration)
    http_requests_total.labels(method=request.method, status=response.status_code, route=request.endpoint).inc()
    return response

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
```

### Step 2: Configure Service Monitor
Create `monitoring/service-monitor.yaml`:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-metrics
  namespace: monitoring
  labels:
    app: my-app
spec:
  selector:
    matchLabels:
      app: my-app-backend
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
---
apiVersion: v1
kind: Service
metadata:
  name: backend-metrics
  namespace: default
  labels:
    app: my-app-backend
spec:
  ports:
  - name: metrics
    port: 8080
    targetPort: 8080
  selector:
    app: backend
```

### Step 3: Deploy Service Monitor
```bash
# Apply the service monitor
kubectl apply -f monitoring/service-monitor.yaml

# Verify Prometheus is scraping your application
# Go to Prometheus UI: http://localhost:9090
# Navigate to Status > Targets
# Look for your application endpoints
```

## 🚨 Phase 4: Alerting Setup (45 minutes)

### Step 1: Configure AlertManager
Create `monitoring/alertmanager-config.yaml`:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-prometheus-kube-prometheus-alertmanager
  namespace: monitoring
type: Opaque
stringData:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: 'alerts@yourcompany.com'
      smtp_auth_username: 'alerts@yourcompany.com'
      smtp_auth_password: 'your-app-password'
      
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
      routes:
      - match:
          severity: critical
        receiver: 'critical-alerts'
      - match:
          severity: warning
        receiver: 'warning-alerts'
    
    receivers:
    - name: 'web.hook'
      webhook_configs:
      - url: 'http://127.0.0.1:5001/'
        
    - name: 'critical-alerts'
      email_configs:
      - to: 'oncall@yourcompany.com'
        subject: 'CRITICAL: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
      slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#alerts'
        title: 'CRITICAL ALERT'
        text: '{{ .CommonAnnotations.summary }}'
        
    - name: 'warning-alerts'
      email_configs:
      - to: 'team@yourcompany.com'
        subject: 'WARNING: {{ .GroupLabels.alertname }}'
```

### Step 2: Create Alert Rules
Create `monitoring/alert-rules.yaml`:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
  namespace: monitoring
  labels:
    prometheus: kube-prometheus
    role: alert-rules
spec:
  groups:
  - name: application.rules
    rules:
    
    # High Error Rate Alert
    - alert: HighErrorRate
      expr: |
        (
          rate(http_requests_total{status=~"5.."}[5m]) /
          rate(http_requests_total[5m])
        ) > 0.05
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value | humanizePercentage }} for the last 5 minutes"
        
    # High Response Time Alert
    - alert: HighLatency
      expr: |
        histogram_quantile(0.95, 
          rate(http_request_duration_seconds_bucket[5m])
        ) > 2.0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High response time detected"
        description: "95th percentile latency is {{ $value }}s"
        
    # Low Success Rate Alert
    - alert: LowSuccessRate
      expr: |
        (
          rate(http_requests_total{status=~"2.."}[5m]) /
          rate(http_requests_total[5m])
        ) < 0.95
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Low success rate detected"
        description: "Success rate is {{ $value | humanizePercentage }}"
        
    # Pod Crash Looping
    - alert: PodCrashLooping
      expr: |
        rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is restarting frequently"
        
    # High Memory Usage
    - alert: HighMemoryUsage
      expr: |
        (
          container_memory_usage_bytes{name!=""} /
          container_spec_memory_limit_bytes{name!=""}
        ) > 0.9
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage detected"
        description: "Container {{ $labels.name }} memory usage is {{ $value | humanizePercentage }}"
        
    # Database Connection Issues
    - alert: DatabaseConnectionFailing
      expr: |
        mysql_up == 0 or postgres_up == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Database connection failed"
        description: "Cannot connect to database"
        
  - name: infrastructure.rules
    rules:
    
    # Node Down Alert
    - alert: NodeDown
      expr: up{job="node-exporter"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Node is down"
        description: "Node {{ $labels.instance }} has been down for more than 5 minutes"
        
    # High CPU Usage
    - alert: HighCPUUsage
      expr: |
        100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "CPU usage is {{ $value }}% on {{ $labels.instance }}"
        
    # Disk Space Low
    - alert: DiskSpaceLow
      expr: |
        (
          node_filesystem_avail_bytes /
          node_filesystem_size_bytes
        ) < 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Disk space low"
        description: "Disk space is {{ $value | humanizePercentage }} full on {{ $labels.instance }}"
```

### Step 3: Deploy Alerts
```bash
# Apply alerting configuration
kubectl apply -f monitoring/alertmanager-config.yaml
kubectl apply -f monitoring/alert-rules.yaml

# Restart AlertManager to pick up new config
kubectl rollout restart statefulset/alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring

# Check AlertManager UI
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
# Open: http://localhost:9093
```

## 📱 Phase 5: Advanced Monitoring Features (30 minutes)

### Step 1: Custom Business Metrics
Add business-specific metrics to your application:

```javascript
// E-commerce specific metrics
const ordersTotal = new client.Counter({
  name: 'orders_total',
  help: 'Total number of orders',
  labelNames: ['status', 'payment_method']
});

const revenue = new client.Gauge({
  name: 'revenue_total',
  help: 'Total revenue generated'
});

const inventoryLevel = new client.Gauge({
  name: 'inventory_level',
  help: 'Current inventory level',
  labelNames: ['product_id', 'category']
});

// Track orders
app.post('/api/orders', (req, res) => {
  // Your order processing logic
  
  // Record metrics
  ordersTotal.inc({ status: 'pending', payment_method: req.body.paymentMethod });
  revenue.inc(req.body.amount);
});
```

### Step 2: Create Business Dashboard
In Grafana, create a new dashboard with:

1. **Revenue metrics**:
   - Query: `rate(revenue_total[5m])`
   - Panel type: Graph

2. **Order rate**:
   - Query: `rate(orders_total[5m])`
   - Panel type: Graph with different colors per status

3. **Inventory alerts**:
   - Query: `inventory_level < 10`
   - Panel type: Table

### Step 3: Set Up Log Monitoring (Optional)
```bash
# Install Loki for log aggregation
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set prometheus.enabled=false

# Configure log shipping from your applications
# Add to your pod spec:
# annotations:
#   prometheus.io/scrape: "true"
#   prometheus.io/port: "8080"
#   prometheus.io/path: "/metrics"
```

## 🧪 Phase 6: Testing Your Monitoring (15 minutes)

### Step 1: Generate Test Traffic
```bash
# Create load test to trigger alerts
for i in {1..1000}; do
  curl -X GET http://your-app-url/api/products &
  curl -X POST http://your-app-url/api/error-endpoint &
done

# Wait 5-10 minutes for alerts to trigger
```

### Step 2: Verify Metrics Collection
```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# In Prometheus UI, go to:
# 1. Status > Targets (verify your apps are being scraped)
# 2. Graph tab, try queries:
#    - http_requests_total
#    - rate(http_requests_total[5m])
#    - histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### Step 3: Test Alerting
```bash
# Simulate high error rate
for i in {1..100}; do
  curl -X GET http://your-app-url/api/nonexistent-endpoint
done

# Check AlertManager
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
# Should see "HighErrorRate" alert in firing state
```

## ✅ Monitoring Checklist

### Metrics Collection ✅
- [ ] Prometheus collecting application metrics
- [ ] Node metrics being scraped
- [ ] Custom business metrics implemented
- [ ] Service monitors configured
- [ ] Metrics endpoints exposed on all services

### Visualization ✅
- [ ] Grafana dashboards created
- [ ] Application performance dashboard
- [ ] Infrastructure monitoring dashboard
- [ ] Business metrics dashboard
- [ ] Custom alerts visualization

### Alerting ✅
- [ ] Critical alerts configured (error rate, latency)
- [ ] Warning alerts for resource usage
- [ ] Business logic alerts (low inventory, payment failures)
- [ ] Notification channels configured (email, Slack)
- [ ] Alert escalation policies defined

### Advanced Features ✅
- [ ] Multi-dimensional metrics with labels
- [ ] Histogram metrics for latency percentiles
- [ ] Rate calculations for trending
- [ ] Business KPI tracking
- [ ] Capacity planning metrics

## 🎉 Congratulations!

You now have enterprise-grade monitoring that rivals companies like:
- ✅ **Netflix** - Comprehensive application performance monitoring
- ✅ **Uber** - Real-time business metrics and alerting
- ✅ **Airbnb** - Infrastructure monitoring and capacity planning
- ✅ **Spotify** - Custom metrics and business intelligence

## ➡️ What's Next?

✅ **Advanced observability**: [Distributed tracing with Jaeger](tracing.md)  
✅ **Log aggregation**: [Centralized logging with ELK stack](logging.md)  
✅ **Performance optimization**: [Using metrics for optimization](optimization.md)

## 🆘 Troubleshooting

**Metrics not showing**:
- Check service monitor labels match your service
- Verify `/metrics` endpoint is accessible
- Check Prometheus targets page for scraping errors

**Alerts not firing**:
- Verify AlertManager configuration
- Check alert rule syntax in Prometheus
- Test notification channels separately

**Grafana dashboard empty**:
- Check data source configuration
- Verify metric names in queries
- Test queries in Prometheus first

---

**Monitoring mastery achieved!** Your applications now have observability that professional DevOps teams would be proud of.