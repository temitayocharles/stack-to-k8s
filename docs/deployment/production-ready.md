# 🚀 Production-Ready Deployment - Real-World Scale

**Goal**: Deploy applications to production with enterprise-grade reliability and performance.

> **Perfect for**: "I want to deploy like major tech companies"

## 🎯 What You'll Achieve
- ✅ **High availability** with zero-downtime deployments
- ✅ **Auto-scaling** based on CPU, memory, and custom metrics
- ✅ **Load balancing** across multiple availability zones
- ✅ **Disaster recovery** with automated backups
- ✅ **Security hardening** with network policies and RBAC

## 📋 Before You Start
**Required time**: 4-6 hours  
**Prerequisites**: [Enterprise setup](../getting-started/enterprise-setup.md) and [CI/CD setup](../getting-started/cicd-setup.md) completed  
**Infrastructure**: Kubernetes cluster with at least 3 nodes

## 🏗️ Phase 1: Infrastructure Preparation (60 minutes)

### Step 1: Cluster Requirements
```bash
# Verify cluster has sufficient resources
kubectl top nodes

# Required minimums:
# - 3+ nodes
# - 8GB+ RAM per node  
# - 4+ CPU cores per node
# - 100GB+ storage per node
```

### Step 2: Create Production Namespaces
```bash
# Create isolated namespaces
kubectl create namespace production
kubectl create namespace monitoring
kubectl create namespace ingress-system
kubectl create namespace backup-system

# Label for production policies
kubectl label namespace production \
  tier=production \
  pod-security.kubernetes.io/enforce=restricted
```

### Step 3: Install Core Infrastructure
```bash
# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-system \
  --set controller.replicaCount=3 \
  --set controller.nodeSelector."kubernetes\.io/os"=linux

# Install cert-manager for SSL
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true
```

## 🔒 Phase 2: Security Hardening (90 minutes)

### Step 1: Network Security
Create `security/network-policies.yaml`:
```yaml
# Deny all traffic by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Allow frontend to backend
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
---
# Allow backend to database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-database
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
```

### Step 2: Pod Security Standards
Create `security/pod-security.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod-template
  namespace: production
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: my-app:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: cache
      mountPath: /app/cache
  volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
```

### Step 3: RBAC Configuration
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
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
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

## ⚡ Phase 3: High Availability Setup (75 minutes)

### Step 1: Multi-Zone Deployment
Create `production/frontend-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: production
  labels:
    app: frontend
    tier: frontend
spec:
  replicas: 6  # 2 per availability zone
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      serviceAccountName: app-service-account
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: frontend
              topologyKey: kubernetes.io/hostname
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: topology.kubernetes.io/zone
                operator: In
                values: ["us-west-2a", "us-west-2b", "us-west-2c"]
      containers:
      - name: frontend
        image: my-registry/frontend:latest
        ports:
        - containerPort: 3000
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        env:
        - name: API_URL
          value: "http://backend-service:8080"
```

### Step 2: Auto-Scaling Configuration
Create `production/hpa.yaml`:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  minReplicas: 6
  maxReplicas: 20
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
        value: 50
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

### Step 3: Pod Disruption Budgets
Create `production/pdb.yaml`:
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: frontend-pdb
  namespace: production
spec:
  minAvailable: 4
  selector:
    matchLabels:
      app: frontend
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: backend-pdb
  namespace: production
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: backend
```

## 💾 Phase 4: Data Persistence and Backup (60 minutes)

### Step 1: Persistent Storage
Create `production/database-statefulset.yaml`:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: production
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
        tier: database
    spec:
      containers:
      - name: postgres
        image: postgres:14
        env:
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: database
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        - name: POSTGRES_REPLICATION_MODE
          value: slave
        - name: POSTGRES_REPLICATION_USER
          value: replicator
        - name: POSTGRES_REPLICATION_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: replication-password
        - name: POSTGRES_MASTER_SERVICE
          value: postgres-master
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 100Gi
```

### Step 2: Backup Strategy
Create `backup/cronjob.yaml`:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
  namespace: production
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: postgres-backup
            image: postgres:14
            command:
            - /bin/bash
            - -c
            - |
              BACKUP_FILE="/backup/backup-$(date +%Y%m%d-%H%M%S).sql"
              pg_dump -h postgres-service -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_FILE
              
              # Upload to S3 (or your cloud storage)
              aws s3 cp $BACKUP_FILE s3://my-backups/database/
              
              # Keep only last 30 days locally
              find /backup -name "backup-*.sql" -mtime +30 -delete
            env:
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: username
            - name: POSTGRES_DB
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: database
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: backup-pvc
```

## 🌐 Phase 5: Load Balancing and Traffic Management (45 minutes)

### Step 1: Load Balancer Service
Create `production/loadbalancer.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-lb
  namespace: production
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - name: http
    port: 80
    targetPort: 3000
  - name: https
    port: 443
    targetPort: 3000
  sessionAffinity: None
```

### Step 2: Ingress Configuration
Create `production/ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - myapp.com
    - api.myapp.com
    secretName: myapp-tls
  rules:
  - host: myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  - host: api.myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
```

## 📊 Phase 6: Production Monitoring (30 minutes)

### Step 1: Application Metrics
Create `monitoring/servicemonitor.yaml`:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-metrics
  namespace: production
spec:
  selector:
    matchLabels:
      monitor: app-metrics
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
```

### Step 2: Alerting Rules
Create `monitoring/alerts.yaml`:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
  namespace: production
spec:
  groups:
  - name: app.rules
    rules:
    - alert: HighErrorRate
      expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High error rate detected"
        
    - alert: HighLatency
      expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High latency detected"
        
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[10m]) > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Pod is crash looping"
```

## 🚀 Phase 7: Deployment and Verification (30 minutes)

### Step 1: Deploy Everything
```bash
# Apply all production configurations
kubectl apply -f security/
kubectl apply -f production/
kubectl apply -f backup/
kubectl apply -f monitoring/

# Verify deployments
kubectl get all -n production
kubectl get pdb -n production
kubectl get hpa -n production
```

### Step 2: Load Testing
```bash
# Install k6 for load testing
brew install k6  # Mac

# Create load test script
cat > load-test.js << EOF
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 500 },
    { duration: '2m', target: 1000 },
    { duration: '5m', target: 1000 },
    { duration: '2m', target: 0 },
  ],
};

export default function () {
  let response = http.get('https://myapp.com');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
EOF

# Run load test
k6 run load-test.js
```

### Step 3: Disaster Recovery Test
```bash
# Test node failure simulation
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Verify application still accessible
curl -f https://myapp.com

# Test database failover
kubectl delete pod postgres-0 -n production

# Verify automatic recovery
kubectl get pods -n production -w
```

## ✅ Production Readiness Checklist

### Security ✅
- [ ] Network policies implemented
- [ ] Pod security standards enforced
- [ ] RBAC configured with least privilege
- [ ] Secrets properly managed
- [ ] TLS/SSL certificates configured

### High Availability ✅
- [ ] Multi-zone deployment
- [ ] Pod anti-affinity rules
- [ ] Pod disruption budgets
- [ ] Auto-scaling configured
- [ ] Load balancer health checks

### Data Protection ✅
- [ ] Persistent storage configured
- [ ] Automated backups scheduled
- [ ] Backup restoration tested
- [ ] Database replication active

### Monitoring & Alerting ✅
- [ ] Application metrics collected
- [ ] Infrastructure monitoring active
- [ ] Critical alerts configured
- [ ] Log aggregation working
- [ ] Dashboards accessible

### Performance ✅
- [ ] Load testing completed
- [ ] Resource limits optimized
- [ ] Caching strategies implemented
- [ ] CDN configured for static assets

## 🎉 Congratulations!

You've successfully deployed a production-ready application with:
- ✅ **Enterprise-grade security** and compliance
- ✅ **High availability** across multiple zones
- ✅ **Auto-scaling** based on demand
- ✅ **Automated backups** and disaster recovery
- ✅ **Comprehensive monitoring** and alerting

## ➡️ What's Next?

✅ **Advanced topics**: [Multi-cluster deployment](multi-cluster.md)  
✅ **Cost optimization**: [Resource optimization guide](cost-optimization.md)  
✅ **Compliance**: [SOC2/HIPAA compliance setup](compliance.md)

## 🆘 Production Issues

**High resource usage**:
- Review resource requests and limits
- Check for memory leaks in applications
- Optimize database queries

**Slow response times**:
- Enable application caching
- Optimize database indexes
- Scale up resources or replicas

**Backup failures**:
- Check storage permissions
- Verify network connectivity
- Review backup job logs

---

**Enterprise achievement unlocked!** Your application is now running with the same reliability standards as major tech companies.