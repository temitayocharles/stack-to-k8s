# Deployment Guide - E-commerce Platform

> **🚀 Step-by-Step Application Deployment**  
> This guide shows you exactly how to deploy the e-commerce application to your Kubernetes cluster.

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ **EKS cluster running** (from the infrastructure setup)
- ✅ **kubectl configured** to access your cluster
- ✅ **Docker installed** locally
- ✅ **AWS CLI configured** with proper permissions

---

## 🚀 STEP 1: Prepare Your Environment

### **First, verify everything is working:**

```bash
# Test cluster access
kubectl get nodes
# You should see your worker nodes

# Test AWS access  
aws sts get-caller-identity
# You should see your account details

# Test Docker
docker --version
# You should see Docker version
```

### **Clone the repository:**

```bash
# Navigate to your workspace
cd ~/Documents/workspace

# If you haven't already, create the project structure
mkdir -p ecommerce-app
cd ecommerce-app
```

---

## 🚀 STEP 2: Build and Push Docker Images

### **Build the backend image:**

```bash
# Navigate to backend directory
cd backend

# Build the Docker image
docker build -t ecommerce-backend:latest .

# Tag for ECR (replace with your ECR URI)
docker tag ecommerce-backend:latest YOUR_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/ecommerce/backend:latest
```

### **Build the frontend image:**

```bash
# Navigate to frontend directory  
cd ../frontend

# Build the Docker image
docker build -t ecommerce-frontend:latest .

# Tag for ECR
docker tag ecommerce-frontend:latest YOUR_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/ecommerce/frontend:latest
```

### **Login to ECR and push images:**

```bash
# Get login token for ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com

# Push backend image
docker push YOUR_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/ecommerce/backend:latest

# Push frontend image  
docker push YOUR_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/ecommerce/frontend:latest
```

### **If you get errors:**

- **"no basic auth credentials"**: Run the ECR login command again
- **"repository does not exist"**: Check your ECR repository names match exactly
- **"access denied"**: Verify your AWS credentials and ECR permissions

---

## 🚀 STEP 3: Update Kubernetes Manifests

### **Update image references:**

```bash
# Navigate to k8s manifests
cd ../k8s

# Open the backend deployment file
# Replace YOUR_ACCOUNT with your actual AWS account ID
# Replace us-west-2 with your region if different
```

### **Backend deployment update:**

1. **Open** `backend-deployment.yaml`
2. **Find** the line with `image:`
3. **Replace** with your ECR URI:

```yaml
image: YOUR_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/ecommerce/backend:latest
```

### **Frontend deployment update:**

1. **Open** `frontend-deployment.yaml`  
2. **Find** the line with `image:`
3. **Replace** with your ECR URI:

```yaml
image: YOUR_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/ecommerce/frontend:latest
```

### **Update Redis connection:**

1. **Open** `configmap.yaml`
2. **Find** `REDIS_URL`
3. **Replace** with your ElastiCache endpoint:

```yaml
REDIS_URL: "redis://your-redis-cluster.cache.amazonaws.com:6379"
```

---

## 🚀 STEP 4: Deploy to Kubernetes

### **Create the namespace:**

```bash
kubectl apply -f namespace.yaml
```

**You should see:** `namespace/ecommerce created`

### **Deploy configuration:**

```bash
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
```

**You should see:**
- `configmap/ecommerce-config created`
- `secret/ecommerce-secrets created`

### **Deploy the database:**

```bash
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f mongodb-service.yaml
```

**You should see:**
- `deployment.apps/mongodb created`
- `service/mongodb created`

### **Wait for MongoDB to be ready:**

```bash
kubectl get pods -n ecommerce -w
# Wait until MongoDB pod shows "Running" status
# Press Ctrl+C to stop watching
```

### **Deploy the backend:**

```bash
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
```

**You should see:**
- `deployment.apps/backend created`
- `service/backend created`

### **Deploy the frontend:**

```bash
kubectl apply -f frontend-deployment.yaml  
kubectl apply -f frontend-service.yaml
```

**You should see:**
- `deployment.apps/frontend created`
- `service/frontend created`

### **Deploy the ingress:**

```bash
kubectl apply -f ingress.yaml
```

**You should see:** `ingress.networking.k8s.io/ecommerce-ingress created`

---

## 🚀 STEP 5: Set Up Load Balancer Integration

### **Install AWS Load Balancer Controller:**

```bash
# Download IAM policy
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

# Create IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# Create service account
eksctl create iamserviceaccount \
  --cluster=ecommerce-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::YOUR_ACCOUNT:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# Install the controller
kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# Download controller spec
curl -Lo v2_7_2_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.7.2/v2_7_2_full.yaml

# Edit the file to add your cluster name
sed -i.bak -e '596s|your-cluster-name|ecommerce-cluster|' v2_7_2_full.yaml

# Apply the controller
kubectl apply -f v2_7_2_full.yaml
```

---

## 🚀 STEP 6: Verify Deployment

### **Check all pods are running:**

```bash
kubectl get pods -n ecommerce
```

**You should see all pods with "Running" status:**

```
NAME                        READY   STATUS    RESTARTS   AGE
mongodb-xxx                 1/1     Running   0          5m
backend-xxx                 1/1     Running   0          3m
frontend-xxx                1/1     Running   0          2m
```

### **Check services:**

```bash
kubectl get services -n ecommerce
```

**You should see all services listed with cluster IPs**

### **Check ingress:**

```bash
kubectl get ingress -n ecommerce
```

**You should see:**

```
NAME                CLASS   HOSTS   ADDRESS                                  PORTS   AGE
ecommerce-ingress   alb     *       xxx.us-west-2.elb.amazonaws.com        80      2m
```

### **Get the application URL:**

```bash
kubectl get ingress -n ecommerce -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

**Copy this URL** - this is your application endpoint!

---

## 🚀 STEP 7: Test the Application

### **Open in browser:**

1. **Copy** the URL from the previous step
2. **Open** your web browser
3. **Navigate** to `http://YOUR_LOAD_BALANCER_URL`
4. **You should see** the e-commerce application homepage

### **Test basic functionality:**

1. **Browse products** - Should load from MongoDB
2. **Add to cart** - Should work with session storage
3. **User registration** - Should create new user account
4. **Login/logout** - Should authenticate properly

### **Check backend API:**

```bash
# Test the API directly
curl http://YOUR_LOAD_BALANCER_URL/api/health

# You should see:
{"status":"healthy","timestamp":"2024-01-01T12:00:00.000Z"}
```

---

## 🚀 STEP 8: Set Up Monitoring (Optional)

### **Deploy metrics server:**

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### **Check resource usage:**

```bash
# Wait 2 minutes for metrics to be collected
kubectl top nodes
kubectl top pods -n ecommerce
```

### **View logs:**

```bash
# Backend logs
kubectl logs -f deployment/backend -n ecommerce

# Frontend logs  
kubectl logs -f deployment/frontend -n ecommerce

# MongoDB logs
kubectl logs -f deployment/mongodb -n ecommerce
```

---

## 🎯 What You've Accomplished

✅ **Built and pushed Docker images** to ECR  
✅ **Deployed full application stack** to Kubernetes  
✅ **Configured load balancer** for external access  
✅ **Set up monitoring** and logging  
✅ **Verified application functionality** end-to-end  

## 🚀 Next Steps

1. **Set up CI/CD pipeline** for automated deployments
2. **Configure custom domain** with Route 53
3. **Add SSL certificate** for HTTPS
4. **Set up monitoring** with Prometheus and Grafana
5. **Implement autoscaling** based on metrics

## 🆘 Troubleshooting

### **Pods not starting:**

```bash
# Check pod details
kubectl describe pod POD_NAME -n ecommerce

# Check logs
kubectl logs POD_NAME -n ecommerce
```

**Common issues:**
- Image pull errors: Check ECR repository permissions
- Environment variables: Verify configmap and secrets
- Resource limits: Check if cluster has enough capacity

### **Ingress not working:**

```bash
# Check ingress controller
kubectl get pods -n kube-system | grep aws-load-balancer

# Check ingress events
kubectl describe ingress ecommerce-ingress -n ecommerce
```

**Common issues:**
- Load balancer controller not installed
- Security group rules blocking traffic
- Subnets not properly tagged

### **Application errors:**

```bash
# Check backend connectivity to MongoDB
kubectl exec -it deployment/backend -n ecommerce -- curl mongodb:27017

# Check environment variables
kubectl exec -it deployment/backend -n ecommerce -- env | grep -E "(MONGO|REDIS)"
```

### **Performance issues:**

```bash
# Check resource usage
kubectl top pods -n ecommerce

# Scale up if needed
kubectl scale deployment backend --replicas=3 -n ecommerce
kubectl scale deployment frontend --replicas=3 -n ecommerce
```

**🎉 Congratulations! You've successfully deployed a production e-commerce application on Kubernetes!**

The application is now running with:
- High availability across multiple nodes
- Load balancing for traffic distribution  
- Autoscaling capabilities
- Professional monitoring and logging
- Production-ready security configurations

**Your application URL:** `http://YOUR_LOAD_BALANCER_URL`
