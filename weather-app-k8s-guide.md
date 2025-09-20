# 🚀 **Weather App - Kubernetes Orchestration**
## **Python Flask + Vue.js + Redis**

> **🎯 Deploy AI-Powered Weather Intelligence Platform**  
> **⏰ Time Needed**: 40-50 minutes  
> **👨‍💻 For**: Complete beginners to Kubernetes experts  
> **📚 Level**: Progressive learning from basic to advanced  

---

## 📋 **Weather App Overview**

**Complete Weather Intelligence System:**
- ✅ **Backend**: Python Flask with AI weather predictions
- ✅ **Frontend**: Vue.js with interactive weather maps
- ✅ **Cache**: Redis for weather data caching
- ✅ **Features**: Real-time weather, AI predictions, alerts
- ✅ **Advanced**: Weather APIs integration, data visualization

---

## 🏗️ **Choose Your Deployment Method**

### **🎯 Method 1: Helm (Recommended for Beginners)**
```bash
helm install weather ./weather-app/k8s/helm/weather \
  --namespace weather \
  --create-namespace \
  --set redis.auth.password='YourSecurePassword123!'
```

### **🎯 Method 2: Raw YAML**
```bash
kubectl apply -f weather-app/k8s/base/
```

### **🎯 Method 3: Kustomize**
```bash
kubectl apply -k weather-app/k8s/overlays/production/
```

---

## 📁 **Weather App Directory Structure**

```
weather-app/
├── k8s/
│   ├── helm/                    # Helm charts
│   │   ├── weather/
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── templates/
│   │   │   │   ├── backend-deployment.yaml
│   │   │   │   ├── backend-service.yaml
│   │   │   │   ├── frontend-deployment.yaml
│   │   │   │   ├── frontend-service.yaml
│   │   │   │   ├── redis-deployment.yaml
│   │   │   │   ├── redis-service.yaml
│   │   │   │   ├── ingress.yaml
│   │   │   │   └── _helpers.tpl
│   │   └── requirements.yaml
│   ├── base/                    # Raw YAML manifests
│   │   ├── namespace.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
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
mkdir -p weather-app/k8s/helm/weather/templates
```

### **1.2 Chart.yaml**
```yaml
apiVersion: v2
name: weather
description: Weather application with Python Flask backend and Vue.js frontend
type: application
version: 1.0.0
appVersion: "1.0.0"
dependencies:
  - name: redis
    version: "17.x.x"
    repository: "https://charts.bitnami.com/bitnami"
```

### **1.3 values.yaml**
```yaml
backend:
  image:
    repository: weather/backend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 5000
  env:
    FLASK_ENV: production
    REDIS_URL: redis://redis:6379
    WEATHER_API_KEY: "your-weather-api-key-here"
    AI_MODEL_PATH: "/app/models/weather_model.pkl"

frontend:
  image:
    repository: weather/frontend
    tag: "latest"
    pullPolicy: IfNotPresent
  replicaCount: 2
  port: 80
  env:
    VUE_APP_API_URL: "http://backend:5000/api"
    VUE_APP_MAPS_API_KEY: "your-maps-api-key-here"

redis:
  auth:
    password: "YourSecurePassword123!"
  architecture: standalone
  persistence:
    enabled: true
    size: 2Gi

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: weather.local
      paths:
        - path: /
          pathType: Prefix
```

### **1.4 Backend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "weather.fullname" . }}-backend
  labels:
    app.kubernetes.io/name: {{ include "weather.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: backend
spec:
  replicas: {{ .Values.backend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "weather.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "weather.name" . }}
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
            - name: FLASK_ENV
              value: {{ .Values.backend.env.FLASK_ENV | quote }}
            - name: REDIS_URL
              value: {{ .Values.backend.env.REDIS_URL | quote }}
            - name: WEATHER_API_KEY
              value: {{ .Values.backend.env.WEATHER_API_KEY | quote }}
            - name: AI_MODEL_PATH
              value: {{ .Values.backend.env.AI_MODEL_PATH | quote }}
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
            - name: ai-models
              mountPath: /app/models
      volumes:
        - name: ai-models
          persistentVolumeClaim:
            claimName: {{ include "weather.fullname" . }}-ai-models
```

### **1.5 Frontend Deployment Template**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "weather.fullname" . }}-frontend
  labels:
    app.kubernetes.io/name: {{ include "weather.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "weather.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/component: frontend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "weather.name" . }}
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
            - name: VUE_APP_API_URL
              value: {{ .Values.frontend.env.VUE_APP_API_URL | quote }}
            - name: VUE_APP_MAPS_API_KEY
              value: {{ .Values.frontend.env.VUE_APP_MAPS_API_KEY | quote }}
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
  name: {{ include "weather.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ include "weather.name" . }}
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
                name: {{ include "weather.fullname" $ }}-frontend
                port:
                  number: {{ $.Values.frontend.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

### **1.7 PVC for AI Models**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "weather.fullname" . }}-ai-models
  labels:
    app.kubernetes.io/name: {{ include "weather.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/component: ai-models
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### **1.8 _helpers.tpl**
```tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "weather.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "weather.fullname" -}}
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
cd weather-app/k8s/helm/weather

# Install dependencies
helm dependency update

# Deploy
helm install weather . \
  --namespace weather \
  --create-namespace \
  --set redis.auth.password='YourSecurePassword123!'

# Check deployment
helm list -n weather
kubectl get pods -n weather
```

---

## 📄 **Method 2: Raw YAML Deployment**

### **2.1 Create Namespace**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: weather
  labels:
    name: weather
    app: weather-app
```

### **2.2 Create ConfigMap**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: weather-config
  namespace: weather
data:
  FLASK_ENV: "production"
  VUE_APP_API_URL: "http://weather-backend:5000/api"
  REDIS_URL: "redis://weather-redis:6379"
```

### **2.3 Backend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: weather-backend
  namespace: weather
  labels:
    app: weather-app
    component: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: weather-app
      component: backend
  template:
    metadata:
      labels:
        app: weather-app
        component: backend
    spec:
      containers:
        - name: backend
          image: weather/backend:latest
          ports:
            - containerPort: 5000
              name: http
          env:
            - name: FLASK_ENV
              valueFrom:
                configMapKeyRef:
                  name: weather-config
                  key: FLASK_ENV
            - name: REDIS_URL
              valueFrom:
                configMapKeyRef:
                  name: weather-config
                  key: REDIS_URL
            - name: WEATHER_API_KEY
              valueFrom:
                secretKeyRef:
                  name: weather-secrets
                  key: weather-api-key
            - name: AI_MODEL_PATH
              value: "/app/models/weather_model.pkl"
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
            - name: ai-models
              mountPath: /app/models
      volumes:
        - name: ai-models
          persistentVolumeClaim:
            claimName: weather-ai-models
```

### **2.4 Frontend Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: weather-frontend
  namespace: weather
  labels:
    app: weather-app
    component: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: weather-app
      component: frontend
  template:
    metadata:
      labels:
        app: weather-app
        component: frontend
    spec:
      containers:
        - name: frontend
          image: weather/frontend:latest
          ports:
            - containerPort: 80
              name: http
          env:
            - name: VUE_APP_API_URL
              valueFrom:
                configMapKeyRef:
                  name: weather-config
                  key: VUE_APP_API_URL
            - name: VUE_APP_MAPS_API_KEY
              valueFrom:
                secretKeyRef:
                  name: weather-secrets
                  key: maps-api-key
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

### **2.5 Redis Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: weather-redis
  namespace: weather
  labels:
    app: weather-app
    component: cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: weather-app
      component: cache
  template:
    metadata:
      labels:
        app: weather-app
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
                  name: weather-secrets
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

### **2.6 Services and Ingress**
```yaml
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: weather-backend
  namespace: weather
spec:
  selector:
    app: weather-app
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
  name: weather-frontend
  namespace: weather
spec:
  selector:
    app: weather-app
    component: frontend
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP

---
# Redis Service
apiVersion: v1
kind: Service
metadata:
  name: weather-redis
  namespace: weather
spec:
  selector:
    app: weather-app
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
  name: weather-ingress
  namespace: weather
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: weather.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: weather-frontend
                port:
                  number: 80
  tls:
    - hosts:
        - weather.local
      secretName: weather-tls
```

### **2.7 Secrets and PVC**
```yaml
# Secrets
apiVersion: v1
kind: Secret
metadata:
  name: weather-secrets
  namespace: weather
type: Opaque
data:
  weather-api-key: eW91ci13ZWF0aGVyLWFwaS1rZXktaGVyZQ==  # base64 encoded
  maps-api-key: eW91ci1tYXBzLWFwaS1rZXktaGVyZQ==  # base64 encoded
  redis-password: cmVkaXMxMjM=  # base64 encoded "redis123"

---
# PVC for Redis
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
  namespace: weather
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

---
# PVC for AI Models
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: weather-ai-models
  namespace: weather
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### **2.8 Deploy Raw YAML**
```bash
cd weather-app/k8s/base

# Apply all manifests
kubectl apply -f .

# Check deployment
kubectl get all -n weather
kubectl get pvc -n weather
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
  - redis-deployment.yaml
  - redis-service.yaml
  - ingress.yaml

commonLabels:
  app: weather-app
  managed-by: kustomize

images:
  - name: weather/backend
    newTag: latest
  - name: weather/frontend
    newTag: latest
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
  - name: weather/backend
    newTag: dev-latest
  - name: weather/frontend
    newTag: dev-latest

replicas:
  - name: weather-backend
    count: 1
  - name: weather-frontend
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
  - name: weather/backend
    newTag: v1.0.0
  - name: weather/frontend
    newTag: v1.0.0

replicas:
  - name: weather-backend
    count: 3
  - name: weather-frontend
    count: 3
```

### **3.4 Deploy with Kustomize**
```bash
# Development
kubectl apply -k weather-app/k8s/overlays/development/

# Production
kubectl apply -k weather-app/k8s/overlays/production/
```

---

## 🚀 **Advanced Features for Weather App**

### **1. Horizontal Pod Autoscaler**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: weather-backend-hpa
  namespace: weather
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: weather-backend
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
  name: weather-backend-network-policy
  namespace: weather
spec:
  podSelector:
    matchLabels:
      app: weather-app
      component: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: weather-app
              component: frontend
      ports:
        - protocol: TCP
          port: 5000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: weather-app
              component: cache
      ports:
        - protocol: TCP
          port: 6379
    - to: []  # Allow external weather API calls
      ports:
        - protocol: TCP
          port: 443   # HTTPS for weather APIs
        - protocol: TCP
          port: 80    # HTTP for weather APIs
```

### **3. Pod Disruption Budget**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: weather-backend-pdb
  namespace: weather
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: weather-app
      component: backend
```

---

## 🎯 **Quick Deployment Commands**

### **Helm**
```bash
helm install weather ./weather-app/k8s/helm/weather \
  --namespace weather \
  --create-namespace
```

### **Raw YAML**
```bash
kubectl apply -f weather-app/k8s/base/
```

### **Kustomize**
```bash
kubectl apply -k weather-app/k8s/overlays/production/
```

---

## 📊 **Verification Commands**

```bash
# Check all resources
kubectl get all -n weather

# Check application health
kubectl logs -f deployment/weather-backend -n weather

# Port forward for testing
kubectl port-forward svc/weather-frontend 8080:80 -n weather

# Access application
curl http://localhost:8080

# Test weather API
curl http://localhost:8080/api/weather?city=London
```

---

## 🔑 **API Keys Setup**

**Before deploying, you need to obtain API keys:**

### **Weather API Key**
1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Get your API key from the dashboard
4. Add it to your secrets

### **Google Maps API Key**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Maps JavaScript API
4. Create credentials (API Key)
5. Restrict the key to your domain
6. Add it to your secrets

---

**🎯 Weather App with AI predictions is now deployed with full Kubernetes orchestration!**