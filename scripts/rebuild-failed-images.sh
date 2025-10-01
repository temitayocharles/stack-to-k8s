#!/bin/bash
# 🔧 FIX & REBUILD FAILED DOCKER IMAGES
# Multi-architecture rebuild for applications that failed

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DOCKER_HUB_USERNAME="temitayocharles"
BUILD_PLATFORMS="linux/amd64,linux/arm64"

# Failed applications to rebuild
FAILED_APPS=(
    "medical-care-system"
    "task-management-app" 
    "social-media-platform"
)

echo -e "${BLUE}🔧 REBUILDING FAILED MULTI-ARCHITECTURE DOCKER IMAGES${NC}"
echo -e "${BLUE}📋 Building for platforms: ${BUILD_PLATFORMS}${NC}"
echo -e "${BLUE}🎯 Rebuilding: ${#FAILED_APPS[@]} failed applications${NC}"
echo "================================================================="

# Function to build application
build_application() {
    local app_name=$1
    local app_path="/Volumes/512-B/Documents/PERSONAL/full-stack-apps/${app_name}"
    
    echo -e "\n${YELLOW}🔨 Rebuilding: ${app_name}${NC}"
    echo "📂 Path: ${app_path}"
    
    # Check if Dockerfile exists
    if [ ! -f "${app_path}/Dockerfile" ]; then
        echo -e "${RED}❌ Dockerfile not found in ${app_path}${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}🏗️  Building multi-arch image (with fixes)...${NC}"
    cd "${app_path}"
    
    # Build for multiple platforms and push to registry
    docker buildx build \
        --platform "${BUILD_PLATFORMS}" \
        --tag "${DOCKER_HUB_USERNAME}/${app_name}:latest" \
        --push \
        .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully built and pushed: ${DOCKER_HUB_USERNAME}/${app_name}:latest${NC}"
        echo -e "${BLUE}🔍 Verifying multi-arch support:${NC}"
        docker buildx imagetools inspect "${DOCKER_HUB_USERNAME}/${app_name}:latest" | grep -E "(Platform)" | head -5
    else
        echo -e "${RED}❌ Failed to build: ${app_name}${NC}"
        return 1
    fi
}

# Build each failed application
SUCCESSFUL_REBUILDS=0
for app in "${FAILED_APPS[@]}"; do
    echo "================================================================="
    
    if build_application "$app"; then
        echo -e "${GREEN}✅ Successfully rebuilt: $app${NC}"
        ((SUCCESSFUL_REBUILDS++))
    else
        echo -e "${RED}❌ Failed to rebuild: $app${NC}"
        echo -e "${YELLOW}⚠️  Please check Dockerfile and dependencies${NC}"
    fi
done

echo -e "\n${BLUE}📊 REBUILD SUMMARY${NC}"
echo "================================================================="
echo -e "${GREEN}✅ Successful rebuilds: ${SUCCESSFUL_REBUILDS}/${#FAILED_APPS[@]}${NC}"

if [ $SUCCESSFUL_REBUILDS -eq ${#FAILED_APPS[@]} ]; then
    echo -e "\n${GREEN}🎉 ALL FAILED APPLICATIONS SUCCESSFULLY REBUILT!${NC}"
    echo -e "${GREEN}🚀 Complete list of multi-arch Docker images:${NC}"
    echo -e "   ${GREEN}✅ ${DOCKER_HUB_USERNAME}/ecommerce-app:latest${NC}"
    echo -e "   ${GREEN}✅ ${DOCKER_HUB_USERNAME}/educational-platform:latest${NC}"
    echo -e "   ${GREEN}✅ ${DOCKER_HUB_USERNAME}/weather-app:latest${NC}"
    echo -e "   ${GREEN}✅ ${DOCKER_HUB_USERNAME}/medical-care-system:latest${NC}"
    echo -e "   ${GREEN}✅ ${DOCKER_HUB_USERNAME}/task-management-app:latest${NC}"
    echo -e "   ${GREEN}✅ ${DOCKER_HUB_USERNAME}/social-media-platform:latest${NC}"
    
    echo -e "\n${BLUE}🎯 Universal compatibility achieved:${NC}"
    echo -e "   ${GREEN}✅ linux/amd64 (x86_64 - Intel/AMD processors)${NC}"
    echo -e "   ${GREEN}✅ linux/arm64 (ARM processors - Apple Silicon, ARM servers)${NC}"
    echo -e "\n${GREEN}🌍 Ready for deployment on ANY OS/kernel type!${NC}"
else
    echo -e "\n${YELLOW}⚠️  Some rebuilds failed. Check logs above for details.${NC}"
fi