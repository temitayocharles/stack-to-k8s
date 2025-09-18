#!/bin/bash

# 🚀 DEPLOY ADVANCED KUBERNETES FEATURES ACROSS ALL APPLICATIONS
# Modular deployment script for enterprise-grade Kubernetes features

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Application configurations (simplified for compatibility)
APPS="ecommerce-app:ecommerce task-management-app:taskmanager educational-platform:education medical-care-system:medical weather-app:weather social-media-platform:social"

# Feature categories
FEATURES=(
    "autoscaling"
    "network-policies"
    "pod-disruption-budgets"
    "resource-management"
    "security"
)

# Function to generate HPA for any application
generate_hpa() {
    local app_name=$1
    local app_prefix=$2
    local backend_port=${3:-5000}
    local frontend_port=${4:-80}
    
    cat > "${app_name}/k8s/advanced-features/autoscaling/hpa.yaml" << EOF
# 🚀 HORIZONTAL POD AUTOSCALER (HPA) CONFIGURATION
# Automatic scaling based on CPU and memory usage for ${app_name}

---
# Horizontal Pod Autoscaler for Backend
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ${app_prefix}-backend-hpa
  namespace: ${app_prefix}-production
  labels:
    app: ${app_prefix}-backend
    tier: production
    version: v1.0.0
    component: autoscaling
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${app_prefix}-backend
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
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 25
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Max

---
# Horizontal Pod Autoscaler for Frontend
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ${app_prefix}-frontend-hpa
  namespace: ${app_prefix}-production
  labels:
    app: ${app_prefix}-frontend
    tier: production
    version: v1.0.0
    component: autoscaling
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${app_prefix}-frontend
  minReplicas: 2
  maxReplicas: 10
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
        averageUtilization: 75
EOF
}

# Function to generate Network Policies for any application
generate_network_policies() {
    local app_name=$1
    local app_prefix=$2
    local backend_port=${3:-5000}
    local db_port=${4:-27017}
    
    cat > "${app_name}/k8s/advanced-features/network-policies/network-segmentation.yaml" << EOF
# 🛡️ NETWORK POLICIES FOR MICRO-SEGMENTATION
# Zero-trust network security for ${app_name} production workloads

---
# Network Policy - Backend Security
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ${app_prefix}-backend-network-policy
  namespace: ${app_prefix}-production
  labels:
    app: ${app_prefix}-backend
    tier: production
    component: security
spec:
  podSelector:
    matchLabels:
      app: ${app_prefix}-backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: ${app_prefix}-frontend
    - podSelector:
        matchLabels:
          app: nginx-ingress
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: ${backend_port}
    - protocol: TCP
      port: 8080  # Health check port
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: ${db_port}
  - to: []  # Allow DNS
    ports:
    - protocol: UDP
      port: 53
  - to: []  # Allow HTTPS outbound for external APIs
    ports:
    - protocol: TCP
      port: 443

---
# Network Policy - Frontend Security
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ${app_prefix}-frontend-network-policy
  namespace: ${app_prefix}-production
  labels:
    app: ${app_prefix}-frontend
    tier: production
    component: security
spec:
  podSelector:
    matchLabels:
      app: ${app_prefix}-frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - podSelector:
        matchLabels:
          app: nginx-ingress
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: ${app_prefix}-backend
    ports:
    - protocol: TCP
      port: ${backend_port}
  - to: []  # Allow DNS
    ports:
    - protocol: UDP
      port: 53

---
# Network Policy - Database Security
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ${app_prefix}-database-network-policy
  namespace: ${app_prefix}-production
  labels:
    app: database
    tier: production
    component: security
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: ${app_prefix}-backend
    - namespaceSelector:
        matchLabels:
          name: monitoring  # For Prometheus monitoring
    ports:
    - protocol: TCP
      port: ${db_port}
  egress:
  - to: []  # Allow DNS
    ports:
    - protocol: UDP
      port: 53
EOF
}

# Function to generate Pod Disruption Budgets
generate_pdb() {
    local app_name=$1
    local app_prefix=$2
    
    cat > "${app_name}/k8s/advanced-features/pod-disruption-budgets/pdb.yaml" << EOF
# 🔒 POD DISRUPTION BUDGETS (PDB)
# Ensure high availability during cluster maintenance for ${app_name}

---
# Pod Disruption Budget for Backend
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ${app_prefix}-backend-pdb
  namespace: ${app_prefix}-production
  labels:
    app: ${app_prefix}-backend
    tier: production
    component: reliability
spec:
  selector:
    matchLabels:
      app: ${app_prefix}-backend
  minAvailable: 2
  maxUnavailable: 1

---
# Pod Disruption Budget for Frontend
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ${app_prefix}-frontend-pdb
  namespace: ${app_prefix}-production
  labels:
    app: ${app_prefix}-frontend
    tier: production
    component: reliability
spec:
  selector:
    matchLabels:
      app: ${app_prefix}-frontend
  minAvailable: 1
  maxUnavailable: 50%

---
# Pod Disruption Budget for Database
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ${app_prefix}-database-pdb
  namespace: ${app_prefix}-production
  labels:
    app: database
    tier: production
    component: reliability
spec:
  selector:
    matchLabels:
      app: database
  minAvailable: 1
  maxUnavailable: 0
EOF
}

# Function to generate Resource Management
generate_resource_management() {
    local app_name=$1
    local app_prefix=$2
    
    cat > "${app_name}/k8s/advanced-features/resource-management/quotas-limits.yaml" << EOF
# 📊 RESOURCE MANAGEMENT & QUOTAS
# Prevent resource starvation for ${app_name}

---
# Resource Quotas for Production Namespace
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ${app_prefix}-production-quota
  namespace: ${app_prefix}-production
  labels:
    tier: production
    component: resource-management
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "20"
    persistentvolumeclaims: "10"
    services: "10"
    secrets: "20"
    configmaps: "20"

---
# Limit Range for Production Namespace
apiVersion: v1
kind: LimitRange
metadata:
  name: ${app_prefix}-production-limits
  namespace: ${app_prefix}-production
  labels:
    tier: production
    component: resource-management
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
  - max:
      cpu: 2
      memory: 4Gi
    min:
      cpu: 50m
      memory: 64Mi
    type: Container
  - max:
      storage: 10Gi
    min:
      storage: 1Gi
    type: PersistentVolumeClaim

---
# Priority Class for Critical Workloads
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: ${app_prefix}-critical
  labels:
    tier: production
    component: resource-management
value: 1000
globalDefault: false
description: "Critical ${app_name} workloads with high priority"
EOF
}

# Function to generate Security Policies
generate_security() {
    local app_name=$1
    local app_prefix=$2
    
    cat > "${app_name}/k8s/advanced-features/security/rbac-policies.yaml" << EOF
# 🔐 SECURITY POLICIES & RBAC
# Role-based access control for ${app_name}

---
# Cluster Role for Advanced Monitoring
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${app_prefix}-monitoring
  labels:
    app: ${app_prefix}
    tier: production
    component: security
rules:
- apiGroups: [""]
  resources: ["nodes", "pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["extensions"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]

---
# Service Account for Monitoring
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${app_prefix}-monitoring
  namespace: ${app_prefix}-production
  labels:
    app: ${app_prefix}
    tier: production
    component: security

---
# Cluster Role Binding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${app_prefix}-monitoring
  labels:
    app: ${app_prefix}
    tier: production
    component: security
subjects:
- kind: ServiceAccount
  name: ${app_prefix}-monitoring
  namespace: ${app_prefix}-production
roleRef:
  kind: ClusterRole
  name: ${app_prefix}-monitoring
  apiGroup: rbac.authorization.k8s.io

---
# Pod Security Policy (for clusters that support it)
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ${app_prefix}-restricted
  labels:
    app: ${app_prefix}
    tier: production
    component: security
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
EOF
}

# Function to generate README for each application
generate_readme() {
    local app_name=$1
    local app_prefix=$2
    
    if [ "$app_name" != "ecommerce-app" ]; then
        cp "ecommerce-app/k8s/advanced-features/README.md" "${app_name}/k8s/advanced-features/README.md"
        
        # Customize README for the specific application
        sed -i '' "s/ecommerce/${app_prefix}/g" "${app_name}/k8s/advanced-features/README.md"
        sed -i '' "s/Ecommerce/$(echo ${app_name} | sed 's/-/ /g' | sed 's/\b\w/\u&/g')/g" "${app_name}/k8s/advanced-features/README.md"
    fi
}

# Main execution
echo -e "${CYAN}🚀 GENERATING ADVANCED KUBERNETES FEATURES FOR ALL APPLICATIONS${NC}"
echo "============================================================="

for app_pair in $APPS; do
    app_name=$(echo $app_pair | cut -d: -f1)
    app_prefix=$(echo $app_pair | cut -d: -f2)
    
    echo -e "\n${BLUE}📦 Processing: ${app_name} (prefix: ${app_prefix})${NC}"
    
    if [ -d "${app_name}/k8s/advanced-features" ]; then
        echo -e "${YELLOW}  🔧 Generating HPA...${NC}"
        generate_hpa "$app_name" "$app_prefix"
        
        echo -e "${YELLOW}  🛡️  Generating Network Policies...${NC}"
        generate_network_policies "$app_name" "$app_prefix"
        
        echo -e "${YELLOW}  🔒 Generating Pod Disruption Budgets...${NC}"
        generate_pdb "$app_name" "$app_prefix"
        
        echo -e "${YELLOW}  📊 Generating Resource Management...${NC}"
        generate_resource_management "$app_name" "$app_prefix"
        
        echo -e "${YELLOW}  🔐 Generating Security Policies...${NC}"
        generate_security "$app_name" "$app_prefix"
        
        echo -e "${YELLOW}  📖 Generating README...${NC}"
        generate_readme "$app_name" "$app_prefix"
        
        echo -e "${GREEN}  ✅ ${app_name} advanced features generated successfully!${NC}"
    else
        echo -e "${RED}  ❌ Skipped: ${app_name}/k8s/advanced-features directory not found${NC}"
    fi
done

echo -e "\n${GREEN}🎉 ADVANCED KUBERNETES FEATURES GENERATION COMPLETE!${NC}"
echo "============================================================="
echo -e "${MAGENTA}📁 Generated features for each application:${NC}"
echo "  • Horizontal Pod Autoscaler (HPA)"
echo "  • Network Policies (Zero-trust security)"
echo "  • Pod Disruption Budgets (High availability)"
echo "  • Resource Management (Quotas & Limits)"
echo "  • Security Policies (RBAC & PSP)"
echo ""
echo -e "${CYAN}🚀 Next steps:${NC}"
echo "  1. Review generated configurations"
echo "  2. Customize for your specific needs"
echo "  3. Deploy selectively using provided commands"
echo ""
echo -e "${YELLOW}📖 Documentation: Check each app's k8s/advanced-features/README.md${NC}"