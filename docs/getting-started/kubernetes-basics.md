# ☸️ Kubernetes Basics - Learn Core Concepts

**Goal**: Understand fundamental Kubernetes concepts through hands-on practice.

> **Perfect for**: "I want to understand what I'm actually doing"

## 🎯 What You'll Learn
- ✅ What Kubernetes is and why it's useful
- ✅ Core concepts: Pods, Services, Deployments
- ✅ How to deploy applications step-by-step
- ✅ Basic troubleshooting and debugging

## 📋 Before You Start
**Required time**: 45 minutes  
**Prerequisites**: [First application](first-app.md) completed successfully

## 🚀 Understanding Kubernetes

### What is Kubernetes?
Think of Kubernetes as a **smart container manager** that:
- ✅ **Keeps your apps running** - Restarts crashed containers
- ✅ **Scales automatically** - Adds more containers when busy
- ✅ **Distributes traffic** - Routes users to healthy containers
- ✅ **Updates safely** - Replaces old versions without downtime

### Why Use Kubernetes?
**Docker Compose** is great for single machines, but **Kubernetes** handles:
- **Multiple servers** - Run across many computers
- **High availability** - No single point of failure  
- **Auto-scaling** - Handle traffic spikes automatically
- **Rolling updates** - Update without downtime

## 🏗️ Core Concepts Explained

### 1. Pods (The Basic Unit)
```bash
# A Pod is like a "container home" - usually one app per Pod
# Think: One house (Pod) = One family (container)
```

**Example**: Your e-commerce app frontend runs in one Pod

### 2. Services (The Phone Book)
```bash
# A Service gives your Pods a stable address
# Think: Like a phone number that always reaches the right person
```

**Example**: No matter which Pod handles your request, the Service finds it

### 3. Deployments (The Manager)
```bash
# A Deployment manages your Pods
# Think: Like a supervisor ensuring the right number of workers
```

**Example**: If a Pod crashes, Deployment creates a new one

## 🚀 Hands-On Practice

### Step 1: Look at Kubernetes Files
```bash
cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/ecommerce-app
ls k8s/
```

**You will see**: YAML files that describe your application to Kubernetes

### Step 2: Examine a Deployment
```bash
cat k8s/frontend-deployment.yaml
```

**Key parts to notice**:
- `replicas: 2` - Run 2 copies of the frontend
- `image: frontend:latest` - Which container to run
- `ports: 3000` - Which port the app uses

### Step 3: Deploy to Kubernetes
```bash
# Make sure Kubernetes is running
kubectl cluster-info

# Deploy the application
kubectl apply -f k8s/
```

**What happens**: Kubernetes reads your YAML files and creates everything

### Step 4: Watch It Start
```bash
# See Pods being created
kubectl get pods -w

# Press Ctrl+C when all show "Running"
```

### Step 5: Access Your Application
```bash
# Forward port to access the app
kubectl port-forward service/ecommerce-frontend 3001:80

# Open browser to http://localhost:3001
```

## 🔍 Understanding What Happened

### Check Your Deployments
```bash
kubectl get deployments
```
**You'll see**: How many replicas are running vs desired

### Check Your Services  
```bash
kubectl get services
```
**You'll see**: How Kubernetes exposes your applications

### Check Your Pods
```bash
kubectl get pods -o wide
```
**You'll see**: Which containers are running and where

## 🧪 Experiment and Learn

### Scale Your Application
```bash
# Increase frontend replicas
kubectl scale deployment ecommerce-frontend --replicas=3

# Watch new Pods start
kubectl get pods -w
```

### Update Your Application
```bash
# Edit the deployment
kubectl edit deployment ecommerce-frontend

# Change replicas or image version, save, and watch updates
```

### View Application Logs
```bash
# See what your app is doing
kubectl logs -f deployment/ecommerce-frontend
```

## 🔄 Clean Up When Done
```bash
# Remove everything
kubectl delete -f k8s/

# Verify cleanup
kubectl get all
```

## 🎉 Congratulations!

You've learned the fundamentals:
- ✅ **Pods** run your containers
- ✅ **Services** provide stable networking
- ✅ **Deployments** manage Pod lifecycle
- ✅ **kubectl** is your control tool

## ➡️ What's Next?

✅ **Ready for advanced features?** → [Advanced Kubernetes](../kubernetes/advanced-features.md)  
✅ **Want production setup?** → [Enterprise deployment](enterprise-setup.md)  
✅ **Need troubleshooting?** → [Common Kubernetes issues](../troubleshooting/kubernetes-issues.md)

## 🆘 Common Kubernetes Questions

**"My Pod is Pending"**
- Check: `kubectl describe pod <pod-name>`
- Usually: Resource constraints or image pull issues

**"Service not accessible"**  
- Check: `kubectl get endpoints`
- Usually: Service selector doesn't match Pod labels

**"Update not working"**
- Check: `kubectl rollout status deployment/<name>`
- Usually: Image tag or configuration error

---

**Great job!** You now understand the building blocks that make Kubernetes so powerful for running applications at scale.