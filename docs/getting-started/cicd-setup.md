# 🔄 CI/CD Pipeline Setup - Automated Deployments

**Goal**: Set up automated testing and deployment pipelines for professional development workflow.

> **Perfect for**: "I want automated deployments like in real companies"

## 🎯 What You'll Build
- ✅ **Automated testing** on every code change
- ✅ **Security scanning** for vulnerabilities
- ✅ **Automated deployment** to staging and production
- ✅ **Quality gates** that prevent bad code from deploying
- ✅ **Rollback capabilities** for quick recovery

## 📋 Before You Start
**Required time**: 2 hours  
**Prerequisites**: [Enterprise setup](enterprise-setup.md) completed  
**Accounts needed**: GitHub account (free)

## 🚀 Choose Your CI/CD Platform

### Option 1: GitHub Actions (Recommended for Beginners)
- ✅ **Free tier**: 2000 minutes/month
- ✅ **Easy setup**: Integrated with GitHub
- ✅ **Great documentation**: Lots of examples

### Option 2: GitLab CI (Best for Advanced Users)
- ✅ **Powerful features**: Advanced pipeline controls
- ✅ **Built-in registry**: Container image storage
- ✅ **Self-hosted option**: Run on your own servers

### Option 3: Jenkins (Enterprise Choice)
- ✅ **Highly customizable**: Unlimited flexibility
- ✅ **Self-hosted**: Complete control
- ✅ **Plugin ecosystem**: Thousands of integrations

> **We'll focus on GitHub Actions** for this guide. Links to other platforms at the end.

## 🔧 Phase 1: GitHub Actions Setup (30 minutes)

### Step 1: Create Workflow Directory
```bash
mkdir -p .github/workflows
```

### Step 2: Basic CI Pipeline
Create `.github/workflows/ci.yml`:
```yaml
name: Continuous Integration

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
      
    - name: Build test images
      run: |
        docker-compose -f docker-compose.test.yml build
        
    - name: Run tests
      run: |
        docker-compose -f docker-compose.test.yml run --rm backend npm test
        docker-compose -f docker-compose.test.yml run --rm frontend npm test
        
    - name: Run integration tests
      run: |
        docker-compose -f docker-compose.test.yml up -d
        sleep 30
        docker-compose -f docker-compose.test.yml run --rm e2e-tests
        
    - name: Cleanup
      if: always()
      run: |
        docker-compose -f docker-compose.test.yml down -v
```

### Step 3: Security Scanning
Add security job to `.github/workflows/ci.yml`:
```yaml
  security:
    runs-on: ubuntu-latest
    needs: test
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'my-app:latest'
        format: 'sarif'
        output: 'trivy-results.sarif'
        
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
        
    - name: Dependency check
      run: |
        npm audit --audit-level high
        pip-audit --format=json --output=audit-results.json || true
```

## 🚀 Phase 2: Deployment Pipeline (45 minutes)

### Step 1: Create Deployment Workflow
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Kubernetes

on:
  push:
    branches: [ main ]
  workflow_dispatch:  # Manual trigger

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
        
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=sha,prefix={{branch}}-
          
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

  deploy-staging:
    runs-on: ubuntu-latest
    needs: build
    environment: staging
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
      
    - name: Deploy to staging
      run: |
        # Update image tag in Kubernetes manifests
        sed -i "s|image: .*|image: ${{ needs.build.outputs.image-tag }}|g" k8s/staging/deployment.yaml
        
        # Apply to staging namespace
        kubectl apply -f k8s/staging/ --namespace=staging
        
        # Wait for rollout
        kubectl rollout status deployment/my-app --namespace=staging --timeout=300s
        
    - name: Run smoke tests
      run: |
        # Test staging deployment
        kubectl port-forward service/my-app 8080:80 --namespace=staging &
        sleep 10
        curl -f http://localhost:8080/health || exit 1

  deploy-production:
    runs-on: ubuntu-latest
    needs: [build, deploy-staging]
    environment: production
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
      
    - name: Deploy to production
      run: |
        # Update image tag
        sed -i "s|image: .*|image: ${{ needs.build.outputs.image-tag }}|g" k8s/production/deployment.yaml
        
        # Rolling update to production
        kubectl apply -f k8s/production/ --namespace=production
        kubectl rollout status deployment/my-app --namespace=production --timeout=600s
        
    - name: Verify deployment
      run: |
        # Health check
        kubectl get pods --namespace=production
        kubectl port-forward service/my-app 8080:80 --namespace=production &
        sleep 10
        curl -f http://localhost:8080/health || exit 1
```

### Step 2: Set Up Environments
In GitHub repository settings:
1. Go to Settings → Environments
2. Create "staging" environment
3. Create "production" environment
4. Add protection rules for production:
   - Required reviewers: 1
   - Wait timer: 5 minutes

### Step 3: Configure Secrets
Add these secrets in GitHub Settings → Secrets:
```bash
# Kubernetes cluster access
KUBE_CONFIG_DATA: <base64 encoded kubeconfig>

# Container registry (if using private registry)
REGISTRY_USERNAME: your-username
REGISTRY_PASSWORD: your-password

# Application secrets
DATABASE_URL: your-database-connection
API_KEYS: your-api-keys
```

## 🔒 Phase 3: Advanced Pipeline Features (45 minutes)

### Step 1: Quality Gates
Add quality checks to `.github/workflows/ci.yml`:
```yaml
  quality-gate:
    runs-on: ubuntu-latest
    needs: [test, security]
    
    steps:
    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        
    - name: Code coverage check
      run: |
        # Fail if coverage below 80%
        coverage=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
        if (( $(echo "$coverage < 80" | bc -l) )); then
          echo "Coverage $coverage% is below 80%"
          exit 1
        fi
        
    - name: Performance test
      run: |
        # Run k6 load test
        docker run --rm -v $PWD:/scripts loadimpact/k6 run /scripts/load-test.js
```

### Step 2: Rollback Capability
Create `.github/workflows/rollback.yml`:
```yaml
name: Rollback Deployment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to rollback'
        required: true
        type: choice
        options:
        - staging
        - production
      revision:
        description: 'Revision number to rollback to'
        required: true
        type: string

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    
    steps:
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
      
    - name: Rollback deployment
      run: |
        kubectl rollout undo deployment/my-app \
          --namespace=${{ github.event.inputs.environment }} \
          --to-revision=${{ github.event.inputs.revision }}
          
        kubectl rollout status deployment/my-app \
          --namespace=${{ github.event.inputs.environment }}
          
    - name: Verify rollback
      run: |
        kubectl get pods --namespace=${{ github.event.inputs.environment }}
        # Add health checks here
```

### Step 3: Notification Setup
Add Slack notifications:
```yaml
    - name: Notify deployment
      if: always()
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
        text: |
          Deployment to ${{ github.event.inputs.environment }} completed
          Status: ${{ job.status }}
          Commit: ${{ github.sha }}
```

## 📊 Phase 4: Monitoring Integration (20 minutes)

### Step 1: Deployment Metrics
Add monitoring to deployments:
```yaml
    - name: Record deployment
      run: |
        # Send deployment event to monitoring
        curl -X POST "http://prometheus-pushgateway:9091/metrics/job/deployments" \
          --data-binary @- << EOF
        deployment_info{version="${{ github.sha }}",environment="${{ github.event.inputs.environment }}"} 1
        EOF
```

### Step 2: Performance Monitoring
```yaml
    - name: Performance baseline
      run: |
        # Run performance test and compare with baseline
        k6 run --out json=results.json performance-test.js
        
        # Compare with previous results
        python scripts/compare-performance.py results.json baseline.json
```

## ✅ Testing Your Pipeline

### Step 1: Make a Test Change
```bash
# Create a feature branch
git checkout -b test-pipeline

# Make a small change
echo "console.log('Testing CI/CD');" >> src/test.js

# Commit and push
git add .
git commit -m "test: add CI/CD pipeline test"
git push origin test-pipeline
```

### Step 2: Create Pull Request
1. Go to GitHub and create PR
2. Watch CI pipeline run automatically
3. Check for security scans and test results
4. Merge when all checks pass

### Step 3: Watch Deployment
1. Monitor deployment to staging
2. Verify staging environment
3. Approve production deployment
4. Monitor production rollout

## 🎉 Success Criteria

Your CI/CD pipeline now provides:
- ✅ **Automated testing** on every change
- ✅ **Security scanning** with vulnerability detection
- ✅ **Quality gates** preventing bad deployments
- ✅ **Staged deployment** with staging → production flow
- ✅ **Rollback capability** for quick recovery

## ➡️ Alternative Platforms

### GitLab CI Setup
See: [GitLab CI Documentation](../ci-cd/gitlab-setup.md)

### Jenkins Setup  
See: [Jenkins Pipeline Documentation](../ci-cd/jenkins-setup.md)

## 🆘 Common CI/CD Issues

**Pipeline failing on tests**:
- Check test configuration in docker-compose.test.yml
- Verify database setup for testing
- Review error logs in Actions tab

**Deployment timeouts**:
- Increase timeout values
- Check cluster resource availability
- Verify image pull times

**Security scan failures**:
- Review and fix high/critical vulnerabilities
- Update dependencies regularly
- Consider vulnerability exceptions for false positives

---

**Professional achievement unlocked!** You now have enterprise-grade CI/CD pipelines that automatically test, secure, and deploy your applications.