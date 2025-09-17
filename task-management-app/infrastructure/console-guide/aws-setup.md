# 🚀 AWS Console Setup Guide - Task Management App
## Go + Svelte + CouchDB Architecture

## 🎯 What You'll Build
- **EKS Cluster** for Kubernetes orchestration
- **CouchDB Database** for document storage
- **Load Balancer** for high availability
- **Monitoring** with CloudWatch

## ⏱️ Time Required: 45 minutes

---

## 📋 Prerequisites Checklist
- [ ] AWS Account with billing enabled
- [ ] IAM user with AdministratorAccess
- [ ] `kubectl` installed on your machine
- [ ] `eksctl` installed on your machine

---

## 🏗️ Step 1: Create VPC and Networking (10 minutes)

### **1.1 Navigate to VPC Dashboard**
1. **Go to**: [AWS VPC Console](https://console.aws.amazon.com/vpc/)
2. **Click**: "Create VPC"
3. **Select**: "VPC and more"

### **1.2 Configure VPC Settings**
```
VPC Name: task-management-vpc
IPv4 CIDR: 10.0.0.0/16
Availability Zones: 2
Public Subnets: 2
Private Subnets: 2
NAT Gateways: 1 per AZ
VPC Endpoints: None
```

4. **Click**: "Create VPC"
5. **Wait**: 3-5 minutes for creation
6. **Expected Result**: VPC with subnets created

**✅ Success Check**: You should see "VPC Created Successfully"

---

## 🎯 Step 2: Create EKS Cluster (15 minutes)

### **2.1 Navigate to EKS**
1. **Go to**: [AWS EKS Console](https://console.aws.amazon.com/eks/)
2. **Click**: "Create cluster"

### **2.2 Configure Cluster**
```
Cluster Name: task-management-cluster
Kubernetes Version: 1.28
Cluster Service Role: Create new role
```

3. **Networking**:
   - **VPC**: Select your task-management-vpc
   - **Subnets**: Select all private and public subnets
   - **Security Groups**: Default

4. **Configure Logging**: Enable all log types
5. **Click**: "Create"

**⏳ Wait Time**: 10-15 minutes

### **2.3 Add Node Group**
1. **Click**: "Add node group"
2. **Configure**:
```
Node Group Name: task-management-nodes
AMI Type: Amazon Linux 2
Instance Types: m5.large
Scaling: Min 2, Max 6, Desired 3
```

---

## 💾 Step 3: Setup CouchDB (10 minutes)

### **3.1 Create EC2 Instance for CouchDB**
1. **Go to**: [EC2 Console](https://console.aws.amazon.com/ec2/)
2. **Click**: "Launch Instance"
3. **Configure**:
```
Name: task-management-couchdb
AMI: Amazon Linux 2
Instance Type: t3.medium
Key Pair: Create or select existing
Security Group: Allow port 5984
Subnet: Private subnet
```

### **3.2 Install CouchDB**
Connect via SSM or SSH and run:
```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install CouchDB
docker run -d --name couchdb \
  -p 5984:5984 \
  -e COUCHDB_USER=admin \
  -e COUCHDB_PASSWORD=YourSecurePassword123! \
  -v couchdb-data:/opt/couchdb/data \
  couchdb:3.3
```

---

## 🔧 Step 4: Configure kubectl (5 minutes)

### **4.1 Update kubeconfig**
```bash
aws eks update-kubeconfig --region us-east-1 --name task-management-cluster
```

### **4.2 Verify Connection**
```bash
kubectl get nodes
```

**Expected Result**: Should show your EKS nodes

---

## 🚀 Step 5: Deploy Application (5 minutes)

### **5.1 Apply Kubernetes Manifests**
```bash
# Navigate to your project
cd task-management-app

# Apply configurations
kubectl apply -f k8s/base/
kubectl apply -f k8s/production/
```

### **5.2 Check Deployment Status**
```bash
kubectl get pods -n task-management
kubectl get services -n task-management
```

---

## 🔍 Step 6: Verify Everything Works

### **6.1 Get Load Balancer URL**
```bash
kubectl get ingress -n task-management
```

### **6.2 Test Application**
1. **Copy the URL** from ingress output
2. **Open in browser**
3. **Expected**: Task management interface loads

---

## 🆘 Troubleshooting

### **Common Issues**

#### **"Cluster Creation Failed"**
- **Check**: IAM permissions
- **Solution**: Ensure AdministratorAccess policy attached

#### **"Nodes Not Joining"**
- **Check**: Security groups allow communication
- **Solution**: Verify node group IAM role has required policies

#### **"CouchDB Connection Failed"**
- **Check**: Security group allows port 5984
- **Solution**: Add inbound rule for port 5984

#### **"kubectl Access Denied"**
- **Check**: Your IAM user has EKS permissions
- **Solution**: Add user to aws-auth ConfigMap

---

## 💰 Cost Breakdown (Monthly USD)
- **EKS Cluster**: $73
- **EC2 Nodes (3 x m5.large)**: ~$195
- **CouchDB Instance (t3.medium)**: ~$30
- **NAT Gateway**: ~$45
- **Load Balancer**: ~$18
- **Total**: ~$361/month

## 🧹 Cleanup Instructions

### **To Delete Everything**:
```bash
# Delete Kubernetes resources
kubectl delete -f k8s/production/
kubectl delete -f k8s/base/

# Delete EKS cluster
eksctl delete cluster --name task-management-cluster

# Delete CouchDB instance via EC2 console
# Delete VPC via VPC console (after all resources are removed)
```

---

## 🎓 What You Learned
- ✅ VPC and networking setup
- ✅ EKS cluster creation and management
- ✅ CouchDB database deployment
- ✅ Kubernetes application deployment
- ✅ Production monitoring setup

**🏆 You now have a production-ready task management platform running on AWS!**
