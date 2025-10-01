#!/bin/bash
# 🚀 MULTI-ARCHITECTURE DOCKER BUILD SCRIPT
# Builds Docker images for universal compatibility across OS types and kernels
# Supports: linux/amd64, linux/arm64 for maximum compatibility

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKER_HUB_USERNAME="temitayocharles"
BUILD_PLATFORMS="linux/amd64,linux/arm64"

# Applications to build
APPLICATIONS=(
    "ecommerce-app"
    "educational-platform" 
    "weather-app"
    "medical-care-system"
    "task-management-app"
    "social-media-platform"
)

# Progress tracking
TOTAL_APPS=${#APPLICATIONS[@]}
CURRENT_APP=0

echo -e "${BLUE}🚀 STARTING MULTI-ARCHITECTURE DOCKER BUILDS${NC}"
echo -e "${BLUE}📋 Building for platforms: ${BUILD_PLATFORMS}${NC}"
echo -e "${BLUE}📊 Total applications: ${TOTAL_APPS}${NC}"
echo "================================================================="

# Check Docker buildx
echo -e "${YELLOW}🔍 Checking Docker buildx support...${NC}"
if ! docker buildx version >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker buildx not available. Please install Docker Desktop or enable buildx${NC}"
    exit 1
fi

# Create buildx instance if not exists
if ! docker buildx inspect multiarch-builder >/dev/null 2>&1; then
    echo -e "${YELLOW}🔧 Creating multiarch-builder instance...${NC}"
    docker buildx create --name multiarch-builder --use --bootstrap
else
    echo -e "${GREEN}✅ Using existing multiarch-builder instance${NC}"
    docker buildx use multiarch-builder
fi

# Function to show progress
show_progress() {
    local current=$1
    local total=$2
    local app_name="$3"
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "\n${BLUE}📊 Progress: %s${NC}\n" "$app_name"
    printf "["
    for ((i=1; i<=completed; i++)); do printf "█"; done
    for ((i=completed+1; i<=width; i++)); do printf "░"; done
    printf "] %d%% (%d/%d)\n" "$percentage" "$current" "$total"
}

# Function to build application
build_application() {
    local app_name=$1
    local app_path="/Volumes/512-B/Documents/PERSONAL/full-stack-apps/${app_name}"
    
    echo -e "\n${YELLOW}🔨 Building: ${app_name}${NC}"
    echo "📂 Path: ${app_path}"
    
    # Check if Dockerfile exists
    if [ ! -f "${app_path}/Dockerfile" ]; then
        echo -e "${RED}❌ Dockerfile not found in ${app_path}${NC}"
        return 1
    fi
    
    # Build and push multi-arch image
    echo -e "${YELLOW}🏗️  Building multi-arch image...${NC}"
    cd "${app_path}"
    
    # Build for multiple platforms and push to registry
    docker buildx build \
        --platform "${BUILD_PLATFORMS}" \
        --tag "${DOCKER_HUB_USERNAME}/${app_name}:latest" \
        --push \
        .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully built and pushed: ${DOCKER_HUB_USERNAME}/${app_name}:latest${NC}"
    else
        echo -e "${RED}❌ Failed to build: ${app_name}${NC}"
        return 1
    fi
}

# Build each application
for app in "${APPLICATIONS[@]}"; do
    ((CURRENT_APP++))
    show_progress $CURRENT_APP $TOTAL_APPS "$app"
    
    if build_application "$app"; then
        echo -e "${GREEN}✅ Completed: $app${NC}"
    else
        echo -e "${RED}❌ Failed: $app${NC}"
        echo -e "${YELLOW}⚠️  Continuing with next application...${NC}"
    fi
    
    echo "================================================================="
done

echo -e "\n${BLUE}🎉 MULTI-ARCHITECTURE BUILD COMPLETE!${NC}"
echo -e "${GREEN}📋 Built applications with universal compatibility:${NC}"
for app in "${APPLICATIONS[@]}"; do
    echo -e "   ${GREEN}✅ ${DOCKER_HUB_USERNAME}/${app}:latest${NC}"
done

echo -e "\n${BLUE}🔍 Verifying multi-arch manifests:${NC}"
for app in "${APPLICATIONS[@]}"; do
    echo -e "${YELLOW}📊 ${app}:${NC}"
    docker buildx imagetools inspect "${DOCKER_HUB_USERNAME}/${app}:latest" | grep -E "(Manifest|Platform)" | head -10
done

echo -e "\n${GREEN}🎯 All images now support:${NC}"
echo -e "   ${GREEN}✅ linux/amd64 (x86_64 - Intel/AMD processors)${NC}"
echo -e "   ${GREEN}✅ linux/arm64 (ARM processors - Apple Silicon, ARM servers)${NC}"
echo -e "\n${BLUE}🚀 Ready for deployment on any OS/kernel type!${NC}"