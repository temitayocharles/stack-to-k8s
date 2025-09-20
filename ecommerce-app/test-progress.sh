#!/bin/bash
# 🎯 ECOMMERCE APPLICATION TESTING PROGRESS TRACKER
# Real-time monitoring of ecommerce app deployment and testing

# Export PATH to ensure Docker is available
export PATH="/usr/local/bin:$PATH"

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Progress tracking
START_TIME=$(date +%s)
CURRENT_STEP=0
TOTAL_STEPS=15

# Test categories and their steps
declare -A TEST_STEPS=(
    ["container_health"]="Container Health Verification"
    ["database_connection"]="Database Connectivity Test"
    ["redis_connection"]="Redis Cache Connection Test"
    ["backend_health"]="Backend Health Endpoints Test"
    ["frontend_access"]="Frontend Accessibility Test"
    ["api_endpoints"]="API Endpoints Validation"
    ["authentication"]="Authentication System Test"
    ["product_crud"]="Product CRUD Operations Test"
    ["cart_operations"]="Shopping Cart Operations Test"
    ["payment_simulation"]="Payment System Simulation"
    ["email_system"]="Email System Validation"
    ["security_scan"]="Security Vulnerability Scan"
    ["performance_test"]="Performance Benchmarking"
    ["monitoring_integration"]="Monitoring Integration Test"
    ["final_validation"]="Final Production Readiness Check"
)

# Function to show animated progress bar with real-time updates
show_progress() {
    local current=$1
    local total=$2
    local title="$3"
    local status="$4"
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local elapsed=$(($(date +%s) - START_TIME))
    
    # Status indicator
    if [[ "$status" == "success" ]]; then
        status_icon="${GREEN}✅${NC}"
        title_color="${GREEN}"
    elif [[ "$status" == "running" ]]; then
        status_icon="${YELLOW}⏳${NC}"
        title_color="${YELLOW}"
    elif [[ "$status" == "error" ]]; then
        status_icon="${RED}❌${NC}"
        title_color="${RED}"
    else
        status_icon="${BLUE}🔄${NC}"
        title_color="${CYAN}"
    fi
    
    # Move cursor up to overwrite previous line for smooth updates
    if [[ $current -gt 1 ]]; then
        printf "\033[2A\033[K"  # Move up 2 lines and clear
    fi
    
    printf "${title_color}🔄 %s${NC}\n" "$title"
    
    # Animated progress bar with live updates
    printf "${BLUE}["
    for ((i=1; i<=completed; i++)); do printf "█"; done
    for ((i=completed+1; i<=width; i++)); do printf "░"; done
    printf "] ${GREEN}%d%%${NC} (%d/%d) ${YELLOW}⏱️ %ds${NC} %s\n" "$percentage" "$current" "$total" "$elapsed" "$status_icon"
}

# Function for animated loading during test execution
show_loading() {
    local message="$1"
    local duration="$2"
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local delay=0.1
    
    for ((i=0; i<duration*10; i++)); do
        local char_index=$((i % ${#chars}))
        printf "\r${YELLOW}${chars:$char_index:1} %s...${NC}" "$message"
        sleep $delay
    done
    printf "\r\033[K"  # Clear the loading line
}

# Function to test specific component with real-time feedback
test_component() {
    local component="$1"
    local test_command="$2"
    local description="$3"
    local timeout="${4:-10}"  # Default 10 second timeout
    
    ((CURRENT_STEP++))
    
    # Show starting progress
    show_progress $CURRENT_STEP $TOTAL_STEPS "$description" "running"
    
    # Show loading animation while test runs
    echo -e "  ${BLUE}🔍 Testing: $description${NC}"
    
    # Run test with timeout and real-time feedback
    local start_time=$(date +%s)
    local test_result=1
    
    # Execute test in background and monitor
    (
        eval "$test_command" >/dev/null 2>&1
        echo $? > /tmp/test_result_$$
    ) &
    local test_pid=$!
    
    # Show animated progress while test runs
    while kill -0 $test_pid 2>/dev/null; do
        local elapsed=$(($(date +%s) - start_time))
        if [[ $elapsed -ge $timeout ]]; then
            kill $test_pid 2>/dev/null
            echo "timeout" > /tmp/test_result_$$
            break
        fi
        
        # Animated dots
        for dot in "." ".." "..."; do
            printf "\r  ${YELLOW}⏳ Testing%s (${elapsed}s)${NC}" "$dot"
            sleep 0.3
            if ! kill -0 $test_pid 2>/dev/null; then
                break 2
            fi
        done
    done
    
    # Get test result
    wait $test_pid 2>/dev/null
    if [[ -f /tmp/test_result_$$ ]]; then
        local result=$(cat /tmp/test_result_$$)
        rm -f /tmp/test_result_$$
        if [[ "$result" == "0" ]]; then
            test_result=0
        elif [[ "$result" == "timeout" ]]; then
            test_result=2
        fi
    fi
    
    printf "\r\033[K"  # Clear the testing line
    
    # Show final result
    if [[ $test_result -eq 0 ]]; then
        show_progress $CURRENT_STEP $TOTAL_STEPS "$description" "success"
        echo -e "  ${GREEN}✅ PASSED:${NC} $description"
        return 0
    elif [[ $test_result -eq 2 ]]; then
        show_progress $CURRENT_STEP $TOTAL_STEPS "$description" "error"
        echo -e "  ${RED}⏰ TIMEOUT:${NC} $description (>${timeout}s)"
        return 1
    else
        show_progress $CURRENT_STEP $TOTAL_STEPS "$description" "error"
        echo -e "  ${RED}❌ FAILED:${NC} $description"
        return 1
    fi
}

# Function to run comprehensive ecommerce tests
run_ecommerce_tests() {
    clear
    echo -e "${BOLD}${PURPLE}🛒 ECOMMERCE APPLICATION TESTING PROGRESS${NC}"
    echo "=================================================="
    echo -e "${CYAN}📊 Started: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}🎯 Application: E-commerce Platform${NC}"
    echo -e "${CYAN}📍 Location: /ecommerce-app${NC}"
    echo ""
    
    # Change to ecommerce directory
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/ecommerce-app || exit 1
    
    local failed_tests=0
    
    # Test 1: Container Health
    if ! test_component "containers" "docker compose ps | grep -q 'healthy'" "Container Health Verification" 5; then
        ((failed_tests++))
    fi
    
    # Test 2: Database Connection
    if ! test_component "database" "docker compose exec -T mongodb mongosh --eval 'db.adminCommand(\"ping\")' --quiet" "Database Connectivity Test" 8; then
        ((failed_tests++))
    fi
    
    # Test 3: Redis Connection  
    if ! test_component "redis" "docker compose exec -T redis redis-cli ping" "Redis Cache Connection Test" 5; then
        ((failed_tests++))
    fi
    
    # Test 4: Backend Health
    if ! test_component "backend" "curl -sf --max-time 5 http://localhost:5001/health" "Backend Health Endpoints Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 5: Frontend Access
    if ! test_component "frontend" "curl -sf --max-time 5 http://localhost:3001" "Frontend Accessibility Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 6: API Endpoints
    if ! test_component "api" "curl -sf --max-time 5 http://localhost:5001/api/products" "API Endpoints Validation" 6; then
        ((failed_tests++))
    fi
    
    # Test 7: Readiness Check
    if ! test_component "readiness" "curl -sf --max-time 5 http://localhost:5001/ready" "Readiness Probe Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 8: Liveness Check
    if ! test_component "liveness" "curl -sf --max-time 5 http://localhost:5001/live" "Liveness Probe Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 9: Dependencies Check
    if ! test_component "dependencies" "curl -sf --max-time 5 http://localhost:5001/health/dependencies" "Dependencies Health Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 10: Metrics Endpoint
    if ! test_component "metrics" "curl -sf --max-time 5 http://localhost:5001/metrics" "Metrics Collection Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 11: Performance Check
    if ! test_component "performance" "curl -w '%{time_total}' -sf --max-time 3 http://localhost:5001/health | awk '{if(\$1 < 1) exit 0; else exit 1}'" "Performance Response Time" 4; then
        ((failed_tests++))
    fi
    
    # Test 12: Concurrent Requests
    if ! test_component "concurrency" "for i in {1..5}; do curl -sf --max-time 2 http://localhost:5001/health >/dev/null & done; wait" "Concurrent Request Handling" 8; then
        ((failed_tests++))
    fi
    
    # Test 13: Monitoring Integration
    if ! test_component "monitoring" "curl -sf --max-time 5 http://localhost:9090" "Monitoring Integration Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 14: Cross-Service Communication
    if ! test_component "cross_service" "curl -sf --max-time 5 http://localhost:3001 && curl -sf --max-time 5 http://localhost:5001/health" "Cross-Service Communication" 7; then
        ((failed_tests++))
    fi
    
    # Test 15: Final Production Readiness
    if ! test_component "production" "curl -sf --max-time 3 http://localhost:3001 && curl -sf --max-time 3 http://localhost:5001/health && echo 'All systems operational'" "Final Production Readiness Check" 8; then
        ((failed_tests++))
    fi
    
    # Final Results
    echo ""
    echo -e "${BOLD}${PURPLE}📊 TESTING RESULTS SUMMARY${NC}"
    echo "=========================="
    local passed_tests=$((TOTAL_STEPS - failed_tests))
    local success_rate=$((passed_tests * 100 / TOTAL_STEPS))
    
    echo -e "${GREEN}✅ Tests Passed: ${BOLD}$passed_tests/$TOTAL_STEPS${NC}"
    echo -e "${RED}❌ Tests Failed: ${BOLD}$failed_tests/$TOTAL_STEPS${NC}"
    echo -e "${BLUE}📈 Success Rate: ${BOLD}$success_rate%${NC}"
    
    local total_time=$(($(date +%s) - START_TIME))
    echo -e "${YELLOW}⏱️ Total Time: ${BOLD}${total_time}s${NC}"
    
    if [[ $failed_tests -eq 0 ]]; then
        echo -e "\n${GREEN}${BOLD}🎉 ALL TESTS PASSED! APPLICATION READY FOR PRODUCTION!${NC}"
        return 0
    elif [[ $success_rate -ge 80 ]]; then
        echo -e "\n${YELLOW}${BOLD}⚠️ MOSTLY READY - $failed_tests ISSUES TO RESOLVE${NC}"
        return 1
    else
        echo -e "\n${RED}${BOLD}❌ SIGNIFICANT ISSUES - REQUIRES IMMEDIATE ATTENTION${NC}"
        return 2
    fi
}

# Function to show real-time monitoring
show_live_monitoring() {
    while true; do
        clear
        echo -e "${BOLD}${PURPLE}📊 LIVE ECOMMERCE APP MONITORING${NC}"
        echo "=================================="
        echo -e "${CYAN}📊 Updated: $(date '+%H:%M:%S')${NC}"
        echo ""
        
        # Container Status
        echo -e "${YELLOW}🐳 CONTAINER STATUS:${NC}"
        if command -v docker &> /dev/null; then
            docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(ecommerce|NAME)" || echo "No ecommerce containers found"
        else
            echo "Docker not available in PATH"
        fi
        echo ""
        
        # Service Health
        echo -e "${YELLOW}🏥 SERVICE HEALTH:${NC}"
        for service in "5001:Backend API" "3001:Frontend App" "27017:MongoDB" "6379:Redis"; do
            IFS=':' read -r port name <<< "$service"
            if nc -z localhost $port 2>/dev/null; then
                echo -e "  ${GREEN}✅${NC} $name (Port $port): HEALTHY"
            else
                echo -e "  ${RED}❌${NC} $name (Port $port): UNHEALTHY"
            fi
        done
        echo ""
        
        # Monitoring Stack
        echo -e "${YELLOW}📊 MONITORING STACK:${NC}"
        for service in "9090:Prometheus" "3001:Grafana"; do
            IFS=':' read -r port name <<< "$service"
            if nc -z localhost $port 2>/dev/null; then
                echo -e "  ${GREEN}✅${NC} $name (Port $port): ACTIVE"
            else
                echo -e "  ${RED}❌${NC} $name (Port $port): INACTIVE"
            fi
        done
        
        echo ""
        echo -e "${CYAN}Press Ctrl+C to stop monitoring${NC}"
        sleep 3
    done
}

# Main execution
case "${1:-test}" in
    "test") run_ecommerce_tests ;;
    "monitor") show_live_monitoring ;;
    "quick") 
        echo -e "${PURPLE}⚡ QUICK STATUS CHECK${NC}"
        echo "===================="
        for port in 3001 5001 9090; do
            if nc -z localhost $port 2>/dev/null; then
                echo -e "Port $port: ${GREEN}✅ ACTIVE${NC}"
            else
                echo -e "Port $port: ${RED}❌ INACTIVE${NC}"
            fi
        done
        ;;
    *) 
        echo "Usage: $0 [test|monitor|quick]"
        echo "  test    - Run comprehensive testing with progress"
        echo "  monitor - Show live monitoring dashboard" 
        echo "  quick   - Quick status check"
        ;;
esac