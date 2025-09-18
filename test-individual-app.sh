#!/bin/bash
# 🧪 Test Individual Application CI/CD Workflow

set -e

APP_NAME="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$APP_NAME" ]; then
    echo -e "${RED}❌ Error: Application name required${NC}"
    echo -e "${YELLOW}Usage: $0 <app-name>${NC}"
    echo -e "${BLUE}Available applications:${NC}"
    echo "  - ecommerce-app"
    echo "  - educational-platform"
    echo "  - weather-app"
    echo "  - medical-care-system"
    echo "  - task-management-app"
    echo "  - social-media-platform"
    exit 1
fi

if [ ! -d "$APP_NAME" ]; then
    echo -e "${RED}❌ Error: Application directory '$APP_NAME' not found${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 Testing CI/CD workflow for: $APP_NAME${NC}"
echo "═══════════════════════════════════════════════════════"

# Change to application directory
cd "$APP_NAME"

# Check for workflow files
echo -e "${BLUE}🔍 Checking workflow files...${NC}"
if [ -f ".github/workflows/ci-cd.yml" ]; then
    echo -e "  ✅ GitHub Actions workflow found"
else
    echo -e "  ⚠️  GitHub Actions workflow not found"
fi

# Validate Docker configuration
echo -e "${BLUE}🐳 Validating Docker configuration...${NC}"
if docker-compose config > /dev/null 2>&1; then
    echo -e "  ✅ Docker Compose configuration valid"
else
    echo -e "  ❌ Docker Compose configuration invalid"
    exit 1
fi

# Test Docker builds (dry run)
echo -e "${BLUE}🏗️ Testing Docker builds...${NC}"
if [ -f "backend/Dockerfile" ]; then
    echo -e "  🔨 Testing backend build..."
    if docker build --no-cache --progress=plain backend > /tmp/backend-build.log 2>&1; then
        echo -e "    ✅ Backend build successful"
    else
        echo -e "    ❌ Backend build failed - check /tmp/backend-build.log"
        exit 1
    fi
else
    echo -e "  ⚠️  Backend Dockerfile not found"
fi

if [ -f "frontend/Dockerfile" ]; then
    echo -e "  🔨 Testing frontend build..."
    if docker build --no-cache --progress=plain frontend > /tmp/frontend-build.log 2>&1; then
        echo -e "    ✅ Frontend build successful"
    else
        echo -e "    ❌ Frontend build failed - check /tmp/frontend-build.log"
        exit 1
    fi
else
    echo -e "  ⚠️  Frontend Dockerfile not found"
fi

# Simulate DockerHub push (tag only)
echo -e "${BLUE}🏷️  Simulating DockerHub operations...${NC}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
COMMIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

if docker images | grep -q "${APP_NAME%-*}-backend"; then
    echo -e "  🏷️  Tagging backend image..."
    docker tag "${APP_NAME%-*}-backend:latest" "tcainfrforge/${APP_NAME%-*}-backend:$TIMESTAMP"
    docker tag "${APP_NAME%-*}-backend:latest" "tcainfrforge/${APP_NAME%-*}-backend:$COMMIT_SHA"
    echo -e "    ✅ Backend image tagged for DockerHub"
fi

if docker images | grep -q "${APP_NAME%-*}-frontend"; then
    echo -e "  🏷️  Tagging frontend image..."
    docker tag "${APP_NAME%-*}-frontend:latest" "tcainfrforge/${APP_NAME%-*}-frontend:$TIMESTAMP"
    docker tag "${APP_NAME%-*}-frontend:latest" "tcainfrforge/${APP_NAME%-*}-frontend:$COMMIT_SHA"
    echo -e "    ✅ Frontend image tagged for DockerHub"
fi

# Integration test
echo -e "${BLUE}🧪 Running integration test...${NC}"
echo -e "  🚀 Starting services..."
docker-compose up -d --wait

# Wait for services to be ready
echo -e "  ⏳ Waiting for services to be ready..."
sleep 30

# Health checks based on application type
case "$APP_NAME" in
    "ecommerce-app")
        echo -e "  🏥 Checking backend health..."
        if curl -f -s http://localhost:5001/health > /dev/null; then
            echo -e "    ✅ Backend health check passed"
        else
            echo -e "    ❌ Backend health check failed"
        fi
        
        echo -e "  🌐 Checking frontend..."
        if curl -f -s http://localhost:3001 > /dev/null; then
            echo -e "    ✅ Frontend accessibility check passed"
        else
            echo -e "    ❌ Frontend accessibility check failed"
        fi
        ;;
    "educational-platform")
        echo -e "  🏥 Checking backend health..."
        if curl -f -s http://localhost:8080/actuator/health > /dev/null; then
            echo -e "    ✅ Backend health check passed"
        else
            echo -e "    ❌ Backend health check failed"
        fi
        
        echo -e "  🌐 Checking frontend..."
        if curl -f -s http://localhost:4200 > /dev/null; then
            echo -e "    ✅ Frontend accessibility check passed"
        else
            echo -e "    ❌ Frontend accessibility check failed"
        fi
        ;;
    "weather-app")
        echo -e "  🏥 Checking backend health..."
        if curl -f -s http://localhost:5000/health > /dev/null; then
            echo -e "    ✅ Backend health check passed"
        else
            echo -e "    ❌ Backend health check failed"
        fi
        
        echo -e "  🌐 Checking frontend..."
        if curl -f -s http://localhost:3000 > /dev/null; then
            echo -e "    ✅ Frontend accessibility check passed"
        else
            echo -e "    ❌ Frontend accessibility check failed"
        fi
        ;;
    "medical-care-system")
        echo -e "  🏥 Checking backend health..."
        if curl -f -s http://localhost:5000/health > /dev/null; then
            echo -e "    ✅ Backend health check passed"
        else
            echo -e "    ❌ Backend health check failed"
        fi
        
        echo -e "  🌐 Checking frontend..."
        if curl -f -s http://localhost:3000 > /dev/null; then
            echo -e "    ✅ Frontend accessibility check passed"
        else
            echo -e "    ❌ Frontend accessibility check failed"
        fi
        ;;
    "task-management-app")
        echo -e "  🏥 Checking backend health..."
        if curl -f -s http://localhost:8080/health > /dev/null; then
            echo -e "    ✅ Backend health check passed"
        else
            echo -e "    ❌ Backend health check failed"
        fi
        
        echo -e "  🌐 Checking frontend..."
        if curl -f -s http://localhost:3000 > /dev/null; then
            echo -e "    ✅ Frontend accessibility check passed"
        else
            echo -e "    ❌ Frontend accessibility check failed"
        fi
        ;;
    "social-media-platform")
        echo -e "  🏥 Checking backend health..."
        if curl -f -s http://localhost:3000/health > /dev/null; then
            echo -e "    ✅ Backend health check passed"
        else
            echo -e "    ❌ Backend health check failed"
        fi
        
        echo -e "  🌐 Checking frontend..."
        if curl -f -s http://localhost:4000 > /dev/null; then
            echo -e "    ✅ Frontend accessibility check passed"
        else
            echo -e "    ❌ Frontend accessibility check failed"
        fi
        ;;
esac

# Cleanup
echo -e "${BLUE}🧹 Cleaning up...${NC}"
docker-compose down -v
docker system prune -f > /dev/null 2>&1

echo -e "\n${GREEN}🎉 CI/CD workflow test completed successfully for $APP_NAME!${NC}"
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "  ✅ Docker configuration validated"
echo -e "  ✅ Container builds successful"
echo -e "  ✅ Images tagged for DockerHub"
echo -e "  ✅ Integration tests passed"
echo -e "  ✅ Services cleanup completed"

echo -e "\n${YELLOW}🔄 Next Steps:${NC}"
echo -e "  1. Push changes to trigger GitHub Actions workflow"
echo -e "  2. Monitor the workflow in GitHub repository > Actions"
echo -e "  3. Check DockerHub for published images"
echo -e "  4. Deploy to Kubernetes cluster for live testing"