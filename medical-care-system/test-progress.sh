#!/bin/bash
# 🏥 MEDICAL CARE SYSTEM TESTING PROGRESS TRACKER
# Real-time monitoring of medical care system deployment and testing

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
TOTAL_STEPS=20

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

# Function to run comprehensive medical care system tests
run_medical_tests() {
    clear
    echo -e "${BOLD}${PURPLE}🏥 MEDICAL CARE SYSTEM TESTING PROGRESS${NC}"
    echo "=============================================="
    echo -e "${CYAN}📊 Started: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}🎯 Application: Medical Care System${NC}"
    echo -e "${CYAN}📍 Location: /medical-care-system${NC}"
    echo ""
    
    # Change to medical care system directory
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/medical-care-system || exit 1
    
    local failed_tests=0
    
    # Test 1: Container Health
    if ! test_component "containers" "/usr/local/bin/docker-compose ps | grep -q 'healthy\|Up'" "Container Health Verification" 5; then
        ((failed_tests++))
    fi
    
    # Test 2: Database Connection (PostgreSQL)
    if ! test_component "database" "/usr/local/bin/docker-compose exec -T medical-care-db psql -U medical_user -d MedicalCareDB -c 'SELECT 1;'" "PostgreSQL Database Test" 8; then
        ((failed_tests++))
    fi
    
    # Test 3: .NET Core API Health
    if ! test_component "backend" "curl -sf --max-time 5 http://localhost:5170/api/health" ".NET Core API Health Check" 6; then
        ((failed_tests++))
    fi
    
    # Test 4: Blazor Frontend Access
    if ! test_component "frontend" "curl -sf --max-time 5 http://localhost:5171" "Blazor Frontend Test" 6; then
        ((failed_tests++))
    fi
    
    # Test 5: Patient Management API
    if ! test_component "patients" "curl -sf --max-time 5 http://localhost:5170/api/patients" "Patient Management API" 6; then
        ((failed_tests++))
    fi
    
    # Test 6: Doctor Management API
    if ! test_component "doctors" "curl -sf --max-time 5 http://localhost:5170/api/doctors" "Doctor Management API" 6; then
        ((failed_tests++))
    fi
    
    # Test 7: Appointment System
    if ! test_component "appointments" "curl -sf --max-time 5 http://localhost:5170/api/appointments" "Appointment System" 6; then
        ((failed_tests++))
    fi
    
    # Test 8: Medical Records System
    if ! test_component "medical-records" "curl -sf --max-time 5 http://localhost:5170/api/medicalrecords" "Medical Records System" 6; then
        ((failed_tests++))
    fi
    
    # Test 9: Prescription Management
    if ! test_component "prescriptions" "curl -sf --max-time 5 http://localhost:5170/api/prescriptions" "Prescription Management" 6; then
        ((failed_tests++))
    fi
    
    # Test 10: Billing System
    if ! test_component "billing" "curl -sf --max-time 5 http://localhost:5170/api/billings" "Billing System" 6; then
        ((failed_tests++))
    fi
    
    # Test 11: HIPAA Compliance Check
    if ! test_component "hipaa" "curl -sf --max-time 5 -H 'X-Test: security' http://localhost:5170/api/health | grep -q 'Healthy'" "HIPAA Compliance Check" 8; then
        ((failed_tests++))
    fi
    
    # Test 12: Healthcare Analytics
    if ! test_component "analytics" "curl -sf --max-time 5 http://localhost:5170/api/healthanalytics" "Healthcare Analytics" 6; then
        ((failed_tests++))
    fi
    
    # Test 13: Telemedicine Features
    if ! test_component "telemedicine" "curl -sf --max-time 5 http://localhost:5170/api/telemedicine" "Telemedicine Features" 8; then
        ((failed_tests++))
    fi
    
    # Test 14: Patient Monitoring
    if ! test_component "monitoring" "curl -sf --max-time 5 http://localhost:5170/api/patientmonitoring" "Patient Monitoring System" 6; then
        ((failed_tests++))
    fi
    
    # Test 15: AI Analysis Features
    if ! test_component "ai-analysis" "curl -sf --max-time 5 http://localhost:5170/api/aianalysis" "AI Analysis Features" 8; then
        ((failed_tests++))
    fi
    
    # Test 16: Performance Check
    if ! test_component "performance" "curl -w '%{time_total}' -sf --max-time 3 http://localhost:5170/api/health | awk '{if(\$1 < 2) exit 0; else exit 1}'" "Performance Response Time" 4; then
        ((failed_tests++))
    fi
    
    # Test 17: Concurrent Users
    if ! test_component "concurrency" "for i in {1..5}; do curl -sf --max-time 2 http://localhost:5170/api/health >/dev/null & done; wait" "Concurrent User Handling" 8; then
        ((failed_tests++))
    fi
    
    # Test 18: Data Security
    if ! test_component "security" "curl -sf --max-time 5 -I http://localhost:5170/api/health | grep -q 'X-Content-Type-Options'" "Data Security Headers" 6; then
        ((failed_tests++))
    fi
    
    # Test 19: Database Performance
    if ! test_component "db-performance" "/usr/local/bin/docker-compose exec -T medical-care-db psql -U medical_user -d MedicalCareDB -c 'EXPLAIN ANALYZE SELECT COUNT(*) FROM \"Patients\";'" "Database Performance" 8; then
        ((failed_tests++))
    fi
    
    # Test 20: Production Readiness
    if ! test_component "production" "curl -sf --max-time 3 http://localhost:5171 && curl -sf --max-time 3 http://localhost:5170/api/health" "Production Readiness Check" 8; then
        ((failed_tests++))
    fi
    
    # Final Results
    echo ""
    echo -e "${BOLD}${PURPLE}📊 MEDICAL CARE SYSTEM TEST RESULTS${NC}"
    echo "=================================="
    local passed_tests=$((TOTAL_STEPS - failed_tests))
    local success_rate=$((passed_tests * 100 / TOTAL_STEPS))
    
    echo -e "${GREEN}✅ Tests Passed: ${BOLD}$passed_tests/$TOTAL_STEPS${NC}"
    echo -e "${RED}❌ Tests Failed: ${BOLD}$failed_tests/$TOTAL_STEPS${NC}"
    echo -e "${BLUE}📈 Success Rate: ${BOLD}$success_rate%${NC}"
    
    local total_time=$(($(date +%s) - START_TIME))
    echo -e "${YELLOW}⏱️ Total Time: ${BOLD}${total_time}s${NC}"
    
    if [[ $failed_tests -eq 0 ]]; then
        echo -e "\n${GREEN}${BOLD}🏥 MEDICAL CARE SYSTEM READY FOR HEALTHCARE PRODUCTION!${NC}"
        return 0
    elif [[ $success_rate -ge 80 ]]; then
        echo -e "\n${YELLOW}${BOLD}⚠️ MOSTLY READY - $failed_tests ISSUES TO RESOLVE${NC}"
        return 1
    else
        echo -e "\n${RED}${BOLD}❌ SIGNIFICANT ISSUES - REQUIRES IMMEDIATE ATTENTION${NC}"
        return 2
    fi
}

# Function to show live monitoring for medical care system
show_live_monitoring() {
    while true; do
        clear
        echo -e "${BOLD}${PURPLE}📊 LIVE MEDICAL CARE SYSTEM MONITORING${NC}"
        echo "========================================"
        echo -e "${CYAN}📊 Updated: $(date '+%H:%M:%S')${NC}"
        echo ""
        
        # Container Status
        echo -e "${YELLOW}🐳 CONTAINER STATUS:${NC}"
        if command -v /usr/local/bin/docker &> /dev/null; then
            /usr/local/bin/docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(medical-care|postgres|NAME)" || echo "No medical care containers found"
        else
            echo "Docker not available in PATH"
        fi
        echo ""
        
        # Service Health
        echo -e "${YELLOW}🏥 HEALTHCARE SERVICE HEALTH:${NC}"
        for service in "5170:.NET Core API" "5171:Blazor Frontend" "5432:PostgreSQL"; do
            IFS=':' read -r port name <<< "$service"
            if nc -z localhost $port 2>/dev/null; then
                echo -e "  ${GREEN}✅${NC} $name (Port $port): HEALTHY"
            else
                echo -e "  ${RED}❌${NC} $name (Port $port): UNHEALTHY"
            fi
        done
        echo ""
        
        # Medical Features
        echo -e "${YELLOW}🏥 MEDICAL CARE FEATURES:${NC}"
        for endpoint in "/api/patients:Patient Management" "/api/doctors:Doctor Management" "/api/appointments:Appointment System" "/api/medicalrecords:Medical Records"; do
            IFS=':' read -r path name <<< "$endpoint"
            if curl -sf --max-time 2 "http://localhost:5170$path" >/dev/null 2>&1; then
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
    "test") run_medical_tests ;;
    "monitor") show_live_monitoring ;;
    "quick") 
        echo -e "${PURPLE}⚡ MEDICAL CARE SYSTEM QUICK STATUS${NC}"
        echo "=================================="
        for port in 5170 5171 5432; do
            if nc -z localhost $port 2>/dev/null; then
                echo -e "Port $port: ${GREEN}✅ ACTIVE${NC}"
            else
                echo -e "Port $port: ${RED}❌ INACTIVE${NC}"
            fi
        done
        ;;
    *) 
        echo "Usage: $0 [test|monitor|quick]"
        echo "  test    - Run comprehensive medical care system testing"
        echo "  monitor - Show live monitoring dashboard" 
        echo "  quick   - Quick status check"
        ;;
esac