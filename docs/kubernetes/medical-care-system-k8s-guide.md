# 🚀 **Medical Care System - Kubernetes Orchestration**
## **.NET Core + Blazor + SQL Server**

> **🎯 Deploy HIPAA-Compliant Healthcare Platform**  
> **⏰ Time Needed**: 50-60 minutes  
> **👨‍💻 For**: Complete beginners to Kubernetes experts  
> **📚 Level**: Progressive learning from basic to advanced  

---

## 📋 **Medical Care System Overview**

**Complete Healthcare Management Platform:**
- ✅ **Backend**: .NET Core Web API with HIPAA compliance
- ✅ **Frontend**: Blazor Server with medical UI components
- ✅ **Database**: SQL Server with healthcare schemas
- ✅ **Features**: Patient management, appointments, EHR, billing
- ✅ **Advanced**: HIPAA compliance, audit trails, secure messaging

---

## 🏗️ **Choose Your Deployment Method**

### **🎯 Method 1: Helm (Recommended for Beginners)**
```bash
helm install medical ./medical-care-system/k8s/helm/medical \
  --namespace medical \
  --create-namespace \
  --set sqlserver.saPassword='YourSecurePassword123!'
```

### **🎯 Method 2: Raw YAML**
```bash
kubectl apply -f medical-care-system/k8s/base/
```

### **🎯 Method 3: Kustomize**
```bash
kubectl apply -k medical-care-system/k8s/overlays/production/
```

---

## 📁 **Medical Care System Directory Structure**

```
medical-care-system/
├── k8s/
│   ├── helm/                    # Helm charts
│   │   ├── medical/
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── templates/
│   │   │   │   ├── backend-deployment.yaml
│   │   │   │   ├── backend-service.yaml
│   │   │   │   ├── frontend-deployment.yaml
│   │   │   │   ├── frontend-service.yaml
│   │   │   │   ├── sqlserver-deployment.yaml
│   │   │   │   ├── sqlserver-service.yaml
│   │   │   │   ├── ingress.yaml
│   │   │   │   └── _helpers.tpl
│   │   └── requirements.yaml
│   ├── base/                    # Raw YAML manifests
│   │   ├── namespace.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── sqlserver-deployment.yaml
│   │   ├── sqlserver-service.yaml
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
mkdir -p medical-care-system/k8s/helm/medical/templates
```

### **1.2 Chart.yaml**
```yaml
apiVersion: v2
name: medical
description: Medical care system with .NET Core backend and Blazor frontend
type: application
version: 1.0.0
appVersion: "1.0.0"
dependencies:
  - name: sqlserver
    version: "1.x.x"
    repository: "https://charts.bitnami.com/bitnami"
```

### **1.3 values.yaml**
```yaml
backend:
  image:
    repository: medical/backend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 5000
  env:
    ASPNETCORE_ENVIRONMENT: Production
    ConnectionStrings__DefaultConnection: "Server=sqlserver;Database=MedicalCare;User Id=sa;Password=YourSecurePassword123!;TrustServerCertificate=True;"
    JWT__Key: "your-jwt-secret-key-here"
    HIPAA__AuditEnabled: "true"
    Encryption__Key: "your-encryption-key-here"

frontend:
  image:
    repository: medical/frontend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 80
  env:
    API_URL: "http://backend:5000/api"
    ASPNETCORE_ENVIRONMENT: Production

sqlserver:
  saPassword: "YourSecurePassword123!"
  persistence:
    enabled: true
    size: 20Gi

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: medical.local
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: medical-tls
      hosts:
        - medical.local
```

### **1.4 Backend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "medical.fullname" . }}-backend
  labels:
    app.kubernetes.io/name: {{ include "medical.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: backend
spec:
  replicas: {{ .Values.backend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "medical.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "medical.name" . }}
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
            - name: ASPNETCORE_ENVIRONMENT
              value: {{ .Values.backend.env.ASPNETCORE_ENVIRONMENT | quote }}
            - name: ConnectionStrings__DefaultConnection
              value: {{ .Values.backend.env.ConnectionStrings__DefaultConnection | quote }}
            - name: JWT__Key
              value: {{ .Values.backend.env.JWT__Key | quote }}
            - name: HIPAA__AuditEnabled
              value: {{ .Values.backend.env.HIPAA__AuditEnabled | quote }}
            - name: Encryption__Key
              value: {{ .Values.backend.env.Encryption__Key | quote }}
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
              path: /health/ready
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          volumeMounts:
            - name: medical-data
              mountPath: /app/data
      volumes:
        - name: medical-data
          persistentVolumeClaim:
            claimName: {{ include "medical.fullname" . }}-data
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
```

### **1.5 Frontend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "medical.fullname" . }}-frontend
  labels:
    app.kubernetes.io/name: {{ include "medical.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "medical.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: frontend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "medical.name" . }}
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
            - name: ASPNETCORE_ENVIRONMENT
              value: {{ .Values.frontend.env.ASPNETCORE_ENVIRONMENT | quote }}
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
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
```

### **1.6 Ingress Template**
```yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "medical.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ include "medical.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
  {{- with .Values.ingress.annotations }}
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
                name: {{ include "medical.fullname" $ }}-frontend
                port:
                  number: {{ $.Values.frontend.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

### **1.7 PVC for Medical Data**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "medical.fullname" . }}-data
  labels:
    app.kubernetes.io/name: {{ include "medical.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: medical-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
```

### **1.8 _helpers.tpl**
```tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "medical.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "medical.fullname" -}}
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
cd medical-care-system/k8s/helm/medical

# Install dependencies
helm dependency update

# Deploy
helm install medical . \
  --namespace medical \
  --create-namespace \
  --set sqlserver.saPassword='YourSecurePassword123!'

# Check deployment
helm list -n medical
kubectl get pods -n medical
```

---

## 📄 **Method 2: Raw YAML Deployment**

### **2.1 Create Namespace**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: medical
  labels:
    name: medical
    app: medical-care-system
```

### **2.2 Create ConfigMap**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: medical-config
  namespace: medical
data:
  ASPNETCORE_ENVIRONMENT: "Production"
  API_URL: "http://medical-backend:5000/api"
  SQLSERVER_CONNECTION: "Server=medical-sqlserver;Database=MedicalCare;User Id=sa;Password=YourSecurePassword123!;TrustServerCertificate=True;"
```

### **2.3 Backend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: medical-backend
  namespace: medical
  labels:
    app: medical-care-system
    component: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: medical-care-system
      component: backend
  template:
    metadata:
      labels:
        app: medical-care-system
        component: backend
    spec:
      containers:
        - name: backend
          image: medical/backend:latest
          ports:
            - containerPort: 5000
              name: http
          env:
            - name: ASPNETCORE_ENVIRONMENT
              valueFrom:
                configMapKeyRef:
                  name: medical-config
                  key: ASPNETCORE_ENVIRONMENT
            - name: ConnectionStrings__DefaultConnection
              valueFrom:
                configMapKeyRef:
                  name: medical-config
                  key: SQLSERVER_CONNECTION
            - name: JWT__Key
              valueFrom:
                secretKeyRef:
                  name: medical-secrets
                  key: jwt-key
            - name: HIPAA__AuditEnabled
              value: "true"
            - name: Encryption__Key
              valueFrom:
                secretKeyRef:
                  name: medical-secrets
                  key: encryption-key
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
              path: /health/ready
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          volumeMounts:
            - name: medical-data
              mountPath: /app/data
          securityContext:
            runAsNonRoot: true
            runAsUser: 1001
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
      volumes:
        - name: medical-data
          persistentVolumeClaim:
            claimName: medical-data-pvc
      securityContext:
        fsGroup: 1001
```

### **2.4 Frontend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: medical-frontend
  namespace: medical
  labels:
    app: medical-care-system
    component: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: medical-care-system
      component: frontend
  template:
    metadata:
      labels:
        app: medical-care-system
        component: frontend
    spec:
      containers:
        - name: frontend
          image: medical/frontend:latest
          ports:
            - containerPort: 80
              name: http
          env:
            - name: API_URL
              valueFrom:
                configMapKeyRef:
                  name: medical-config
                  key: API_URL
            - name: ASPNETCORE_ENVIRONMENT
              valueFrom:
                configMapKeyRef:
                  name: medical-config
                  key: ASPNETCORE_ENVIRONMENT
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
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          securityContext:
            runAsNonRoot: true
            runAsUser: 1001
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
      securityContext:
        fsGroup: 1001
```

### **2.5 SQL Server Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: medical-sqlserver
  namespace: medical
  labels:
    app: medical-care-system
    component: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: medical-care-system
      component: database
  template:
    metadata:
      labels:
        app: medical-care-system
        component: database
    spec:
      containers:
        - name: sqlserver
          image: mcr.microsoft.com/mssql/server:2022-latest
          ports:
            - containerPort: 1433
              name: sqlserver
          env:
            - name: ACCEPT_EULA
              value: "Y"
            - name: SA_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: medical-secrets
                  key: sa-password
            - name: MSSQL_PID
              value: "Express"
          volumeMounts:
            - name: sqlserver-data
              mountPath: /var/opt/mssql
            - name: sqlserver-log
              mountPath: /var/opt/mssql/log
            - name: sqlserver-backup
              mountPath: /var/opt/mssql/backup
          resources:
            requests:
              memory: "2Gi"
              cpu: "1000m"
            limits:
              memory: "4Gi"
              cpu: "2000m"
          livenessProbe:
            exec:
              command:
                - /opt/mssql-tools/bin/sqlcmd
                - -S
                - localhost
                - -U
                - sa
                - -P
                - "$(SA_PASSWORD)"
                - -Q
                - "SELECT 1"
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            exec:
              command:
                - /opt/mssql-tools/bin/sqlcmd
                - -S
                - localhost
                - -U
                - sa
                - -P
                - "$(SA_PASSWORD)"
                - -Q
                - "SELECT 1"
            initialDelaySeconds: 30
            periodSeconds: 10
          securityContext:
            runAsNonRoot: true
            runAsUser: 10001
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
      volumes:
        - name: sqlserver-data
          persistentVolumeClaim:
            claimName: sqlserver-data-pvc
        - name: sqlserver-log
          persistentVolumeClaim:
            claimName: sqlserver-log-pvc
        - name: sqlserver-backup
          persistentVolumeClaim:
            claimName: sqlserver-backup-pvc
      securityContext:
        fsGroup: 10001
```

### **2.6 Services and Ingress**
```yaml
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: medical-backend
  namespace: medical
spec:
  selector:
    app: medical-care-system
    component: backend
  ports:
    - name: http
      port: 5000
      targetPort: 5000
  type: ClusterIP

---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: medical-frontend
  namespace: medical
spec:
  selector:
    app: medical-care-system
    component: frontend
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP

---
# SQL Server Service
apiVersion: v1
kind: Service
metadata:
  name: medical-sqlserver
  namespace: medical
spec:
  selector:
    app: medical-care-system
    component: database
  ports:
    - name: sqlserver
      port: 1433
      targetPort: 1433
  type: ClusterIP

---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: medical-ingress
  namespace: medical
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
spec:
  ingressClassName: nginx
  rules:
    - host: medical.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: medical-frontend
                port:
                  number: 80
  tls:
    - hosts:
        - medical.local
      secretName: medical-tls
```

### **2.7 Secrets and PVC**
```yaml
# Secrets
apiVersion: v1
kind: Secret
metadata:
  name: medical-secrets
  namespace: medical
type: Opaque
data:
  jwt-key: eW91ci1qd3Qtc2VjcmV0LWtleS1oZXJl  # base64 encoded
  encryption-key: eW91ci1lbmNyeXB0aW9uLWtleS1oZXJl  # base64 encoded
  sa-password: WW91clNlY3VyZVBhc3N3b3JkMTIzIQ==  # base64 encoded "YourSecurePassword123!"

---
# PVC for Medical Data
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: medical-data-pvc
  namespace: medical
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi

---
# PVC for SQL Server Data
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sqlserver-data-pvc
  namespace: medical
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi

---
# PVC for SQL Server Log
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sqlserver-log-pvc
  namespace: medical
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi

---
# PVC for SQL Server Backup
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sqlserver-backup-pvc
  namespace: medical
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
```

### **2.8 Deploy Raw YAML**
```bash
cd medical-care-system/k8s/base

# Apply all manifests
kubectl apply -f .

# Check deployment
kubectl get all -n medical
kubectl get pvc -n medical
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
  - sqlserver-deployment.yaml
  - sqlserver-service.yaml
  - ingress.yaml

commonLabels:
  app: medical-care-system
  managed-by: kustomize

images:
  - name: medical/backend
    newTag: latest
  - name: medical/frontend
    newTag: latest
  - name: mcr.microsoft.com/mssql/server
    newTag: "2022-latest"
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
  - name: medical/backend
    newTag: dev-latest
  - name: medical/frontend
    newTag: dev-latest

replicas:
  - name: medical-backend
    count: 1
  - name: medical-frontend
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
  - name: medical/backend
    newTag: v1.0.0
  - name: medical/frontend
    newTag: v1.0.0

replicas:
  - name: medical-backend
    count: 3
  - name: medical-frontend
    count: 3
```

### **3.4 Deploy with Kustomize**
```bash
# Development
kubectl apply -k medical-care-system/k8s/overlays/development/

# Production
kubectl apply -k medical-care-system/k8s/overlays/production/
```

---

## 🚀 **Advanced Features for Medical Care System**

### **1. Horizontal Pod Autoscaler**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: medical-backend-hpa
  namespace: medical
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: medical-backend
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
```

### **2. Network Policies**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: medical-backend-network-policy
  namespace: medical
spec:
  podSelector:
    matchLabels:
      app: medical-care-system
      component: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: medical-care-system
              component: frontend
      ports:
        - protocol: TCP
          port: 5000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: medical-care-system
              component: database
      ports:
        - protocol: TCP
          port: 1433
```

### **3. Pod Disruption Budget**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: medical-backend-pdb
  namespace: medical
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: medical-care-system
      component: backend
```

---

## 🔒 **HIPAA Compliance Configuration**

### **Security Context for HIPAA**
```yaml
# Add to backend deployment
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  fsGroup: 1001
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

### **Audit Logging**
```yaml
# Enable audit logging in config
HIPAA__AuditEnabled: "true"
HIPAA__AuditLogPath: "/app/logs/audit"
```

### **Encryption at Rest**
```yaml
# Database encryption
env:
  - name: MSSQL_ENCRYPTION_ENABLED
    value: "true"
```

---

## 🎯 **Quick Deployment Commands**

### **Helm**
```bash
helm install medical ./medical-care-system/k8s/helm/medical \
  --namespace medical \
  --create-namespace
```

### **Raw YAML**
```bash
kubectl apply -f medical-care-system/k8s/base/
```

### **Kustomize**
```bash
kubectl apply -k medical-care-system/k8s/overlays/production/
```

---

## 📊 **Verification Commands**

```bash
# Check all resources
kubectl get all -n medical

# Check application health
kubectl logs -f deployment/medical-backend -n medical

# Port forward for testing
kubectl port-forward svc/medical-frontend 8080:80 -n medical

# Access application
curl http://localhost:8080

# Test API health
curl http://localhost:8080/api/health
```

---

## 🔑 **Security Keys Setup**

**Before deploying, generate secure keys:**

### **JWT Secret Key**
```bash
# Generate a secure JWT key
openssl rand -base64 32
```

### **Encryption Key**
```bash
# Generate an encryption key
openssl rand -hex 32
```

### **Database Password**
```bash
# Generate a strong password
openssl rand -base64 16
```

---

**🎯 HIPAA-compliant Medical Care System is now deployed with full Kubernetes orchestration!**