# 🚀 ADVANCED KUBERNETES FEATURES - DEPLOYMENT GUIDE

## 📋 Feature Categories

Each advanced feature is organized into separate folders for **modular deployment**:

### 🔧 **Autoscaling** (`autoscaling/`)
- **HPA (Horizontal Pod Autoscaler)**: Automatic scaling based on CPU/memory
- **VPA (Vertical Pod Autoscaler)**: Automatic resource allocation optimization
- **Usage**: Deploy when you need automatic scaling under load

### 🛡️ **Network Policies** (`network-policies/`)
- **Micro-segmentation**: Zero-trust network security
- **Traffic Control**: Ingress/egress rules for pods
- **Usage**: Deploy for production security and compliance

### 🔒 **Pod Disruption Budgets** (`pod-disruption-budgets/`)
- **High Availability**: Ensure minimum replicas during maintenance
- **Graceful Failures**: Controlled pod termination
- **Usage**: Deploy for production reliability

### 📊 **Resource Management** (`resource-management/`)
- **Resource Quotas**: Namespace-level resource limits
- **Limit Ranges**: Pod-level resource constraints
- **Priority Classes**: Workload prioritization
- **Usage**: Deploy for resource governance

### 🔐 **Security** (`security/`)
- **RBAC**: Role-based access control
- **Pod Security Policies**: Security constraints
- **Service Accounts**: Identity management
- **Usage**: Deploy for security compliance

## 🎯 **Selective Deployment Options**

### **Option 1: Deploy Everything**
```bash
kubectl apply -f k8s/advanced-features/ -R
```

### **Option 2: Deploy Specific Features**
```bash
# Deploy only autoscaling
kubectl apply -f k8s/advanced-features/autoscaling/

# Deploy only network security
kubectl apply -f k8s/advanced-features/network-policies/

# Deploy only reliability features
kubectl apply -f k8s/advanced-features/pod-disruption-budgets/

# Deploy only resource management
kubectl apply -f k8s/advanced-features/resource-management/

# Deploy only security policies
kubectl apply -f k8s/advanced-features/security/
```

### **Option 3: Custom Combination**
```bash
# Deploy reliability + security
kubectl apply -f k8s/advanced-features/pod-disruption-budgets/
kubectl apply -f k8s/advanced-features/security/

# Deploy performance + resource management
kubectl apply -f k8s/advanced-features/autoscaling/
kubectl apply -f k8s/advanced-features/resource-management/
```

## 📈 **Progressive Deployment Strategy**

### **Phase 1: Basic Production** (Minimum viable production)
```bash
kubectl apply -f k8s/advanced-features/pod-disruption-budgets/
kubectl apply -f k8s/advanced-features/resource-management/
```

### **Phase 2: Security Hardening**
```bash
kubectl apply -f k8s/advanced-features/security/
kubectl apply -f k8s/advanced-features/network-policies/
```

### **Phase 3: Performance Optimization**
```bash
kubectl apply -f k8s/advanced-features/autoscaling/
```

## 🎛️ **Configuration Customization**

Each feature folder contains:
- **README.md**: Feature-specific documentation
- **values.yaml**: Customizable parameters
- **examples/**: Usage examples and scenarios

## 📊 **Monitoring Integration**

All features include:
- ✅ **Prometheus metrics**: Performance monitoring
- ✅ **Grafana dashboards**: Visual monitoring
- ✅ **AlertManager rules**: Proactive alerting
- ✅ **Service monitors**: Automatic discovery

## 🔧 **Troubleshooting**

### Common Issues:
1. **Network policies too restrictive**: Check pod-to-pod communication
2. **HPA not scaling**: Verify metrics-server installation
3. **PDB blocking updates**: Adjust minAvailable settings
4. **Resource quotas exceeded**: Review namespace limits

### Debug Commands:
```bash
# Check HPA status
kubectl get hpa -n social-production

# Verify network policies
kubectl describe networkpolicy -n social-production

# Check pod disruption budgets
kubectl get pdb -n social-production

# Review resource quotas
kubectl describe quota -n social-production
```