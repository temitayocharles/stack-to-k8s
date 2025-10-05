#!/bin/bash
# 📊 Multi-Arch Build Status Monitor
# Real-time monitoring of GitHub Actions builds

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

GITHUB_REPO="temitayocharles/full-stack-apps"

echo -e "${BOLD}${BLUE}📊 MULTI-ARCH BUILD STATUS MONITOR${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

# Check GitHub CLI
if ! command -v gh >/dev/null 2>&1; then
    echo -e "${RED}❌ GitHub CLI not found${NC}"
    exit 1
fi

# Monitor function
monitor_builds() {
    while true; do
        clear
        echo -e "${BOLD}${BLUE}📊 MULTI-ARCH BUILD STATUS MONITOR${NC}"
        echo -e "${BLUE}═══════════════════════════════════════${NC}"
        echo -e "${CYAN}Repository: ${GITHUB_REPO}${NC}"
        echo -e "${CYAN}Updated: $(date)${NC}"
        echo ""
        
        # Get recent workflow runs
        echo -e "${YELLOW}🏃 Recent Workflow Runs:${NC}"
        gh run list --repo "$GITHUB_REPO" --limit 10 --json status,conclusion,name,createdAt,url | \
        jq -r '.[] | "\(.status) | \(.conclusion // "running") | \(.name) | \(.createdAt) | \(.url)"' | \
        while IFS='|' read -r status conclusion name created_at url; do
            # Status emoji
            case "$status" in
                "completed")
                    if [ "$conclusion" = "success" ]; then
                        status_emoji="✅"
                    elif [ "$conclusion" = "failure" ]; then
                        status_emoji="❌"
                    else
                        status_emoji="⚠️"
                    fi
                    ;;
                "in_progress")
                    status_emoji="🔄"
                    ;;
                *)
                    status_emoji="⏳"
                    ;;
            esac
            
            echo -e "${status_emoji} ${name} (${created_at})"
        done
        
        echo ""
        echo -e "${YELLOW}🐳 Docker Hub Images Status:${NC}"
        
        # Check Docker Hub images
        declare -a images=(
            "ecommerce-backend" "ecommerce-frontend"
            "educational-backend" "educational-frontend"
            "weather-backend" "weather-frontend"
            "medical-api" "medical-frontend"
            "task-backend" "task-frontend"
            "social-backend" "social-frontend"
        )
        
        for image in "${images[@]}"; do
            if curl -s "https://hub.docker.com/v2/repositories/temitayocharles/${image}/tags/latest/" | grep -q '"name":"latest"'; then
                echo -e "✅ temitayocharles/${image}:latest"
            else
                echo -e "❌ temitayocharles/${image}:latest"
            fi
        done
        
        echo ""
        echo -e "${CYAN}Press Ctrl+C to exit | Auto-refresh in 30s${NC}"
        sleep 30
    done
}

# Start monitoring
monitor_builds