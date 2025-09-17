# Jenkins CI/CD Setup Guide - E-commerce Platform

> **🔧 Complete Jenkins Configuration for Kubernetes Deployment**  
> This guide shows you how to set up Jenkins for automated CI/CD pipelines.

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ **Jenkins server** running (can be on EC2, local, or Docker)
- ✅ **kubectl access** to your EKS cluster
- ✅ **AWS CLI configured** with proper permissions
- ✅ **Docker installed** on Jenkins agent

---

## 🚀 STEP 1: Install Required Jenkins Plugins

### **Navigate to Plugin Manager:**

1. **Login** to your Jenkins dashboard
2. **Click** "Manage Jenkins" in the left sidebar
3. **Click** "Manage Plugins"
4. **Click** the "Available" tab

### **Install these essential plugins:**

Search and install each plugin:

- ✅ **Pipeline** - For pipeline-as-code
- ✅ **Pipeline: Stage View** - Visual pipeline representation
- ✅ **Blue Ocean** - Modern UI for pipelines
- ✅ **Docker Pipeline** - Docker integration
- ✅ **Kubernetes** - Kubernetes integration
- ✅ **AWS Steps** - AWS CLI commands in pipeline
- ✅ **CloudBees AWS Credentials** - AWS credential management
- ✅ **Pipeline: AWS Steps** - Advanced AWS operations
- ✅ **Slack Notification** - Team notifications
- ✅ **JUnit** - Test result publishing
- ✅ **Cobertura** - Code coverage reports
- ✅ **SonarQube Scanner** - Code quality analysis
- ✅ **Trivy** - Security vulnerability scanning

### **Install the plugins:**

1. **Check the boxes** for all required plugins
2. **Click** "Install without restart"
3. **Wait** for installation to complete
4. **Check** "Restart Jenkins when installation is complete"

---

## 🚀 STEP 2: Configure Global Tools

### **Configure Node.js:**

1. **Go to** "Manage Jenkins" → "Global Tool Configuration"
2. **Scroll to** "NodeJS" section
3. **Click** "Add NodeJS"
4. **Fill in:**
   - **Name**: `Node-18`
   - **Version**: `18.x` (latest)
   - **Install automatically**: ✅ Checked
5. **Click** "Save"

### **Configure Docker:**

1. **In the same page**, scroll to "Docker" section
2. **Click** "Add Docker"
3. **Fill in:**
   - **Name**: `docker-latest`
   - **Install automatically**: ✅ Checked
   - **Installer**: "Download from docker.com"
4. **Click** "Save"

### **Configure kubectl:**

1. **Scroll to** "Custom Tool" section (if available)
2. **Click** "Add Custom Tool"
3. **Fill in:**
   - **Name**: `kubectl`
   - **Install automatically**: ✅ Checked
   - **Download URL**: `https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl`

---

## 🚀 STEP 3: Set Up Credentials

### **AWS Credentials:**

1. **Go to** "Manage Jenkins" → "Manage Credentials"
2. **Click** "System" → "Global credentials"
3. **Click** "Add Credentials"
4. **Select** "AWS Credentials"
5. **Fill in:**
   - **ID**: `aws-credentials`
   - **Description**: `AWS credentials for EKS and ECR`
   - **Access Key ID**: Your AWS access key
   - **Secret Access Key**: Your AWS secret key
6. **Click** "OK"

### **AWS Account ID:**

1. **Click** "Add Credentials" again
2. **Select** "Secret text"
3. **Fill in:**
   - **Secret**: Your 12-digit AWS account ID
   - **ID**: `aws-account-id`
   - **Description**: `AWS Account ID for ECR`
4. **Click** "OK"

### **Kubeconfig File:**

1. **On your local machine**, get your kubeconfig:

```bash
# Copy your kubeconfig content
cat ~/.kube/config
```

2. **Back in Jenkins**, click "Add Credentials"
3. **Select** "Secret file"
4. **Upload** your kubeconfig file or paste content
5. **Fill in:**
   - **ID**: `kubeconfig-file`
   - **Description**: `Kubeconfig for EKS cluster access`
6. **Click** "OK"

### **Docker Hub Credentials (Optional):**

1. **Click** "Add Credentials"
2. **Select** "Username with password"
3. **Fill in:**
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub token
   - **ID**: `dockerhub-credentials`
   - **Description**: `Docker Hub credentials`

---

## 🚀 STEP 4: Create Pipeline Job

### **Create New Pipeline:**

1. **Click** "New Item" on Jenkins dashboard
2. **Enter** item name: `ecommerce-pipeline`
3. **Select** "Pipeline"
4. **Click** "OK"

### **Configure Pipeline:**

1. **In the configuration page**, scroll to "Pipeline" section
2. **Select** "Pipeline script from SCM"
3. **SCM**: Git
4. **Repository URL**: Your Git repository URL
5. **Credentials**: Add your Git credentials if private repo
6. **Branch**: `*/main` (or your default branch)
7. **Script Path**: `infrastructure/jenkins/Jenkinsfile`

### **Configure Build Triggers:**

1. **Scroll up** to "Build Triggers" section
2. **Check** these options:
   - ✅ **GitHub hook trigger for GITScm polling** (if using GitHub)
   - ✅ **Poll SCM** with schedule: `H/5 * * * *` (every 5 minutes)

### **Save the Pipeline:**

1. **Click** "Save"
2. **You will be** redirected to the pipeline page

---

## 🚀 STEP 5: Set Up GitHub Webhook (Optional)

### **If using GitHub:**

1. **Go to** your GitHub repository
2. **Click** "Settings" tab
3. **Click** "Webhooks" in left sidebar
4. **Click** "Add webhook"
5. **Fill in:**
   - **Payload URL**: `http://your-jenkins-url/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: "Just the push event"
   - **Active**: ✅ Checked
6. **Click** "Add webhook"

---

## 🚀 STEP 6: Configure Slack Notifications (Optional)

### **Set up Slack App:**

1. **Go to** your Slack workspace
2. **Click** workspace name → "Settings & administration" → "Manage apps"
3. **Search** for "Jenkins CI"
4. **Install** the Jenkins app
5. **Get** the webhook URL provided

### **Add Slack credentials in Jenkins:**

1. **In Jenkins**, go to "Manage Credentials"
2. **Add** new "Secret text" credential
3. **Fill in:**
   - **Secret**: Your Slack webhook URL
   - **ID**: `slack-webhook`
   - **Description**: `Slack webhook for notifications`

### **Update Jenkinsfile:**

In your Jenkinsfile, update the Slack channel and webhook:

```groovy
slackSend(
    channel: '#your-deployment-channel',
    // ... rest of the configuration
)
```

---

## 🚀 STEP 7: Test the Pipeline

### **Trigger First Build:**

1. **Go to** your pipeline page
2. **Click** "Build Now"
3. **Watch** the build progress in Blue Ocean view

### **Monitor Build Stages:**

The pipeline will execute these stages:

1. **🚀 Checkout Code** - Downloads source code
2. **🔍 Code Quality & Security** - Runs tests and analysis
3. **🐳 Build Docker Images** - Creates container images
4. **🔒 Security Scanning** - Scans for vulnerabilities
5. **📦 Push to ECR** - Uploads images to registry
6. **🚀 Deploy to Staging** - Deploys to staging environment
7. **🎯 Deploy to Production** - Deploys to production (with approval)

### **Check Build Logs:**

1. **Click** on the build number
2. **Click** "Console Output" to see detailed logs
3. **Use** Blue Ocean for visual pipeline view

---

## 🚀 STEP 8: Set Up Multi-Branch Pipeline (Advanced)

### **For better Git workflow:**

1. **Create** new item: `ecommerce-multibranch`
2. **Select** "Multibranch Pipeline"
3. **Add** Git source with your repository
4. **Configure** branch discovery strategies:
   - Discover branches
   - Discover pull requests from origin
   - Discover pull requests from forks

### **Branch-specific behaviors:**

- **main**: Deploy to production (with approval)
- **develop**: Deploy to staging automatically
- **feature/***: Run tests only
- **release/***: Deploy to staging for testing

---

## 🎯 Pipeline Features

### **✅ Automated Testing:**

- Unit tests for backend and frontend
- Code coverage reporting
- Security vulnerability scanning
- Kubernetes manifest validation

### **✅ Multi-Environment Deployment:**

- **Staging**: Automatic deployment from develop branch
- **Production**: Manual approval required from main branch
- Environment-specific configurations

### **✅ Security & Quality:**

- ESLint and code quality checks
- Trivy security scanning
- Container image vulnerability assessment
- Infrastructure security validation

### **✅ Monitoring & Notifications:**

- Slack notifications for build status
- Test result publishing
- Coverage reports
- Deployment status updates

---

## 🆘 Troubleshooting

### **Build Failures:**

```bash
# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check agent connectivity
kubectl get nodes
docker ps
```

### **Permission Issues:**

```bash
# Add Jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Check AWS credentials
aws sts get-caller-identity
```

### **Kubernetes Connection:**

```bash
# Test kubectl access
kubectl get nodes
kubectl get pods -n ecommerce

# Update kubeconfig
aws eks update-kubeconfig --name ecommerce-cluster
```

### **ECR Push Issues:**

```bash
# Login to ECR manually
aws ecr get-login-password --region us-west-2 | \
docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com

# Check repository exists
aws ecr describe-repositories --region us-west-2
```

### **Common Pipeline Errors:**

1. **"No space left on device"**:
   ```bash
   # Clean Docker images
   docker system prune -f
   docker image prune -a -f
   ```

2. **"Permission denied" for kubectl**:
   - Check kubeconfig file permissions
   - Verify AWS IAM permissions for EKS

3. **"Image pull error"**:
   - Verify ECR repository exists
   - Check image tag is correct
   - Ensure cluster has ECR access

## 🎉 Success! Your CI/CD Pipeline is Ready

Your Jenkins pipeline now provides:

- ✅ **Automated builds** on every code push
- ✅ **Comprehensive testing** and security scanning
- ✅ **Multi-environment deployment** with approvals
- ✅ **Real-time notifications** to your team
- ✅ **Production-ready** deployment automation

**Next Steps:**
1. Push code changes to trigger builds
2. Monitor deployments through Jenkins
3. Set up additional environments (QA, UAT)
4. Configure advanced monitoring and alerting
