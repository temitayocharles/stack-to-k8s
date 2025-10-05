# Lab 7: Multi-App Orchestration

**Time**: 120 minutes  
**Difficulty**: ⭐⭐⭐⭐ Expert  
**Focus**: Service mesh, Centralized logging, Monitoring, Complex orchestration

---

## 🎯 Objective
Deploy all 6 applications together and learn how to manage complex multi-app environments with service mesh, monitoring, and logging.

## 📋 What You'll Learn
- Deploy multiple apps simultaneously
- Service mesh basics (Istio)
- Centralized logging (Loki)
- Monitoring (Prometheus + Grafana)
- Cross-app communication
- Traffic management
- Observability

---

## 🚀 Steps

### 1. Create Namespace & Deploy All Apps (20 min)

```bash
kubectl create namespace platform
kubectl config set-context --current --namespace=platform

# Deploy Weather App
kubectl apply -f weather-app/k8s/ -n platform
kubectl label deployment weather-app app=weather version=v1 -n platform

# Deploy E-commerce
kubectl apply -f ecommerce-app/k8s/ -n platform
kubectl label deployment ecommerce-frontend app=ecommerce component=frontend -n platform
kubectl label deployment ecommerce-backend app=ecommerce component=backend -n platform

# Deploy Educational Platform
kubectl apply -f educational-platform/k8s/ -n platform
kubectl label deployment educational-frontend app=educational component=frontend -n platform
kubectl label deployment educational-backend app=educational component=backend -n platform

# Deploy Task Management
kubectl apply -f task-management-app/k8s/ -n platform
kubectl label deployment task-frontend app=task component=frontend -n platform
kubectl label deployment task-backend app=task component=backend -n platform

# Deploy Medical Care
kubectl apply -f medical-care-system/k8s/ -n platform
kubectl label deployment medical-frontend app=medical component=frontend -n platform
kubectl label deployment medical-backend app=medical component=backend -n platform

# Deploy Social Media
kubectl apply -f social-media-platform/k8s/ -n platform
kubectl label deployment social-frontend app=social component=frontend -n platform
kubectl label deployment social-backend app=social component=backend -n platform

# Wait for all pods
kubectl wait --for=condition=ready pod --all -n platform --timeout=300s
```

### 2. View All Resources (5 min)

```bash
# Get all deployments
kubectl get deployments -n platform

# Get all services
kubectl get services -n platform

# Get all pods organized by app
kubectl get pods -n platform --show-labels | sort

# Count pods per app
kubectl get pods -n platform -o json | jq '.items | group_by(.metadata.labels.app) | map({app: .[0].metadata.labels.app, count: length})'
```

### 3. Install Prometheus & Grafana (15 min)

```bash
# Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus stack (includes Grafana)
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# Wait for all pods
kubectl wait --for=condition=ready pod --all -n monitoring --timeout=300s

# Port forward Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 &

# Default credentials: admin / prom-operator
echo "Grafana: http://localhost:3000"
echo "Username: admin"
echo "Password: prom-operator"
```

### 4. Install Loki for Logging (10 min)

```bash
# Add Loki repo
helm repo add grafana https://grafana.github.io/helm-charts

# Install Loki
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set promtail.enabled=true

# Verify Loki installed
kubectl get pods -n monitoring -l app=loki

# Add Loki datasource to Grafana (via UI)
# URL: http://loki:3100
```

### 5. Create Service Monitors (10 min)

```bash
# Create ServiceMonitor for all apps
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: platform-apps
  namespace: platform
  labels:
    release: monitoring
spec:
  selector:
    matchLabels:
      monitored: "true"
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
EOF

# Label services for monitoring
kubectl label service weather-app monitored=true -n platform
kubectl label service ecommerce-backend monitored=true -n platform
kubectl label service educational-backend monitored=true -n platform
kubectl label service task-backend monitored=true -n platform
kubectl label service medical-backend monitored=true -n platform
kubectl label service social-backend monitored=true -n platform

# Verify ServiceMonitor
kubectl get servicemonitor -n platform
```

### 6. Basic Istio Setup (20 min)

```bash
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# Install Istio
istioctl install --set profile=demo -y

# Enable sidecar injection
kubectl label namespace platform istio-injection=enabled

# Restart all pods to inject sidecars
kubectl rollout restart deployment -n platform

# Wait for pods to restart with sidecars (2 containers per pod)
kubectl wait --for=condition=ready pod --all -n platform --timeout=300s

# Verify sidecars injected
kubectl get pods -n platform -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
# Should see 2 containers per pod
```

### 7. Create Istio Gateway & Virtual Services (15 min)

```bash
# Create Gateway
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: platform-gateway
  namespace: platform
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
EOF

# Create VirtualServices for each app
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: platform-routes
  namespace: platform
spec:
  hosts:
  - "*"
  gateways:
  - platform-gateway
  http:
  - match:
    - uri:
        prefix: "/weather"
    route:
    - destination:
        host: weather-app
        port:
          number: 3000
  - match:
    - uri:
        prefix: "/ecommerce"
    route:
    - destination:
        host: ecommerce-frontend
        port:
          number: 3000
  - match:
    - uri:
        prefix: "/educational"
    route:
    - destination:
        host: educational-frontend
        port:
          number: 3000
  - match:
    - uri:
        prefix: "/tasks"
    route:
    - destination:
        host: task-frontend
        port:
          number: 3000
  - match:
    - uri:
        prefix: "/medical"
    route:
    - destination:
        host: medical-frontend
        port:
          number: 3000
  - match:
    - uri:
        prefix: "/social"
    route:
    - destination:
        host: social-frontend
        port:
          number: 3000
EOF

# Get Ingress Gateway address
kubectl get svc istio-ingressgateway -n istio-system
```

### 8. Traffic Management (10 min)

```bash
# Create DestinationRule with circuit breaking
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: social-backend-cb
  namespace: platform
spec:
  host: social-backend
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 1m
      maxEjectionPercent: 50
EOF

# Verify
kubectl get destinationrule -n platform
```

### 9. View Kiali Dashboard (10 min)

```bash
# Install Kiali (Istio dashboard)
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Wait for Kiali
kubectl wait --for=condition=ready pod -l app=kiali -n istio-system --timeout=120s

# Port forward Kiali
kubectl port-forward -n istio-system svc/kiali 20001:20001 &

# Open Kiali
echo "Kiali: http://localhost:20001"

# Generate some traffic to see in Kiali
for i in {1..100}; do
  curl http://<INGRESS_IP>/weather
  curl http://<INGRESS_IP>/ecommerce
  curl http://<INGRESS_IP>/social
  sleep 1
done
```

### 10. View Logs in Grafana (5 min)

```bash
# Open Grafana (should already be running)
# http://localhost:3000

# Navigate to Explore > Loki
# Query: {namespace="platform"}

# Filter by app: {namespace="platform", app="social"}
# Filter by component: {namespace="platform", component="backend"}

# See real-time logs across all apps
```

---

## ✅ Validation

```bash
# 1. All apps running
kubectl get pods -n platform
# Expected: All pods RUNNING with 2/2 containers (app + sidecar)

# 2. Monitoring installed
kubectl get pods -n monitoring
# Expected: prometheus, grafana, loki, promtail running

# 3. Istio installed
kubectl get pods -n istio-system
# Expected: istiod, ingressgateway running

# 4. ServiceMonitors created
kubectl get servicemonitor -n platform

# 5. Gateway and VirtualService
kubectl get gateway,virtualservice -n platform

# 6. Kiali accessible
curl -s http://localhost:20001 | grep Kiali

# 7. Grafana accessible
curl -s http://localhost:3000/login

# 8. Prometheus scraping targets
# Open http://localhost:9090/targets
# Should see platform apps
```

**All checks pass?** ✅ Lab complete!

---

## 🧹 Cleanup

```bash
kubectl delete namespace platform
kubectl delete namespace monitoring
istioctl uninstall --purge -y
kubectl delete namespace istio-system

# Kill port forwards
pkill -f "port-forward"
```

---

## 🎓 Key Concepts Learned

1. **Multi-app deployment**: Manage 6+ apps in single namespace
2. **Service mesh**: Istio for traffic management
3. **Observability**: Prometheus, Grafana, Loki, Kiali
4. **Circuit breaking**: Protect services from cascading failures
5. **Centralized logging**: View logs across all apps
6. **Sidecar injection**: Automatic proxy injection
7. **Traffic routing**: Path-based routing with VirtualServices

---

## 📚 Service Mesh Benefits

### Without Istio
- Manual load balancing
- No traffic visibility
- Hard to implement retries/timeouts
- No circuit breaking
- Limited observability

### With Istio
- Automatic load balancing
- Real-time traffic visualization (Kiali)
- Declarative retries/timeouts
- Built-in circuit breaking
- Distributed tracing
- mTLS between services

---

## 📊 Grafana Dashboards to Explore

1. **Kubernetes / Compute Resources / Namespace (Pods)**
   - CPU/Memory per pod
   - Network traffic

2. **Kubernetes / Compute Resources / Cluster**
   - Overall cluster health

3. **Istio / Performance Dashboard**
   - Request rates
   - Error rates
   - Latencies

4. **Loki Dashboard**
   - Logs across all apps
   - Filter by label

---

## 🔧 Istio Traffic Management Patterns

### A/B Testing
```yaml
- match:
  - headers:
      user-agent:
        regex: ".*mobile.*"
  route:
  - destination:
      host: app-v2
- route:
  - destination:
      host: app-v1
```

### Canary Deployment
```yaml
- route:
  - destination:
      host: app
      subset: v1
    weight: 90
  - destination:
      host: app
      subset: v2
    weight: 10
```

### Fault Injection
```yaml
fault:
  delay:
    percentage:
      value: 10
    fixedDelay: 5s
```

---

## 🔍 Debugging Tips

**Sidecar not injecting?**
```bash
# Check namespace label
kubectl get namespace platform --show-labels

# Check injection status
kubectl get pods -n platform -o jsonpath='{.items[*].spec.containers[*].name}'
```

**Can't access apps via Ingress?**
```bash
# Check Gateway
kubectl describe gateway platform-gateway -n platform

# Check VirtualService
kubectl describe virtualservice platform-routes -n platform

# Check Ingress Gateway logs
kubectl logs -n istio-system -l app=istio-ingressgateway
```

**Prometheus not scraping?**
```bash
# Check ServiceMonitor
kubectl describe servicemonitor platform-apps -n platform

# Check service labels
kubectl get services -n platform --show-labels
```

---

## 🚀 Next Lab

**[Lab 8: Chaos Engineering](08-chaos.md)**

Learn about:
- Chaos Mesh installation
- Pod failure scenarios
- Network delays
- Resource stress
- Recovery strategies
- Resilience testing
