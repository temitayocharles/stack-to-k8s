# 🚀 Real CI/CD Testing with GitHub Actions Runner

This script sets up a self-hosted GitHub Actions runner for testing our CI/CD workflows with real builds and DockerHub pushes.

## 🎯 Prerequisites

1. **GitHub Repository** with Actions enabled
2. **DockerHub Account** (free tier works)
3. **GitHub Personal Access Token** with repo permissions
4. **Docker Desktop** installed and running

## 📋 Quick Setup Steps

### Step 1: Create GitHub Personal Access Token
1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select these scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
4. Copy the token - you'll need it below

### Step 2: Create DockerHub Access Token
1. Go to [DockerHub Settings > Security](https://hub.docker.com/settings/security)
2. Click "New Access Token"
3. Name: `github-actions-ci-cd`
4. Permissions: `Read, Write, Delete`
5. Copy the token

### Step 3: Set Repository Secrets
In your GitHub repository:
1. Go to Settings > Secrets and variables > Actions
2. Add these repository secrets:
   - `DOCKERHUB_USERNAME`: Your DockerHub username
   - `DOCKERHUB_TOKEN`: The access token from Step 2

### Step 4: Test Individual Application Workflow
```bash
# Test e-commerce application
cd ecommerce-app
git add .
git commit -m "Test ecommerce CI/CD workflow"
git push origin main

# Monitor the workflow:
# 1. Go to your repository > Actions tab
# 2. Watch the "E-commerce App CI/CD" workflow run
# 3. Check DockerHub for the pushed images
```

### Step 5: Test Global Workspace Workflow
```bash
# Test all applications at once
git add .
git commit -m "Test global CI/CD workflow"
git push origin main

# Monitor the workflow:
# 1. Go to your repository > Actions tab  
# 2. Watch the "Global Workspace CI/CD Pipeline" workflow run
# 3. Check DockerHub for all application images
```

## 🔧 Workflow Testing Commands

### Quick Test Individual Apps
```bash
# Test specific application
./test-individual-app.sh ecommerce-app
./test-individual-app.sh educational-platform
./test-individual-app.sh weather-app
./test-individual-app.sh medical-care-system
./test-individual-app.sh task-management-app
./test-individual-app.sh social-media-platform
```

### Test Global Workflow
```bash
# Test all applications with change detection
./test-global-workflow.sh
```

### Manual Workflow Trigger
```bash
# Trigger workflow manually via GitHub CLI
gh workflow run "Global Workspace CI/CD Pipeline" \
  --ref main \
  --field deploy_environment=staging
```

## 📊 Expected Results

### DockerHub Images Created
After successful runs, you should see these images in your DockerHub account:

- `yourusername/ecommerce-backend:latest`
- `yourusername/ecommerce-frontend:latest`
- `yourusername/educational-backend:latest`
- `yourusername/educational-frontend:latest`
- `yourusername/weather-backend:latest`
- `yourusername/weather-frontend:latest`
- `yourusername/medical-backend:latest`
- `yourusername/medical-frontend:latest`
- `yourusername/task-management-backend:latest`
- `yourusername/task-management-frontend:latest`
- `yourusername/social-media-backend:latest`
- `yourusername/social-media-frontend:latest`

### Kubernetes Deployment Ready
Once images are built, you can deploy to Kubernetes:

```bash
# Update image references in Kubernetes manifests
cd ecommerce-app/k8s
kubectl apply -f .

# Or use the convenience script
./deploy-to-k8s.sh ecommerce-app
```

## 🛠️ Troubleshooting

### Build Failures
If builds fail, check:
1. **Dockerfile syntax** in each application
2. **Package dependencies** are correctly specified
3. **Environment variables** are properly set
4. **Docker context** has all required files

### Authentication Issues
If DockerHub push fails:
1. Verify `DOCKERHUB_USERNAME` secret is correct
2. Regenerate `DOCKERHUB_TOKEN` if expired
3. Check token permissions include write access

### Workflow Not Triggering
If workflows don't start:
1. Check file paths in workflow triggers
2. Ensure workflows are in `.github/workflows/`
3. Verify YAML syntax is valid
4. Check branch protection rules

## 🚀 Advanced Features

### Custom Build Parameters
```bash
# Build with specific tags
gh workflow run "Global Workspace CI/CD Pipeline" \
  --ref main \
  --field image_tag=v1.0.0 \
  --field deploy_environment=production
```

### Multi-Environment Deployment
```bash
# Deploy to staging first
gh workflow run "Global Workspace CI/CD Pipeline" \
  --ref main \
  --field deploy_environment=staging

# Then promote to production
gh workflow run "Global Workspace CI/CD Pipeline" \
  --ref main \
  --field deploy_environment=production
```

### Monitoring and Alerts
Set up monitoring for your workflows:
1. Enable GitHub Actions email notifications
2. Configure Slack integration for build status
3. Set up DockerHub webhooks for image push notifications

## 🎯 Success Criteria

✅ **All applications build successfully**
✅ **All images pushed to DockerHub**  
✅ **No security vulnerabilities found**
✅ **Integration tests pass**
✅ **Workflows complete in under 15 minutes**
✅ **Kubernetes manifests updated with new images**

---

**Next Steps**: Once CI/CD is working, proceed to Kubernetes deployment and practice advanced features like HPA, Network Policies, and Pod Disruption Budgets!