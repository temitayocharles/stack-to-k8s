# 🚀 **Kubernetes Orchestration Complete Guide**
## **Deploy All Applications with Helm, Raw YAML & Kustomize**

> **🎯 Your Main Goal: Master Kubernetes Orchestration**  
> **⏰ Time Needed**: 45-60 minutes per application  
> **👨‍💻 For**: Complete beginners to Kubernetes experts  
> **📚 Level**: Progressive learning from basic to advanced  

---

## 📋 **What You'll Master**

**Complete Kubernetes Deployment Stack:**
- ✅ **Helm Charts** - Package manager for Kubernetes applications
- ✅ **Raw YAML** - Direct Kubernetes manifest deployment
- ✅ **Kustomize** - Template-free configuration customization
- ✅ **Multi-Environment** - Development, staging, production setups
- ✅ **Advanced Features** - HPA, Network Policies, Pod Disruption Budgets

**All 6 Applications Covered:**
1. **E-commerce App** (Node.js + React + MongoDB)
2. **Educational Platform** (Java Spring Boot + Angular + PostgreSQL)
3. **Weather App** (Python Flask + Vue.js + Redis)
4. **Medical Care System** (.NET Core + Blazor + SQL Server)
5. **Task Management App** (Go + Svelte + CouchDB)
6. **Social Media Platform** (Ruby on Rails + React Native Web + PostgreSQL)

---

## 🏗️ **Three Deployment Methods - Choose Your Path**

### **🎯 Method 1: Helm (Recommended for Beginners)**
**Best For**: First-time Kubernetes users, production deployments
- **Package Management**: Like apt/yum for Kubernetes
- **Easy Upgrades**: Simple version management
- **Built-in Security**: RBAC and security contexts included
- **Community Charts**: Pre-built solutions available

### **🎯 Method 2: Raw YAML**
**Best For**: Learning Kubernetes internals, custom configurations
- **Full Control**: Every resource defined explicitly
- **Educational**: Understand every Kubernetes object
- **Debugging**: Easy to troubleshoot issues
- **Version Control**: Clear git history of changes

### **🎯 Method 3: Kustomize**
**Best For**: Environment management, configuration customization
- **Template-Free**: No complex templating syntax
- **Environment-Specific**: Easy dev/staging/prod configs
- **GitOps Ready**: Perfect for automated deployments
- **Overlay System**: Clean configuration inheritance

---

## 🚀 **Quick Start: Deploy E-commerce App**

### **Step 1: Prerequisites Check**
```bash
# Check if you have required tools
kubectl version --client
helm version
kustomize version

# Expected output:
# Client Version: v1.28.0
# version.BuildInfo{Version:"v3.13.0"}
# v5.0.1
```

### **Step 2: Choose Your Method**

#### **Option A: Helm Deployment (5 minutes)**
```bash
# Navigate to ecommerce app
cd ecommerce-app

# Add Helm repository (if using external charts)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Deploy with Helm
helm install ecommerce ./k8s/helm/ecommerce \
  --namespace ecommerce \
  --create-namespace \
  --set mongodb.auth.rootPassword='YourSecurePassword123!'

# Check deployment
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
```

#### **Option B: Raw YAML Deployment (10 minutes)**
```bash
# Navigate to ecommerce app
cd ecommerce-app

# Apply all Kubernetes manifests
kubectl apply -f k8s/base/

# Check deployment status
kubectl get deployments -n ecommerce
kubectl get services -n ecommerce
kubectl get ingress -n ecommerce
```

#### **Option C: Kustomize Deployment (8 minutes)**
```bash
# Navigate to ecommerce app
cd ecommerce-app

# Deploy with Kustomize
kubectl apply -k k8s/overlays/development/

# Or for production
kubectl apply -k k8s/overlays/production/

# Check deployment
kubectl get all -n ecommerce
```

---

## 📁 **Complete Application Directory Structure**

```
ecommerce-app/
├── k8s/
│   ├── helm/                    # Helm charts
│   │   ├── ecommerce/
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── templates/
│   │   │   │   ├── deployment.yaml
│   │   │   │   ├── service.yaml
│   │   │   │   ├── ingress.yaml
│   │   │   │   ├── configmap.yaml
│   │   │   │   └── _helpers.tpl
│   │   └── requirements.yaml
│   ├── base/                    # Raw YAML manifests
│   │   ├── namespace.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── mongodb-deployment.yaml
│   │   ├── mongodb-service.yaml
│   │   ├── redis-deployment.yaml
│   │   ├── redis-service.yaml
│   │   ├── ingress.yaml
│   │   └── configmap.yaml
│   └── overlays/                # Kustomize overlays
│       ├── development/
│       │   ├── kustomization.yaml
│       │   ├── namespace.yaml
│       │   └── configmap.yaml
│       └── production/
│           ├── kustomization.yaml
│           ├── namespace.yaml
│           ├── configmap.yaml
│           └── ingress.yaml
```

---

## 🎯 **Method 1: Helm Deployment Guide**

### **1.1 Understanding Helm Charts**

**Helm is like a package manager for Kubernetes:**
- **Chart**: Package containing Kubernetes manifests
- **Release**: Instance of a deployed chart
- **Repository**: Collection of charts (like Docker Hub)
- **Values**: Configuration parameters for customization

### **1.2 E-commerce App Helm Deployment**

#### **Step 1: Create Helm Chart Structure**
```bash
# Create Helm chart directory
mkdir -p ecommerce-app/k8s/helm/ecommerce/templates

# Create Chart.yaml
cat > ecommerce-app/k8s/helm/ecommerce/Chart.yaml << EOF
apiVersion: v2
name: ecommerce
description: E-commerce application with Node.js backend and React frontend
type: application
version: 1.0.0
appVersion: "1.0.0"
dependencies:
  - name: mongodb
    version: "13.x.x"
    repository: "https://charts.bitnami.com/bitnami"
  - name: redis
    version: "17.x.x"
    repository: "https://charts.bitnami.com/bitnami"
EOF
```

#### **Step 2: Create values.yaml**
```yaml
# ecommerce-app/k8s/helm/ecommerce/values.yaml
# Backend Configuration
backend:
  image:
    repository: ecommerce/backend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 5000
  env:
    NODE_ENV: production
    MONGODB_URI: mongodb://mongodb:27017/ecommerce
    REDIS_URL: redis://redis:6379
    JWT_SECRET: "your-jwt-secret-here"

# Frontend Configuration
frontend:
  image:
    repository: ecommerce/frontend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 3000
  env:
    REACT_APP_API_URL: "http://backend:5000/api"

# Database Configuration
mongodb:
  auth:
    rootPassword: "YourSecurePassword123!"
    username: "ecommerce"
    password: "ecommerce123"
    database: "ecommerce"
  architecture: standalone
  persistence:
    enabled: true
    size: 8Gi

# Redis Configuration
redis:
  auth:
    password: "redis123"
  architecture: standalone
  persistence:
    enabled: true
    size: 1Gi

# Ingress Configuration
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: ecommerce.local
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: ecommerce-tls
      hosts:
        - ecommerce.local
```

#### **Step 3: Create Backend Deployment Template**
```yaml
# ecommerce-app/k8s/helm/ecommerce/templates/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "ecommerce.fullname" . }}-backend
  labels:
    app.kubernetes.io/name: {{ include "ecommerce.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: backend
spec:
  replicas: {{ .Values.backend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "ecommerce.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "ecommerce.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        app.kubernetes.io/component: backend
    spec:
      containers:
        - name: backend
          image: "{{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag }}"
          imagePullPolicy: {{ .Values.backend.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.backend.port }}
              protocol: TCP
          env:
            - name: NODE_ENV
              value: {{ .Values.backend.env.NODE_ENV | quote }}
            - name: MONGODB_URI
              value: {{ .Values.backend.env.MONGODB_URI | quote }}
            - name: REDIS_URL
              value: {{ .Values.backend.env.REDIS_URL | quote }}
            - name: JWT_SECRET
              value: {{ .Values.backend.env.JWT_SECRET | quote }}
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
```

#### **Step 4: Create Backend Service Template**
```yaml
# ecommerce-app/k8s/helm/ecommerce/templates/backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "ecommerce.fullname" . }}-backend
  labels:
    app.kubernetes.io/name: {{ include "ecommerce.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: backend
spec:
  type: ClusterIP
  ports:
    - port: {{ .Values.backend.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: {{ include "ecommerce.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: backend
```

#### **Step 5: Create Frontend Deployment Template**
```yaml
# ecommerce-app/k8s/helm/ecommerce/templates/frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "ecommerce.fullname" . }}-frontend
  labels:
    app.kubernetes.io/name: {{ include "ecommerce.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "ecommerce.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: frontend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "ecommerce.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        app.kubernetes.io/component: frontend
    spec:
      containers:
        - name: frontend
          image: "{{ .Values.frontend.image.repository }}:{{ .Values.frontend.image.tag }}"
          imagePullPolicy: {{ .Values.frontend.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.frontend.port }}
              protocol: TCP
          env:
            - name: REACT_APP_API_URL
              value: {{ .Values.frontend.env.REACT_APP_API_URL | quote }}
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
```

#### **Step 6: Create Ingress Template**
```yaml
# ecommerce-app/k8s/helm/ecommerce/templates/ingress.yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "ecommerce.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ include "ecommerce.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "ecommerce.fullname" $ }}-frontend
                port:
                  number: {{ $.Values.frontend.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

#### **Step 7: Create _helpers.tpl**
```tpl
# ecommerce-app/k8s/helm/ecommerce/templates/_helpers.tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "ecommerce.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ecommerce.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ecommerce.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ecommerce.labels" -}}
helm.sh/chart: {{ include "ecommerce.chart" . }}
{{ include "ecommerce.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ecommerce.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ecommerce.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

#### **Step 8: Deploy with Helm**
```bash
# Navigate to Helm chart directory
cd ecommerce-app/k8s/helm/ecommerce

# Install dependencies
helm dependency update

# Deploy to development
helm install ecommerce-dev . \
  --namespace ecommerce-dev \
  --create-namespace \
  --values values.yaml

# Check deployment
helm list -n ecommerce-dev
kubectl get pods -n ecommerce-dev
kubectl get services -n ecommerce-dev

# Get application URL
kubectl get ingress -n ecommerce-dev
```

---

## 📄 **Method 2: Raw YAML Deployment Guide**

### **2.1 Understanding Raw YAML**

**Raw YAML gives you complete control:**
- **Every Resource**: Explicitly defined Kubernetes objects
- **No Abstractions**: Direct interaction with Kubernetes API
- **Educational**: Learn every aspect of Kubernetes
- **Debugging**: Easy to identify and fix issues

### **2.2 E-commerce App Raw YAML Deployment**

#### **Step 1: Create Namespace**
```yaml
# ecommerce-app/k8s/base/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
  labels:
    name: ecommerce
    app: ecommerce-app
```

#### **Step 2: Create ConfigMap**
```yaml
# ecommerce-app/k8s/base/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-config
  namespace: ecommerce
  labels:
    app: ecommerce-app
data:
  NODE_ENV: "production"
  REACT_APP_API_URL: "http://ecommerce-backend:5000/api"
  MONGODB_URI: "mongodb://ecommerce-mongodb:27017/ecommerce"
  REDIS_URL: "redis://ecommerce-redis:6379"
```

#### **Step 3: Create Backend Deployment**
```yaml
# ecommerce-app/k8s/base/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecommerce-app
      component: backend
  template:
    metadata:
      labels:
        app: ecommerce-app
        component: backend
    spec:
      containers:
        - name: backend
          image: ecommerce/backend:latest
          ports:
            - containerPort: 5000
              name: http
          env:
            - name: NODE_ENV
              valueFrom:
                configMapKeyRef:
                  name: ecommerce-config
                  key: NODE_ENV
            - name: MONGODB_URI
              valueFrom:
                configMapKeyRef:
                  name: ecommerce-config
                  key: MONGODB_URI
            - name: REDIS_URL
              valueFrom:
                configMapKeyRef:
                  name: ecommerce-config
                  key: REDIS_URL
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: ecommerce-secrets
                  key: jwt-secret
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
```

#### **Step 4: Create Backend Service**
```yaml
# ecommerce-app/k8s/base/backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-backend
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: backend
spec:
  selector:
    app: ecommerce-app
    component: backend
  ports:
    - name: http
      port: 5000
      targetPort: 5000
      protocol: TCP
  type: ClusterIP
```

#### **Step 5: Create Frontend Deployment**
```yaml
# ecommerce-app/k8s/base/frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-frontend
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecommerce-app
      component: frontend
  template:
    metadata:
      labels:
        app: ecommerce-app
        component: frontend
    spec:
      containers:
        - name: frontend
          image: ecommerce/frontend:latest
          ports:
            - containerPort: 3000
              name: http
          env:
            - name: REACT_APP_API_URL
              valueFrom:
                configMapKeyRef:
                  name: ecommerce-config
                  key: REACT_APP_API_URL
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
```

#### **Step 6: Create Frontend Service**
```yaml
# ecommerce-app/k8s/base/frontend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-frontend
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: frontend
spec:
  selector:
    app: ecommerce-app
    component: frontend
  ports:
    - name: http
      port: 3000
      targetPort: 3000
      protocol: TCP
  type: ClusterIP
```

#### **Step 7: Create MongoDB Deployment**
```yaml
# ecommerce-app/k8s/base/mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-mongodb
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ecommerce-app
      component: database
  template:
    metadata:
      labels:
        app: ecommerce-app
        component: database
    spec:
      containers:
        - name: mongodb
          image: mongo:6.0
          ports:
            - containerPort: 27017
              name: mongodb
          env:
            - name: MONGO_INITDB_ROOT_USERNAME
              valueFrom:
                secretKeyRef:
                  name: ecommerce-secrets
                  key: mongodb-username
            - name: MONGO_INITDB_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: ecommerce-secrets
                  key: mongodb-password
            - name: MONGO_INITDB_DATABASE
              value: ecommerce
          volumeMounts:
            - name: mongodb-data
              mountPath: /data/db
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          livenessProbe:
            exec:
              command:
                - mongo
                - --eval
                - "db.adminCommand('ping')"
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - mongo
                - --eval
                - "db.adminCommand('ping')"
            initialDelaySeconds: 5
            periodSeconds: 5
      volumes:
        - name: mongodb-data
          persistentVolumeClaim:
            claimName: mongodb-pvc
```

#### **Step 8: Create MongoDB Service**
```yaml
# ecommerce-app/k8s/base/mongodb-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-mongodb
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: database
spec:
  selector:
    app: ecommerce-app
    component: database
  ports:
    - name: mongodb
      port: 27017
      targetPort: 27017
      protocol: TCP
  type: ClusterIP
```

#### **Step 9: Create Redis Deployment**
```yaml
# ecommerce-app/k8s/base/redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-redis
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ecommerce-app
      component: cache
  template:
    metadata:
      labels:
        app: ecommerce-app
        component: cache
    spec:
      containers:
        - name: redis
          image: redis:7-alpine
          ports:
            - containerPort: 6379
              name: redis
          env:
            - name: REDIS_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: ecommerce-secrets
                  key: redis-password
          command: ["redis-server", "--requirepass", "$(REDIS_PASSWORD)"]
          volumeMounts:
            - name: redis-data
              mountPath: /data
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
          livenessProbe:
            exec:
              command:
                - redis-cli
                - -a
                - "$(REDIS_PASSWORD)"
                - ping
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - redis-cli
                - -a
                - "$(REDIS_PASSWORD)"
                - ping
            initialDelaySeconds: 5
            periodSeconds: 5
      volumes:
        - name: redis-data
          persistentVolumeClaim:
            claimName: redis-pvc
```

#### **Step 10: Create Secrets**
```yaml
# ecommerce-app/k8s/base/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ecommerce-secrets
  namespace: ecommerce
  labels:
    app: ecommerce-app
type: Opaque
data:
  jwt-secret: eW91ci1qd3Qtc2VjcmV0LWhlcmU=  # base64 encoded
  mongodb-username: ZWNvbW1lcmNl  # base64 encoded "ecommerce"
  mongodb-password: ZWNvbW1lcmNlMTIz  # base64 encoded "ecommerce123"
  redis-password: cmVkaXMxMjM=  # base64 encoded "redis123"
```

#### **Step 11: Create Persistent Volume Claims**
```yaml
# ecommerce-app/k8s/base/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-pvc
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: database
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: cache
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

#### **Step 12: Create Ingress**
```yaml
# ecommerce-app/k8s/base/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: ecommerce
  labels:
    app: ecommerce-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: ecommerce.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ecommerce-frontend
                port:
                  number: 3000
  tls:
    - hosts:
        - ecommerce.local
      secretName: ecommerce-tls
```

#### **Step 13: Deploy Raw YAML**
```bash
# Navigate to base directory
cd ecommerce-app/k8s/base

# Apply all manifests
kubectl apply -f .

# Check deployment
kubectl get all -n ecommerce
kubectl get pvc -n ecommerce
kubectl get secrets -n ecommerce

# Check pod status
kubectl get pods -n ecommerce -w

# Check logs if needed
kubectl logs -f deployment/ecommerce-backend -n ecommerce
kubectl logs -f deployment/ecommerce-frontend -n ecommerce
```

---

## 🔧 **Method 3: Kustomize Deployment Guide**

### **3.1 Understanding Kustomize**

**Kustomize is template-free configuration management:**
- **Base**: Common configuration shared across environments
- **Overlay**: Environment-specific customizations
- **Patches**: Strategic merges instead of templates
- **GitOps Ready**: Perfect for automated deployments

### **3.2 E-commerce App Kustomize Deployment**

#### **Step 1: Create Base Configuration**
```yaml
# ecommerce-app/k8s/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: ecommerce-base

resources:
  - namespace.yaml
  - configmap.yaml
  - secrets.yaml
  - pvc.yaml
  - backend-deployment.yaml
  - backend-service.yaml
  - frontend-deployment.yaml
  - frontend-service.yaml
  - mongodb-deployment.yaml
  - mongodb-service.yaml
  - redis-deployment.yaml
  - redis-service.yaml
  - ingress.yaml

commonLabels:
  app: ecommerce-app
  managed-by: kustomize

images:
  - name: ecommerce/backend
    newTag: latest
  - name: ecommerce/frontend
    newTag: latest
  - name: mongo
    newTag: "6.0"
  - name: redis
    newTag: "7-alpine"
```

#### **Step 2: Create Development Overlay**
```yaml
# ecommerce-app/k8s/overlays/development/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: ecommerce-development

bases:
  - ../../base

patchesStrategicMerge:
  - namespace.yaml
  - configmap.yaml
  - backend-deployment.yaml
  - frontend-deployment.yaml

commonLabels:
  environment: development

images:
  - name: ecommerce/backend
    newTag: dev-latest
  - name: ecommerce/frontend
    newTag: dev-latest

replicas:
  - name: ecommerce-backend
    count: 1
  - name: ecommerce-frontend
    count: 1
```

#### **Step 3: Development Namespace Patch**
```yaml
# ecommerce-app/k8s/overlays/development/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-dev
  labels:
    environment: development
```

#### **Step 4: Development ConfigMap Patch**
```yaml
# ecommerce-app/k8s/overlays/development/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-config
  namespace: ecommerce-dev
data:
  NODE_ENV: "development"
  REACT_APP_API_URL: "http://ecommerce-backend:5000/api"
  MONGODB_URI: "mongodb://ecommerce-mongodb:27017/ecommerce"
  REDIS_URL: "redis://ecommerce-redis:6379"
```

#### **Step 5: Development Backend Patch**
```yaml
# ecommerce-app/k8s/overlays/development/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: backend
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
```

#### **Step 6: Create Production Overlay**
```yaml
# ecommerce-app/k8s/overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: ecommerce-production

bases:
  - ../../base

patchesStrategicMerge:
  - namespace.yaml
  - configmap.yaml
  - backend-deployment.yaml
  - frontend-deployment.yaml
  - ingress.yaml

commonLabels:
  environment: production

images:
  - name: ecommerce/backend
    newTag: v1.0.0
  - name: ecommerce/frontend
    newTag: v1.0.0

replicas:
  - name: ecommerce-backend
    count: 3
  - name: ecommerce-frontend
    count: 3

configMapGenerator:
  - name: production-config
    literals:
      - PRODUCTION=true
      - LOG_LEVEL=info
```

#### **Step 7: Production Namespace Patch**
```yaml
# ecommerce-app/k8s/overlays/production/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-prod
  labels:
    environment: production
```

#### **Step 8: Production ConfigMap Patch**
```yaml
# ecommerce-app/k8s/overlays/production/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-config
  namespace: ecommerce-prod
data:
  NODE_ENV: "production"
  REACT_APP_API_URL: "https://api.ecommerce.com/api"
  MONGODB_URI: "mongodb://ecommerce-mongodb:27017/ecommerce"
  REDIS_URL: "redis://ecommerce-redis:6379"
```

#### **Step 9: Production Backend Patch**
```yaml
# ecommerce-app/k8s/overlays/production/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: backend
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          env:
            - name: LOG_LEVEL
              value: "info"
```

#### **Step 10: Production Ingress Patch**
```yaml
# ecommerce-app/k8s/overlays/production/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  rules:
    - host: ecommerce.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ecommerce-frontend
                port:
                  number: 3000
  tls:
    - hosts:
        - ecommerce.com
      secretName: ecommerce-tls
```

#### **Step 11: Deploy with Kustomize**
```bash
# Deploy to development
kubectl apply -k ecommerce-app/k8s/overlays/development/

# Deploy to production
kubectl apply -k ecommerce-app/k8s/overlays/production/

# Check deployments
kubectl get all -n ecommerce-dev
kubectl get all -n ecommerce-prod

# View generated manifests (dry run)
kubectl kustomize ecommerce-app/k8s/overlays/development/
kubectl kustomize ecommerce-app/k8s/overlays/production/
```

---

## 🚀 **Advanced Kubernetes Features**

### **1. Horizontal Pod Autoscaler (HPA)**

#### **Create HPA for Backend**
```yaml
# ecommerce-app/k8s/advanced/hpa-backend.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ecommerce-backend-hpa
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: backend
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 100
          periodSeconds: 60
          max: 4
```

#### **Create HPA for Frontend**
```yaml
# ecommerce-app/k8s/advanced/hpa-frontend.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ecommerce-frontend-hpa
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: frontend
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-frontend
  minReplicas: 2
  maxReplicas: 8
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 25
          periodSeconds: 60
```

### **2. Network Policies**

#### **Backend Network Policy**
```yaml
# ecommerce-app/k8s/advanced/network-policy-backend.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ecommerce-backend-network-policy
  namespace: ecommerce
  labels:
    app: ecommerce-app
spec:
  podSelector:
    matchLabels:
      app: ecommerce-app
      component: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: ecommerce-app
              component: frontend
        - podSelector:
            matchLabels:
              app: ecommerce-app
              component: ingress
      ports:
        - protocol: TCP
          port: 5000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: ecommerce-app
              component: database
        - podSelector:
            matchLabels:
              app: ecommerce-app
              component: cache
      ports:
        - protocol: TCP
          port: 27017  # MongoDB
        - protocol: TCP
          port: 6379   # Redis
    - to: []  # Allow external API calls
      ports:
        - protocol: TCP
          port: 443   # HTTPS
        - protocol: TCP
          port: 80    # HTTP
```

#### **Database Network Policy**
```yaml
# ecommerce-app/k8s/advanced/network-policy-database.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ecommerce-database-network-policy
  namespace: ecommerce
  labels:
    app: ecommerce-app
spec:
  podSelector:
    matchLabels:
      app: ecommerce-app
      component: database
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: ecommerce-app
              component: backend
      ports:
        - protocol: TCP
          port: 27017
```

### **3. Pod Disruption Budget**

#### **Backend PDB**
```yaml
# ecommerce-app/k8s/advanced/pdb-backend.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ecommerce-backend-pdb
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: backend
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: ecommerce-app
      component: backend
```

#### **Database PDB**
```yaml
# ecommerce-app/k8s/advanced/pdb-database.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ecommerce-database-pdb
  namespace: ecommerce
  labels:
    app: ecommerce-app
    component: database
spec:
  maxUnavailable: 0
  selector:
    matchLabels:
      app: ecommerce-app
      component: database
```

---

## 🎯 **Complete Deployment Commands**

### **Helm Commands**
```bash
# Install all applications with Helm
helm install ecommerce ./ecommerce-app/k8s/helm/ecommerce -n ecommerce --create-namespace
helm install educational ./educational-platform/k8s/helm/educational -n educational --create-namespace
helm install weather ./weather-app/k8s/helm/weather -n weather --create-namespace
helm install medical ./medical-care-system/k8s/helm/medical -n medical --create-namespace
helm install task ./task-management-app/k8s/helm/task -n task --create-namespace
helm install social ./social-media-platform/k8s/helm/social -n social --create-namespace

# Check all deployments
helm list --all-namespaces

# Upgrade specific application
helm upgrade ecommerce ./ecommerce-app/k8s/helm/ecommerce -n ecommerce

# Rollback if needed
helm rollback ecommerce 1 -n ecommerce
```

### **Raw YAML Commands**
```bash
# Deploy all applications with raw YAML
kubectl apply -f ecommerce-app/k8s/base/
kubectl apply -f educational-platform/k8s/base/
kubectl apply -f weather-app/k8s/base/
kubectl apply -f medical-care-system/k8s/base/
kubectl apply -f task-management-app/k8s/base/
kubectl apply -f social-media-platform/k8s/base/

# Check all resources
kubectl get all --all-namespaces

# View logs
kubectl logs -f deployment/ecommerce-backend -n ecommerce
```

### **Kustomize Commands**
```bash
# Deploy all applications with Kustomize
kubectl apply -k ecommerce-app/k8s/overlays/production/
kubectl apply -k educational-platform/k8s/overlays/production/
kubectl apply -k weather-app/k8s/overlays/production/
kubectl apply -k medical-care-system/k8s/overlays/production/
kubectl apply -k task-management-app/k8s/overlays/production/
kubectl apply -k social-media-platform/k8s/overlays/production/

# Preview changes
kubectl kustomize ecommerce-app/k8s/overlays/production/

# Dry run deployment
kubectl apply -k ecommerce-app/k8s/overlays/production/ --dry-run=client
```

---

## 📊 **Monitoring & Troubleshooting**

### **Check Application Health**
```bash
# Check all pods
kubectl get pods --all-namespaces

# Check services
kubectl get services --all-namespaces

# Check ingress
kubectl get ingress --all-namespaces

# Check HPA
kubectl get hpa --all-namespaces

# Check network policies
kubectl get networkpolicies --all-namespaces
```

### **Debugging Commands**
```bash
# Check pod logs
kubectl logs -f deployment/ecommerce-backend -n ecommerce

# Describe pod for detailed info
kubectl describe pod ecommerce-backend-12345-abcde -n ecommerce

# Check events
kubectl get events -n ecommerce --sort-by=.metadata.creationTimestamp

# Port forward for local testing
kubectl port-forward svc/ecommerce-frontend 3000:3000 -n ecommerce

# Exec into pod for debugging
kubectl exec -it deployment/ecommerce-backend -n ecommerce -- /bin/bash
```

---

## 🎉 **Success Metrics**

**Your Kubernetes deployment is successful when:**
- ✅ All pods are in `Running` state
- ✅ All services have `ClusterIP` assigned
- ✅ Ingress shows proper host routing
- ✅ Applications are accessible via browser
- ✅ HPA is scaling pods based on metrics
- ✅ Network policies are restricting traffic
- ✅ PDB is protecting against disruptions

---

## 🚀 **Next Steps**

### **Ready for Production?**
- **[Advanced Monitoring](./monitoring-setup.md)** - Prometheus & Grafana
- **[Security Hardening](./security-guide.md)** - RBAC & Security Contexts
- **[CI/CD Integration](./cicd-guide.md)** - GitOps with ArgoCD

### **Want to Scale Further?**
- **[Multi-Cluster](./multi-cluster.md)** - Cross-cluster deployments
- **[Service Mesh](./service-mesh.md)** - Istio integration
- **[Advanced Networking](./networking-advanced.md)** - Ingress controllers & load balancing

---

**🎯 You've now mastered Kubernetes orchestration with Helm, Raw YAML, and Kustomize! Ready to deploy enterprise-grade applications at scale!**