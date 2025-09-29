# 🚀 Production Deployment Guide

## Kubernetes Deployment

### Prerequisites
- Kubernetes cluster (AWS EKS, Google GKS, or local)
- kubectl configured
- Docker images built and pushed to registry

### Quick Deploy

```bash
# Apply basic deployment
kubectl apply -f k8s/base/

# Apply advanced features
kubectl apply -f k8s/advanced-features/

# Check deployment status
kubectl get pods -n social-media
```

### Environment Configuration

Create production environment file:

```bash
# production.env
NODE_ENV=production
DATABASE_URL=postgresql://user:password@postgres:5432/socialmedia
REDIS_URL=redis://redis:6379
JWT_SECRET=your-production-jwt-secret
```

### Scaling

```bash
# Scale backend pods
kubectl scale deployment social-media-backend --replicas=3

# Enable autoscaling
kubectl apply -f k8s/advanced-features/hpa.yaml
```

### Monitoring

```bash
# Deploy monitoring stack
kubectl apply -f k8s/monitoring/

# Access Grafana dashboard
kubectl port-forward svc/grafana 3000:3000
```

Open http://localhost:3000 (admin/admin)

### SSL/TLS

Update your ingress configuration:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: social-media-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - your-domain.com
    secretName: social-media-tls
  rules:
  - host: your-domain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: social-media-frontend
            port:
              number: 80
```

### Database Backup

```bash
# Backup PostgreSQL
kubectl exec -it postgres-pod -- pg_dump -U postgres socialmedia > backup.sql

# Restore from backup
kubectl exec -i postgres-pod -- psql -U postgres socialmedia < backup.sql
```

## Health Checks

Verify your deployment:

```bash
# Check all pods are running
kubectl get pods

# Check service endpoints
kubectl get endpoints

# Test API health
curl https://your-domain.com/api/health
```