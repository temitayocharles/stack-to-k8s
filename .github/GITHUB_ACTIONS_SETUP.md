# 🚀 GitHub Actions Multi-Architecture Build Setup

## 🔐 Required Secrets Setup

Before running the workflows, you need to add Docker Hub credentials to your GitHub repository secrets:

### Step 1: Get Docker Hub Credentials
1. Go to [Docker Hub](https://hub.docker.com/)
2. Log in to your account
3. Go to **Account Settings** → **Security** → **New Access Token**
4. Create a new access token with **Read, Write, Delete** permissions
5. Copy the token (you won't see it again!)

### Step 2: Add Secrets to GitHub Repository
1. Go to your GitHub repository: `https://github.com/temitayocharles/full-stack-apps`
2. Click **Settings** tab
3. Click **Secrets and variables** → **Actions**
4. Click **New repository secret** and add:

```
Name: DOCKER_USERNAME
Value: temitayocharles
```

```
Name: DOCKER_PASSWORD  
Value: [Your Docker Hub Access Token]
```

## 🏗️ Available Workflows

### 1. Automatic Build (build-multiarch.yml)
- **Triggers**: Push to main branch, Pull requests, Manual dispatch
- **Builds**: All 6 applications simultaneously
- **Architectures**: linux/amd64, linux/arm64
- **Matrix Strategy**: Parallel builds for efficiency

### 2. Manual Build (manual-build.yml)  
- **Trigger**: Manual dispatch only
- **Options**: Build single application or all applications
- **Architectures**: linux/amd64, linux/arm64
- **Use Case**: Testing individual applications or troubleshooting

## 🚀 How to Use

### Option A: Automatic Build (Recommended)
1. Push code to main branch
2. Workflow automatically starts
3. All 6 applications build in parallel
4. Check **Actions** tab for progress

### Option B: Manual Build
1. Go to **Actions** tab in GitHub repository
2. Select **Manual Multi-Arch Build** workflow
3. Click **Run workflow**
4. Choose application (or "all")
5. Click **Run workflow** button

## 📊 Build Matrix

The workflow builds these applications:

| Application | Tech Stack | Description |
|-------------|------------|-------------|
| ecommerce-app | Node.js/React | E-commerce Platform |
| educational-platform | Java/Angular | Learning Management System |
| weather-app | Python/Vue.js | Weather Application |
| medical-care-system | ASP.NET/Blazor | Medical Care System |
| task-management-app | Go/Svelte | Task Management App |
| social-media-platform | Ruby/React | Social Media Platform |

## 🔍 Verification

After builds complete, each image will have multi-architecture support:

```bash
docker buildx imagetools inspect temitayocharles/ecommerce-app:latest
```

Expected output:
```
MediaType: application/vnd.docker.distribution.manifest.list.v2+json
Digest: sha256:...

Manifests:
  MediaType: application/vnd.docker.distribution.manifest.v2+json
  Platform:  linux/amd64

  MediaType: application/vnd.docker.distribution.manifest.v2+json  
  Platform:  linux/arm64
```

## 🎯 Benefits of GitHub Actions Approach

✅ **Reliable**: Professional CI/CD infrastructure  
✅ **Parallel**: All apps build simultaneously  
✅ **Cached**: Faster subsequent builds  
✅ **Multi-Arch**: Native ARM64 support  
✅ **Automated**: Triggers on code changes  
✅ **Free**: 2000 minutes/month on public repos  

## 🚨 Important Notes

1. **First Build**: May take 20-30 minutes for all applications
2. **Subsequent Builds**: Much faster due to layer caching  
3. **ARM64 Native**: No emulation, true ARM64 performance
4. **Disk Space**: GitHub runners have sufficient space
5. **Parallel Limits**: GitHub runs up to 20 jobs simultaneously

## 🆘 Troubleshooting

### Build Fails
- Check secrets are set correctly
- Verify Dockerfile syntax
- Check application dependencies

### Permission Denied
- Ensure Docker Hub token has **Read, Write, Delete** permissions
- Verify secrets are named exactly: `DOCKER_USERNAME` and `DOCKER_PASSWORD`

### Out of Disk Space
- GitHub Actions runners have 14GB available
- Our applications should fit comfortably
- Builds use multi-stage optimization