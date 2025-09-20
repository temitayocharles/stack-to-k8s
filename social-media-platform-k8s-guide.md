# 🚀 **Social Media Platform - Kubernetes Orchestration**
## **Ruby on Rails + React Native Web + PostgreSQL**

> **🎯 Deploy Complete Social Network with AI Features**  
> **⏰ Time Needed**: 50-60 minutes  
> **👨‍💻 For**: Complete beginners to Kubernetes experts  
> **📚 Level**: Progressive learning from basic to advanced  

---

## 📋 **Social Media Platform Overview**

**Complete Social Network Platform:**
- ✅ **Backend**: Ruby on Rails with real-time features
- ✅ **Frontend**: React Native Web with mobile-first design
- ✅ **Database**: PostgreSQL with advanced schemas
- ✅ **Features**: Posts, comments, likes, real-time chat, live streaming
- ✅ **Advanced**: AI content moderation, recommendation engine, analytics

---

## 🏗️ **Choose Your Deployment Method**

### **🎯 Method 1: Helm (Recommended for Beginners)**
```bash
helm install social ./social-media-platform/k8s/helm/social \
  --namespace social \
  --create-namespace \
  --set postgresql.auth.postgresPassword='YourSecurePassword123!'
```

### **🎯 Method 2: Raw YAML**
```bash
kubectl apply -f social-media-platform/k8s/base/
```

### **🎯 Method 3: Kustomize**
```bash
kubectl apply -k social-media-platform/k8s/overlays/production/
```

---

## 📁 **Social Media Platform Directory Structure**

```
social-media-platform/
├── k8s/
│   ├── helm/                    # Helm charts
│   │   ├── social/
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── templates/
│   │   │   │   ├── backend-deployment.yaml
│   │   │   │   ├── backend-service.yaml
│   │   │   │   ├── frontend-deployment.yaml
│   │   │   │   ├── frontend-service.yaml
│   │   │   │   ├── postgresql-deployment.yaml
│   │   │   │   ├── postgresql-service.yaml
│   │   │   │   ├── redis-deployment.yaml
│   │   │   │   ├── redis-service.yaml
│   │   │   │   ├── ingress.yaml
│   │   │   │   └── _helpers.tpl
│   │   └── requirements.yaml
│   ├── base/                    # Raw YAML manifests
│   │   ├── namespace.yaml
│   │   ├── backend-deployment.yaml
│   │   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── postgresql-deployment.yaml
│   │   ├── postgresql-service.yaml
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

## 🎯 **Method 1: Helm Deployment**

### **1.1 Create Helm Chart Structure**
```bash
mkdir -p social-media-platform/k8s/helm/social/templates
```

### **1.2 Chart.yaml**
```yaml
apiVersion: v2
name: social
description: Social media platform with Ruby on Rails backend and React Native Web frontend
type: application
version: 1.0.0
appVersion: "1.0.0"
dependencies:
  - name: postgresql
    version: "12.x.x"
    repository: "https://charts.bitnami.com/bitnami"
  - name: redis
    version: "17.x.x"
    repository: "https://charts.bitnami.com/bitnami"
```

### **1.3 values.yaml**
```yaml
backend:
  image:
    repository: social/backend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 3
  port: 3000
  env:
    RAILS_ENV: production
    DATABASE_URL: "postgresql://social:YourSecurePassword123!@postgresql:5432/social"
    REDIS_URL: "redis://redis:6379"
    SECRET_KEY_BASE: "your-secret-key-base-here"
    JWT_SECRET: "your-jwt-secret-here"
    AWS_ACCESS_KEY_ID: "your-aws-access-key"
    AWS_SECRET_ACCESS_KEY: "your-aws-secret-key"
    S3_BUCKET: "your-s3-bucket"

frontend:
  image:
    repository: social/frontend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 80
  env:
    API_URL: "http://backend:3000/api"
    NODE_ENV: production
    REACT_APP_API_URL: "http://backend:3000/api"

postgresql:
  auth:
    postgresPassword: "YourSecurePassword123!"
    username: "social"
    password: "social123"
    database: "social"
  architecture: standalone
  persistence:
    enabled: true
    size: 50Gi

redis:
  auth:
    password: "redis123"
  architecture: standalone
  persistence:
    enabled: true
    size: 5Gi

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: social.local
      paths:
        - path: /
          pathType: Prefix
```

### **1.4 Backend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "social.fullname" . }}-backend
  labels:
    app.kubernetes.io/name: {{ include "social.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: backend
spec:
  replicas: {{ .Values.backend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "social.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "social.name" . }}
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
            - name: RAILS_ENV
              value: {{ .Values.backend.env.RAILS_ENV | quote }}
            - name: DATABASE_URL
              value: {{ .Values.backend.env.DATABASE_URL | quote }}
            - name: REDIS_URL
              value: {{ .Values.backend.env.REDIS_URL | quote }}
            - name: SECRET_KEY_BASE
              value: {{ .Values.backend.env.SECRET_KEY_BASE | quote }}
            - name: JWT_SECRET
              value: {{ .Values.backend.env.JWT_SECRET | quote }}
            - name: AWS_ACCESS_KEY_ID
              value: {{ .Values.backend.env.AWS_ACCESS_KEY_ID | quote }}
            - name: AWS_SECRET_ACCESS_KEY
              value: {{ .Values.backend.env.AWS_SECRET_ACCESS_KEY | quote }}
            - name: S3_BUCKET
              value: {{ .Values.backend.env.S3_BUCKET | quote }}
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          volumeMounts:
            - name: uploads
              mountPath: /app/public/uploads
            - name: logs
              mountPath: /app/log
      volumes:
        - name: uploads
          persistentVolumeClaim:
            claimName: {{ include "social.fullname" . }}-uploads
        - name: logs
          persistentVolumeClaim:
            claimName: {{ include "social.fullname" . }}-logs
```

### **1.5 Frontend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "social.fullname" . }}-frontend
  labels:
    app.kubernetes.io/name: {{ include "social.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "social.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: frontend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "social.name" . }}
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
            - name: REACT_APP_API_URL
              value: {{ .Values.frontend.env.REACT_APP_API_URL | quote }}
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
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
  name: {{ include "social.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ include "social.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
  {{- with .Values.ingress.annotations }}
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
                name: {{ include "social.fullname" $ }}-frontend
                port:
                  number: {{ $.Values.frontend.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

### **1.7 PVC Templates**
```yaml
# PVC for File Uploads
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "social.fullname" . }}-uploads
  labels:
    app.kubernetes.io/name: {{ include "social.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: uploads
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi

---
# PVC for Logs
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "social.fullname" . }}-logs
  labels:
    app.kubernetes.io/name: {{ include "social.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: logs
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### **1.8 _helpers.tpl**
```tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "social.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "social.fullname" -}}
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

### **1.9 Deploy with Helm**
```bash
cd social-media-platform/k8s/helm/social

# Install dependencies
helm dependency update

# Deploy
helm install social . \
  --namespace social \
  --create-namespace \
  --set postgresql.auth.postgresPassword='YourSecurePassword123!'

# Check deployment
helm list -n social
kubectl get pods -n social
```

---

## 📄 **Method 2: Raw YAML Deployment**

### **2.1 Create Namespace**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: social
  labels:
    name: social
    app: social-media-platform
```

### **2.2 Create ConfigMap**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: social-config
  namespace: social
data:
  RAILS_ENV: "production"
  API_URL: "http://social-backend:3000/api"
  DATABASE_URL: "postgresql://social:YourSecurePassword123!@social-postgresql:5432/social"
  REDIS_URL: "redis://social-redis:6379"
  NODE_ENV: "production"
  REACT_APP_API_URL: "http://social-backend:3000/api"
```

### **2.3 Backend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: social-backend
  namespace: social
  labels:
    app: social-media-platform
    component: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: social-media-platform
      component: backend
  template:
    metadata:
      labels:
        app: social-media-platform
        component: backend
    spec:
      containers:
        - name: backend
          image: social/backend:latest
          ports:
            - containerPort: 3000
              name: http
          env:
            - name: RAILS_ENV
              valueFrom:
                configMapKeyRef:
                  name: social-config
                  key: RAILS_ENV
            - name: DATABASE_URL
              valueFrom:
                configMapKeyRef:
                  name: social-config
                  key: DATABASE_URL
            - name: REDIS_URL
              valueFrom:
                configMapKeyRef:
                  name: social-config
                  key: REDIS_URL
            - name: SECRET_KEY_BASE
              valueFrom:
                secretKeyRef:
                  name: social-secrets
                  key: secret-key-base
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: social-secrets
                  key: jwt-secret
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: social-secrets
                  key: aws-access-key
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: social-secrets
                  key: aws-secret-key
            - name: S3_BUCKET
              valueFrom:
                secretKeyRef:
                  name: social-secrets
                  key: s3-bucket
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          volumeMounts:
            - name: uploads
              mountPath: /app/public/uploads
            - name: logs
              mountPath: /app/log
      volumes:
        - name: uploads
          persistentVolumeClaim:
            claimName: social-uploads-pvc
        - name: logs
          persistentVolumeClaim:
            claimName: social-logs-pvc
```

### **2.4 Frontend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: social-frontend
  namespace: social
  labels:
    app: social-media-platform
    component: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: social-media-platform
      component: frontend
  template:
    metadata:
      labels:
        app: social-media-platform
        component: frontend
    spec:
      containers:
        - name: frontend
          image: social/frontend:latest
          ports:
            - containerPort: 80
              name: http
          env:
            - name: API_URL
              valueFrom:
                configMapKeyRef:
                  name: social-config
                  key: API_URL
            - name: NODE_ENV
              valueFrom:
                configMapKeyRef:
                  name: social-config
                  key: NODE_ENV
            - name: REACT_APP_API_URL
              valueFrom:
                configMapKeyRef:
                  name: social-config
                  key: REACT_APP_API_URL
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
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

### **2.5 PostgreSQL Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: social-postgresql
  namespace: social
  labels:
    app: social-media-platform
    component: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: social-media-platform
      component: database
  template:
    metadata:
      labels:
        app: social-media-platform
        component: database
    spec:
      containers:
        - name: postgresql
          image: postgres:14-alpine
          ports:
            - containerPort: 5432
              name: postgresql
          env:
            - name: POSTGRES_DB
              valueFrom:
                secretKeyRef:
                  name: social-secrets
                  key: db-name
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: social-secrets
                  key: db-username
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: social-secrets
                  key: db-password
          volumeMounts:
            - name: postgresql-data
              mountPath: /var/lib/postgresql/data
          resources:
            requests:
              memory: "1Gi"
              cpu: "500m"
            limits:
              memory: "2Gi"
              cpu: "1000m"
          livenessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - $(POSTGRES_USER)
                - -d
                - $(POSTGRES_DB)
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - $(POSTGRES_USER)
                - -d
                - $(POSTGRES_DB)
            initialDelaySeconds: 5
            periodSeconds: 5
      volumes:
        - name: postgresql-data
          persistentVolumeClaim:
            claimName: postgresql-data-pvc
```

### **2.6 Redis Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: social-redis
  namespace: social
  labels:
    app: social-media-platform
    component: cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: social-media-platform
      component: cache
  template:
    metadata:
      labels:
        app: social-media-platform
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
                  name: social-secrets
                  key: redis-password
          command: ["redis-server", "--requirepass", "$(REDIS_PASSWORD)"]
          volumeMounts:
            - name: redis-data
              mountPath: /data
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
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
  name: social-backend
  namespace: social
spec:
  selector:
    app: social-media-platform
    component: backend
  ports:
    - name: http
      port: 3000
      targetPort: 3000
  type: ClusterIP

---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: social-frontend
  namespace: social
spec:
  selector:
    app: social-media-platform
    component: frontend
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP

---
# PostgreSQL Service
apiVersion: v1
kind: Service
metadata:
  name: social-postgresql
  namespace: social
spec:
  selector:
    app: social-media-platform
    component: database
  ports:
    - name: postgresql
      port: 5432
      targetPort: 5432
  type: ClusterIP

---
# Redis Service
apiVersion: v1
kind: Service
metadata:
  name: social-redis
  namespace: social
spec:
  selector:
    app: social-media-platform
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
  name: social-ingress
  namespace: social
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: social.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: social-frontend
                port:
                  number: 80
  tls:
    - hosts:
        - social.local
      secretName: social-tls
```

### **2.8 Secrets and PVC**
```yaml
# Secrets
apiVersion: v1
kind: Secret
metadata:
  name: social-secrets
  namespace: social
type: Opaque
data:
  secret-key-base: eW91ci1zZWNyZXQtkey1iYXNlLWhlcmU=  # base64 encoded
  jwt-secret: eW91ci1qd3Qtc2VjcmV0LWhlcmU=  # base64 encoded
  db-name: c29jaWFs  # base64 encoded "social"
  db-username: c29jaWFs  # base64 encoded "social"
  db-password: WW91clNlY3VyZVBhc3N3b3JkMTIzIQ==  # base64 encoded "YourSecurePassword123!"
  redis-password: cmVkaXMxMjM=  # base64 encoded "redis123"
  aws-access-key: eW91ci1hd3MtYWNjZXNzLWtleQ==  # base64 encoded
  aws-secret-key: eW91ci1hd3Mtc2VjcmV0LWtleQ==  # base64 encoded
  s3-bucket: eW91ci1zMy1idWNrZXQ=  # base64 encoded

---
# PVC for File Uploads
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: social-uploads-pvc
  namespace: social
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi

---
# PVC for Logs
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: social-logs-pvc
  namespace: social
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi

---
# PVC for PostgreSQL Data
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-data-pvc
  namespace: social
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi

---
# PVC for Redis Data
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-data-pvc
  namespace: social
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### **2.9 Deploy Raw YAML**
```bash
cd social-media-platform/k8s/base

# Apply all manifests
kubectl apply -f .

# Check deployment
kubectl get all -n social
kubectl get pvc -n social
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
  - postgresql-deployment.yaml
  - postgresql-service.yaml
  - redis-deployment.yaml
  - redis-service.yaml
  - ingress.yaml

commonLabels:
  app: social-media-platform
  managed-by: kustomize

images:
  - name: social/backend
    newTag: latest
  - name: social/frontend
    newTag: latest
  - name: postgres
    newTag: "14-alpine"
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
  - name: social/backend
    newTag: dev-latest
  - name: social/frontend
    newTag: dev-latest

replicas:
  - name: social-backend
    count: 1
  - name: social-frontend
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
  - name: social/backend
    newTag: v1.0.0
  - name: social/frontend
    newTag: v1.0.0

replicas:
  - name: social-backend
    count: 5
  - name: social-frontend
    count: 3
```

### **3.4 Deploy with Kustomize**
```bash
# Development
kubectl apply -k social-media-platform/k8s/overlays/development/

# Production
kubectl apply -k social-media-platform/k8s/overlays/production/
```

---

## 🚀 **Advanced Features for Social Media Platform**

### **1. Horizontal Pod Autoscaler**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: social-backend-hpa
  namespace: social
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: social-backend
  minReplicas: 3
  maxReplicas: 15
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
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 100
          periodSeconds: 60
          max: 5
```

### **2. Network Policies**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: social-backend-network-policy
  namespace: social
spec:
  podSelector:
    matchLabels:
      app: social-media-platform
      component: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: social-media-platform
              component: frontend
      ports:
        - protocol: TCP
          port: 3000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: social-media-platform
              component: database
        - podSelector:
            matchLabels:
              app: social-media-platform
              component: cache
      ports:
        - protocol: TCP
          port: 5432  # PostgreSQL
        - protocol: TCP
          port: 6379  # Redis
    - to: []  # Allow external S3 access
      ports:
        - protocol: TCP
          port: 443   # HTTPS for S3
```

### **3. Pod Disruption Budget**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: social-backend-pdb
  namespace: social
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: social-media-platform
      component: backend
```

---

## 🎯 **Quick Deployment Commands**

### **Helm**
```bash
helm install social ./social-media-platform/k8s/helm/social \
  --namespace social \
  --create-namespace
```

### **Raw YAML**
```bash
kubectl apply -f social-media-platform/k8s/base/
```

### **Kustomize**
```bash
kubectl apply -k social-media-platform/k8s/overlays/production/
```

---

## 📊 **Verification Commands**

```bash
# Check all resources
kubectl get all -n social

# Check application health
kubectl logs -f deployment/social-backend -n social

# Port forward for testing
kubectl port-forward svc/social-frontend 8080:80 -n social

# Access application
curl http://localhost:8080

# Test API health
curl http://localhost:8080/api/health

# Check database connectivity
curl http://localhost:8080/api/db-status
```

---

## ☁️ **AWS S3 Configuration**

**Before deploying, configure AWS S3 for file storage:**

### **Create S3 Bucket**
1. Go to [AWS S3 Console](https://s3.console.aws.amazon.com/)
2. Click "Create bucket"
3. Enter bucket name (must be globally unique)
4. Choose region closest to your users
5. Enable versioning and encryption

### **Create IAM User**
1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Create new user with programmatic access
3. Attach S3 full access policy
4. Save Access Key ID and Secret Access Key

### **Configure CORS for Web Access**
```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
        "AllowedOrigins": ["https://yourdomain.com"],
        "ExposeHeaders": ["ETag"],
        "MaxAgeSeconds": 3000
    }
]
```

---

## 🤖 **AI Features Configuration**

**The Social Media Platform includes AI features that require additional setup:**

### **Content Moderation AI**
- Uses machine learning models for content analysis
- Requires pre-trained models stored in S3
- Configurable sensitivity levels

### **Recommendation Engine**
- Analyzes user behavior patterns
- Requires Redis for caching recommendations
- PostgreSQL for storing user interaction data

### **Analytics Dashboard**
- Real-time metrics and insights
- Uses Redis for caching analytics data
- PostgreSQL for long-term analytics storage

---

**🎯 Social Media Platform with AI features is now deployed with full Kubernetes orchestration!**