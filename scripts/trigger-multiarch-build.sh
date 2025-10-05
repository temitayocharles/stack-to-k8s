#!/bin/bash
# 🚀 GitHub Actions Multi-Arch Build Trigger
# Automated trigger for multi-architecture Docker builds

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}🚀 MULTI-ARCHITECTURE BUILD TRIGGER${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

# Configuration
GITHUB_REPO="temitayocharles/full-stack-apps"
WORKFLOW_FILE="build-multiarch.yml"

# Check if GitHub CLI is installed
if ! command -v gh >/dev/null 2>&1; then
    echo -e "${RED}❌ GitHub CLI (gh) not found. Please install it first.${NC}"
    echo -e "${YELLOW}   Visit: https://cli.github.com/${NC}"
    exit 1
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo -e "${RED}❌ Not authenticated with GitHub CLI${NC}"
    echo -e "${YELLOW}   Run: gh auth login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI authenticated${NC}"

# Get user input for build options
echo -e "\n${YELLOW}🔧 Build Configuration:${NC}"

# Force rebuild option
echo -e "${CYAN}Force rebuild all services? (y/N):${NC}"
read -r force_rebuild
if [[ $force_rebuild =~ ^[Yy]$ ]]; then
    FORCE_REBUILD="true"
else
    FORCE_REBUILD="false"
fi

# Platform selection
echo -e "\n${CYAN}Select target platforms:${NC}"
echo "1) Standard (linux/amd64,linux/arm64)"
echo "2) Extended (linux/amd64,linux/arm64,linux/arm/v7)"
echo "3) AMD64 only (linux/amd64)"
echo "4) Custom"
read -p "Choice (1-4) [2]: " platform_choice

case $platform_choice in
    1)
        PLATFORMS="linux/amd64,linux/arm64"
        ;;
    2|"")
        PLATFORMS="linux/amd64,linux/arm64,linux/arm/v7"
        ;;
    3)
        PLATFORMS="linux/amd64"
        ;;
    4)
        read -p "Enter custom platforms: " PLATFORMS
        ;;
    *)
        echo -e "${RED}Invalid choice. Using default.${NC}"
        PLATFORMS="linux/amd64,linux/arm64,linux/arm/v7"
        ;;
esac

echo -e "\n${YELLOW}📋 Build Summary:${NC}"
echo -e "   ${CYAN}Repository: ${GITHUB_REPO}${NC}"
echo -e "   ${CYAN}Workflow: ${WORKFLOW_FILE}${NC}"
echo -e "   ${CYAN}Force Rebuild: ${FORCE_REBUILD}${NC}"
echo -e "   ${CYAN}Platforms: ${PLATFORMS}${NC}"

echo -e "\n${YELLOW}🚀 Trigger build? (Y/n):${NC}"
read -r confirm
if [[ ! $confirm =~ ^[Nn]$ ]]; then
    echo -e "${BLUE}🚀 Triggering multi-architecture build...${NC}"
    
    gh workflow run "$WORKFLOW_FILE" \
        --repo "$GITHUB_REPO" \
        --field force_rebuild="$FORCE_REBUILD" \
        --field target_platforms="$PLATFORMS"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Build triggered successfully!${NC}"
        echo -e "\n${CYAN}🔍 Monitor progress:${NC}"
        echo -e "   ${YELLOW}GitHub Actions: https://github.com/$GITHUB_REPO/actions${NC}"
        echo -e "   ${YELLOW}Or run: gh run list --repo $GITHUB_REPO${NC}"
        
        # Wait and show recent runs
        echo -e "\n${YELLOW}📊 Recent workflow runs:${NC}"
        sleep 2
        gh run list --repo "$GITHUB_REPO" --limit 5
    else
        echo -e "${RED}❌ Failed to trigger build${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⏹️  Build cancelled${NC}"
fi

echo -e "\n${GREEN}🎯 Multi-architecture build system ready!${NC}"