# AWS Console Setup Guide - E-commerce Platform

> **🎯 Step-by-Step Manual Setup for Budget-Conscious Users**  
> This guide shows you exactly where to click and what to configure in the AWS Console.

## 📋 What You'll Build

- ✅ **EKS Kubernetes Cluster** for container orchestration
- ✅ **VPC with public/private subnets** for network isolation  
- ✅ **Application Load Balancer** for traffic distribution
- ✅ **ElastiCache Redis** for caching and sessions
- ✅ **ECR Repositories** for Docker images
- ✅ **S3 Bucket** for static assets

---

## 🚀 STEP 1: Create Your VPC

### **Next, you do this:**
1. **Click** on the AWS Console search bar
2. **Type** "VPC" and press Enter
3. **You will see** the VPC Dashboard

### **Create the VPC:**
1. **Click** the blue "Create VPC" button
2. **You will see** the VPC creation form
3. **Select** "VPC and more" (this creates everything at once)
4. **Fill in these values:**
   - **Name tag**: `ecommerce-vpc`
   - **IPv4 CIDR block**: `10.0.0.0/16`
   - **Number of Availability Zones**: `3`
   - **Number of public subnets**: `3`
   - **Number of private subnets**: `3`
   - **NAT gateways**: `In 1 AZ` (saves money)
   - **VPC endpoints**: `None`

5. **Click** "Create VPC"
6. **You will see** a progress screen
7. **Wait** 2-3 minutes until you see "VPC created successfully"

### **If you see an error:**
- Go back to STEP 1 and check your CIDR block
- Make sure you selected the correct region (top-right corner)

---

## 🚀 STEP 2: Create EKS Cluster

### **Next, you do this:**
1. **Click** the search bar and type "EKS"
2. **Click** on "Elastic Kubernetes Service"
3. **You will see** the EKS Dashboard

### **Create the Cluster:**
1. **Click** "Add cluster" → "Create"
2. **You will see** the cluster configuration page

### **Configure Basic Settings:**
1. **Name**: Type `ecommerce-cluster`
2. **Kubernetes version**: Select `1.28`
3. **Cluster service role**: 
   - **If you don't have one**, click "Create role"
   - **You will be redirected** to IAM
   - **Select** "EKS - Cluster" 
   - **Click** "Next" → "Next" → "Create role"
   - **Go back** to EKS and refresh the dropdown
4. **Click** "Next"

### **Configure Networking:**
1. **VPC**: Select `ecommerce-vpc` (the one you just created)
2. **Subnets**: Select ALL private subnets (should be 3)
3. **Security groups**: Leave default
4. **Cluster endpoint access**: Select "Public and private"
5. **Click** "Next"

### **Configure Logging (Optional):**
1. **You can skip this** for now to save costs
2. **Click** "Next"

### **Review and Create:**
1. **Review** all settings
2. **Click** "Create"
3. **You will see** "Creating cluster..."
4. **Wait** 10-15 minutes (grab a coffee! ☕)

### **If cluster creation fails:**
- Check if you have the correct IAM permissions
- Verify your VPC has internet access through NAT gateway
- Go back to STEP 2 and try again

---

## 🚀 STEP 3: Create Node Group

### **After cluster is ready:**
1. **Click** on your cluster name `ecommerce-cluster`
2. **You will see** the cluster details page
3. **Click** the "Compute" tab
4. **Click** "Add node group"

### **Configure Node Group:**
1. **Name**: Type `main-nodes`
2. **Node IAM role**:
   - **Click** "Create role" if you don't have one
   - **Select** "EC2" service
   - **Search and attach** these policies:
     - `AmazonEKSWorkerNodePolicy`
     - `AmazonEKS_CNI_Policy`
     - `AmazonEC2ContainerRegistryReadOnly`
   - **Click** "Create role"
   - **Go back** and select the role

3. **Click** "Next"

### **Set Compute Configuration:**
1. **AMI type**: Amazon Linux 2 (AL2_x86_64)
2. **Capacity type**: On-Demand
3. **Instance types**: t3.medium
4. **Disk size**: 20 GB
5. **Click** "Next"

### **Set Scaling Configuration:**
1. **Desired size**: 2
2. **Minimum size**: 1  
3. **Maximum size**: 4
4. **Click** "Next"

### **Specify Networking:**
1. **Subnets**: Select your private subnets
2. **Allow remote access**: Enable
3. **EC2 Key Pair**: Select your key pair (create one if needed)
4. **Click** "Next"

### **Review and Create:**
1. **Click** "Create"
2. **Wait** 5-10 minutes for nodes to be ready

---

## 🚀 STEP 4: Create ElastiCache Redis

### **Next, you do this:**
1. **Type** "ElastiCache" in the search bar
2. **Click** on "ElastiCache"
3. **You will see** the ElastiCache dashboard

### **Create Redis Cluster:**
1. **Click** "Create" 
2. **Select** "Redis"
3. **Choose** "Configure and create a new cluster"

### **Configure Cluster Settings:**
1. **Name**: `ecommerce-redis`
2. **Description**: `Redis cache for e-commerce platform`
3. **Port**: `6379` (default)
4. **Parameter group**: default.redis7.x
5. **Node type**: cache.t3.micro (cheapest option)
6. **Number of replicas**: 1

### **Configure Advanced Settings:**
1. **Subnet group**: 
   - **Click** "Create new"
   - **Name**: `ecommerce-subnet-group`
   - **VPC**: Select `ecommerce-vpc`
   - **Subnets**: Select all private subnets
   - **Click** "Create"

2. **Security groups**:
   - **Click** "Create new"
   - **Name**: `ecommerce-redis-sg`
   - **VPC**: Select `ecommerce-vpc`
   - **Add inbound rule**:
     - Type: Custom TCP
     - Port: 6379
     - Source: VPC CIDR (10.0.0.0/16)

### **Create the Cluster:**
1. **Click** "Create"
2. **Wait** 5-10 minutes for creation
3. **Copy the endpoint** when ready - you'll need this later

---

## 🚀 STEP 5: Create ECR Repositories

### **Next, you do this:**
1. **Search** for "ECR" in the console
2. **Click** "Elastic Container Registry"
3. **You will see** the ECR dashboard

### **Create Backend Repository:**
1. **Click** "Create repository"
2. **Repository name**: `ecommerce/backend`
3. **Tag immutability**: Mutable
4. **Scan on push**: Enable
5. **Click** "Create repository"

### **Create Frontend Repository:**
1. **Click** "Create repository" again
2. **Repository name**: `ecommerce/frontend`  
3. **Tag immutability**: Mutable
4. **Scan on push**: Enable
5. **Click** "Create repository"

### **Copy the repository URIs:**
- **You will need** these URIs for pushing Docker images
- **Click** on each repository name to see the URI
- **Copy** both URIs to a notepad

---

## 🚀 STEP 6: Create S3 Bucket

### **Next, you do this:**
1. **Search** for "S3" in the console
2. **Click** on "S3"
3. **Click** "Create bucket"

### **Configure the Bucket:**
1. **Bucket name**: `ecommerce-assets-[your-name]-[random-number]`
   - **Note**: Must be globally unique
   - **Example**: `ecommerce-assets-john-12345`
2. **Region**: Same as your EKS cluster
3. **Block Public Access**: Keep all boxes checked
4. **Versioning**: Enable
5. **Encryption**: Enable (Server-side encryption)

### **Create the Bucket:**
1. **Click** "Create bucket"
2. **You will see** "Successfully created bucket"

---

## 🚀 STEP 7: Create Application Load Balancer

### **Next, you do this:**
1. **Search** for "EC2" in the console
2. **Click** on "EC2"
3. **In the left menu**, click "Load Balancers"

### **Create the Load Balancer:**
1. **Click** "Create Load Balancer"
2. **Select** "Application Load Balancer"
3. **Click** "Create"

### **Configure Basic Settings:**
1. **Name**: `ecommerce-alb`
2. **Scheme**: Internet-facing
3. **IP address type**: IPv4

### **Network Mapping:**
1. **VPC**: Select `ecommerce-vpc`
2. **Availability Zones**: Select all 3 AZs
3. **Subnets**: Select the PUBLIC subnets for each AZ

### **Security Groups:**
1. **Click** "Create new security group"
2. **Name**: `ecommerce-alb-sg`
3. **Description**: Security group for e-commerce ALB
4. **VPC**: Select `ecommerce-vpc`
5. **Add inbound rules**:
   - HTTP (80) from 0.0.0.0/0
   - HTTPS (443) from 0.0.0.0/0
6. **Click** "Create security group"
7. **Go back** and select this security group

### **Listeners and Routing:**
1. **Keep** default HTTP:80 listener
2. **Target group**: Create new
   - **Name**: `ecommerce-targets`
   - **Target type**: IP addresses
   - **Protocol**: HTTP
   - **Port**: 80
   - **VPC**: `ecommerce-vpc`
   - **Click** "Create target group"

### **Create the Load Balancer:**
1. **Click** "Create load balancer"
2. **Wait** 2-3 minutes for it to become active
3. **Copy the DNS name** - you'll need this

---

## 🚀 STEP 8: Configure kubectl Access

### **Install AWS CLI (if not installed):**
```bash
# Copy this command and run in terminal:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### **Configure AWS credentials:**
```bash
# Copy this command:
aws configure

# You will be prompted to enter:
# AWS Access Key ID: [Your access key]
# AWS Secret Access Key: [Your secret key] 
# Default region name: us-west-2 (or your region)
# Default output format: json
```

### **Configure kubectl:**
```bash
# Copy this command (replace with your region and cluster name):
aws eks update-kubeconfig --region us-west-2 --name ecommerce-cluster

# Test the connection:
kubectl get nodes
# You should see your worker nodes listed
```

---

## 🎯 What You've Accomplished

✅ **VPC with proper networking** - Isolated environment for your application  
✅ **EKS cluster with worker nodes** - Container orchestration platform  
✅ **Redis cache** - High-performance data store for sessions  
✅ **ECR repositories** - Secure Docker image storage  
✅ **S3 bucket** - Object storage for static assets  
✅ **Application Load Balancer** - Traffic distribution and SSL termination  
✅ **kubectl access** - Command-line access to your cluster  

## 🚀 Next Steps

1. **Deploy the application** using the Kubernetes manifests
2. **Push Docker images** to your ECR repositories  
3. **Configure DNS** to point to your load balancer
4. **Set up monitoring** with Prometheus and Grafana

## 💰 Cost Optimization Tips

- **Use t3.micro instances** for development
- **Stop the cluster** when not in use
- **Use Spot instances** for worker nodes (advanced)
- **Set up billing alerts** to monitor costs

## 🆘 Troubleshooting

### **If kubectl doesn't work:**
1. Check your AWS credentials: `aws sts get-caller-identity`
2. Verify cluster is active in EKS console
3. Make sure you're in the correct region

### **If nodes don't join cluster:**
1. Check the node group IAM role has required policies
2. Verify nodes are in private subnets
3. Check security group rules

### **If you get access denied:**
1. Your IAM user needs EKS permissions
2. Add the IAM user to the cluster's access config
3. Check AWS credentials are correctly configured

**🎉 Congratulations! You've manually created a production-ready Kubernetes infrastructure on AWS!**
