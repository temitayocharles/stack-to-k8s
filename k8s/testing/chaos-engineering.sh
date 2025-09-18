#!/bin/bash
# Chaos Engineering Test Suite
# Resilience testing for containerized applications

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHAOS_DIR="$(pwd)/chaos-test-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$CHAOS_DIR/chaos_report_$TIMESTAMP.json"

echo -e "${BLUE}🔥 CHAOS ENGINEERING TEST SUITE${NC}"
echo -e "${BLUE}===============================${NC}"

# Create results directory
mkdir -p "$CHAOS_DIR"

# Initialize chaos report
cat > "$REPORT_FILE" << EOF
{
  "chaos_test_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "test_type": "chaos_engineering",
  "scenarios": []
}
EOF

# Function to log chaos events
log_chaos_event() {
    local scenario=$1
    local action=$2
    local status=$3
    local details=$4
    
    echo -e "${BLUE}[$(date)] CHAOS: $scenario - $action - $status${NC}"
    echo "$(date): $scenario - $action - $status - $details" >> "$CHAOS_DIR/chaos_log_$TIMESTAMP.txt"
}

# Function to check application health
check_application_health() {
    local app_name=$1
    local health_url=$2
    local expected_status=${3:-200}
    
    local response_code=$(curl -s -w "%{http_code}" -o /dev/null "$health_url" 2>/dev/null || echo "000")
    
    if [ "$response_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ $app_name is healthy (HTTP $response_code)${NC}"
        return 0
    else
        echo -e "${RED}❌ $app_name is unhealthy (HTTP $response_code)${NC}"
        return 1
    fi
}

# Function to monitor recovery time
monitor_recovery() {
    local app_name=$1
    local health_url=$2
    local max_wait=${3:-300}  # 5 minutes default
    
    echo -e "${YELLOW}⏱️  Monitoring $app_name recovery...${NC}"
    
    local start_time=$(date +%s)
    local recovered=false
    
    while [ $(($(date +%s) - start_time)) -lt $max_wait ]; do
        if check_application_health "$app_name" "$health_url" >/dev/null 2>&1; then
            local recovery_time=$(($(date +%s) - start_time))
            echo -e "${GREEN}🎉 $app_name recovered in ${recovery_time}s${NC}"
            log_chaos_event "Recovery Monitor" "$app_name" "RECOVERED" "Recovery time: ${recovery_time}s"
            recovered=true
            break
        fi
        sleep 5
    done
    
    if [ "$recovered" = false ]; then
        local total_time=$(($(date +%s) - start_time))
        echo -e "${RED}❌ $app_name did not recover within ${total_time}s${NC}"
        log_chaos_event "Recovery Monitor" "$app_name" "FAILED" "No recovery within ${total_time}s"
        return 1
    fi
    
    return 0
}

# Chaos Scenario 1: Container Restart Test
chaos_container_restart() {
    echo -e "\n${BLUE}🔄 CHAOS SCENARIO 1: Container Restart Test${NC}"
    echo -e "${BLUE}===========================================${NC}"
    
    log_chaos_event "Container Restart" "START" "INITIATED" "Testing container resilience"
    
    # Get running containers
    local containers=($(docker ps --format "{{.Names}}" | grep -E "(educational|medical|weather|task)" | head -4))
    
    for container in "${containers[@]}"; do
        echo -e "${YELLOW}🔄 Restarting container: $container${NC}"
        log_chaos_event "Container Restart" "$container" "RESTARTING" "Forcing container restart"
        
        # Record pre-restart health
        local app_name=$(echo "$container" | cut -d'-' -f1)
        local health_url=""
        
        case "$app_name" in
            "educational") health_url="http://localhost:8080/actuator/health" ;;
            "medical") health_url="http://localhost:5170/api/health" ;;
            "weather") health_url="http://localhost:5002/api/health" ;;
            "task") health_url="http://localhost:8082/api/v1/health" ;;
        esac
        
        # Restart container
        docker restart "$container" &
        
        # Monitor recovery
        sleep 10  # Give container time to start shutting down
        monitor_recovery "$container" "$health_url" 180
    done
    
    log_chaos_event "Container Restart" "COMPLETE" "FINISHED" "All container restart tests completed"
}

# Chaos Scenario 2: Network Partition Test
chaos_network_partition() {
    echo -e "\n${BLUE}🌐 CHAOS SCENARIO 2: Network Partition Test${NC}"
    echo -e "${BLUE}===========================================${NC}"
    
    log_chaos_event "Network Partition" "START" "INITIATED" "Testing network resilience"
    
    # Simulate network issues using iptables (requires sudo)
    if command -v iptables &> /dev/null && [ "$EUID" -eq 0 ]; then
        echo -e "${YELLOW}🚫 Blocking network traffic temporarily...${NC}"
        
        # Block outbound HTTP traffic for 30 seconds
        iptables -A OUTPUT -p tcp --dport 80 -j DROP
        iptables -A OUTPUT -p tcp --dport 443 -j DROP
        
        log_chaos_event "Network Partition" "BLOCK" "ACTIVE" "Blocked HTTP/HTTPS traffic"
        
        sleep 30
        
        # Restore network traffic
        iptables -D OUTPUT -p tcp --dport 80 -j DROP
        iptables -D OUTPUT -p tcp --dport 443 -j DROP
        
        log_chaos_event "Network Partition" "RESTORE" "ACTIVE" "Restored network traffic"
        
        # Check application recovery
        sleep 10
        check_application_health "Educational Platform" "http://localhost:8080/actuator/health"
        check_application_health "Medical Care" "http://localhost:5170/api/health"
        check_application_health "Weather App" "http://localhost:5002/api/health"
        check_application_health "Task Management" "http://localhost:8082/api/v1/health"
    else
        echo -e "${YELLOW}⚠️  Network partition test requires root privileges, skipping...${NC}"
        log_chaos_event "Network Partition" "SKIP" "SKIPPED" "Requires root privileges"
    fi
    
    log_chaos_event "Network Partition" "COMPLETE" "FINISHED" "Network partition test completed"
}

# Chaos Scenario 3: Resource Exhaustion Test
chaos_resource_exhaustion() {
    echo -e "\n${BLUE}💾 CHAOS SCENARIO 3: Resource Exhaustion Test${NC}"
    echo -e "${BLUE}=============================================${NC}"
    
    log_chaos_event "Resource Exhaustion" "START" "INITIATED" "Testing resource limits"
    
    # CPU stress test
    echo -e "${YELLOW}⚡ Starting CPU stress test...${NC}"
    log_chaos_event "Resource Exhaustion" "CPU_STRESS" "ACTIVE" "High CPU load simulation"
    
    # Start CPU stress (if stress tool is available)
    if command -v stress &> /dev/null; then
        stress --cpu 4 --timeout 60s &
        stress_pid=$!
    else
        # Fallback: CPU stress using yes command
        yes > /dev/null &
        stress_pid=$!
    fi
    
    # Monitor applications during stress
    sleep 10
    echo -e "${BLUE}📊 Checking application health under CPU stress...${NC}"
    check_application_health "Educational Platform" "http://localhost:8080/actuator/health"
    check_application_health "Medical Care" "http://localhost:5170/api/health"
    check_application_health "Weather App" "http://localhost:5002/api/health"
    check_application_health "Task Management" "http://localhost:8082/api/v1/health"
    
    # Stop stress test
    kill $stress_pid 2>/dev/null || true
    
    log_chaos_event "Resource Exhaustion" "CPU_STRESS" "STOPPED" "CPU stress test completed"
    
    # Memory stress test
    echo -e "${YELLOW}🧠 Starting memory stress test...${NC}"
    log_chaos_event "Resource Exhaustion" "MEMORY_STRESS" "ACTIVE" "High memory usage simulation"
    
    if command -v stress &> /dev/null; then
        stress --vm 2 --vm-bytes 1G --timeout 60s &
        memory_stress_pid=$!
        
        # Wait and check health
        sleep 30
        echo -e "${BLUE}📊 Checking application health under memory stress...${NC}"
        check_application_health "Educational Platform" "http://localhost:8080/actuator/health"
        check_application_health "Medical Care" "http://localhost:5170/api/health"
        check_application_health "Weather App" "http://localhost:5002/api/health"
        check_application_health "Task Management" "http://localhost:8082/api/v1/health"
        
        wait $memory_stress_pid
    else
        echo -e "${YELLOW}⚠️  Memory stress test requires 'stress' tool, skipping...${NC}"
    fi
    
    log_chaos_event "Resource Exhaustion" "COMPLETE" "FINISHED" "Resource exhaustion test completed"
}

# Chaos Scenario 4: Database Connection Failure
chaos_database_failure() {
    echo -e "\n${BLUE}🗄️  CHAOS SCENARIO 4: Database Connection Failure${NC}"
    echo -e "${BLUE}=================================================${NC}"
    
    log_chaos_event "Database Failure" "START" "INITIATED" "Testing database resilience"
    
    # Get database containers
    local db_containers=($(docker ps --format "{{.Names}}" | grep -E "(postgres|mongodb|redis|sqlserver)"))
    
    for db_container in "${db_containers[@]}"; do
        echo -e "${YELLOW}🛑 Temporarily stopping database: $db_container${NC}"
        log_chaos_event "Database Failure" "$db_container" "STOPPING" "Simulating database outage"
        
        # Stop database container
        docker stop "$db_container" &
        
        # Wait for applications to detect the failure
        sleep 15
        
        # Check application behavior
        echo -e "${BLUE}📊 Checking application behavior without database...${NC}"
        check_application_health "Educational Platform" "http://localhost:8080/actuator/health" || true
        check_application_health "Medical Care" "http://localhost:5170/api/health" || true
        check_application_health "Weather App" "http://localhost:5002/api/health" || true
        check_application_health "Task Management" "http://localhost:8082/api/v1/health" || true
        
        # Restart database
        echo -e "${YELLOW}🔄 Restarting database: $db_container${NC}"
        docker start "$db_container"
        log_chaos_event "Database Failure" "$db_container" "RESTARTING" "Restoring database service"
        
        # Monitor application recovery
        sleep 20
        monitor_recovery "$db_container" "http://localhost:8080/actuator/health" 120 || true
    done
    
    log_chaos_event "Database Failure" "COMPLETE" "FINISHED" "Database failure test completed"
}

# Chaos Scenario 5: Traffic Spike Simulation
chaos_traffic_spike() {
    echo -e "\n${BLUE}📈 CHAOS SCENARIO 5: Traffic Spike Simulation${NC}"
    echo -e "${BLUE}=============================================${NC}"
    
    log_chaos_event "Traffic Spike" "START" "INITIATED" "Testing traffic handling"
    
    # Use curl to simulate traffic spike
    echo -e "${YELLOW}🚀 Generating high traffic load...${NC}"
    
    # Create concurrent requests
    for i in {1..50}; do
        curl -s "http://localhost:8080/actuator/health" > /dev/null &
        curl -s "http://localhost:5170/api/health" > /dev/null &
        curl -s "http://localhost:5002/api/health" > /dev/null &
        curl -s "http://localhost:8082/api/v1/health" > /dev/null &
    done
    
    log_chaos_event "Traffic Spike" "LOAD" "ACTIVE" "Generated 200 concurrent requests"
    
    # Wait for requests to complete
    sleep 30
    
    # Check application health after spike
    echo -e "${BLUE}📊 Checking application health after traffic spike...${NC}"
    check_application_health "Educational Platform" "http://localhost:8080/actuator/health"
    check_application_health "Medical Care" "http://localhost:5170/api/health"
    check_application_health "Weather App" "http://localhost:5002/api/health"
    check_application_health "Task Management" "http://localhost:8082/api/v1/health"
    
    log_chaos_event "Traffic Spike" "COMPLETE" "FINISHED" "Traffic spike test completed"
}

# Function to generate chaos report
generate_chaos_report() {
    echo -e "\n${BLUE}📊 GENERATING CHAOS ENGINEERING REPORT${NC}"
    echo -e "${BLUE}====================================${NC}"
    
    local summary_file="$CHAOS_DIR/chaos_summary_$TIMESTAMP.txt"
    
    cat > "$summary_file" << EOF
CHAOS ENGINEERING TEST SUMMARY
==============================
Test Date: $(date)
Test Duration: $(date -u -d @$(($(date +%s) - start_time)) +"%H:%M:%S")

CHAOS SCENARIOS EXECUTED:
-------------------------
✓ Container Restart Test
✓ Network Partition Test
✓ Resource Exhaustion Test
✓ Database Connection Failure
✓ Traffic Spike Simulation

RESILIENCE ASSESSMENT:
---------------------
EOF

    # Analyze chaos log for failures
    local total_tests=$(grep -c "COMPLETE.*FINISHED" "$CHAOS_DIR/chaos_log_$TIMESTAMP.txt" 2>/dev/null || echo "0")
    local failed_tests=$(grep -c "FAILED" "$CHAOS_DIR/chaos_log_$TIMESTAMP.txt" 2>/dev/null || echo "0")
    local success_rate=$(( (total_tests - failed_tests) * 100 / (total_tests == 0 ? 1 : total_tests) ))
    
    echo "Total Chaos Scenarios: $total_tests" >> "$summary_file"
    echo "Failed Scenarios: $failed_tests" >> "$summary_file"
    echo "Success Rate: $success_rate%" >> "$summary_file"
    echo "" >> "$summary_file"
    
    if [ "$success_rate" -ge 90 ]; then
        echo -e "${GREEN}✅ RESILIENCE SCORE: EXCELLENT ($success_rate%)${NC}"
        echo "ASSESSMENT: Applications demonstrate excellent resilience to chaos." >> "$summary_file"
    elif [ "$success_rate" -ge 75 ]; then
        echo -e "${YELLOW}⚠️  RESILIENCE SCORE: GOOD ($success_rate%)${NC}"
        echo "ASSESSMENT: Applications show good resilience with room for improvement." >> "$summary_file"
    else
        echo -e "${RED}❌ RESILIENCE SCORE: NEEDS IMPROVEMENT ($success_rate%)${NC}"
        echo "ASSESSMENT: Applications need significant resilience improvements." >> "$summary_file"
    fi
    
    echo "" >> "$summary_file"
    echo "DETAILED LOGS: $CHAOS_DIR/chaos_log_$TIMESTAMP.txt" >> "$summary_file"
    
    echo -e "${GREEN}📋 Chaos summary generated: $summary_file${NC}"
}

# Main execution
echo -e "${BLUE}Starting chaos engineering tests...${NC}"
start_time=$(date +%s)

# Execute chaos scenarios
chaos_container_restart
chaos_network_partition
chaos_resource_exhaustion
chaos_database_failure
chaos_traffic_spike

# Generate final report
generate_chaos_report

echo -e "\n${GREEN}🎉 Chaos engineering tests completed!${NC}"
echo -e "${GREEN}📁 Results location: $CHAOS_DIR${NC}"
echo -e "${GREEN}📋 Summary report: $CHAOS_DIR/chaos_summary_$TIMESTAMP.txt${NC}"

# Return appropriate exit code
if [ "$success_rate" -ge 75 ]; then
    echo -e "${GREEN}✅ CHAOS TESTS PASSED - EXIT CODE 0${NC}"
    exit 0
else
    echo -e "${RED}❌ CHAOS TESTS FAILED - EXIT CODE 1${NC}"
    exit 1
fi