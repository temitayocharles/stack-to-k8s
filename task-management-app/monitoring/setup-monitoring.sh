#!/bin/bash

# Task Management Application - Monitoring Setup Script
# This script sets up a complete monitoring stack for the Task Management application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="monitoring"
APP_NAMESPACE="task-management"
PROMETHEUS_VERSION="v2.45.0"
GRAFANA_VERSION="10.1.0"
NODE_EXPORTER_VERSION="1.6.1"
POSTGRES_EXPORTER_VERSION="0.13.1"
REDIS_EXPORTER_VERSION="1.54.0"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed. Please install it first."
        exit 1
    fi

    if ! command -v helm &> /dev/null; then
        log_error "Helm is not installed. Please install it first."
        exit 1
    fi

    log_success "All dependencies are installed."
}

create_namespace() {
    log_info "Creating monitoring namespace..."

    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        kubectl create namespace $NAMESPACE
        log_success "Created namespace: $NAMESPACE"
    else
        log_warning "Namespace $NAMESPACE already exists."
    fi
}

setup_prometheus() {
    log_info "Setting up Prometheus..."

    # Add Prometheus Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    # Create Prometheus configuration
    cat > prometheus-values.yaml << EOF
server:
  persistentVolume:
    enabled: true
    size: 50Gi
  service:
    type: ClusterIP
    port: 80
    targetPort: 9090
    nodePort: ""
  additionalScrapeConfigs:
    - job_name: 'task-management-backend'
      static_configs:
        - targets: ['task-management-backend.task-management.svc.cluster.local:8080']
      metrics_path: '/metrics'
      scrape_interval: 15s

    - job_name: 'postgres'
      static_configs:
        - targets: ['postgres.task-management.svc.cluster.local:5432']
      metrics_path: '/metrics'

    - job_name: 'redis'
      static_configs:
        - targets: ['redis.task-management.svc.cluster.local:6379']
      metrics_path: '/metrics'

alertmanager:
  enabled: true
  persistentVolume:
    enabled: true
    size: 10Gi

pushgateway:
  enabled: false

nodeExporter:
  enabled: true

kubeStateMetrics:
  enabled: true

grafana:
  enabled: true
  adminPassword: 'admin123'
  service:
    type: ClusterIP
    port: 80
    targetPort: 3000
  persistence:
    enabled: true
    size: 10Gi
  additionalDataSources:
    - name: prometheus
      type: prometheus
      url: http://prometheus-server.monitoring.svc.cluster.local
      access: proxy
      isDefault: true
EOF

    # Install Prometheus
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace $NAMESPACE \
        --values prometheus-values.yaml \
        --wait

    log_success "Prometheus stack deployed successfully."
}

setup_additional_exporters() {
    log_info "Setting up additional exporters..."

    # PostgreSQL Exporter
    cat > postgres-exporter-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-exporter
  namespace: $NAMESPACE
  labels:
    app: postgres-exporter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-exporter
  template:
    metadata:
      labels:
        app: postgres-exporter
    spec:
      containers:
      - name: postgres-exporter
        image: prometheuscommunity/postgres-exporter:$POSTGRES_EXPORTER_VERSION
        ports:
        - containerPort: 9187
        env:
        - name: DATA_SOURCE_NAME
          value: "postgresql://taskuser:taskpass@postgres.task-management.svc.cluster.local:5432/taskmanagement?sslmode=disable"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-exporter
  namespace: $NAMESPACE
  labels:
    app: postgres-exporter
spec:
  selector:
    app: postgres-exporter
  ports:
  - name: metrics
    port: 9187
    targetPort: 9187
EOF

    kubectl apply -f postgres-exporter-deployment.yaml

    # Redis Exporter
    cat > redis-exporter-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-exporter
  namespace: $NAMESPACE
  labels:
    app: redis-exporter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-exporter
  template:
    metadata:
      labels:
        app: redis-exporter
    spec:
      containers:
      - name: redis-exporter
        image: oliver006/redis_exporter:$REDIS_EXPORTER_VERSION
        ports:
        - containerPort: 9121
        env:
        - name: REDIS_ADDR
          value: "redis://redis.task-management.svc.cluster.local:6379"
        - name: REDIS_PASSWORD
          value: ""
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: redis-exporter
  namespace: $NAMESPACE
  labels:
    app: redis-exporter
spec:
  selector:
    app: redis-exporter
  ports:
  - name: metrics
    port: 9121
    targetPort: 9121
EOF

    kubectl apply -f redis-exporter-deployment.yaml

    log_success "Additional exporters deployed successfully."
}

setup_service_monitors() {
    log_info "Setting up ServiceMonitors..."

    cat > service-monitors.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: task-management-backend
  namespace: $NAMESPACE
  labels:
    app: task-management-backend
spec:
  selector:
    matchLabels:
      app: task-management-backend
  endpoints:
  - port: metrics
    path: /metrics
    interval: 15s
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: postgres-exporter
  namespace: $NAMESPACE
  labels:
    app: postgres-exporter
spec:
  selector:
    matchLabels:
      app: postgres-exporter
  endpoints:
  - port: metrics
    interval: 30s
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: redis-exporter
  namespace: $NAMESPACE
  labels:
    app: redis-exporter
spec:
  selector:
    matchLabels:
      app: redis-exporter
  endpoints:
  - port: metrics
    interval: 30s
EOF

    kubectl apply -f service-monitors.yaml

    log_success "ServiceMonitors created successfully."
}

setup_alerts() {
    log_info "Setting up alerting rules..."

    # Create ConfigMap for alert rules
    kubectl create configmap prometheus-alerts \
        --from-file=alert_rules.yml=monitoring/alert_rules.yml \
        --namespace $NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -

    # Update Prometheus configuration to include alert rules
    cat > alertmanager-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: $NAMESPACE
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: 'alerts@taskmanagement.com'
      smtp_auth_username: 'your-email@gmail.com'
      smtp_auth_password: 'your-app-password'

    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'email'
      routes:
      - match:
          severity: critical
        receiver: 'email'

    receivers:
    - name: 'email'
      email_configs:
      - to: 'admin@taskmanagement.com'
        send_resolved: true
EOF

    kubectl apply -f alertmanager-config.yaml

    log_success "Alerting configuration deployed successfully."
}

setup_grafana_dashboard() {
    log_info "Setting up Grafana dashboard..."

    # Apply the dashboard ConfigMap
    kubectl apply -f monitoring/grafana-dashboard.yaml

    log_success "Grafana dashboard deployed successfully."
}

create_ingress() {
    log_info "Creating ingress for monitoring services..."

    cat > monitoring-ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring-ingress
  namespace: $NAMESPACE
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: prometheus.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-server
            port:
              number: 80
  - host: grafana.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-grafana
            port:
              number: 80
  - host: alertmanager.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-alertmanager
            port:
              number: 80
EOF

    kubectl apply -f monitoring-ingress.yaml

    log_success "Ingress created successfully."
}

wait_for_services() {
    log_info "Waiting for services to be ready..."

    # Wait for Prometheus
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus-server -n $NAMESPACE
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus-grafana -n $NAMESPACE

    log_success "All monitoring services are ready."
}

print_access_info() {
    log_success "Monitoring setup completed successfully!"
    echo ""
    echo "Access URLs (add to /etc/hosts if using local cluster):"
    echo "  Prometheus: http://prometheus.local"
    echo "  Grafana:    http://grafana.local (admin/admin123)"
    echo "  AlertManager: http://alertmanager.local"
    echo ""
    echo "Port-forward commands (if not using ingress):"
    echo "  kubectl port-forward -n $NAMESPACE svc/prometheus-server 9090:80"
    echo "  kubectl port-forward -n $NAMESPACE svc/prometheus-grafana 3000:80"
    echo "  kubectl port-forward -n $NAMESPACE svc/prometheus-alertmanager 9093:80"
    echo ""
    echo "Next steps:"
    echo "1. Update alertmanager-config.yaml with your email settings"
    echo "2. Import the dashboard in Grafana using the provided JSON"
    echo "3. Configure additional alert channels (Slack, PagerDuty, etc.)"
    echo "4. Set up proper RBAC for team access"
}

cleanup_temp_files() {
    log_info "Cleaning up temporary files..."

    rm -f prometheus-values.yaml
    rm -f postgres-exporter-deployment.yaml
    rm -f redis-exporter-deployment.yaml
    rm -f service-monitors.yaml
    rm -f alertmanager-config.yaml
    rm -f monitoring-ingress.yaml

    log_success "Cleanup completed."
}

main() {
    echo "🚀 Task Management Application - Monitoring Setup"
    echo "=================================================="

    check_dependencies
    create_namespace
    setup_prometheus
    setup_additional_exporters
    setup_service_monitors
    setup_alerts
    setup_grafana_dashboard
    create_ingress
    wait_for_services
    print_access_info
    cleanup_temp_files

    log_success "🎉 Monitoring setup completed successfully!"
    echo ""
    echo "Your application now has enterprise-grade monitoring with:"
    echo "✅ Prometheus for metrics collection"
    echo "✅ Grafana for visualization"
    echo "✅ AlertManager for notifications"
    echo "✅ Comprehensive alerting rules"
    echo "✅ Custom dashboards"
    echo "✅ Service discovery and auto-scaling metrics"
}

# Run main function
main "$@"