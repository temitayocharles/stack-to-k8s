# GitLab CI/CD Setup Guide - E-commerce Platform

> **🔧 Complete GitLab CI/CD Configuration for Kubernetes Deployment**  
> This guide shows you how to set up GitLab CI/CD for automated deployment pipelines.

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ **GitLab account** (GitLab.com or self-hosted)
- ✅ **EKS cluster running** (from infrastructure setup)
- ✅ **AWS credentials** with ECR and EKS permissions
- ✅ **GitLab Runner** configured (or use shared runners)

---

## 🚀 STEP 1: Set Up GitLab Project

### **Create or import your repository:**

1. **Login** to your GitLab account
2. **Click** "New project" 
3. **Choose** "Import project" if you have existing code
4. **Or** "Create blank project" for new setup
5. **Fill in:**
   - **Project name**: `ecommerce-platform`
   - **Project slug**: `ecommerce-platform`
   - **Visibility**: Private (recommended)
   - **Initialize with README**: ✅ Checked
6. **Click** "Create project"

### **Upload project files:**

1. **Clone** the repository locally:

```bash
git clone https://gitlab.com/your-username/ecommerce-platform.git
cd ecommerce-platform
```

2. **Copy** all your e-commerce application files to this directory
3. **Add** and commit the files:

```bash
git add .
git commit -m "Initial commit: E-commerce platform with Kubernetes"
git push origin main
```

---

## 🚀 STEP 2: Configure GitLab Variables

### **Navigate to CI/CD settings:**

1. **Go to** your project in GitLab
2. **Click** "Settings" in the left sidebar
3. **Click** "CI/CD"
4. **Expand** "Variables" section

### **Add required variables:**

Add each variable by clicking "Add variable":

#### **AWS Configuration:**

1. **AWS_ACCOUNT_ID**
   - **Key**: `AWS_ACCOUNT_ID`
   - **Value**: Your 12-digit AWS account ID
   - **Type**: Variable
   - **Protected**: ✅ Checked
   - **Masked**: ✅ Checked

2. **AWS_ACCESS_KEY_ID**
   - **Key**: `AWS_ACCESS_KEY_ID`
   - **Value**: Your AWS access key
   - **Type**: Variable
   - **Protected**: ✅ Checked
   - **Masked**: ✅ Checked

3. **AWS_SECRET_ACCESS_KEY**
   - **Key**: `AWS_SECRET_ACCESS_KEY`
   - **Value**: Your AWS secret key
   - **Type**: Variable
   - **Protected**: ✅ Checked
   - **Masked**: ✅ Checked

#### **Kubernetes Configuration:**

4. **KUBECONFIG**
   - **Key**: `KUBECONFIG`
   - **Value**: Contents of your `~/.kube/config` file
   - **Type**: File
   - **Protected**: ✅ Checked

#### **Notification Configuration (Optional):**

5. **SLACK_WEBHOOK_URL**
   - **Key**: `SLACK_WEBHOOK_URL`
   - **Value**: Your Slack webhook URL
   - **Type**: Variable
   - **Protected**: ✅ Checked
   - **Masked**: ✅ Checked

### **To get your kubeconfig content:**

```bash
# Copy the content of your kubeconfig file
cat ~/.kube/config

# Copy the entire output and paste as the KUBECONFIG variable value
```

---

## 🚀 STEP 3: Set Up GitLab Runner (If Using Self-Hosted)

### **Install GitLab Runner on your server:**

```bash
# For Ubuntu/Debian
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install gitlab-runner

# For CentOS/RHEL
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
sudo yum install gitlab-runner
```

### **Register the runner:**

1. **Go to** your GitLab project
2. **Click** "Settings" → "CI/CD"
3. **Expand** "Runners" section
4. **Copy** the registration token

```bash
# Register the runner
sudo gitlab-runner register

# Follow the prompts:
# GitLab instance URL: https://gitlab.com/ (or your GitLab URL)
# Registration token: [paste your token]
# Description: ecommerce-docker-runner
# Tags: docker,kubernetes,aws
# Executor: docker
# Default Docker image: alpine:latest
```

### **Configure runner for Docker:**

```bash
# Edit runner configuration
sudo nano /etc/gitlab-runner/config.toml

# Update the configuration:
[[runners]]
  name = "ecommerce-docker-runner"
  url = "https://gitlab.com/"
  token = "your-token"
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "alpine:latest"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
    shm_size = 0
```

---

## 🚀 STEP 4: Configure Shared Runners (Alternative)

### **If using GitLab.com shared runners:**

1. **Go to** your project settings
2. **Click** "CI/CD" → "Runners"
3. **Enable** shared runners for your project
4. **Note**: Shared runners have usage limits on free plans

### **Runner tags and requirements:**

Your `.gitlab-ci.yml` is configured to work with:
- Docker-enabled runners
- Runners with AWS CLI capability
- Runners with kubectl access

---

## 🚀 STEP 5: Test the Pipeline

### **Trigger your first pipeline:**

1. **Make a small change** to your code:

```bash
# Edit a file (e.g., README.md)
echo "# E-commerce Platform CI/CD" > README.md

# Commit and push
git add README.md
git commit -m "Test: Trigger CI/CD pipeline"
git push origin main
```

### **Monitor the pipeline:**

1. **Go to** your GitLab project
2. **Click** "CI/CD" → "Pipelines"
3. **Click** on the running pipeline
4. **Watch** each stage execute

### **Pipeline stages you'll see:**

1. **🔍 Code Analysis** - Linting and validation
2. **🧪 Test** - Unit tests and coverage
3. **🐳 Build** - Docker image creation
4. **🔒 Security** - Vulnerability scanning
5. **📦 Package** - Push to ECR (main/develop branches only)
6. **🚀 Deploy Staging** - Auto-deploy to staging (develop branch)
7. **🎯 Deploy Production** - Manual deploy to production (main branch)

---

## 🚀 STEP 6: Set Up Branch Protection

### **Configure protected branches:**

1. **Go to** "Settings" → "Repository"
2. **Expand** "Protected branches"
3. **Add** protection for `main` branch:
   - **Allowed to merge**: Maintainers
   - **Allowed to push**: No one
   - **Force push**: ❌ Disabled
4. **Add** protection for `develop` branch:
   - **Allowed to merge**: Developers + Maintainers
   - **Allowed to push**: Developers + Maintainers

### **Configure merge request settings:**

1. **Go to** "Settings" → "General"
2. **Expand** "Merge requests"
3. **Enable**:
   - ✅ **Pipelines must succeed**
   - ✅ **All discussions must be resolved**
   - ✅ **Delete source branch when merge request is accepted**

---

## 🚀 STEP 7: Set Up Environments

### **Configure staging environment:**

1. **Go to** "Deployments" → "Environments"
2. **Click** "New environment"
3. **Fill in:**
   - **Name**: `staging`
   - **External URL**: `http://staging.your-domain.com`
4. **Click** "Save"

### **Configure production environment:**

1. **Click** "New environment" again
2. **Fill in:**
   - **Name**: `production`
   - **External URL**: `http://your-domain.com`
3. **Click** "Save"

---

## 🚀 STEP 8: Set Up Slack Notifications (Optional)

### **Create Slack webhook:**

1. **Go to** your Slack workspace
2. **Click** workspace name → "Settings & administration" → "Manage apps"
3. **Search** for "Incoming Webhooks"
4. **Add** to Slack and configure
5. **Choose** your deployment channel
6. **Copy** the webhook URL

### **Add webhook to GitLab:**

1. **Go back** to GitLab project settings
2. **Click** "CI/CD" → "Variables"
3. **Add** the `SLACK_WEBHOOK_URL` variable (as shown in STEP 2)

---

## 🚀 STEP 9: Create Multi-Environment Workflow

### **Recommended Git workflow:**

```bash
# Development workflow
git checkout -b feature/new-payment-gateway
# Make changes...
git commit -m "feat: Add new payment gateway"
git push origin feature/new-payment-gateway

# Create merge request to develop branch
# Pipeline runs tests only

# After merge to develop:
# - Pipeline runs full CI/CD
# - Deploys automatically to staging

# When ready for production:
git checkout main
git merge develop
git push origin main

# - Pipeline runs full CI/CD
# - Requires manual approval for production deployment
```

### **Branch-specific behaviors:**

- **Feature branches**: Run tests and code analysis only
- **develop branch**: Deploy automatically to staging
- **main branch**: Deploy to production with manual approval
- **release branches**: Deploy to staging for final testing

---

## 🎯 Pipeline Features

### **✅ Comprehensive Testing:**

- **Backend**: Unit tests, integration tests, coverage reporting
- **Frontend**: Component tests, build verification
- **Security**: Dependency scanning, container vulnerability scanning
- **Quality**: Code linting, SAST analysis

### **✅ Multi-Stage Deployment:**

- **Staging**: Automatic deployment from develop branch
- **Production**: Manual approval required
- **Rollback**: Previous deployment backups created automatically

### **✅ Security & Compliance:**

- **Image scanning** with Trivy
- **Dependency scanning** with GitLab Security
- **SAST analysis** for code vulnerabilities
- **Container scanning** for runtime security

### **✅ Monitoring & Notifications:**

- **Pipeline status** notifications to Slack
- **Deployment tracking** in GitLab environments
- **Artifact management** with automatic cleanup

---

## 🆘 Troubleshooting

### **Pipeline Failures:**

1. **Check pipeline logs:**
   - Click on failed job
   - Review "Job log" section
   - Look for specific error messages

2. **Common issues:**

```bash
# Permission denied errors
# Solution: Check AWS credentials and policies

# Image pull errors  
# Solution: Verify ECR repository exists and permissions

# Kubernetes connection issues
# Solution: Verify kubeconfig variable is correctly set
```

### **Runner Issues:**

```bash
# Check runner status
sudo gitlab-runner status

# Restart runner if needed
sudo gitlab-runner restart

# View runner logs
sudo journalctl -u gitlab-runner -f
```

### **AWS Permission Issues:**

Required AWS policies for the CI/CD user:
- `AmazonEKSClusterPolicy`
- `AmazonEC2ContainerRegistryFullAccess`
- `AmazonEKSWorkerNodePolicy`

### **Kubernetes Access Issues:**

```bash
# Test kubectl access locally
kubectl get nodes

# If working locally but failing in CI/CD:
# 1. Check kubeconfig variable format
# 2. Verify AWS credentials in pipeline
# 3. Ensure cluster name matches
```

### **Docker Build Issues:**

```bash
# Enable Docker BuildKit debugging
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

# Check Docker daemon status
docker info

# Verify Dockerfile syntax
docker build --no-cache -t test .
```

## 🎉 Success! Your GitLab CI/CD is Ready

Your GitLab pipeline now provides:

- ✅ **Automated testing** on every push
- ✅ **Security scanning** for vulnerabilities
- ✅ **Multi-environment deployment** with proper controls
- ✅ **Integration with Kubernetes** and AWS
- ✅ **Professional workflow** for team collaboration

### **Next Steps:**

1. **Create feature branches** and test merge requests
2. **Set up monitoring** for deployed applications
3. **Configure custom domains** for staging/production
4. **Add performance testing** to the pipeline
5. **Implement automated rollback** strategies

**Your GitLab project URL:** `https://gitlab.com/your-username/ecommerce-platform`
