#!/bin/bash
# 🎯 COMPREHENSIVE PROGRESS MONITORING SYSTEM
# Real-time tracking of all background processes and deployments

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Progress tracking variables
TOTAL_STEPS=0
CURRENT_STEP=0
START_TIME=$(date +%s)

# Function to show animated progress bar
show_progress() {
    local current=$1
    local total=$2
    local title="$3"
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local elapsed=$(($(date +%s) - START_TIME))
    
    printf "\n${CYAN}🔄 %s${NC}\n" "$title"
    printf "${BLUE}["
    for ((i=1; i<=completed; i++)); do printf "█"; done
    for ((i=completed+1; i<=width; i++)); do printf "░"; done
    printf "] ${GREEN}%d%%${NC} (%d/%d) ${YELLOW}⏱️ %ds${NC}\n" "$percentage" "$current" "$total" "$elapsed"
}

# Function to monitor Docker containers
monitor_containers() {
    echo -e "${PURPLE}🐳 CONTAINER STATUS MONITORING${NC}"
    echo "================================"
    
    while true; do
        clear
        echo -e "${PURPLE}🐳 REAL-TIME CONTAINER MONITORING${NC}"
        echo "=================================="
        echo -e "${CYAN}📊 Updated: $(date '+%H:%M:%S')${NC}"
        echo ""
        
        # Ecommerce App Containers
        echo -e "${YELLOW}🛒 ECOMMERCE APPLICATION:${NC}"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep ecommerce || echo "No ecommerce containers running"
        echo ""
        
        # Kubernetes Monitoring
        echo -e "${YELLOW}☸️ KUBERNETES MONITORING:${NC}"
        kubectl get pods -n monitoring --no-headers 2>/dev/null | while read line; do
            name=$(echo $line | awk '{print $1}')
            status=$(echo $line | awk '{print $3}')
            if [[ "$status" == "Running" ]]; then
                echo -e "  ${GREEN}✅${NC} $name: $status"
            else
                echo -e "  ${RED}❌${NC} $name: $status"
            fi
        done || echo "Kubernetes not accessible"
        echo ""
        
        # System Resources
        echo -e "${YELLOW}💻 SYSTEM RESOURCES:${NC}"
        echo -e "  CPU: $(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')"
        echo -e "  Memory: $(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')"
        echo ""
        
        # Port Status
        echo -e "${YELLOW}🌐 SERVICE ACCESSIBILITY:${NC}"
        for port in 3001 5001 9090; do
            if nc -z localhost $port 2>/dev/null; then
                echo -e "  ${GREEN}✅${NC} Port $port: ACCESSIBLE"
            else
                echo -e "  ${RED}❌${NC} Port $port: NOT ACCESSIBLE"
            fi
        done
        
        echo ""
        echo -e "${CYAN}Press Ctrl+C to stop monitoring${NC}"
        sleep 3
    done
}

# Function to monitor health endpoints
monitor_health() {
    echo -e "${PURPLE}🏥 HEALTH ENDPOINT MONITORING${NC}"
    echo "==============================="
    
    local endpoints=(
        "http://localhost:5001/health:Ecommerce Backend"
        "http://localhost:3001:Ecommerce Frontend"
        "http://localhost:9090:Prometheus"
    )
    
    while true; do
        clear
        echo -e "${PURPLE}🏥 REAL-TIME HEALTH MONITORING${NC}"
        echo "==============================="
        echo -e "${CYAN}📊 Updated: $(date '+%H:%M:%S')${NC}"
        echo ""
        
        for endpoint_info in "${endpoints[@]}"; do
            IFS=':' read -r url name <<< "$endpoint_info"
            
            if curl -s -f "$url" > /dev/null 2>&1; then
                response_time=$(curl -s -w "%{time_total}" -o /dev/null "$url")
                echo -e "  ${GREEN}✅${NC} $name: HEALTHY (${response_time}s)"
            else
                echo -e "  ${RED}❌${NC} $name: UNHEALTHY"
            fi
        done
        
        echo ""
        echo -e "${CYAN}Press Ctrl+C to stop monitoring${NC}"
        sleep 5
    done
}

# Function to show deployment progress
show_deployment_progress() {
    local app_name="$1"
    local total_steps="$2"
    
    echo -e "${PURPLE}🚀 DEPLOYMENT PROGRESS: $app_name${NC}"
    echo "======================================="
    
    for ((step=1; step<=total_steps; step++)); do
        case $step in
            1) task="Checking dependencies" ;;
            2) task="Building containers" ;;
            3) task="Starting services" ;;
            4) task="Health checks" ;;
            5) task="Network validation" ;;
            6) task="Security scanning" ;;
            7) task="Performance testing" ;;
            8) task="Final validation" ;;
            *) task="Additional verification" ;;
        esac
        
        show_progress $step $total_steps "$task"
        
        # Simulate realistic deployment timing
        case $step in
            2) sleep 3 ;; # Building takes longer
            3) sleep 2 ;; # Starting services
            *) sleep 1 ;; # Other steps
        esac
    done
    
    echo -e "\n${GREEN}✅ DEPLOYMENT COMPLETE: $app_name${NC}"
}

# Function to monitor log files
monitor_logs() {
    echo -e "${PURPLE}📋 LOG MONITORING${NC}"
    echo "=================="
    
    # Create logs directory if it doesn't exist
    mkdir -p /tmp/progress-logs
    
    while true; do
        clear
        echo -e "${PURPLE}📋 REAL-TIME LOG MONITORING${NC}"
        echo "==========================="
        echo -e "${CYAN}📊 Updated: $(date '+%H:%M:%S')${NC}"
        echo ""
        
        # Docker logs
        echo -e "${YELLOW}🐳 CONTAINER LOGS (Last 5 lines):${NC}"
        for container in ecommerce-backend ecommerce-frontend; do
            if docker ps --format "{{.Names}}" | grep -q "$container"; then
                echo -e "${BLUE}[$container]${NC}"
                docker logs --tail 2 "$container" 2>/dev/null | sed 's/^/  /'
                echo ""
            fi
        done
        
        # System logs
        echo -e "${YELLOW}📊 SYSTEM STATUS:${NC}"
        echo -e "  Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
        echo -e "  Load: $(uptime | awk -F'load averages: ' '{print $2}')"
        
        echo ""
        echo -e "${CYAN}Press Ctrl+C to stop monitoring${NC}"
        sleep 4
    done
}

# Main menu
show_menu() {
    clear
    echo -e "${PURPLE}🎯 PROGRESS MONITORING SYSTEM${NC}"
    echo "=============================="
    echo ""
    echo -e "${CYAN}Available monitoring options:${NC}"
    echo -e "  ${GREEN}1${NC}) Container Status Monitor"
    echo -e "  ${GREEN}2${NC}) Health Endpoint Monitor" 
    echo -e "  ${GREEN}3${NC}) Deployment Progress Demo"
    echo -e "  ${GREEN}4${NC}) Log File Monitor"
    echo -e "  ${GREEN}5${NC}) All-in-One Dashboard"
    echo -e "  ${GREEN}q${NC}) Quit"
    echo ""
    read -p "Select option [1-5,q]: " choice
    
    case $choice in
        1) monitor_containers ;;
        2) monitor_health ;;
        3) 
            read -p "Enter application name: " app_name
            read -p "Enter number of steps [8]: " steps
            show_deployment_progress "$app_name" "${steps:-8}"
            ;;
        4) monitor_logs ;;
        5) 
            echo "Starting comprehensive dashboard..."
            (monitor_containers &)
            (monitor_health &)
            wait
            ;;
        q|Q) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option"; sleep 1; show_menu ;;
    esac
}

# Quick monitoring function for immediate feedback
quick_status() {
    echo -e "${PURPLE}⚡ QUICK STATUS CHECK${NC}"
    echo "===================="
    
    # Docker containers
    echo -e "${YELLOW}🐳 Containers:${NC}"
    docker ps --format "  {{.Names}}: {{.Status}}" | head -10
    
    # Kubernetes pods
    echo -e "\n${YELLOW}☸️ Kubernetes:${NC}"
    kubectl get pods -n monitoring --no-headers 2>/dev/null | awk '{print "  " $1 ": " $3}' || echo "  Not accessible"
    
    # Services
    echo -e "\n${YELLOW}🌐 Services:${NC}"
    for port in 3001 5001 9090; do
        if nc -z localhost $port 2>/dev/null; then
            echo -e "  Port $port: ${GREEN}✅ ACTIVE${NC}"
        else
            echo -e "  Port $port: ${RED}❌ INACTIVE${NC}"
        fi
    done
}

# Command line argument handling
case "${1:-menu}" in
    "containers") monitor_containers ;;
    "health") monitor_health ;;
    "logs") monitor_logs ;;
    "quick") quick_status ;;
    "deploy") show_deployment_progress "${2:-Application}" "${3:-8}" ;;
    *) show_menu ;;
esac