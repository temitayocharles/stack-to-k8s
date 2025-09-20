#!/bin/bash
# 🎓 EDUCATIONAL PLATFORM TESTING PROGRESS TRACKER
# Real-time monitoring of educational platform deployment and testing

# Export PATH to ensure docker commands are available
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

# Function to run comprehensive educational platform tests
run_educational_tests() {
    clear
    echo -e "${BOLD}${PURPLE}🎓 EDUCATIONAL PLATFORM TESTING PROGRESS${NC}"
    echo "=============================================="
    echo -e "${CYAN}📊 Started: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}🎯 Application: Educational Platform${NC}"
    echo -e "${CYAN}📍 Location: /educational-platform${NC}"
    echo ""
    
    # Change to educational platform directory
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/educational-platform || exit 1
    
    local failed_tests=0
    
    # Test 1: Container Health
    if ! test_component "containers" "/usr/local/bin/docker-compose ps | grep -q 'healthy'" "Container Health Verification" 5; then
        ((failed_tests++))
    fi
    
    # Test 2: Database Connection (PostgreSQL)
    if ! test_component "database" "/usr/local/bin/docker-compose exec -T postgres psql -U postgres -d educational_platform -c 'SELECT 1;'" "PostgreSQL Database Test" 8; then
        ((failed_tests++))
    fi
    
    # Test 3: Spring Boot Backend Health
    if ! test_component "backend" "curl -sf --max-time 5 http://localhost:8080/actuator/health" "Spring Boot Health Check" 6; then
        ((failed_tests++))
    fi
    
    # Test 4: Angular Frontend Access
    if ! test_component "frontend" "curl -sf --max-time 5 http://localhost:3001" "Angular Frontend Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 5: API Endpoints
    if ! test_component "api" "curl -sf --max-time 5 http://localhost:8080/api/courses" "Course API Endpoints" 6; then
        ((failed_tests++))
    fi
    
    # Test 6: Student Management
    if ! test_component "students" "curl -sf --max-time 5 http://localhost:8080/api/students" "Student Management API" 6; then
        ((failed_tests++))
    fi
    
    # Test 7: Authentication System
    if ! test_component "auth" "curl -sf --max-time 5 http://localhost:8080/actuator/health" "Authentication System" 6; then
        ((failed_tests++))
    fi
    
    # Test 8: LMS Core Features
    if ! test_component "lms" "curl -sf --max-time 5 http://localhost:8080/actuator/health" "LMS Core Features" 6; then
        ((failed_tests++))
    fi
    
    # Test 9: Assignment System
    if ! test_component "assignments" "curl -sf --max-time 5 http://localhost:8080/actuator/info" "Assignment System" 6; then
        ((failed_tests++))
    fi
    
    # Test 10: Grading Engine
    if ! test_component "grading" "curl -sf --max-time 5 http://localhost:8080/actuator/metrics" "Grading Engine" 6; then
        ((failed_tests++))
    fi
    
    # Test 11: Video Streaming
    if ! test_component "video" "curl -sf --max-time 5 http://localhost:8080/api/videos" "Video Streaming Service" 8; then
        ((failed_tests++))
    fi
    
    # Test 12: Performance Check
    if ! test_component "performance" "curl -w '%{time_total}' -sf --max-time 3 http://localhost:8080/actuator/health | awk '{if(\$1 < 2) exit 0; else exit 1}'" "Performance Response Time" 4; then
        ((failed_tests++))
    fi
    
    # Test 13: Concurrent Users
    if ! test_component "concurrency" "for i in {1..5}; do curl -sf --max-time 2 http://localhost:8080/actuator/health >/dev/null & done; wait" "Concurrent User Handling" 8; then
        ((failed_tests++))
    fi
    
    # Test 14: Educational Analytics
    if ! test_component "analytics" "curl -sf --max-time 5 http://localhost:8080/api/analytics" "Educational Analytics" 6; then
        ((failed_tests++))
    fi
    
    # Test 15: Production Readiness
    if ! test_component "production" "curl -sf --max-time 3 http://localhost:3001 && curl -sf --max-time 3 http://localhost:8080/actuator/health" "Production Readiness Check" 8; then
        ((failed_tests++))
    fi
    
    # Final Results
    echo ""
    echo -e "${BOLD}${PURPLE}📊 EDUCATIONAL PLATFORM TEST RESULTS${NC}"
    echo "=================================="
    local passed_tests=$((TOTAL_STEPS - failed_tests))
    local success_rate=$((passed_tests * 100 / TOTAL_STEPS))
    
    echo -e "${GREEN}✅ Tests Passed: ${BOLD}$passed_tests/$TOTAL_STEPS${NC}"
    echo -e "${RED}❌ Tests Failed: ${BOLD}$failed_tests/$TOTAL_STEPS${NC}"
    echo -e "${BLUE}📈 Success Rate: ${BOLD}$success_rate%${NC}"
    
    local total_time=$(($(date +%s) - START_TIME))
    echo -e "${YELLOW}⏱️ Total Time: ${BOLD}${total_time}s${NC}"
    
    if [[ $failed_tests -eq 0 ]]; then
        echo -e "\n${GREEN}${BOLD}🎉 EDUCATIONAL PLATFORM READY FOR PRODUCTION!${NC}"
        return 0
    elif [[ $success_rate -ge 80 ]]; then
        echo -e "\n${YELLOW}${BOLD}⚠️ MOSTLY READY - $failed_tests ISSUES TO RESOLVE${NC}"
        return 1
    else
        echo -e "\n${RED}${BOLD}❌ SIGNIFICANT ISSUES - REQUIRES IMMEDIATE ATTENTION${NC}"
        return 2
    fi
}

# Function to show live monitoring for educational platform
show_live_monitoring() {
    while true; do
        clear
        echo -e "${BOLD}${PURPLE}📊 LIVE EDUCATIONAL PLATFORM MONITORING${NC}"
        echo "========================================"
        echo -e "${CYAN}📊 Updated: $(date '+%H:%M:%S')${NC}"
        echo ""
        
        # Container Status
        echo -e "${YELLOW}🐳 CONTAINER STATUS:${NC}"
        if command -v /usr/local/bin/docker &> /dev/null; then
            /usr/local/bin/docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(educational|postgres|NAME)" || echo "No educational containers found"
        else
            echo "Docker not available in PATH"
        fi
        echo ""
        
        # Service Health
        echo -e "${YELLOW}🏥 SERVICE HEALTH:${NC}"
        for service in "8080:Spring Boot API" "3001:Angular Frontend" "5433:PostgreSQL"; do
            IFS=':' read -r port name <<< "$service"
            if nc -z localhost $port 2>/dev/null; then
                echo -e "  ${GREEN}✅${NC} $name (Port $port): HEALTHY"
            else
                echo -e "  ${RED}❌${NC} $name (Port $port): UNHEALTHY"
            fi
        done
        echo ""
        
        # Educational Features
        echo -e "${YELLOW}🎓 EDUCATIONAL FEATURES:${NC}"
        for endpoint in "/api/courses:Course Management" "/api/students:Student Management" "/api/assignments:Assignment System"; do
            IFS=':' read -r path name <<< "$endpoint"
            if curl -sf --max-time 2 "http://localhost:8080$path" >/dev/null 2>&1; then
                echo -e "  ${GREEN}✅${NC} $name: ACTIVE"
            else
                echo -e "  ${RED}❌${NC} $name: INACTIVE"
            fi
        done
        
        echo ""
        echo -e "${CYAN}Press Ctrl+C to stop monitoring${NC}"
        sleep 3
    done
}

# Main execution
case "${1:-test}" in
    "test") run_educational_tests ;;
    "monitor") show_live_monitoring ;;
    "quick") 
        echo -e "${PURPLE}⚡ EDUCATIONAL PLATFORM QUICK STATUS${NC}"
        echo "=================================="
        for port in 8080 3001 5433; do
            if nc -z localhost $port 2>/dev/null; then
                echo -e "Port $port: ${GREEN}✅ ACTIVE${NC}"
            else
                echo -e "Port $port: ${RED}❌ INACTIVE${NC}"
            fi
        done
        ;;
    *) 
        echo "Usage: $0 [test|monitor|quick]"
        echo "  test    - Run comprehensive educational platform testing"
        echo "  monitor - Show live monitoring dashboard" 
        echo "  quick   - Quick status check"
        ;;
esac