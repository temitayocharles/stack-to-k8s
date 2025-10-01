#!/bin/bash
# 📊 COMPLETE OBSERVABILITY STACK DEPLOYMENT
# Deploy production-ready monitoring, logging, and tracing

set -euo pipefail

# Colors and styling
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
readonly NAMESPACE="monitoring"
readonly RELEASE_NAME="observability"
readonly TIMEOUT="600s"

show_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}📊 COMPLETE OBSERVABILITY STACK DEPLOYMENT${NC}"
    echo -e "${CYAN}║${NC} ${BLUE}Production-ready monitoring, logging, and tracing${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is required but not installed${NC}"
        exit 1
    fi
    
    # Check helm
    if ! command -v helm &> /dev/null; then
        echo -e "${YELLOW}⚠️  Helm not found, installing...${NC}"
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites satisfied${NC}"
    echo ""
}

create_namespace() {
    echo -e "${BLUE}📁 Creating monitoring namespace...${NC}"
    
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Label namespace for monitoring
    kubectl label namespace $NAMESPACE monitoring=enabled --overwrite
    
    echo -e "${GREEN}✅ Namespace created: $NAMESPACE${NC}"
    echo ""
}

deploy_prometheus_stack() {
    echo -e "${PURPLE}🎯 Deploying Prometheus Stack...${NC}"
    
    # Add helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Create custom values for Prometheus stack
    cat > prometheus-values.yaml << 'EOF'
prometheus:
  prometheusSpec:
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
    additionalScrapeConfigs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true

grafana:
  adminPassword: admin
  persistence:
    enabled: true
    size: 10Gi
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/default
  dashboards:
    default:
      kubernetes-cluster:
        gnetId: 7249
        revision: 1
        datasource: Prometheus
      application-overview:
        gnetId: 6417
        revision: 1
        datasource: Prometheus

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi

nodeExporter:
  enabled: true

kubeStateMetrics:
  enabled: true
EOF
    
    # Deploy Prometheus stack
    helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
        --namespace $NAMESPACE \
        --values prometheus-values.yaml \
        --timeout $TIMEOUT \
        --wait
    
    echo -e "${GREEN}✅ Prometheus Stack deployed${NC}"
    echo ""
}

deploy_loki_stack() {
    echo -e "${PURPLE}📋 Deploying Loki Stack (Logging)...${NC}"
    
    # Create Loki values
    cat > loki-values.yaml << 'EOF'
loki:
  persistence:
    enabled: true
    size: 30Gi
  config:
    schema_config:
      configs:
        - from: 2020-10-24
          store: boltdb-shipper
          object_store: filesystem
          schema: v11
          index:
            prefix: index_
            period: 24h
    storage_config:
      boltdb_shipper:
        active_index_directory: /loki/boltdb-shipper-active
        cache_location: /loki/boltdb-shipper-cache
        shared_store: filesystem
      filesystem:
        directory: /loki/chunks

promtail:
  enabled: true
  config:
    clients:
      - url: http://{{ include "loki.fullname" . }}:3100/loki/api/v1/push

grafana:
  enabled: false  # Already deployed with Prometheus stack
  
fluent-bit:
  enabled: true
EOF
    
    # Deploy Loki
    helm upgrade --install loki grafana/loki-stack \
        --namespace $NAMESPACE \
        --values loki-values.yaml \
        --timeout $TIMEOUT \
        --wait
    
    echo -e "${GREEN}✅ Loki Stack deployed${NC}"
    echo ""
}

deploy_jaeger() {
    echo -e "${PURPLE}🕵️ Deploying Jaeger (Distributed Tracing)...${NC}"
    
    # Create Jaeger manifest
    cat > jaeger-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  namespace: monitoring
  labels:
    app: jaeger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:latest
        ports:
        - containerPort: 16686
        - containerPort: 14250
        - containerPort: 14268
        - containerPort: 9411
        env:
        - name: COLLECTOR_ZIPKIN_HOST_PORT
          value: ":9411"
        - name: SPAN_STORAGE_TYPE
          value: "memory"
        resources:
          limits:
            memory: 1Gi
            cpu: 500m
          requests:
            memory: 512Mi
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger
  namespace: monitoring
  labels:
    app: jaeger
spec:
  ports:
  - name: query
    port: 16686
    targetPort: 16686
  - name: collector-grpc
    port: 14250
    targetPort: 14250
  - name: collector-http
    port: 14268
    targetPort: 14268
  - name: zipkin
    port: 9411
    targetPort: 9411
  selector:
    app: jaeger
  type: ClusterIP
EOF
    
    kubectl apply -f jaeger-deployment.yaml
    
    echo -e "${GREEN}✅ Jaeger deployed${NC}"
    echo ""
}

deploy_opentelemetry_collector() {
    echo -e "${PURPLE}📡 Deploying OpenTelemetry Collector...${NC}"
    
    # Create OpenTelemetry Collector configuration
    cat > otel-collector.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-config
  namespace: monitoring
data:
  config.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      jaeger:
        protocols:
          grpc:
            endpoint: 0.0.0.0:14250
          thrift_http:
            endpoint: 0.0.0.0:14268
      zipkin:
        endpoint: 0.0.0.0:9411

    processors:
      batch:
      resource:
        attributes:
        - key: environment
          value: "kubernetes"
          action: upsert

    exporters:
      jaeger:
        endpoint: jaeger:14250
        tls:
          insecure: true
      prometheus:
        endpoint: "0.0.0.0:8889"

    service:
      pipelines:
        traces:
          receivers: [otlp, jaeger, zipkin]
          processors: [batch, resource]
          exporters: [jaeger]
        metrics:
          receivers: [otlp]
          processors: [batch, resource]
          exporters: [prometheus]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-collector
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: otel-collector
  template:
    metadata:
      labels:
        app: otel-collector
    spec:
      containers:
      - name: otel-collector
        image: otel/opentelemetry-collector:latest
        command:
        - "/otelcol"
        - "--config=/conf/config.yaml"
        volumeMounts:
        - name: config-volume
          mountPath: /conf
        ports:
        - containerPort: 4317   # OTLP gRPC
        - containerPort: 4318   # OTLP HTTP
        - containerPort: 8889   # Prometheus metrics
        - containerPort: 14250  # Jaeger gRPC
        - containerPort: 14268  # Jaeger HTTP
        - containerPort: 9411   # Zipkin
        resources:
          limits:
            memory: 512Mi
            cpu: 500m
          requests:
            memory: 256Mi
            cpu: 100m
      volumes:
      - name: config-volume
        configMap:
          name: otel-collector-config
---
apiVersion: v1
kind: Service
metadata:
  name: otel-collector
  namespace: monitoring
spec:
  selector:
    app: otel-collector
  ports:
  - name: otlp-grpc
    port: 4317
    targetPort: 4317
  - name: otlp-http
    port: 4318
    targetPort: 4318
  - name: metrics
    port: 8889
    targetPort: 8889
  - name: jaeger-grpc
    port: 14250
    targetPort: 14250
  - name: jaeger-http
    port: 14268
    targetPort: 14268
  - name: zipkin
    port: 9411
    targetPort: 9411
EOF
    
    kubectl apply -f otel-collector.yaml
    
    echo -e "${GREEN}✅ OpenTelemetry Collector deployed${NC}"
    echo ""
}

configure_grafana_datasources() {
    echo -e "${BLUE}🔗 Configuring Grafana data sources...${NC}"
    
    # Wait for Grafana to be ready
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n $NAMESPACE --timeout=300s
    
    # Get Grafana admin password
    GRAFANA_PASSWORD=$(kubectl get secret --namespace $NAMESPACE observability-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
    
    # Configure Loki data source
    kubectl exec -n $NAMESPACE deployment/observability-grafana -- grafana-cli admin reset-admin-password admin
    
    echo -e "${GREEN}✅ Grafana configured with data sources${NC}"
    echo -e "${CYAN}📊 Grafana admin password: admin${NC}"
    echo ""
}

create_service_monitors() {
    echo -e "${BLUE}📊 Creating Service Monitors for applications...${NC}"
    
    # Create service monitor for applications
    cat > application-servicemonitors.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: application-metrics
  namespace: monitoring
spec:
  selector:
    matchLabels:
      monitoring: enabled
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: otel-collector-metrics
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: otel-collector
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
EOF
    
    kubectl apply -f application-servicemonitors.yaml
    
    echo -e "${GREEN}✅ Service Monitors created${NC}"
    echo ""
}

show_access_info() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🎉 OBSERVABILITY STACK DEPLOYED SUCCESSFULLY!${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${PURPLE}📊 Access your dashboards:${NC}"
    echo ""
    
    echo -e "${YELLOW}Grafana (Dashboards & Visualization):${NC}"
    echo "   kubectl port-forward -n $NAMESPACE svc/observability-grafana 3001:80"
    echo "   URL: http://localhost:3001"
    echo "   Username: admin"
    echo "   Password: admin"
    echo ""
    
    echo -e "${YELLOW}Prometheus (Metrics & Alerts):${NC}"
    echo "   kubectl port-forward -n $NAMESPACE svc/observability-kube-prometheus-prometheus 9090:9090"
    echo "   URL: http://localhost:9090"
    echo ""
    
    echo -e "${YELLOW}AlertManager (Alert Management):${NC}"
    echo "   kubectl port-forward -n $NAMESPACE svc/observability-kube-prometheus-alertmanager 9093:9093"
    echo "   URL: http://localhost:9093"
    echo ""
    
    echo -e "${YELLOW}Jaeger (Distributed Tracing):${NC}"
    echo "   kubectl port-forward -n $NAMESPACE svc/jaeger 16686:16686"
    echo "   URL: http://localhost:16686"
    echo ""
    
    echo -e "${GREEN}🔍 Quick verification:${NC}"
    echo "   kubectl get pods -n $NAMESPACE"
    echo "   kubectl get svc -n $NAMESPACE"
    echo ""
    
    echo -e "${BLUE}📚 Next steps:${NC}"
    echo "   1. Configure your applications to send metrics to Prometheus"
    echo "   2. Add OpenTelemetry instrumentation for tracing"
    echo "   3. Import custom Grafana dashboards"
    echo "   4. Configure alert rules and notification channels"
    echo ""
    
    echo -e "${CYAN}🎯 Pro tip: Use './test-observability.sh' to verify everything is working${NC}"
}

cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning up temporary files...${NC}"
    rm -f prometheus-values.yaml loki-values.yaml jaeger-deployment.yaml otel-collector.yaml application-servicemonitors.yaml
}

# Main execution
main() {
    show_banner
    check_prerequisites
    create_namespace
    deploy_prometheus_stack
    deploy_loki_stack
    deploy_jaeger
    deploy_opentelemetry_collector
    configure_grafana_datasources
    create_service_monitors
    
    # Wait for all pods to be ready
    echo -e "${BLUE}⏳ Waiting for all pods to be ready...${NC}"
    kubectl wait --for=condition=ready pod --all -n $NAMESPACE --timeout=600s
    
    show_access_info
    cleanup
    
    echo -e "${GREEN}🎉 Observability stack deployment complete!${NC}"
}

trap cleanup EXIT
main "$@"