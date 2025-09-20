# 🚀 **Educational Platform - Kubernetes Orchestration**
## **Java Spring Boot + Angular + PostgreSQL**

> **🎯 Deploy Complete Learning Management System**  
> **⏰ Time Needed**: 45-60 minutes  
> **👨‍💻 For**: Complete beginners to Kubernetes experts  
> **📚 Level**: Progressive learning from basic to advanced  

---

## 📋 **Educational Platform Overview**

**Complete Learning Management System:**
- ✅ **Backend**: Java Spring Boot with REST APIs
- ✅ **Frontend**: Angular with modern UI components
- ✅ **Database**: PostgreSQL with advanced schemas
- ✅ **Features**: Courses, Students, Instructors, Assessments
- ✅ **Advanced**: Video streaming, real-time chat, analytics

---

## 🏗️ **Choose Your Deployment Method**

### **🎯 Method 1: Helm (Recommended for Beginners)**
**Best For**: Quick deployment, production-ready setup
```bash
helm install educational ./educational-platform/k8s/helm/educational \
  --namespace educational \
  --create-namespace \
  --set postgresql.auth.postgresPassword='YourSecurePassword123!'
```

### **🎯 Method 2: Raw YAML**
**Best For**: Learning Kubernetes internals, custom configurations
```bash
kubectl apply -f educational-platform/k8s/base/
```

### **🎯 Method 3: Kustomize**
**Best For**: Multi-environment management, GitOps workflows
```bash
kubectl apply -k educational-platform/k8s/overlays/production/
```

---

## 📁 **Educational Platform Directory Structure**

```
educational-platform/
├── k8s/
│   ├── helm/                    # Helm charts
│   │   ├── educational/
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── templates/
│   │   │   │   ├── backend-deployment.yaml
│   │   │   │   ├── backend-service.yaml
│   │   │   │   ├── frontend-deployment.yaml
│   │   │   │   ├── frontend-service.yaml
│   │   │   │   ├── postgresql-deployment.yaml
│   │   │   │   ├── postgresql-service.yaml
│   │   │   │   ├── ingress.yaml
│   │   │   │   └── _helpers.tpl
│   │   └── requirements.yaml
│   ├── base/                    # Raw YAML manifests
│   │   ├── namespace.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── postgresql-deployment.yaml
│   │   ├── postgresql-service.yaml
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
mkdir -p educational-platform/k8s/helm/educational/templates
```

### **1.2 Chart.yaml**
```yaml
apiVersion: v2
name: educational
description: Educational platform with Java Spring Boot backend and Angular frontend
type: application
version: 1.0.0
appVersion: "1.0.0"
dependencies:
  - name: postgresql
    version: "12.x.x"
    repository: "https://charts.bitnami.com/bitnami"
```

### **1.3 values.yaml**
```yaml
backend:
  image:
    repository: educational/backend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 8080
  env:
    SPRING_PROFILES_ACTIVE: production
    SPRING_DATASOURCE_URL: jdbc:postgresql://postgresql:5432/educational
    SPRING_DATASOURCE_USERNAME: educational
    SPRING_DATASOURCE_PASSWORD: "YourSecurePassword123!"
    JWT_SECRET: "your-jwt-secret-here"

frontend:
  image:
    repository: educational/frontend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 80
  env:
    API_URL: "http://backend:8080/api"

postgresql:
  auth:
    postgresPassword: "YourSecurePassword123!"
    username: "educational"
    password: "educational123"
    database: "educational"
  architecture: standalone
  persistence:
    enabled: true
    size: 10Gi

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: educational.local
      paths:
        - path: /
          pathType: Prefix
```

### **1.4 Backend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "educational.fullname" . }}-backend
  labels:
    app.kubernetes.io/name: {{ include "educational.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: backend
spec:
  replicas: {{ .Values.backend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "educational.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "educational.name" . }}
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
            - name: SPRING_PROFILES_ACTIVE
              value: {{ .Values.backend.env.SPRING_PROFILES_ACTIVE | quote }}
            - name: SPRING_DATASOURCE_URL
              value: {{ .Values.backend.env.SPRING_DATASOURCE_URL | quote }}
            - name: SPRING_DATASOURCE_USERNAME
              value: {{ .Values.backend.env.SPRING_DATASOURCE_USERNAME | quote }}
            - name: SPRING_DATASOURCE_PASSWORD
              value: {{ .Values.backend.env.SPRING_DATASOURCE_PASSWORD | quote }}
            - name: JWT_SECRET
              value: {{ .Values.backend.env.JWT_SECRET | quote }}
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: http
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
```

### **1.5 Frontend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "educational.fullname" . }}-frontend
  labels:
    app.kubernetes.io/name: {{ include "educational.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "educational.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: frontend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "educational.name" . }}
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
  name: {{ include "educational.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ include "educational.name" . }}
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
                name: {{ include "educational.fullname" $ }}-frontend
                port:
                  number: {{ $.Values.frontend.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

### **1.7 _helpers.tpl**
```tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "educational.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "educational.fullname" -}}
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

### **1.8 Deploy with Helm**
```bash
cd educational-platform/k8s/helm/educational

# Install dependencies
helm dependency update

# Deploy
helm install educational . \
  --namespace educational \
  --create-namespace \
  --set postgresql.auth.postgresPassword='YourSecurePassword123!'

# Check deployment
helm list -n educational
kubectl get pods -n educational
```

---

## 📄 **Method 2: Raw YAML Deployment**

### **2.1 Create Namespace**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: educational
  labels:
    name: educational
    app: educational-platform
```

### **2.2 Create ConfigMap**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: educational-config
  namespace: educational
data:
  SPRING_PROFILES_ACTIVE: "production"
  API_URL: "http://educational-backend:8080/api"
  SPRING_DATASOURCE_URL: "jdbc:postgresql://educational-postgresql:5432/educational"
```

### **2.3 Backend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: educational-backend
  namespace: educational
  labels:
    app: educational-platform
    component: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: educational-platform
      component: backend
  template:
    metadata:
      labels:
        app: educational-platform
        component: backend
    spec:
      containers:
        - name: backend
          image: educational/backend:latest
          ports:
            - containerPort: 8080
              name: http
          env:
            - name: SPRING_PROFILES_ACTIVE
              valueFrom:
                configMapKeyRef:
                  name: educational-config
                  key: SPRING_PROFILES_ACTIVE
            - name: SPRING_DATASOURCE_URL
              valueFrom:
                configMapKeyRef:
                  name: educational-config
                  key: SPRING_DATASOURCE_URL
            - name: SPRING_DATASOURCE_USERNAME
              valueFrom:
                secretKeyRef:
                  name: educational-secrets
                  key: db-username
            - name: SPRING_DATASOURCE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: educational-secrets
                  key: db-password
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: educational-secrets
                  key: jwt-secret
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: http
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
```

### **2.4 Frontend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: educational-frontend
  namespace: educational
  labels:
    app: educational-platform
    component: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: educational-platform
      component: frontend
  template:
    metadata:
      labels:
        app: educational-platform
        component: frontend
    spec:
      containers:
        - name: frontend
          image: educational/frontend:latest
          ports:
            - containerPort: 80
              name: http
          env:
            - name: API_URL
              valueFrom:
                configMapKeyRef:
                  name: educational-config
                  key: API_URL
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

### **2.5 PostgreSQL Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: educational-postgresql
  namespace: educational
  labels:
    app: educational-platform
    component: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: educational-platform
      component: database
  template:
    metadata:
      labels:
        app: educational-platform
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
                  name: educational-secrets
                  key: db-name
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: educational-secrets
                  key: db-username
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: educational-secrets
                  key: db-password
          volumeMounts:
            - name: postgresql-data
              mountPath: /var/lib/postgresql/data
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
            claimName: postgresql-pvc
```

### **2.6 Services and Ingress**
```yaml
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: educational-backend
  namespace: educational
spec:
  selector:
    app: educational-platform
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
  name: educational-frontend
  namespace: educational
spec:
  selector:
    app: educational-platform
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
  name: educational-postgresql
  namespace: educational
spec:
  selector:
    app: educational-platform
    component: database
  ports:
    - name: postgresql
      port: 5432
      targetPort: 5432
  type: ClusterIP

---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: educational-ingress
  namespace: educational
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: educational.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: educational-frontend
                port:
                  number: 80
  tls:
    - hosts:
        - educational.local
      secretName: educational-tls
```

### **2.7 Secrets and PVC**
```yaml
# Secrets
apiVersion: v1
kind: Secret
metadata:
  name: educational-secrets
  namespace: educational
type: Opaque
data:
  jwt-secret: eW91ci1qd3Qtc2VjcmV0LWhlcmU=  # base64 encoded
  db-name: ZWR1Y2F0aW9uYWw=  # base64 encoded "educational"
  db-username: ZWR1Y2F0aW9uYWw=  # base64 encoded "educational"
  db-password: ZWR1Y2F0aW9uYWwxMjM=  # base64 encoded "educational123"

---
# PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-pvc
  namespace: educational
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### **2.8 Deploy Raw YAML**
```bash
cd educational-platform/k8s/base

# Apply all manifests
kubectl apply -f .

# Check deployment
kubectl get all -n educational
kubectl get pvc -n educational
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
  - ingress.yaml

commonLabels:
  app: educational-platform
  managed-by: kustomize

images:
  - name: educational/backend
    newTag: latest
  - name: educational/frontend
    newTag: latest
  - name: postgres
    newTag: "14-alpine"
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
  - name: educational/backend
    newTag: dev-latest
  - name: educational/frontend
    newTag: dev-latest

replicas:
  - name: educational-backend
    count: 1
  - name: educational-frontend
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
  - name: educational/backend
    newTag: v1.0.0
  - name: educational/frontend
    newTag: v1.0.0

replicas:
  - name: educational-backend
    count: 3
  - name: educational-frontend
    count: 3
```

### **3.4 Deploy with Kustomize**
```bash
# Development
kubectl apply -k educational-platform/k8s/overlays/development/

# Production
kubectl apply -k educational-platform/k8s/overlays/production/
```

---

## 🚀 **Advanced Features for Educational Platform**

### **1. Horizontal Pod Autoscaler**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: educational-backend-hpa
  namespace: educational
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: educational-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### **2. Network Policies**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: educational-backend-network-policy
  namespace: educational
spec:
  podSelector:
    matchLabels:
      app: educational-platform
      component: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: educational-platform
              component: frontend
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: educational-platform
              component: database
      ports:
        - protocol: TCP
          port: 5432
```

### **3. Pod Disruption Budget**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: educational-backend-pdb
  namespace: educational
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: educational-platform
      component: backend
```

---

## 🎯 **Quick Deployment Commands**

### **Helm**
```bash
helm install educational ./educational-platform/k8s/helm/educational \
  --namespace educational \
  --create-namespace
```

### **Raw YAML**
```bash
kubectl apply -f educational-platform/k8s/base/
```

### **Kustomize**
```bash
kubectl apply -k educational-platform/k8s/overlays/production/
```

---

## 📊 **Verification Commands**

```bash
# Check all resources
kubectl get all -n educational

# Check application health
kubectl logs -f deployment/educational-backend -n educational

# Port forward for testing
kubectl port-forward svc/educational-frontend 8080:80 -n educational

# Access application
curl http://localhost:8080
```

---

**🎯 Educational Platform is now deployed with full Kubernetes orchestration!**