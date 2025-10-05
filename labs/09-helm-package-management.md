# Lab 9: Helm Package Management

**Time**: 75 minutes  
**Difficulty**: ⭐⭐⭐⭐ Expert  
**Focus**: Helm charts, Templating, Values, Package management, Custom charts

---

## 🎯 Objective
Master Helm - the "package manager for Kubernetes". Learn to use existing charts, customize them, and create your own charts for deployment automation.

## 📋 What You'll Learn
- Helm basics (chart, release, repository)
- Installing public charts (nginx, PostgreSQL)
- Values customization and overrides
- Creating custom Helm charts
- Templating with Go templates
- Chart lifecycle management
- Best practices for production

---

## 🚀 Steps

### 1. Install & Configure Helm (10 min)

```bash
# Install Helm (if not already installed)
# macOS: brew install helm
# Or download from: https://helm.sh/docs/intro/install/

# Verify installation
helm version

# Add popular repositories
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

# List available repos
helm repo list

# Search for charts
helm search repo nginx
helm search repo postgresql
```

### 2. Deploy PostgreSQL with Helm (15 min)

```bash
# Create namespace
kubectl create namespace helm-demo

# View chart details before installing
helm show chart bitnami/postgresql
helm show values bitnami/postgresql

# Install PostgreSQL with custom values
helm install my-postgres bitnami/postgresql \
  --namespace helm-demo \
  --set auth.postgresPassword=mypassword \
  --set auth.database=testdb \
  --set primary.persistence.size=1Gi \
  --set volumePermissions.enabled=true

# Check release status
helm status my-postgres -n helm-demo
helm list -n helm-demo

# Get generated resources
kubectl get all -n helm-demo

# Test connection
kubectl run postgresql-client --rm --tty -i --restart='Never' \
  --namespace helm-demo \
  --image docker.io/bitnami/postgresql:16 \
  --env="PGPASSWORD=mypassword" \
  --command -- psql --host my-postgres-postgresql -U postgres -d testdb -p 5432
```

### 3. Customize with Values File (10 min)

```bash
# Create custom values file
cat <<EOF > postgres-values.yaml
auth:
  postgresPassword: "supersecret123"
  database: "ecommerce"
  username: "app_user"
  password: "app_password"

primary:
  persistence:
    enabled: true
    size: 2Gi
    storageClass: ""
  
  resources:
    requests:
      memory: 256Mi
      cpu: 250m
    limits:
      memory: 512Mi
      cpu: 500m

  service:
    type: ClusterIP
    ports:
      postgresql: 5432

metrics:
  enabled: true
  serviceMonitor:
    enabled: false
EOF

# Upgrade with values file
helm upgrade my-postgres bitnami/postgresql \
  --namespace helm-demo \
  --values postgres-values.yaml

# Check what changed
helm get values my-postgres -n helm-demo
kubectl describe pod -l app.kubernetes.io/name=postgresql -n helm-demo
```

### 4. Create Your First Helm Chart (25 min)

```bash
# Create a new chart for weather app
helm create weather-chart

# Examine chart structure
tree weather-chart/
# weather-chart/
# ├── Chart.yaml          # Chart metadata
# ├── values.yaml         # Default values
# ├── charts/             # Chart dependencies
# └── templates/          # Kubernetes manifests with templating
#     ├── deployment.yaml
#     ├── service.yaml
#     ├── ingress.yaml
#     ├── _helpers.tpl    # Template helpers
#     └── tests/

# Examine Chart.yaml
cat weather-chart/Chart.yaml

# Examine values.yaml
cat weather-chart/values.yaml

# Look at template structure
cat weather-chart/templates/deployment.yaml
cat weather-chart/templates/service.yaml
```

### 5. Customize Chart for Weather App (15 min)

```bash
# Update Chart.yaml
cat <<EOF > weather-chart/Chart.yaml
apiVersion: v2
name: weather-chart
description: A Helm chart for Weather Application
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - weather
  - vue
  - python
  - redis
home: https://github.com/temitayocharles/weather-app
maintainers:
  - name: Your Name
    email: you@example.com
EOF

# Update values.yaml for weather app
cat <<EOF > weather-chart/values.yaml
# Default values for weather-chart
replicaCount: 3

image:
  repository: temitayocharles/weather-app
  pullPolicy: IfNotPresent
  tag: "latest"

nameOverride: ""
fullnameOverride: ""

service:
  type: LoadBalancer
  port: 3000
  targetPort: 3000

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: weather-local.com
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: false
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

nodeSelector: {}
tolerations: []
affinity: {}

redis:
  enabled: true
  auth:
    enabled: false
  master:
    persistence:
      enabled: false
EOF

# Update deployment template to use our values
cat <<EOF > weather-chart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "weather-chart.fullname" . }}
  labels:
    {{- include "weather-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "weather-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "weather-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          env:
            - name: REDIS_HOST
              value: "{{ include "weather-chart.fullname" . }}-redis-master"
            - name: REDIS_PORT
              value: "6379"
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
EOF
```

### 6. Add Redis Dependency (10 min)

```bash
# Add Redis as chart dependency
cat <<EOF >> weather-chart/Chart.yaml

dependencies:
  - name: redis
    version: "~18.1.0"
    repository: "https://charts.bitnami.com/bitnami"
    condition: redis.enabled
EOF

# Update dependencies
helm dependency update weather-chart/

# Check downloaded dependencies
ls weather-chart/charts/
```

### 7. Test & Deploy Your Chart (10 min)

```bash
# Lint the chart (check for issues)
helm lint weather-chart/

# Test template rendering (dry run)
helm template my-weather weather-chart/ \
  --namespace weather-helm \
  --set replicaCount=2

# Install your custom chart
kubectl create namespace weather-helm
helm install my-weather weather-chart/ \
  --namespace weather-helm \
  --set replicaCount=2 \
  --set autoscaling.enabled=true

# Check deployment
helm status my-weather -n weather-helm
kubectl get all -n weather-helm

# Test upgrade
helm upgrade my-weather weather-chart/ \
  --namespace weather-helm \
  --set replicaCount=4 \
  --set resources.requests.memory=128Mi

# Check rollout history
helm history my-weather -n weather-helm
```

### 8. Package & Share Chart (Optional - 5 min)

```bash
# Package chart
helm package weather-chart/

# The creates weather-chart-0.1.0.tgz

# You could publish to chart repository
# helm repo index . --url https://your-repo.com/charts
# Upload to GitHub Pages, Artifactory, etc.
```

---

## ✅ Validation

```bash
# 1. Verify Helm is working
helm version --short

# 2. Check PostgreSQL release
helm list -n helm-demo
kubectl get pods -n helm-demo

# 3. Check weather app release
helm list -n weather-helm
kubectl get pods -n weather-helm

# 4. Test weather app
kubectl port-forward -n weather-helm svc/my-weather-weather-chart 3000:3000 &
curl http://localhost:3000/health

# 5. Verify Redis connection
kubectl exec -it deployment/my-weather-weather-chart -n weather-helm -- \
  sh -c 'redis-cli -h my-weather-redis-master ping'
```

---

## 🧹 Cleanup

```bash
# Uninstall releases
helm uninstall my-postgres -n helm-demo
helm uninstall my-weather -n weather-helm

# Delete namespaces
kubectl delete namespace helm-demo weather-helm

# Remove chart files
rm -rf weather-chart/
rm postgres-values.yaml weather-chart-0.1.0.tgz
```

---

## 🎓 Key Concepts Learned

### **Helm Terminology**
- **Chart**: Package of Kubernetes resources
- **Release**: Running instance of a chart
- **Repository**: Collection of charts
- **Values**: Configuration parameters

### **Chart Structure**
- `Chart.yaml`: Metadata (name, version, dependencies)
- `values.yaml`: Default configuration values
- `templates/`: Kubernetes manifests with Go templating
- `charts/`: Chart dependencies (downloaded)

### **Templating Power**
- `{{ .Values.replicaCount }}`: Access values
- `{{ include "chart.name" . }}`: Use helpers
- `{{- if .Values.redis.enabled }}`: Conditional logic
- `{{- toYaml .Values.resources | nindent 12 }}`: Format YAML

### **Lifecycle Management**
- `helm install`: Deploy new release
- `helm upgrade`: Update existing release
- `helm rollback`: Revert to previous version
- `helm uninstall`: Remove release

---

## 📚 Helm Best Practices

### **Chart Development**
✅ **DO**:
- Use semantic versioning for charts
- Document all values in values.yaml
- Add resource limits and requests
- Include health checks
- Use helpers for repeated labels
- Test with multiple value combinations

❌ **DON'T**:
- Hardcode values in templates
- Use `latest` tags
- Skip input validation
- Create overly complex charts
- Ignore security contexts

### **Production Usage**
✅ **DO**:
- Pin chart versions in production
- Use separate values files per environment
- Store sensitive values in secrets
- Test upgrades in staging first
- Keep releases organized by namespace
- Use chart repositories for distribution

❌ **DON'T**:
- Use `--force` upgrades in production
- Skip backup before major upgrades
- Install charts without reviewing values
- Use default passwords
- Deploy without resource limits

---

## 🔧 Common Helm Commands

```bash
# Repository management
helm repo add <name> <url>
helm repo update
helm search repo <keyword>

# Chart development
helm create <name>
helm lint <chart>
helm template <name> <chart>
helm dependency update <chart>

# Release management
helm install <name> <chart> -n <namespace>
helm upgrade <name> <chart> -n <namespace>
helm rollback <name> <revision> -n <namespace>
helm uninstall <name> -n <namespace>

# Information
helm list -A
helm status <name> -n <namespace>
helm history <name> -n <namespace>
helm get values <name> -n <namespace>
```

---

## 🔍 Debugging Tips

### **Chart Issues**
```bash
# Validate chart syntax
helm lint weather-chart/

# See rendered templates
helm template my-weather weather-chart/ --debug

# Dry run installation
helm install my-weather weather-chart/ --dry-run --debug
```

### **Release Issues**
```bash
# Check release status
helm status my-weather -n weather-helm

# Get all release information
helm get all my-weather -n weather-helm

# Check for failed releases
helm list --failed -A
```

### **Template Debugging**
```bash
# Add debug statements to templates
{{ printf "DEBUG: replicaCount is %v" .Values.replicaCount }}

# Use dry-run to see values
helm install --dry-run --debug <name> <chart>
```

---

## 🎯 Real-World Scenarios

### **Scenario 1: Environment-Specific Deployments**
```bash
# Development values
cat <<EOF > values-dev.yaml
replicaCount: 1
resources:
  requests:
    memory: 128Mi
    cpu: 100m
redis:
  master:
    persistence:
      enabled: false
EOF

# Production values
cat <<EOF > values-prod.yaml
replicaCount: 5
resources:
  requests:
    memory: 512Mi
    cpu: 250m
  limits:
    memory: 1Gi
    cpu: 500m
redis:
  master:
    persistence:
      enabled: true
      size: 10Gi
autoscaling:
  enabled: true
EOF

# Deploy to different environments
helm install weather-dev weather-chart/ -f values-dev.yaml -n dev
helm install weather-prod weather-chart/ -f values-prod.yaml -n production
```

### **Scenario 2: Blue-Green Deployments**
```bash
# Deploy blue version
helm install weather-blue weather-chart/ \
  --set image.tag=v1.0.0 \
  --set nameOverride=blue \
  -n weather

# Deploy green version
helm install weather-green weather-chart/ \
  --set image.tag=v2.0.0 \
  --set nameOverride=green \
  -n weather

# Switch traffic (update ingress/service)
# Then cleanup old version
helm uninstall weather-blue -n weather
```

---

## 🏆 Congratulations!

You've mastered Helm package management! You can now:

✅ **Install & manage** existing charts from repositories  
✅ **Customize deployments** using values files  
✅ **Create custom charts** with proper templating  
✅ **Manage dependencies** between charts  
✅ **Handle chart lifecycle** (install/upgrade/rollback)  
✅ **Debug chart issues** effectively  
✅ **Apply best practices** for production usage  

---

## 🚀 What's Next?

1. **Practice**: Convert other apps to Helm charts
2. **Advanced**: Learn Helm hooks and tests
3. **GitOps**: Combine Helm with ArgoCD
4. **Security**: Use Helm secrets plugins
5. **Monitoring**: Add ServiceMonitors to charts

---

## 📚 Additional Resources

- **[Official Helm Docs](https://helm.sh/docs/)**
- **[Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)**
- **[Artifact Hub](https://artifacthub.io/)** - Find charts
- **[Helm Secrets Plugin](https://github.com/jkroepke/helm-secrets)**
- **[Chart Testing](https://github.com/helm/chart-testing)**

**Remember**: Helm is like package manager (apt/yum) for Kubernetes - it manages complexity and enables reusable deployments!