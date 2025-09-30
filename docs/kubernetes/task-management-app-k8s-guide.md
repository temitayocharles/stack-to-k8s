# 🚀 **Task Management App - Kubernetes Orchestration**
## **Go + Svelte + CouchDB**

> **🎯 Deploy Complete Project Management Platform**  
> **⏰ Time Needed**: 45-55 minutes  
> **👨‍💻 For**: Complete beginners to Kubernetes experts  
> **📚 Level**: Progressive learning from basic to advanced  

---

## 📋 **Task Management App Overview**

**Complete Project Management System:**
- ✅ **Backend**: Go with REST APIs and real-time updates
- ✅ **Frontend**: Svelte with modern reactive UI
- ✅ **Database**: CouchDB with document-based storage
- ✅ **Features**: Tasks, projects, teams, time tracking, notifications
- ✅ **Advanced**: Real-time collaboration, file attachments, reporting

---

## 🏗️ **Choose Your Deployment Method**

### **🎯 Method 1: Helm (Recommended for Beginners)**
```bash
helm install task ./task-management-app/k8s/helm/task \
  --namespace task \
  --create-namespace \
  --set couchdb.adminPassword='YourSecurePassword123!'
```

### **🎯 Method 2: Raw YAML**
```bash
kubectl apply -f task-management-app/k8s/base/
```

### **🎯 Method 3: Kustomize**
```bash
kubectl apply -k task-management-app/k8s/overlays/production/
```

---

## 📁 **Task Management App Directory Structure**

```
task-management-app/
├── k8s/
│   ├── helm/                    # Helm charts
│   │   ├── task/
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── templates/
│   │   │   │   ├── backend-deployment.yaml
│   │   │   │   ├── backend-service.yaml
│   │   │   │   ├── frontend-deployment.yaml
│   │   │   │   ├── frontend-service.yaml
│   │   │   │   ├── couchdb-deployment.yaml
│   │   │   │   ├── couchdb-service.yaml
│   │   │   │   ├── ingress.yaml
│   │   │   │   └── _helpers.tpl
│   │   └── requirements.yaml
│   ├── base/                    # Raw YAML manifests
│   │   ├── namespace.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── couchdb-deployment.yaml
│   │   ├── couchdb-service.yaml
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

## 🎯 **Method 1: Helm Deployment**

### **1.1 Create Helm Chart Structure**
```bash
mkdir -p task-management-app/k8s/helm/task/templates
```

### **1.2 Chart.yaml**
```yaml
apiVersion: v2
name: task
description: Task management application with Go backend and Svelte frontend
type: application
version: 1.0.0
appVersion: "1.0.0"
dependencies:
  - name: couchdb
    version: "4.x.x"
    repository: "https://charts.bitnami.com/bitnami"
```

### **1.3 values.yaml**
```yaml
backend:
  image:
    repository: task/backend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 8080
  env:
    GO_ENV: production
    COUCHDB_URL: "http://couchdb:5984"
    JWT_SECRET: "your-jwt-secret-here"
    REDIS_URL: "redis://redis:6379"
    SMTP_HOST: "smtp.gmail.com"
    SMTP_PORT: "587"

frontend:
  image:
    repository: task/frontend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 80
  env:
    API_URL: "http://backend:8080/api"
    NODE_ENV: production

couchdb:
  adminPassword: "YourSecurePassword123!"
  persistence:
    enabled: true
    size: 10Gi

redis:
  enabled: true
  auth:
    password: "redis123"
  architecture: standalone
  persistence:
    enabled: true
    size: 1Gi

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: task.local
      paths:
        - path: /
          pathType: Prefix
```

### **1.4 Backend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "task.fullname" . }}-backend
  labels:
    app.kubernetes.io/name: {{ include "task.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: backend
spec:
  replicas: {{ .Values.backend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "task.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "task.name" . }}
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
            - name: GO_ENV
              value: {{ .Values.backend.env.GO_ENV | quote }}
            - name: COUCHDB_URL
              value: {{ .Values.backend.env.COUCHDB_URL | quote }}
            - name: JWT_SECRET
              value: {{ .Values.backend.env.JWT_SECRET | quote }}
            - name: REDIS_URL
              value: {{ .Values.backend.env.REDIS_URL | quote }}
            - name: SMTP_HOST
              value: {{ .Values.backend.env.SMTP_HOST | quote }}
            - name: SMTP_PORT
              value: {{ .Values.backend.env.SMTP_PORT | quote }}
            - name: SMTP_USER
              valueFrom:
                secretKeyRef:
                  name: {{ include "task.fullname" . }}-secrets
                  key: smtp-user
            - name: SMTP_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "task.fullname" . }}-secrets
                  key: smtp-password
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
          volumeMounts:
            - name: uploads
              mountPath: /app/uploads
      volumes:
        - name: uploads
          persistentVolumeClaim:
            claimName: {{ include "task.fullname" . }}-uploads
```

### **1.5 Frontend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "task.fullname" . }}-frontend
  labels:
    app.kubernetes.io/name: {{ include "task.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "task.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: frontend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "task.name" . }}
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
            - name: API_URL
              value: {{ .Values.frontend.env.API_URL | quote }}
            - name: NODE_ENV
              value: {{ .Values.frontend.env.NODE_ENV | quote }}
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

### **1.6 Ingress Template**
```yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "task.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ include "task.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
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
                name: {{ include "task.fullname" $ }}-frontend
                port:
                  number: {{ $.Values.frontend.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

### **1.7 PVC for File Uploads**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "task.fullname" . }}-uploads
  labels:
    app.kubernetes.io/name: {{ include "task.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: uploads
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```

### **1.8 Secrets Template**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "task.fullname" . }}-secrets
  labels:
    app.kubernetes.io/name: {{ include "task.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
type: Opaque
data:
  smtp-user: eW91ckBlbWFpbC5jb20=  # base64 encoded
  smtp-password: eW91ci1lbWFpbC1wYXNzd29yZA==  # base64 encoded
```

### **1.9 _helpers.tpl**
```tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "task.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "task.fullname" -}}
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
```

### **1.10 Deploy with Helm**
```bash
cd task-management-app/k8s/helm/task

# Install dependencies
helm dependency update

# Deploy
helm install task . \
  --namespace task \
  --create-namespace \
  --set couchdb.adminPassword='YourSecurePassword123!'

# Check deployment
helm list -n task
kubectl get pods -n task
```

---

## 📄 **Method 2: Raw YAML Deployment**

### **2.1 Create Namespace**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: task
  labels:
    name: task
    app: task-management-app
```

### **2.2 Create ConfigMap**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: task-config
  namespace: task
data:
  GO_ENV: "production"
  API_URL: "http://task-backend:8080/api"
  COUCHDB_URL: "http://task-couchdb:5984"
  REDIS_URL: "redis://task-redis:6379"
  NODE_ENV: "production"
```

### **2.3 Backend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-backend
  namespace: task
  labels:
    app: task-management-app
    component: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: task-management-app
      component: backend
  template:
    metadata:
      labels:
        app: task-management-app
        component: backend
    spec:
      containers:
        - name: backend
          image: task/backend:latest
          ports:
            - containerPort: 8080
              name: http
          env:
            - name: GO_ENV
              valueFrom:
                configMapKeyRef:
                  name: task-config
                  key: GO_ENV
            - name: COUCHDB_URL
              valueFrom:
                configMapKeyRef:
                  name: task-config
                  key: COUCHDB_URL
            - name: REDIS_URL
              valueFrom:
                configMapKeyRef:
                  name: task-config
                  key: REDIS_URL
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: task-secrets
                  key: jwt-secret
            - name: SMTP_USER
              valueFrom:
                secretKeyRef:
                  name: task-secrets
                  key: smtp-user
            - name: SMTP_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: task-secrets
                  key: smtp-password
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
          volumeMounts:
            - name: uploads
              mountPath: /app/uploads
      volumes:
        - name: uploads
          persistentVolumeClaim:
            claimName: task-uploads-pvc
```

### **2.4 Frontend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-frontend
  namespace: task
  labels:
    app: task-management-app
    component: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: task-management-app
      component: frontend
  template:
    metadata:
      labels:
        app: task-management-app
        component: frontend
    spec:
      containers:
        - name: frontend
          image: task/frontend:latest
          ports:
            - containerPort: 80
              name: http
          env:
            - name: API_URL
              valueFrom:
                configMapKeyRef:
                  name: task-config
                  key: API_URL
            - name: NODE_ENV
              valueFrom:
                configMapKeyRef:
                  name: task-config
                  key: NODE_ENV
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

### **2.5 CouchDB Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-couchdb
  namespace: task
  labels:
    app: task-management-app
    component: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: task-management-app
      component: database
  template:
    metadata:
      labels:
        app: task-management-app
        component: database
    spec:
      containers:
        - name: couchdb
          image: couchdb:3.3
          ports:
            - containerPort: 5984
              name: couchdb
          env:
            - name: COUCHDB_USER
              valueFrom:
                secretKeyRef:
                  name: task-secrets
                  key: couchdb-user
            - name: COUCHDB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: task-secrets
                  key: couchdb-password
          volumeMounts:
            - name: couchdb-data
              mountPath: /opt/couchdb/data
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /
              port: couchdb
              httpHeaders:
                - name: Authorization
                  value: "Basic YWRtaW46cGFzc3dvcmQ="  # admin:password base64
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /
              port: couchdb
              httpHeaders:
                - name: Authorization
                  value: "Basic YWRtaW46cGFzc3dvcmQ="  # admin:password base64
            initialDelaySeconds: 30
            periodSeconds: 10
      volumes:
        - name: couchdb-data
          persistentVolumeClaim:
            claimName: couchdb-data-pvc
```

### **2.6 Redis Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-redis
  namespace: task
  labels:
    app: task-management-app
    component: cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: task-management-app
      component: cache
  template:
    metadata:
      labels:
        app: task-management-app
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
                  name: task-secrets
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
            claimName: redis-data-pvc
```

### **2.7 Services and Ingress**
```yaml
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: task-backend
  namespace: task
spec:
  selector:
    app: task-management-app
    component: backend
  ports:
    - name: http
      port: 8080
      targetPort: 8080
  type: ClusterIP

---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: task-frontend
  namespace: task
spec:
  selector:
    app: task-management-app
    component: frontend
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP

---
# CouchDB Service
apiVersion: v1
kind: Service
metadata:
  name: task-couchdb
  namespace: task
spec:
  selector:
    app: task-management-app
    component: database
  ports:
    - name: couchdb
      port: 5984
      targetPort: 5984
  type: ClusterIP

---
# Redis Service
apiVersion: v1
kind: Service
metadata:
  name: task-redis
  namespace: task
spec:
  selector:
    app: task-management-app
    component: cache
  ports:
    - name: redis
      port: 6379
      targetPort: 6379
  type: ClusterIP

---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: task-ingress
  namespace: task
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: task.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: task-frontend
                port:
                  number: 80
  tls:
    - hosts:
        - task.local
      secretName: task-tls
```

### **2.8 Secrets and PVC**
```yaml
# Secrets
apiVersion: v1
kind: Secret
metadata:
  name: task-secrets
  namespace: task
type: Opaque
data:
  jwt-secret: eW91ci1qd3Qtc2VjcmV0LWhlcmU=  # base64 encoded
  couchdb-user: YWRtaW4=  # base64 encoded "admin"
  couchdb-password: cGFzc3dvcmQ=  # base64 encoded "password"
  redis-password: cmVkaXMxMjM=  # base64 encoded "redis123"
  smtp-user: eW91ckBlbWFpbC5jb20=  # base64 encoded
  smtp-password: eW91ci1lbWFpbC1wYXNzd29yZA==  # base64 encoded

---
# PVC for File Uploads
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-uploads-pvc
  namespace: task
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi

---
# PVC for CouchDB Data
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: couchdb-data-pvc
  namespace: task
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi

---
# PVC for Redis Data
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-data-pvc
  namespace: task
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### **2.9 Deploy Raw YAML**
```bash
cd task-management-app/k8s/base

# Apply all manifests
kubectl apply -f .

# Check deployment
kubectl get all -n task
kubectl get pvc -n task
```

---

## 🔧 **Method 3: Kustomize Deployment**

### **3.1 Base Configuration**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - configmap.yaml
  - secrets.yaml
  - pvc.yaml
  - backend-deployment.yaml
  - backend-service.yaml
  - frontend-deployment.yaml
  - frontend-service.yaml
  - couchdb-deployment.yaml
  - couchdb-service.yaml
  - redis-deployment.yaml
  - redis-service.yaml
  - ingress.yaml

commonLabels:
  app: task-management-app
  managed-by: kustomize

images:
  - name: task/backend
    newTag: latest
  - name: task/frontend
    newTag: latest
  - name: couchdb
    newTag: "3.3"
  - name: redis
    newTag: "7-alpine"
```

### **3.2 Development Overlay**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

patchesStrategicMerge:
  - namespace.yaml
  - configmap.yaml

commonLabels:
  environment: development

images:
  - name: task/backend
    newTag: dev-latest
  - name: task/frontend
    newTag: dev-latest

replicas:
  - name: task-backend
    count: 1
  - name: task-frontend
    count: 1
```

### **3.3 Production Overlay**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

patchesStrategicMerge:
  - namespace.yaml
  - configmap.yaml
  - ingress.yaml

commonLabels:
  environment: production

images:
  - name: task/backend
    newTag: v1.0.0
  - name: task/frontend
    newTag: v1.0.0

replicas:
  - name: task-backend
    count: 3
  - name: task-frontend
    count: 3
```

### **3.4 Deploy with Kustomize**
```bash
# Development
kubectl apply -k task-management-app/k8s/overlays/development/

# Production
kubectl apply -k task-management-app/k8s/overlays/production/
```

---

## 🚀 **Advanced Features for Task Management App**

### **1. Horizontal Pod Autoscaler**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: task-backend-hpa
  namespace: task
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: task-backend
  minReplicas: 2
  maxReplicas: 8
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 70
```

### **2. Network Policies**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: task-backend-network-policy
  namespace: task
spec:
  podSelector:
    matchLabels:
      app: task-management-app
      component: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: task-management-app
              component: frontend
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: task-management-app
              component: database
        - podSelector:
            matchLabels:
              app: task-management-app
              component: cache
      ports:
        - protocol: TCP
          port: 5984  # CouchDB
        - protocol: TCP
          port: 6379  # Redis
    - to: []  # Allow SMTP for notifications
      ports:
        - protocol: TCP
          port: 587   # SMTP
```

### **3. Pod Disruption Budget**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: task-backend-pdb
  namespace: task
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: task-management-app
      component: backend
```

---

## 🎯 **Quick Deployment Commands**

### **Helm**
```bash
helm install task ./task-management-app/k8s/helm/task \
  --namespace task \
  --create-namespace
```

### **Raw YAML**
```bash
kubectl apply -f task-management-app/k8s/base/
```

### **Kustomize**
```bash
kubectl apply -k task-management-app/k8s/overlays/production/
```

---

## 📊 **Verification Commands**

```bash
# Check all resources
kubectl get all -n task

# Check application health
kubectl logs -f deployment/task-backend -n task

# Port forward for testing
kubectl port-forward svc/task-frontend 8080:80 -n task

# Access application
curl http://localhost:8080

# Test API health
curl http://localhost:8080/api/health

# Check CouchDB
curl http://localhost:8080/api/db-status
```

---

## 📧 **Email Configuration**

**Before deploying, configure SMTP settings:**

### **Gmail SMTP Setup**
1. Go to [Google Account Settings](https://myaccount.google.com/)
2. Enable 2-Factor Authentication
3. Generate App Password
4. Use the App Password in your secrets

### **Other SMTP Providers**
- **SendGrid**: Get API key and use SMTP credentials
- **Mailgun**: Get SMTP credentials from dashboard
- **AWS SES**: Get SMTP credentials from SES console

---

**🎯 Task Management App with real-time collaboration is now deployed with full Kubernetes orchestration!**