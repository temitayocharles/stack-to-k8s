#!/bin/bash
# 🎯 REAL-TIME PROGRESS MONITOR
# Shows live updates of what's happening in background

export PATH="/usr/local/bin:$PATH"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Function to show spinning indicator
show_spinner() {
    local message="$1"
    local delay=0.1
    local spinstr='|/-\'
    
    while true; do
        for ((i=0; i<${#spinstr}; i++)); do
            printf "\r${YELLOW}%s %s${NC}" "${spinstr:$i:1}" "$message"
            sleep $delay
        done
    done
}

# Function to monitor in real-time
monitor_progress() {
    clear
    echo -e "${BOLD}${PURPLE}⚡ REAL-TIME TESTING MONITOR${NC}"
    echo "============================"
    echo ""
    
    local step=1
    while true; do
        # Clear previous content but keep header
        printf "\033[4;0H\033[J"  # Move to line 4 and clear below
        
        echo -e "${CYAN}📊 Monitoring Step: $step${NC}"
        echo -e "${CYAN}🕐 Time: $(date '+%H:%M:%S')${NC}"
        echo ""
        
        # Check container status
        echo -e "${YELLOW}🐳 CONTAINERS:${NC}"
        if docker ps --format "{{.Names}}: {{.Status}}" | grep ecommerce; then
            echo -e "  ${GREEN}✅ Containers are running${NC}"
        else
            echo -e "  ${RED}❌ Containers not found${NC}"
        fi
        echo ""
        
        # Check services
        echo -e "${YELLOW}🌐 SERVICES:${NC}"
        for port in 5001 3001 9090; do
            if nc -z localhost $port 2>/dev/null; then
                echo -e "  ${GREEN}✅${NC} Port $port: ACTIVE"
            else
                echo -e "  ${RED}❌${NC} Port $port: DOWN"
            fi
        done
        echo ""
        
        # Check if tests are running
        echo -e "${YELLOW}🧪 TEST STATUS:${NC}"
        if pgrep -f "test-progress.sh" >/dev/null; then
            echo -e "  ${GREEN}✅ Tests are running${NC}"
        else
            echo -e "  ${BLUE}ℹ️ No tests currently running${NC}"
        fi
        echo ""
        
        # Show system load
        echo -e "${YELLOW}💻 SYSTEM:${NC}"
        echo -e "  Load: $(uptime | awk -F'load averages: ' '{print $2}')"
        echo ""
        
        echo -e "${CYAN}Press Ctrl+C to exit monitor${NC}"
        ((step++))
        sleep 2
    done
}

# Start monitoring
monitor_progress