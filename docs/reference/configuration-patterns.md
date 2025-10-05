# 🔧 Configuration Management Patterns

## Overview

Advanced patterns and best practices for managing configuration across different environments in Kubernetes applications.

---

## 🎯 Configuration Hierarchy

### 1. **Configuration Layers**
```
Production Values
    ↓
Staging Overrides  
    ↓
Development Defaults
    ↓
Application Defaults
```

### 2. **Environment-Specific Configs**
```bash
configs/
├── base/                 # Common configuration
│   ├── configmap.yaml
│   └── secrets.yaml
├── development/          # Dev overrides
│   ├── kustomization.yaml
│   └── dev-config.yaml
├── staging/              # Staging overrides
│   ├── kustomization.yaml  
│   └── staging-config.yaml
└── production/           # Prod overrides
    ├── kustomization.yaml
    └── prod-config.yaml
```

---

## 🏗️ Kustomize Configuration

### Base Configuration
```yaml
# configs/base/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: "info"
  CACHE_TTL: "3600"
  MAX_CONNECTIONS: "100"
  FEATURE_FLAGS: "basic,auth"
```

### Environment Overlays
```yaml
# configs/development/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../base

patchesStrategicMerge:
- dev-config.yaml

configMapGenerator:
- name: app-config
  behavior: merge
  literals:
  - LOG_LEVEL=debug
  - CACHE_TTL=60
  - FEATURE_FLAGS=basic,auth,debug,dev-tools
```

### Production Overrides
```yaml
# configs/production/prod-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: "warn"
  CACHE_TTL: "7200"
  MAX_CONNECTIONS: "1000"
  FEATURE_FLAGS: "basic,auth,analytics,monitoring"
  CORS_ORIGINS: "https://yourdomain.com,https://app.yourdomain.com"
```

---

## 🌍 Multi-Environment Setup

### Directory Structure
```bash
environments/
├── dev/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secrets.yaml
│   └── kustomization.yaml
├── staging/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secrets.yaml
│   └── kustomization.yaml
└── prod/
    ├── namespace.yaml
    ├── configmap.yaml
    ├── secrets.yaml
    └── kustomization.yaml
```

### Deployment Script
```bash
#!/bin/bash
# deploy-env.sh

ENV=${1:-dev}
NAMESPACE="myapp-${ENV}"

echo "🚀 Deploying to ${ENV} environment..."

# Apply environment-specific configuration
kubectl apply -k environments/${ENV}/

# Wait for rollout
kubectl rollout status deployment/myapp -n ${NAMESPACE}

# Verify deployment
kubectl get pods -n ${NAMESPACE}
```

---

## 🔄 Dynamic Configuration

### 1. **ConfigMap Hot Reload**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  annotations:
    reloader.stakater.com/match: "true"
data:
  app.properties: |
    server.port=8080
    logging.level=INFO
    cache.ttl=3600
```

### 2. **Init Container Pattern**
```yaml
spec:
  initContainers:
  - name: config-fetcher
    image: alpine/curl:latest
    command: ['sh', '-c']
    args:
    - |
      echo "Fetching configuration..."
      curl -o /shared/config.json \
        "https://config-service/api/config?env=${ENVIRONMENT}"
    env:
    - name: ENVIRONMENT
      value: "production"
    volumeMounts:
    - name: shared-config
      mountPath: /shared
  containers:
  - name: app
    image: myapp:latest
    volumeMounts:
    - name: shared-config
      mountPath: /config
```

### 3. **Sidecar Configuration**
```yaml
spec:
  containers:
  - name: app
    image: myapp:latest
    ports:
    - containerPort: 8080
  - name: config-watcher
    image: config-watcher:latest
    env:
    - name: CONFIG_URL
      value: "https://config-service/api/watch"
    - name: RELOAD_ENDPOINT
      value: "http://localhost:8080/admin/reload"
    volumeMounts:
    - name: shared-config
      mountPath: /config
```

---

## 🎛️ Feature Flags

### 1. **ConfigMap-based Flags**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-flags
data:
  features.json: |
    {
      "newUserInterface": {
        "enabled": true,
        "rollout": 50
      },
      "advancedAnalytics": {
        "enabled": false,
        "environments": ["staging", "prod"]
      },
      "experimentalFeature": {
        "enabled": true,
        "users": ["beta-group"],
        "startDate": "2024-01-01T00:00:00Z"
      }
    }
```

### 2. **Application Code**
```javascript
// Feature flag service
class FeatureFlags {
  constructor() {
    this.flags = JSON.parse(process.env.FEATURE_FLAGS || '{}');
  }

  isEnabled(feature, user = null, environment = null) {
    const flag = this.flags[feature];
    if (!flag) return false;

    // Basic enable/disable
    if (!flag.enabled) return false;

    // Environment check
    if (flag.environments && !flag.environments.includes(environment)) {
      return false;
    }

    // User-specific flags
    if (flag.users && user && !flag.users.includes(user.id)) {
      return false;
    }

    // Percentage rollout
    if (flag.rollout) {
      const hash = this.hashUser(user?.id || 'anonymous');
      return (hash % 100) < flag.rollout;
    }

    return true;
  }

  hashUser(userId) {
    // Simple hash function for consistent rollout
    let hash = 0;
    for (let i = 0; i < userId.length; i++) {
      hash = ((hash << 5) - hash + userId.charCodeAt(i)) & 0xffffffff;
    }
    return Math.abs(hash);
  }
}

// Usage
const features = new FeatureFlags();
if (features.isEnabled('newUserInterface', user, 'production')) {
  // Show new UI
}
```

---

## 📊 Configuration Validation

### 1. **Schema Validation**
```yaml
# config-schema.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-schema
data:
  schema.json: |
    {
      "type": "object",
      "required": ["database", "redis", "jwt"],
      "properties": {
        "database": {
          "type": "object",
          "required": ["host", "port", "name"],
          "properties": {
            "host": {"type": "string"},
            "port": {"type": "integer", "minimum": 1, "maximum": 65535},
            "name": {"type": "string", "minLength": 1}
          }
        },
        "jwt": {
          "type": "object",
          "required": ["secret", "expiry"],
          "properties": {
            "secret": {"type": "string", "minLength": 32},
            "expiry": {"type": "string", "pattern": "^\\d+[hmd]$"}
          }
        }
      }
    }
```

### 2. **Validation Init Container**
```yaml
spec:
  initContainers:
  - name: config-validator
    image: node:alpine
    command: ['node', '-e']
    args:
    - |
      const Ajv = require('ajv');
      const schema = JSON.parse(process.env.CONFIG_SCHEMA);
      const config = JSON.parse(process.env.APP_CONFIG);
      
      const ajv = new Ajv();
      const validate = ajv.compile(schema);
      
      if (!validate(config)) {
        console.error('Configuration validation failed:', validate.errors);
        process.exit(1);
      }
      
      console.log('✅ Configuration validation passed');
    env:
    - name: CONFIG_SCHEMA
      valueFrom:
        configMapKeyRef:
          name: config-schema
          key: schema.json
    - name: APP_CONFIG
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: config.json
```

---

## 🔐 Secrets in Configuration

### 1. **Mixed ConfigMaps and Secrets**
```yaml
# Application deployment
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    # Non-sensitive config
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
    # Sensitive config
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: DATABASE_URL
    # Constructed from multiple sources
    - name: FULL_DATABASE_URL
      value: "$(DATABASE_PROTOCOL)://$(DATABASE_USER):$(DATABASE_PASSWORD)@$(DATABASE_HOST):$(DATABASE_PORT)/$(DATABASE_NAME)"
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: app-secrets
```

### 2. **Secret-backed ConfigMaps**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-template
data:
  app.properties: |
    server.port=8080
    database.url=jdbc:postgresql://{{.DATABASE_HOST}}:{{.DATABASE_PORT}}/{{.DATABASE_NAME}}
    database.username={{.DATABASE_USER}}
    database.password={{.DATABASE_PASSWORD}}
    jwt.secret={{.JWT_SECRET}}
```

---

## 🧪 Testing Configuration

### 1. **Configuration Tests**
```bash
#!/bin/bash
# test-config.sh

ENVIRONMENT=${1:-dev}

echo "🧪 Testing configuration for ${ENVIRONMENT}..."

# Apply configuration
kubectl apply -k environments/${ENVIRONMENT}/ --dry-run=client

# Validate required secrets exist
REQUIRED_SECRETS=("database-password" "jwt-secret" "api-key")
for secret in "${REQUIRED_SECRETS[@]}"; do
  if ! kubectl get secret app-secrets -o jsonpath="{.data.${secret}}" > /dev/null 2>&1; then
    echo "❌ Missing required secret: ${secret}"
    exit 1
  fi
done

# Test configuration values
kubectl create job config-test --image=alpine:latest --dry-run=client -o yaml > /tmp/test-job.yaml
cat >> /tmp/test-job.yaml << 'EOF'
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secrets
        command: ['sh', '-c']
        args:
        - |
          echo "Testing configuration..."
          
          # Check required environment variables
          for var in LOG_LEVEL DATABASE_URL JWT_SECRET; do
            if [ -z "${!var}" ]; then
              echo "❌ Missing environment variable: $var"
              exit 1
            fi
          done
          
          echo "✅ All required configuration present"
EOF

kubectl apply -f /tmp/test-job.yaml
kubectl wait --for=condition=complete job/config-test --timeout=60s
kubectl logs job/config-test
kubectl delete job config-test
```

### 2. **Configuration Monitoring**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-monitor
data:
  monitor.sh: |
    #!/bin/bash
    while true; do
      # Check configuration changes
      CURRENT_HASH=$(kubectl get configmap app-config -o yaml | sha256sum)
      if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
        echo "🔄 Configuration changed, triggering reload..."
        curl -X POST http://localhost:8080/admin/reload
        LAST_HASH=$CURRENT_HASH
      fi
      sleep 30
    done
```

---

## 📋 Configuration Checklist

### Development
- [ ] All `.env.example` files have corresponding `.env` files
- [ ] No hardcoded secrets in code
- [ ] Feature flags implemented for new features
- [ ] Configuration validation in place

### Staging
- [ ] Environment-specific values configured
- [ ] Secrets properly separated from config
- [ ] Configuration matches production structure
- [ ] Automated deployment and rollback

### Production
- [ ] All secrets rotated and secured
- [ ] Configuration changes are audited
- [ ] Rollback procedures tested
- [ ] Monitoring and alerting configured

---

## 🔧 Tools & Utilities

### Configuration Management Tools
- **Helm**: Template-based configuration
- **Kustomize**: Overlay-based configuration
- **Skaffold**: Development workflow automation
- **ArgoCD**: GitOps configuration deployment

### Secret Management
- **External Secrets Operator**: Kubernetes secret sync
- **Sealed Secrets**: Encrypted secrets in git
- **HashiCorp Vault**: Enterprise secret management
- **AWS Secrets Manager**: Cloud-native secrets

**Remember**: Configuration should be environment-specific, secrets should be secure, and both should be easily manageable across your development lifecycle! 🚀