# 📊 Task Management Application - Monitoring Guide

## 🎯 Overview

This guide covers the comprehensive monitoring setup for the Task Management application, including metrics collection, visualization, alerting, and performance monitoring.

## 🏗️ Architecture

The monitoring stack consists of:

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notifications
- **Node Exporter**: System metrics
- **PostgreSQL Exporter**: Database metrics
- **Redis Exporter**: Cache metrics
- **Custom Exporters**: Application-specific metrics

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster with kubectl configured
- Helm 3.x installed
- Task Management application deployed

### Automated Setup

```bash
# Make the script executable
chmod +x monitoring/setup-monitoring.sh

# Run the setup script
./monitoring/setup-monitoring.sh
```

This will deploy the complete monitoring stack automatically.

## 📈 Metrics Collection

### Application Metrics

The application exposes the following metrics:

- **HTTP Request Metrics**: Request count, duration, status codes
- **Database Metrics**: Connection pools, query performance, slow queries
- **Cache Metrics**: Hit/miss rates, memory usage
- **Business Metrics**: Task creation, user activity, project metrics
- **System Metrics**: CPU, memory, disk usage

### Custom Metrics

```go
// Example custom metrics in Go
var (
    tasksCreated = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "task_creation_total",
            Help: "Total number of tasks created",
        },
        []string{"user_id", "project_id"},
    )

    requestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "http_request_duration_seconds",
            Help: "HTTP request duration in seconds",
            Buckets: prometheus.DefBuckets,
        },
        []string{"method", "path", "status"},
    )
)
```

## 📊 Grafana Dashboards

### Pre-configured Dashboard

The setup includes a comprehensive dashboard with:

1. **Application Health Overview**: Service status and uptime
2. **HTTP Request Rate**: Request rates by status code
3. **Response Time Analysis**: 95th percentile and median response times
4. **Database Performance**: Connection counts and query performance
5. **Cache Performance**: Hit/miss rates and memory usage
6. **System Resources**: CPU, memory, and disk usage
7. **Kubernetes Status**: Pod status and resource usage
8. **Business Metrics**: Task creation and user activity
9. **Error Analysis**: Error rates by endpoint

### Accessing Grafana

```bash
# Port forward (if not using ingress)
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Access at: http://localhost:3000
# Default credentials: admin / admin123
```

### Custom Dashboard Creation

1. Click "Create" → "Dashboard"
2. Add panels for your metrics
3. Use queries like:
   ```promql
   rate(http_requests_total{job="task-management-backend"}[5m])
   histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
   ```

## 🚨 Alerting

### Alert Categories

#### Critical Alerts
- Service down (backend, database, cache)
- Low disk space (< 10%)
- Database connection pool exhausted

#### Warning Alerts
- High error rate (> 5%)
- High response time (> 2s)
- High CPU/memory usage (> 85%)
- Slow database queries (> 30s)

#### Info Alerts
- Task creation rate spikes
- Unusual login attempts
- Low user activity

### Alert Configuration

Alerts are configured in `monitoring/alert_rules.yml`:

```yaml
groups:
  - name: application_health
    rules:
      - alert: TaskManagementBackendDown
        expr: up{job="task-management-backend"} == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Task Management Backend is down"
```

### AlertManager Configuration

Configure notification channels in `alertmanager-config.yaml`:

```yaml
receivers:
- name: 'email'
  email_configs:
  - to: 'admin@taskmanagement.com'
    send_resolved: true
```

## 📋 Monitoring Checklist

### Daily Checks
- [ ] All services are up and healthy
- [ ] Error rates are below 1%
- [ ] Response times are under 500ms (median)
- [ ] Database connections are stable
- [ ] Cache hit rate > 90%

### Weekly Reviews
- [ ] Review alert history
- [ ] Analyze performance trends
- [ ] Check resource utilization patterns
- [ ] Update dashboards as needed

### Monthly Audits
- [ ] Review monitoring coverage
- [ ] Update alert thresholds
- [ ] Archive old metrics data
- [ ] Plan capacity upgrades

## 🔧 Troubleshooting

### Common Issues

#### Prometheus Not Scraping Metrics
```bash
# Check service discovery
kubectl get servicemonitors -n monitoring

# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
# Visit: http://localhost:9090/targets
```

#### Grafana Dashboard Not Loading
```bash
# Check Grafana logs
kubectl logs -n monitoring deployment/prometheus-grafana

# Reset admin password
kubectl exec -n monitoring deployment/prometheus-grafana -- grafana-cli admin reset-admin-password newpassword
```

#### Alerts Not Firing
```bash
# Check alert rules
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
# Visit: http://localhost:9090/alerts

# Check AlertManager
kubectl port-forward -n monitoring svc/prometheus-alertmanager 9093:80
# Visit: http://localhost:9093
```

### Performance Optimization

#### Query Optimization
```sql
-- Add indexes for frequently queried columns
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);

-- Use EXPLAIN ANALYZE for query optimization
EXPLAIN ANALYZE SELECT * FROM tasks WHERE user_id = $1 AND status = 'pending';
```

#### Cache Optimization
```go
// Implement cache warming
func warmCache() {
    popularTasks := getPopularTasks()
    for _, task := range popularTasks {
        cache.Set(fmt.Sprintf("task:%d", task.ID), task, time.Hour)
    }
}
```

## 📈 Scaling and High Availability

### Horizontal Scaling
```yaml
# HPA for backend service
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: task-management-backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: task-management-backend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Prometheus Federation
For multi-cluster monitoring:

```yaml
# Federation configuration
scrape_configs:
  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{job="prometheus"}'
        - '{__name__=~"job:.*"}'
    static_configs:
      - targets:
        - 'prometheus-cluster-1:9090'
        - 'prometheus-cluster-2:9090'
```

## 🔒 Security Considerations

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: monitoring-network-policy
  namespace: monitoring
spec:
  podSelector:
    matchLabels:
      app: prometheus
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: task-management
```

### RBAC Configuration
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-viewer
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]
```

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [AlertManager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Kubernetes Monitoring Best Practices](https://kubernetes.io/docs/tasks/debug-application-cluster/monitor-node-health/)

## 🎯 Next Steps

1. **Customize Alerts**: Adjust alert thresholds based on your environment
2. **Add More Dashboards**: Create team-specific dashboards
3. **Implement SLOs**: Define Service Level Objectives
4. **Set Up Log Aggregation**: Integrate with ELK stack
5. **Configure Backup**: Set up metrics data backup strategy

---

*This monitoring setup provides enterprise-grade observability for your Task Management application, ensuring high availability and performance.*