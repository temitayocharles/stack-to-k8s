# 📊 Complete Observability Stack

Production-ready monitoring, logging, and tracing implementation for all applications with hands-on labs.

## 🎯 Observability Strategy

### The Three Pillars of Observability

1. **Metrics** - What happened? (Prometheus + Grafana)
2. **Logs** - Why did it happen? (Loki + Grafana)  
3. **Traces** - How did it happen? (Jaeger + OpenTelemetry)

## 🚀 Quick Deploy - Full Stack

Deploy the complete observability stack in under 5 minutes:

```bash
# Deploy everything
./scripts/observability/deploy-stack.sh

# Access dashboards
echo "🔗 Grafana: http://localhost:3001 (admin/admin)"
echo "🔗 Prometheus: http://localhost:9090"
echo "🔗 Jaeger: http://localhost:16686"
echo "🔗 AlertManager: http://localhost:9093"
```

## 📊 Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Applications  │    │   Observability │    │   Dashboards    │
│                 │    │      Stack      │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ E-commerce  │ │───▶│ │ Prometheus  │ │───▶│ │   Grafana   │ │
│ │ Educational │ │    │ │    Loki     │ │    │ │  Dashboards │ │
│ │ Medical     │ │    │ │   Jaeger    │ │    │ │             │ │
│ │ Task Mgmt   │ │    │ │ AlertMgr    │ │    │ │             │ │
│ │ Weather     │ │    │ └─────────────┘ │    │ └─────────────┘ │
│ │ Social      │ │    └─────────────────┘    └─────────────────┘
│ └─────────────┘ │
└─────────────────┘
```

## 🔧 Component Details

### Prometheus Stack
- **Prometheus Server**: Metrics collection and storage
- **AlertManager**: Alert routing and notifications
- **Node Exporter**: System metrics
- **cAdvisor**: Container metrics
- **Blackbox Exporter**: Endpoint monitoring

### Grafana Stack
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation
- **Promtail**: Log collection agent

### Tracing Stack
- **Jaeger**: Distributed tracing
- **OpenTelemetry Collector**: Telemetry data collection

## 📈 Metrics Collection

### Application Metrics
Each application exposes metrics on `/metrics` endpoint:

```yaml
# Exposed metrics for each app
http_requests_total{method="GET",status="200"} 150
http_request_duration_seconds_bucket{le="0.1"} 95
database_connections_active 5
business_transactions_total{type="purchase"} 23
error_rate_5m 0.02
```

### Custom Business Metrics
Track application-specific KPIs:

**E-commerce App:**
- Orders per minute
- Revenue tracking
- Cart abandonment rate
- Payment success rate

**Educational Platform:**
- Active students
- Course completion rate
- Video streaming quality
- Assignment submission rate

**Medical Care System:**
- Patient check-ins
- Appointment scheduling
- Critical alert response time
- System availability

## 📋 Logging Strategy

### Structured Logging
All applications use structured JSON logging:

```json
{
  "timestamp": "2023-12-07T10:30:00Z",
  "level": "INFO",
  "service": "ecommerce-backend",
  "trace_id": "abc123def456",
  "user_id": "user_789",
  "action": "purchase_completed",
  "order_id": "order_456",
  "amount": 99.99,
  "payment_method": "stripe"
}
```

### Log Levels and Retention
- **ERROR**: 90 days retention
- **WARN**: 30 days retention  
- **INFO**: 7 days retention
- **DEBUG**: 1 day retention

## 🕵️ Distributed Tracing

### OpenTelemetry Integration
Each application includes OpenTelemetry instrumentation:

```javascript
// Example: Node.js instrumentation
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');

const sdk = new NodeSDK({
  instrumentations: [getNodeAutoInstrumentations()],
  serviceName: 'ecommerce-backend',
  serviceVersion: '1.0.0',
});

sdk.start();
```

### Trace Correlation
All logs include trace IDs for correlation:
- Follow requests across microservices
- Identify performance bottlenecks
- Debug complex distributed issues

## 🚨 Alerting Rules

### Critical Alerts (Page immediately)
```yaml
# High error rate
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"

# Service down
- alert: ServiceDown
  expr: up == 0
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: "Service is down"

# Database connectivity
- alert: DatabaseDown
  expr: database_up == 0
  for: 30s
  labels:
    severity: critical
  annotations:
    summary: "Database connection failed"
```

### Warning Alerts (Investigate)
```yaml
# High response time
- alert: HighResponseTime
  expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
  for: 5m
  labels:
    severity: warning

# High memory usage
- alert: HighMemoryUsage
  expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.8
  for: 10m
  labels:
    severity: warning
```

## 📊 Pre-built Dashboards

### Application Overview Dashboard
- Request rate and response times
- Error rates and status codes
- Resource utilization (CPU, Memory)
- Database connection health
- Active users and sessions

### Infrastructure Dashboard
- Node resource utilization
- Container metrics
- Network I/O
- Disk usage and IOPS
- Kubernetes cluster health

### Business Metrics Dashboard
- Revenue and transactions
- User engagement metrics
- Feature usage statistics
- Performance KPIs
- SLA compliance

## 🔧 Hands-on Labs

### Lab 1: Deploy Monitoring Stack
**Objective**: Get the full observability stack running

1. **Deploy the stack:**
   ```bash
   cd k8s/monitoring
   kubectl apply -f namespace.yaml
   kubectl apply -f prometheus/
   kubectl apply -f grafana/
   kubectl apply -f jaeger/
   ```

2. **Verify deployment:**
   ```bash
   kubectl get pods -n monitoring
   kubectl get services -n monitoring
   ```

3. **Access dashboards:**
   - Grafana: `kubectl port-forward -n monitoring svc/grafana 3001:3000`
   - Prometheus: `kubectl port-forward -n monitoring svc/prometheus 9090:9090`
   - Jaeger: `kubectl port-forward -n monitoring svc/jaeger 16686:16686`

### Lab 2: Configure Application Monitoring
**Objective**: Monitor your first application

1. **Enable metrics in application:**
   ```bash
   # Add Prometheus metrics endpoint
   cd ecommerce-app
   
   # Update docker-compose.yml to include metrics
   docker-compose up -d
   ```

2. **Configure Prometheus targets:**
   ```yaml
   # Add to prometheus.yml
   - job_name: 'ecommerce-app'
     static_configs:
     - targets: ['ecommerce-backend:5000']
   ```

3. **Import Grafana dashboard:**
   - Go to Grafana → Import
   - Upload `grafana-dashboards/application-overview.json`

### Lab 3: Create Custom Alerts
**Objective**: Set up meaningful alerts for your application

1. **Define alert rules:**
   ```yaml
   # custom-alerts.yml
   groups:
   - name: ecommerce.rules
     rules:
     - alert: HighCartAbandonmentRate
       expr: (cart_abandoned_total / cart_created_total) > 0.7
       for: 5m
       annotations:
         summary: "Cart abandonment rate is too high"
   ```

2. **Configure notification channels:**
   ```yaml
   # alertmanager.yml
   route:
     routes:
     - match:
         severity: critical
       receiver: 'slack-critical'
   
   receivers:
   - name: 'slack-critical'
     slack_configs:
     - api_url: 'YOUR_SLACK_WEBHOOK_URL'
       channel: '#alerts'
   ```

### Lab 4: Implement Distributed Tracing
**Objective**: Trace requests across microservices

1. **Instrument your application:**
   ```javascript
   // Add tracing to Express.js
   const tracer = require('./tracer');
   
   app.use((req, res, next) => {
     const span = tracer.startSpan(`${req.method} ${req.path}`);
     req.span = span;
     next();
   });
   ```

2. **Configure trace sampling:**
   ```yaml
   # jaeger-config.yml
   sampling:
     type: probabilistic
     param: 0.1  # Sample 10% of traces
   ```

3. **Visualize traces:**
   - Go to Jaeger UI
   - Search for your service
   - Analyze trace timeline and dependencies

## 🎯 Progressive Learning Path

### 🟢 **Beginner Level**: Basic Monitoring
**Time**: 2-3 hours
- Deploy Prometheus and Grafana
- Create first dashboard
- Set up basic alerts
- Monitor system metrics

### 🟡 **Intermediate Level**: Application Monitoring
**Time**: 4-6 hours
- Add custom metrics to applications
- Create business dashboards
- Implement log aggregation
- Configure alert routing

### 🔵 **Advanced Level**: Full Observability
**Time**: 6-8 hours
- Deploy distributed tracing
- Implement SLI/SLO monitoring
- Create runbooks for alerts
- Set up cross-service correlation

### 🔴 **Expert Level**: Production Operations
**Time**: 8+ hours
- Implement capacity planning dashboards
- Create automated incident response
- Build compliance reporting
- Optimize performance using observability data

## 📋 Troubleshooting Guide

### Common Issues

**Prometheus not scraping targets:**
```bash
# Check target status
curl http://localhost:9090/api/v1/targets

# Verify network connectivity
kubectl exec -it prometheus-pod -- wget -qO- http://target-service:port/metrics
```

**Grafana dashboards not loading data:**
```bash
# Check data source configuration
# Verify Prometheus URL in Grafana
# Test query in Prometheus UI first
```

**Missing traces in Jaeger:**
```bash
# Check OpenTelemetry collector logs
kubectl logs -n monitoring deployment/otel-collector

# Verify sampling configuration
# Check application instrumentation
```

### Performance Optimization

**Prometheus Storage:**
```yaml
# Optimize retention and storage
prometheus:
  storage:
    retention: "30d"
    size: "50Gi"
  config:
    global:
      scrape_interval: 30s  # Increase for better performance
```

**Grafana Performance:**
```yaml
# Configure caching
grafana:
  config:
    caching:
      enabled: true
    query_timeout: 30s
```

## 🏆 Success Metrics

### SLI/SLO Implementation
```yaml
# Service Level Indicators
sli:
  availability: "rate(http_requests_total{status!~'5..'}[30d]) / rate(http_requests_total[30d])"
  latency: "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[30d]))"
  error_rate: "rate(http_requests_total{status=~'5..'}[30d]) / rate(http_requests_total[30d])"

# Service Level Objectives
slo:
  availability: 99.9%    # 99.9% uptime
  latency: 200ms         # 95th percentile < 200ms
  error_rate: 0.1%       # Less than 0.1% error rate
```

### Observability Maturity Assessment
- [ ] **Level 1**: Basic metrics collection
- [ ] **Level 2**: Custom dashboards and alerts
- [ ] **Level 3**: Distributed tracing implemented
- [ ] **Level 4**: SLI/SLO monitoring
- [ ] **Level 5**: Automated incident response

## 🔗 Integration with Applications

Each application includes:
- Pre-configured monitoring endpoints
- Application-specific dashboards
- Custom business metrics
- Distributed tracing instrumentation
- Alert rules tailored to the application

## 📚 Additional Resources

### Learning Materials
- [Prometheus Monitoring Guide](https://prometheus.io/docs/)
- [Grafana Dashboard Creation](https://grafana.com/docs/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [SRE Workbook](https://sre.google/workbook/table-of-contents/)

### Community Resources
- [Awesome Prometheus](https://github.com/roaldnefs/awesome-prometheus)
- [Grafana Community Dashboards](https://grafana.com/grafana/dashboards/)
- [OpenTelemetry Registry](https://opentelemetry.io/registry/)

---

**Ready to master observability?** Start with the basic monitoring lab and progress through each level. Remember: you can't improve what you can't measure! 📊