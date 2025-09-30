# 🏢 Enterprise Setup - Production-Ready Configuration

**Goal**: Configure a professional development environment with enterprise-grade tools.

> **Perfect for**: "I want production-ready skills and tools"

## 🎯 What You'll Get
- ✅ **Professional IDE setup** with VS Code extensions
- ✅ **Enterprise security** with secrets management
- ✅ **Monitoring and observability** with Prometheus and Grafana
- ✅ **Development workflow** with Git hooks and code quality
- ✅ **Container registry** for image management

## 📋 Before You Start
**Required time**: 2-3 hours  
**Prerequisites**: [System setup](system-setup.md) and [Kubernetes basics](kubernetes-basics.md) completed  
**Skills**: Comfortable with command line and Docker

## 🚀 Phase 1: Professional IDE Setup (30 minutes)

### Step 1: Install VS Code Extensions
```bash
# Essential Kubernetes extensions
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-vscode.vscode-yaml
code --install-extension redhat.vscode-docker

# Code quality extensions
code --install-extension esbenp.prettier-vscode
code --install-extension ms-vscode.vscode-eslint
code --install-extension bradlc.vscode-tailwindcss
```

### Step 2: Configure VS Code Settings
Create `.vscode/settings.json` in your workspace:
```json
{
  "kubernetes.defaultNamespace": "default",
  "yaml.schemas": {
    "kubernetes": "*.yaml"
  },
  "editor.formatOnSave": true,
  "docker.showStartPage": false
}
```

### Step 3: Set Up Code Quality Tools
```bash
# Install commitizen for consistent commits
npm install -g commitizen
npm install -g cz-conventional-changelog

# Set up pre-commit hooks
npm install -g husky
husky install
```

## 🔒 Phase 2: Enterprise Security Setup (45 minutes)

### Step 1: Set Up Secrets Management
```bash
# Install vault for secrets management
brew install vault  # Mac
# or
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -  # Linux
```

### Step 2: Configure Kubernetes Secrets
```bash
# Create namespace for your applications
kubectl create namespace production

# Create secret for database
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=secure-password \
  --namespace=production
```

### Step 3: Set Up TLS Certificates
```bash
# Generate development certificates
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=myapp.local/O=myapp"

# Create TLS secret
kubectl create secret tls myapp-tls \
  --cert=tls.crt --key=tls.key \
  --namespace=production
```

## 📊 Phase 3: Monitoring and Observability (60 minutes)

### Step 1: Deploy Prometheus Stack
```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=admin123
```

### Step 2: Configure Application Monitoring
Create `monitoring/service-monitor.yaml`:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-metrics
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: my-application
  endpoints:
  - port: metrics
    path: /metrics
```

### Step 3: Access Monitoring Dashboards
```bash
# Access Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80

# Access Prometheus
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090

# Access AlertManager
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093
```

## 🔄 Phase 4: Development Workflow (45 minutes)

### Step 1: Set Up Git Hooks
Create `.husky/pre-commit`:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run tests before commit
npm test

# Run linting
npm run lint

# Check Docker builds
docker-compose build --dry-run
```

### Step 2: Configure Automated Testing
Create `.github/workflows/test.yml`:
```yaml
name: Test Applications
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Run tests
      run: |
        docker-compose -f docker-compose.test.yml run --rm test
```

### Step 3: Set Up Code Quality Checks
```bash
# Install quality tools
npm install -g sonarjs eslint prettier

# Create .eslintrc.js
echo "module.exports = { extends: ['eslint:recommended'] };" > .eslintrc.js

# Create .prettierrc
echo '{ "singleQuote": true, "trailingComma": "es5" }' > .prettierrc
```

## 🏗️ Phase 5: Container Registry Setup (30 minutes)

### Step 1: Set Up Local Registry
```bash
# Run local Docker registry
docker run -d -p 5000:5000 --name registry registry:2

# Configure insecure registry (for development)
# Add to Docker Desktop settings: "insecure-registries": ["localhost:5000"]
```

### Step 2: Build and Push Images
```bash
# Build application image
docker build -t localhost:5000/my-app:v1.0.0 .

# Push to registry
docker push localhost:5000/my-app:v1.0.0

# Verify image in registry
curl http://localhost:5000/v2/_catalog
```

### Step 3: Configure Kubernetes to Use Registry
Update your deployment YAML:
```yaml
spec:
  template:
    spec:
      containers:
      - name: my-app
        image: localhost:5000/my-app:v1.0.0
        imagePullPolicy: Always
```

## 🛡️ Phase 6: Security Hardening (30 minutes)

### Step 1: Enable Pod Security Standards
```bash
# Label namespace for security
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

### Step 2: Create Network Policies
Create `security/network-policy.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### Step 3: Configure RBAC
Create `security/rbac.yaml`:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: production
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-role-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: production
roleRef:
  kind: Role
  name: app-role
  apiGroup: rbac.authorization.k8s.io
```

## ✅ Verify Enterprise Setup

### Check All Components
```bash
# Verify monitoring
kubectl get pods -n monitoring

# Check security policies
kubectl get networkpolicies -n production

# Verify secrets
kubectl get secrets -n production

# Test image registry
curl http://localhost:5000/v2/_catalog
```

### Performance Test
```bash
# Run load test against your application
kubectl run load-test --image=busybox --rm -it -- sh -c \
  'for i in $(seq 1 100); do wget -q -O- http://my-app-service; done'
```

## 🎉 Success Criteria

You've successfully set up enterprise-grade development environment with:
- ✅ **Professional IDE** with Kubernetes integration
- ✅ **Monitoring stack** with Prometheus and Grafana
- ✅ **Security policies** with network isolation and RBAC
- ✅ **Development workflow** with automated testing
- ✅ **Container registry** for image management

## ➡️ What's Next?

✅ **Ready for CI/CD?** → [Automated pipeline setup](cicd-setup.md)  
✅ **Want production deployment?** → [Production-ready deployment](../deployment/production-ready.md)  
✅ **Need advanced monitoring?** → [Advanced observability](../deployment/monitoring.md)

## 🆘 Enterprise Setup Issues

**Monitoring pods not starting**:
- Check cluster resources: `kubectl top nodes`
- Verify Helm installation: `helm list -n monitoring`

**Security policies too restrictive**:
- Start with permissive policies
- Gradually tighten based on application needs

**Registry connection issues**:
- Check Docker daemon configuration
- Verify firewall settings

---

**Congratulations!** You now have a professional development environment that mirrors enterprise production setups.