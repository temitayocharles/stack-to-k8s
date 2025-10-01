#!/bin/bash
# 🎯 SIMPLE SEQUENTIAL MULTI-ARCH BUILDS
# Build applications one by one for better error handling and progress tracking

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

echo -e "${BLUE}🎯 SIMPLE SEQUENTIAL MULTI-ARCH BUILDS${NC}"
echo -e "${BLUE}📋 Building for platforms: ${BUILD_PLATFORMS}${NC}"
echo "================================================================="

# Function to build one application
build_single_app() {
    local app_name=$1
    local app_path="/Volumes/512-B/Documents/PERSONAL/full-stack-apps/${app_name}"
    
    echo -e "\n${YELLOW}🔨 Building: ${app_name}${NC}"
    echo "📂 Path: ${app_path}"
    
    if [ ! -f "${app_path}/Dockerfile" ]; then
        echo -e "${RED}❌ Dockerfile not found${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}🏗️  Starting build...${NC}"
    cd "${app_path}"
    
    # Build with timeout and better error handling
    timeout 1800 docker buildx build \
        --platform "${BUILD_PLATFORMS}" \
        --tag "${DOCKER_HUB_USERNAME}/${app_name}:latest" \
        --push \
        . || {
        echo -e "${RED}❌ Build failed or timed out (30 min limit)${NC}"
        return 1
    }
    
    echo -e "${GREEN}✅ Successfully built: ${DOCKER_HUB_USERNAME}/${app_name}:latest${NC}"
    
    # Verify multi-arch
    echo -e "${BLUE}🔍 Verifying multi-arch support:${NC}"
    docker buildx imagetools inspect "${DOCKER_HUB_USERNAME}/${app_name}:latest" | grep -E "(Platform)" | head -3
    
    return 0
}

# Function to show menu
show_menu() {
    echo -e "\n${BLUE}📋 Available Applications:${NC}"
    echo "1. medical-care-system (.NET Core + Blazor)"
    echo "2. task-management-app (Go + Svelte)" 
    echo "3. social-media-platform (Ruby + React Native)"
    echo "4. Build all remaining"
    echo "5. Exit"
    echo -e "${YELLOW}Choose option (1-5):${NC}"
}

# Main menu loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            echo -e "${BLUE}🏥 Building Medical Care System...${NC}"
            if build_single_app "medical-care-system"; then
                echo -e "${GREEN}🎉 Medical Care System build completed!${NC}"
            else
                echo -e "${RED}💥 Medical Care System build failed${NC}"
            fi
            ;;
        2)
            echo -e "${BLUE}✅ Building Task Management App...${NC}"
            if build_single_app "task-management-app"; then
                echo -e "${GREEN}🎉 Task Management App build completed!${NC}"
            else
                echo -e "${RED}💥 Task Management App build failed${NC}"
            fi
            ;;
        3)
            echo -e "${BLUE}📱 Building Social Media Platform...${NC}"
            if build_single_app "social-media-platform"; then
                echo -e "${GREEN}🎉 Social Media Platform build completed!${NC}"
            else
                echo -e "${RED}💥 Social Media Platform build failed${NC}"
            fi
            ;;
        4)
            echo -e "${BLUE}🚀 Building all remaining applications...${NC}"
            apps=("medical-care-system" "task-management-app" "social-media-platform")
            successful=0
            
            for app in "${apps[@]}"; do
                echo -e "\n${BLUE}════════════════════════════════════════${NC}"
                if build_single_app "$app"; then
                    ((successful++))
                    echo -e "${GREEN}✅ $app: SUCCESS${NC}"
                else
                    echo -e "${RED}❌ $app: FAILED${NC}"
                fi
            done
            
            echo -e "\n${BLUE}📊 FINAL RESULTS:${NC}"
            echo -e "${GREEN}✅ Successful: ${successful}/3${NC}"
            echo -e "${RED}❌ Failed: $((3-successful))/3${NC}"
            
            if [ $successful -eq 3 ]; then
                echo -e "\n${GREEN}🎉 ALL BUILDS COMPLETED SUCCESSFULLY!${NC}"
                echo -e "${GREEN}🌍 Complete multi-arch Docker image set ready!${NC}"
            fi
            ;;
        5)
            echo -e "${BLUE}👋 Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option. Please choose 1-5.${NC}"
            ;;
    esac
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
done