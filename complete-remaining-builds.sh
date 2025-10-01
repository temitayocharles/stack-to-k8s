#!/bin/bash

# Complete Remaining Multi-Architecture Docker Builds
# Using proven working Dockerfiles from successful commit

echo "🚀 Completing Remaining Multi-Architecture Docker Builds"
echo "======================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BUILD_COUNT=0
SUCCESS_COUNT=0
FAILED_COUNT=0

# Function to build and track results
build_app() {
    local app_name="$1"
    local image_name="$2"
    
    echo -e "${YELLOW}🔄 Building: $app_name${NC}"
    echo "   Image: temitayocharles/$image_name:latest"
    echo "   Platforms: linux/amd64, linux/arm64"
    echo ""
    
    ((BUILD_COUNT++))
    
    if docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t "temitayocharles/$image_name:latest" \
        --push \
        "$app_name/"; then
        
        echo -e "${GREEN}✅ SUCCESS: $app_name built and pushed${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}❌ FAILED: $app_name build failed${NC}"
        ((FAILED_COUNT++))
    fi
    
    echo ""
    echo "---"
    echo ""
}

echo "Starting builds with working Dockerfiles..."
echo ""

# Build remaining applications
build_app "medical-care-system" "medical-care-system"
build_app "task-management-app" "task-management-app" 
build_app "social-media-platform" "social-media-platform"

# Final summary
echo "🎯 FINAL BUILD SUMMARY"
echo "====================="
echo "Total builds attempted: $BUILD_COUNT"
echo -e "Successful builds: ${GREEN}$SUCCESS_COUNT${NC}"
echo -e "Failed builds: ${RED}$FAILED_COUNT${NC}"
echo ""

if [ $SUCCESS_COUNT -eq $BUILD_COUNT ]; then
    echo -e "${GREEN}🎉 ALL BUILDS SUCCESSFUL!${NC}"
    echo "All 6 applications now have multi-architecture Docker images"
    echo ""
    echo "📋 Complete Docker Hub Registry:"
    echo "• temitayocharles/ecommerce-app:latest"
    echo "• temitayocharles/educational-platform:latest" 
    echo "• temitayocharles/weather-app:latest"
    echo "• temitayocharles/medical-care-system:latest"
    echo "• temitayocharles/task-management-app:latest"
    echo "• temitayocharles/social-media-platform:latest"
    echo ""
    echo "🌍 Universal Compatibility: All images support linux/amd64 and linux/arm64"
    exit 0
else
    echo -e "${RED}⚠️ Some builds failed. Check errors above.${NC}"
    exit 1
fi