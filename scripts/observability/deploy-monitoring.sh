#!/bin/bash
# 🔍 COMPREHENSIVE MONITORING DEPLOYMENT SYSTEM
# One-command monitoring deployment for all applications

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
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly MONITORING_STACK_DIR="$WORKSPACE_ROOT/shared-k8s/monitoring"

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🔍 COMPREHENSIVE MONITORING DEPLOYMENT SYSTEM${NC}"
    echo -e "${CYAN}║${NC} ${BLUE}Production-ready monitoring stack with one command${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_progress() {
    local current=$1
    local total=$2
    local title="$3"
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "\r🔄 %s " "$title"
    printf "["
    for ((i=1; i<=completed; i++)); do printf "█"; done
    for ((i=completed+1; i<=width; i++)); do printf "░"; done
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$total"
}

deploy_monitoring_stack() {
    echo -e "${BLUE}🚀 Deploying comprehensive monitoring stack...${NC}"
    echo ""
    
    local total_steps=12
    local current_step=0
    
    # Step 1: Create monitoring namespace
    ((current_step++))
    show_progress $current_step $total_steps "Creating monitoring namespace..."
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    sleep 1
    
    # Step 2: Deploy Prometheus
    ((current_step++))
    show_progress $current_step $total_steps "Deploying Prometheus..."
    kubectl apply -f "$MONITORING_STACK_DIR/prometheus/" -n monitoring
    sleep 2
    
    # Step 3: Deploy Grafana
    ((current_step++))
    show_progress $current_step $total_steps "Deploying Grafana..."
    kubectl apply -f "$MONITORING_STACK_DIR/grafana/" -n monitoring
    sleep 2
    
    # Step 4: Deploy AlertManager
    ((current_step++))
    show_progress $current_step $total_steps "Deploying AlertManager..."
    kubectl apply -f "$MONITORING_STACK_DIR/alertmanager/" -n monitoring
    sleep 2
    
    # Step 5: Deploy Node Exporter
    ((current_step++))
    show_progress $current_step $total_steps "Deploying Node Exporter..."
    kubectl apply -f "$MONITORING_STACK_DIR/node-exporter/" -n monitoring
    sleep 2
    
    # Step 6: Deploy Blackbox Exporter
    ((current_step++))
    show_progress $current_step $total_steps "Deploying Blackbox Exporter..."
    kubectl apply -f "$MONITORING_STACK_DIR/blackbox-exporter/" -n monitoring
    sleep 2
    
    # Step 7: Deploy Service Monitors
    ((current_step++))
    show_progress $current_step $total_steps "Deploying Service Monitors..."
    kubectl apply -f "$MONITORING_STACK_DIR/service-monitors/" -n monitoring
    sleep 1
    
    # Step 8: Deploy PrometheusRules
    ((current_step++))
    show_progress $current_step $total_steps "Deploying Alert Rules..."
    kubectl apply -f "$MONITORING_STACK_DIR/prometheus-rules/" -n monitoring
    sleep 1
    
    # Step 9: Deploy Network Policies
    ((current_step++))
    show_progress $current_step $total_steps "Deploying Network Policies..."
    kubectl apply -f "$MONITORING_STACK_DIR/network-policies/" -n monitoring
    sleep 1
    
    # Step 10: Configure Ingress
    ((current_step++))
    show_progress $current_step $total_steps "Configuring Ingress..."
    kubectl apply -f "$MONITORING_STACK_DIR/ingress/" -n monitoring
    sleep 1
    
    # Step 11: Deploy Dashboards
    ((current_step++))
    show_progress $current_step $total_steps "Loading Grafana Dashboards..."
    kubectl apply -f "$MONITORING_STACK_DIR/dashboards/" -n monitoring
    sleep 2
    
    # Step 12: Verify deployment
    ((current_step++))
    show_progress $current_step $total_steps "Verifying deployment..."
    sleep 3
    
    echo ""
    echo ""
}

create_monitoring_manifests() {
    echo -e "${BLUE}🏗️  Creating comprehensive monitoring manifests...${NC}"
    
    mkdir -p "$MONITORING_STACK_DIR"/{prometheus,grafana,alertmanager,node-exporter,blackbox-exporter,service-monitors,prometheus-rules,network-policies,ingress,dashboards}
    
    # Prometheus Configuration
    cat > "$MONITORING_STACK_DIR/prometheus/prometheus-config.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
      external_labels:
        cluster: 'learning-platform'
        environment: 'production'

    alerting:
      alertmanagers:
        - static_configs:
            - targets:
              - alertmanager:9093

    rule_files:
      - "/etc/prometheus/rules/*.yml"

    scrape_configs:
      # Prometheus itself
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']

      # Node Exporter
      - job_name: 'node-exporter'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_endpoints_name]
            action: keep
            regex: node-exporter

      # Application Health Checks
      - job_name: 'ecommerce-app'
        static_configs:
          - targets: ['ecommerce-backend:5000']
        metrics_path: '/health'
        scrape_interval: 30s

      - job_name: 'educational-platform'
        static_configs:
          - targets: ['educational-backend:8080']
        metrics_path: '/actuator/prometheus'
        scrape_interval: 30s

      - job_name: 'medical-care-system'
        static_configs:
          - targets: ['medical-backend:5000']
        metrics_path: '/health'
        scrape_interval: 30s

      - job_name: 'task-management-app'
        static_configs:
          - targets: ['task-backend:8080']
        metrics_path: '/metrics'
        scrape_interval: 30s

      - job_name: 'weather-app'
        static_configs:
          - targets: ['weather-backend:5000']
        metrics_path: '/health'
        scrape_interval: 30s

      - job_name: 'social-media-platform'
        static_configs:
          - targets: ['social-backend:4567']
        metrics_path: '/health'
        scrape_interval: 30s

      # Blackbox Exporter for URL monitoring
      - job_name: 'blackbox'
        metrics_path: /probe
        params:
          module: [http_2xx]
        static_configs:
          - targets:
            - http://ecommerce-frontend:3000
            - http://educational-frontend:4200
            - http://medical-frontend:5000
            - http://task-frontend:5173
            - http://weather-frontend:8080
            - http://social-frontend:3000
        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: blackbox-exporter:9115

      # Kubernetes API Server
      - job_name: 'kubernetes-apiservers'
        kubernetes_sd_configs:
          - role: endpoints
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
          - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
            action: keep
            regex: default;kubernetes;https

      # Kubernetes Nodes
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
          - target_label: __address__
            replacement: kubernetes.default.svc:443
          - source_labels: [__meta_kubernetes_node_name]
            regex: (.+)
            target_label: __metrics_path__
            replacement: /api/v1/nodes/${1}/proxy/metrics

      # Kubernetes Pods
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: kubernetes_pod_name
EOF

    # Prometheus Deployment
    cat > "$MONITORING_STACK_DIR/prometheus/prometheus-deployment.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus
        image: prom/prometheus:v2.45.0
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=15d'
          - '--web.enable-lifecycle'
          - '--web.enable-admin-api'
        ports:
        - containerPort: 9090
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus/
        - name: prometheus-storage
          mountPath: /prometheus/
        - name: rules-volume
          mountPath: /etc/prometheus/rules/
      volumes:
      - name: config-volume
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        emptyDir: {}
      - name: rules-volume
        configMap:
          name: prometheus-rules
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
spec:
  type: ClusterIP
  ports:
  - port: 9090
    targetPort: 9090
    protocol: TCP
  selector:
    app: prometheus
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
EOF

    # Grafana Configuration
    cat > "$MONITORING_STACK_DIR/grafana/grafana-config.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-config
  namespace: monitoring
data:
  grafana.ini: |
    [analytics]
    check_for_updates = true
    [grafana_net]
    url = https://grafana.net
    [log]
    mode = console
    [paths]
    data = /var/lib/grafana/data
    logs = /var/log/grafana
    plugins = /var/lib/grafana/plugins
    provisioning = /etc/grafana/provisioning
    [server]
    root_url = http://localhost:3000/
    [security]
    admin_user = admin
    admin_password = admin123
    [users]
    allow_sign_up = false
  datasources.yaml: |
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus:9090
      access: proxy
      isDefault: true
      editable: true
EOF

    # Grafana Deployment
    cat > "$MONITORING_STACK_DIR/grafana/grafana-deployment.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:10.0.0
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        - name: GF_INSTALL_PLUGINS
          value: "grafana-kubernetes-app,grafana-clock-panel,grafana-simple-json-datasource"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "200m"
        volumeMounts:
        - name: grafana-config
          mountPath: /etc/grafana
        - name: grafana-datasources
          mountPath: /etc/grafana/provisioning/datasources
        - name: grafana-storage
          mountPath: /var/lib/grafana
      volumes:
      - name: grafana-config
        configMap:
          name: grafana-config
      - name: grafana-datasources
        configMap:
          name: grafana-config
          items:
          - key: datasources.yaml
            path: datasources.yaml
      - name: grafana-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
  labels:
    app: grafana
spec:
  type: ClusterIP
  ports:
  - port: 3000
    targetPort: 3000
    protocol: TCP
  selector:
    app: grafana
EOF

    # AlertManager Configuration
    cat > "$MONITORING_STACK_DIR/alertmanager/alertmanager-config.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'localhost:587'
      smtp_from: 'alertmanager@kubernetes-learning.com'

    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'

    receivers:
    - name: 'web.hook'
      email_configs:
      - to: 'admin@kubernetes-learning.com'
        subject: 'Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
      webhook_configs:
      - url: 'http://localhost:5001/webhook'
        send_resolved: true

    inhibit_rules:
      - source_match:
          severity: 'critical'
        target_match:
          severity: 'warning'
        equal: ['alertname', 'dev', 'instance']
EOF

    # AlertManager Deployment
    cat > "$MONITORING_STACK_DIR/alertmanager/alertmanager-deployment.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alertmanager
  namespace: monitoring
  labels:
    app: alertmanager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alertmanager
  template:
    metadata:
      labels:
        app: alertmanager
    spec:
      containers:
      - name: alertmanager
        image: prom/alertmanager:v0.25.0
        args:
          - '--config.file=/etc/alertmanager/alertmanager.yml'
          - '--storage.path=/alertmanager'
        ports:
        - containerPort: 9093
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "100m"
        volumeMounts:
        - name: config-volume
          mountPath: /etc/alertmanager
        - name: alertmanager-storage
          mountPath: /alertmanager
      volumes:
      - name: config-volume
        configMap:
          name: alertmanager-config
      - name: alertmanager-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: alertmanager
  namespace: monitoring
  labels:
    app: alertmanager
spec:
  type: ClusterIP
  ports:
  - port: 9093
    targetPort: 9093
    protocol: TCP
  selector:
    app: alertmanager
EOF

    # Node Exporter DaemonSet
    cat > "$MONITORING_STACK_DIR/node-exporter/node-exporter-daemonset.yaml" << 'EOF'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:v1.6.0
        args:
          - '--path.sysfs=/host/sys'
          - '--path.rootfs=/host/root'
          - '--no-collector.wifi'
          - '--no-collector.hwmon'
          - '--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/)'
          - '--collector.netclass.ignored-devices=^(veth.*)$'
        ports:
        - containerPort: 9100
          protocol: TCP
        resources:
          limits:
            memory: 180Mi
          requests:
            cpu: 100m
            memory: 180Mi
        volumeMounts:
        - mountPath: /host/sys
          name: sys
          readOnly: true
        - mountPath: /host/root
          mountPropagation: HostToContainer
          name: root
          readOnly: true
      tolerations:
      - operator: Exists
      volumes:
      - hostPath:
          path: /sys
        name: sys
      - hostPath:
          path: /
        name: root
---
apiVersion: v1
kind: Service
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  type: ClusterIP
  clusterIP: None
  ports:
  - port: 9100
    targetPort: 9100
    protocol: TCP
  selector:
    app: node-exporter
EOF

    # Blackbox Exporter
    cat > "$MONITORING_STACK_DIR/blackbox-exporter/blackbox-exporter-config.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: blackbox-exporter-config
  namespace: monitoring
data:
  config.yml: |
    modules:
      http_2xx:
        prober: http
        timeout: 5s
        http:
          valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
          valid_status_codes: []
          method: GET
          headers:
            Host: kubernetes-learning.com
            Accept-Language: en-US
          no_follow_redirects: false
          fail_if_ssl: false
          fail_if_not_ssl: false
          tls_config:
            insecure_skip_verify: false
          preferred_ip_protocol: "ip4"
      http_post_2xx:
        prober: http
        timeout: 5s
        http:
          method: POST
          headers:
            Content-Type: application/json
          body: '{}'
      tcp_connect:
        prober: tcp
        timeout: 5s
      pop3s_banner:
        prober: tcp
        tcp:
          query_response:
          - expect: "^+OK"
          tls: true
          tls_config:
            insecure_skip_verify: false
      ssh_banner:
        prober: tcp
        timeout: 10s
        tcp:
          query_response:
          - expect: "^SSH-2.0-"
      irc_banner:
        prober: tcp
        timeout: 5s
        tcp:
          query_response:
          - send: "NICK prober"
          - send: "USER prober prober prober :prober"
          - expect: "PING :([^ ]+)"
            send: "PONG ${1}"
          - expect: "^:[^ ]+ 001"
      icmp:
        prober: icmp
        timeout: 5s
        icmp:
          preferred_ip_protocol: "ip4"
EOF

    # Blackbox Exporter Deployment
    cat > "$MONITORING_STACK_DIR/blackbox-exporter/blackbox-exporter-deployment.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blackbox-exporter
  namespace: monitoring
  labels:
    app: blackbox-exporter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: blackbox-exporter
  template:
    metadata:
      labels:
        app: blackbox-exporter
    spec:
      containers:
      - name: blackbox-exporter
        image: prom/blackbox-exporter:v0.24.0
        args:
          - '--config.file=/config/config.yml'
        ports:
        - containerPort: 9115
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: config
          mountPath: /config
      volumes:
      - name: config
        configMap:
          name: blackbox-exporter-config
---
apiVersion: v1
kind: Service
metadata:
  name: blackbox-exporter
  namespace: monitoring
  labels:
    app: blackbox-exporter
spec:
  type: ClusterIP
  ports:
  - port: 9115
    targetPort: 9115
    protocol: TCP
  selector:
    app: blackbox-exporter
EOF

    # Prometheus Rules
    cat > "$MONITORING_STACK_DIR/prometheus-rules/prometheus-rules.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
  namespace: monitoring
data:
  alerts.yml: |
    groups:
    - name: kubernetes-learning-platform
      rules:
      # Application Health Alerts
      - alert: ApplicationDown
        expr: up{job=~"ecommerce-app|educational-platform|medical-care-system|task-management-app|weather-app|social-media-platform"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Application {{ $labels.job }} is down"
          description: "Application {{ $labels.job }} has been down for more than 1 minute."

      - alert: HighResponseTime
        expr: http_request_duration_seconds{quantile="0.95"} > 2
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High response time for {{ $labels.job }}"
          description: "95th percentile response time is {{ $value }}s for {{ $labels.job }}."

      # Infrastructure Alerts  
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 85% on {{ $labels.instance }}."

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% on {{ $labels.instance }}."

      - alert: DiskSpaceLow
        expr: (node_filesystem_free_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk space is below 10% on {{ $labels.instance }}."

      # Kubernetes Alerts
      - alert: KubernetesPodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Pod {{ $labels.pod }} is crash looping"
          description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is restarting frequently."

      - alert: KubernetesNodeNotReady
        expr: kube_node_status_condition{condition="Ready",status="true"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Kubernetes node {{ $labels.node }} is not ready"
          description: "Node {{ $labels.node }} has been not ready for more than 1 minute."

      # Application-Specific Alerts
      - alert: EcommerceHighErrorRate
        expr: rate(http_requests_total{job="ecommerce-app",status=~"5.."}[5m]) > 0.1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate in E-commerce application"
          description: "Error rate is {{ $value }} errors per second."

      - alert: EducationalPlatformSlowQueries
        expr: mysql_slow_queries > 10
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Slow queries detected in Educational Platform"
          description: "{{ $value }} slow queries detected in the last minute."

      # Security Alerts
      - alert: TooManyFailedLogins
        expr: rate(failed_login_attempts_total[5m]) > 5
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "High number of failed login attempts"
          description: "{{ $value }} failed login attempts per second detected."

      - alert: UnauthorizedAccess
        expr: rate(http_requests_total{status="401"}[5m]) > 10
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "High number of unauthorized access attempts"
          description: "{{ $value }} unauthorized access attempts per second detected."
EOF

    # Service Monitors
    cat > "$MONITORING_STACK_DIR/service-monitors/application-monitors.yaml" << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: application-monitors
  namespace: monitoring
spec:
  selector:
    matchLabels:
      monitoring: enabled
  endpoints:
  - port: web
    path: /metrics
    interval: 30s
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ecommerce-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: ecommerce-backend
  endpoints:
  - port: http
    path: /health
    interval: 30s
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: educational-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: educational-backend
  endpoints:
  - port: http
    path: /actuator/prometheus
    interval: 30s
EOF

    # Network Policies
    cat > "$MONITORING_STACK_DIR/network-policies/monitoring-network-policies.yaml" << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: monitoring-network-policy
  namespace: monitoring
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    - namespaceSelector:
        matchLabels:
          name: default
    - namespaceSelector:
        matchLabels:
          name: kube-system
  egress:
  - {}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus-scraping
  namespace: monitoring
spec:
  podSelector:
    matchLabels:
      app: prometheus
  policyTypes:
  - Egress
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 9100  # Node Exporter
    - protocol: TCP
      port: 9115  # Blackbox Exporter
    - protocol: TCP
      port: 5000  # Application metrics
    - protocol: TCP
      port: 8080  # Application metrics
    - protocol: TCP
      port: 4567  # Application metrics
EOF

    # Ingress Configuration
    cat > "$MONITORING_STACK_DIR/ingress/monitoring-ingress.yaml" << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring-ingress
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: monitoring.local
    http:
      paths:
      - path: /grafana
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 3000
      - path: /prometheus
        pathType: Prefix
        backend:
          service:
            name: prometheus
            port:
              number: 9090
      - path: /alertmanager
        pathType: Prefix
        backend:
          service:
            name: alertmanager
            port:
              number: 9093
---
apiVersion: v1
kind: Service
metadata:
  name: monitoring-nodeport
  namespace: monitoring
spec:
  type: NodePort
  selector:
    app: grafana
  ports:
  - name: grafana
    port: 3000
    targetPort: 3000
    nodePort: 30300
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus-nodeport
  namespace: monitoring
spec:
  type: NodePort
  selector:
    app: prometheus
  ports:
  - name: prometheus
    port: 9090
    targetPort: 9090
    nodePort: 30900
EOF

    # Grafana Dashboards
    cat > "$MONITORING_STACK_DIR/dashboards/kubernetes-cluster-dashboard.json" << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Kubernetes Learning Platform Overview",
    "description": "Comprehensive monitoring for Kubernetes learning platform applications",
    "tags": ["kubernetes", "learning", "applications"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Application Health Status",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=~\"ecommerce-app|educational-platform|medical-care-system|task-management-app|weather-app|social-media-platform\"}",
            "legendFormat": "{{job}}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "mappings": [
              {
                "options": {
                  "0": {"text": "DOWN", "color": "red"},
                  "1": {"text": "UP", "color": "green"}
                },
                "type": "value"
              }
            ]
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Response Time (95th percentile)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, job))",
            "legendFormat": "{{job}}"
          }
        ],
        "yAxes": [
          {
            "label": "Seconds",
            "min": 0
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "id": 3,
        "title": "Memory Usage by Application",
        "type": "graph",
        "targets": [
          {
            "expr": "container_memory_usage_bytes{pod=~\".*-(backend|frontend).*\"}",
            "legendFormat": "{{pod}}"
          }
        ],
        "yAxes": [
          {
            "label": "Bytes",
            "min": 0
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 4,
        "title": "CPU Usage by Application",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total{pod=~\".*-(backend|frontend).*\"}[5m])",
            "legendFormat": "{{pod}}"
          }
        ],
        "yAxes": [
          {
            "label": "CPU cores",
            "min": 0
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF

    echo -e "${GREEN}✅ Monitoring manifests created successfully!${NC}"
}

verify_deployment() {
    echo -e "${BLUE}🔍 Verifying monitoring stack deployment...${NC}"
    echo ""
    
    # Check namespace
    echo -n "📁 Checking monitoring namespace... "
    if kubectl get namespace monitoring >/dev/null 2>&1; then
        echo -e "${GREEN}✅ EXISTS${NC}"
    else
        echo -e "${RED}❌ MISSING${NC}"
        return 1
    fi
    
    # Check deployments
    echo -n "🚀 Checking deployments... "
    local deployments=(prometheus grafana alertmanager blackbox-exporter)
    local ready_deployments=0
    
    for deployment in "${deployments[@]}"; do
        if kubectl get deployment "$deployment" -n monitoring >/dev/null 2>&1; then
            ((ready_deployments++))
        fi
    done
    
    if [[ $ready_deployments -eq ${#deployments[@]} ]]; then
        echo -e "${GREEN}✅ ${ready_deployments}/${#deployments[@]} READY${NC}"
    else
        echo -e "${YELLOW}⚠️  ${ready_deployments}/${#deployments[@]} READY${NC}"
    fi
    
    # Check services
    echo -n "🌐 Checking services... "
    local services=(prometheus grafana alertmanager blackbox-exporter node-exporter)
    local ready_services=0
    
    for service in "${services[@]}"; do
        if kubectl get service "$service" -n monitoring >/dev/null 2>&1; then
            ((ready_services++))
        fi
    done
    
    echo -e "${GREEN}✅ ${ready_services}/${#services[@]} READY${NC}"
    
    # Wait for pods to be ready
    echo -n "⏳ Waiting for pods to be ready... "
    kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=120s >/dev/null 2>&1 &
    kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=120s >/dev/null 2>&1 &
    wait
    echo -e "${GREEN}✅ READY${NC}"
    
    echo ""
    show_access_information
}

show_access_information() {
    echo -e "${CYAN}🎯 MONITORING STACK ACCESS INFORMATION${NC}"
    echo "==============================================================================="
    echo ""
    
    # Get node IP for NodePort access
    local node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || echo "localhost")
    
    echo -e "${GREEN}📊 GRAFANA DASHBOARD${NC}"
    echo "   🌐 URL: http://$node_ip:30300"
    echo "   👤 Username: admin"
    echo "   🔑 Password: admin123"
    echo ""
    
    echo -e "${BLUE}📈 PROMETHEUS METRICS${NC}"
    echo "   🌐 URL: http://$node_ip:30900"
    echo "   📊 Query Interface: Available"
    echo "   🎯 Targets: /targets"
    echo ""
    
    echo -e "${YELLOW}🚨 ALERTMANAGER${NC}"
    echo "   🌐 Access via: kubectl port-forward -n monitoring svc/alertmanager 9093:9093"
    echo "   📧 Email alerts: Configured"
    echo "   🔔 Webhook alerts: Configured"
    echo ""
    
    echo -e "${PURPLE}🔍 APPLICATION METRICS${NC}"
    echo "   📱 E-commerce: Monitored at /health endpoint"
    echo "   🎓 Educational: Monitored at /actuator/prometheus"
    echo "   🏥 Medical Care: Monitored at /health endpoint"
    echo "   📋 Task Management: Monitored at /metrics endpoint"
    echo "   🌤️  Weather: Monitored at /health endpoint"
    echo "   📱 Social Media: Monitored at /health endpoint"
    echo ""
    
    echo -e "${CYAN}🎯 NEXT STEPS${NC}"
    echo "   1. Access Grafana dashboard for visual monitoring"
    echo "   2. Explore pre-configured dashboards"
    echo "   3. Set up custom alerts"
    echo "   4. Monitor your applications in real-time"
    echo ""
    
    echo -e "${GREEN}💡 PRO TIPS${NC}"
    echo "   • Import additional dashboards from grafana.com"
    echo "   • Customize alert thresholds for your needs"
    echo "   • Use Prometheus queries to create custom metrics"
    echo "   • Set up email notifications for critical alerts"
}

cleanup_monitoring() {
    echo -e "${YELLOW}🧹 Cleaning up monitoring stack...${NC}"
    
    echo -n "Are you sure you want to remove the entire monitoring stack? (y/N): "
    read -r confirmation
    
    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
        kubectl delete namespace monitoring --ignore-not-found=true
        echo -e "${GREEN}✅ Monitoring stack removed.${NC}"
    else
        echo "Cleanup cancelled."
    fi
}

show_help() {
    echo -e "${CYAN}🔍 Comprehensive Monitoring System Help${NC}"
    echo ""
    echo "Deploy and manage production-ready monitoring for Kubernetes learning platform."
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy             Deploy the complete monitoring stack"
    echo "  create             Create monitoring manifests"
    echo "  verify             Check deployment status"
    echo "  access             Show access information"
    echo "  cleanup            Remove monitoring stack"
    echo "  help               Show this help"
    echo ""
    echo "Features:"
    echo "  📊 Grafana dashboards with custom visualizations"
    echo "  📈 Prometheus metrics collection from all applications"
    echo "  🚨 AlertManager with email and webhook notifications"
    echo "  🔍 Blackbox monitoring for URL health checks"
    echo "  📱 Node Exporter for infrastructure monitoring"
    echo "  🛡️  Network policies for security"
    echo "  🌐 Ingress configuration for external access"
    echo ""
    echo "Examples:"
    echo "  $0 deploy          # Deploy complete monitoring stack"
    echo "  $0 verify          # Check if everything is running"
    echo "  $0 access          # Show how to access dashboards"
}

main() {
    case "${1:-}" in
        "deploy")
            show_banner
            create_monitoring_manifests
            deploy_monitoring_stack
            verify_deployment
            ;;
        "create")
            create_monitoring_manifests
            ;;
        "verify")
            verify_deployment
            ;;
        "access")
            show_access_information
            ;;
        "cleanup")
            cleanup_monitoring
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

main "$@"