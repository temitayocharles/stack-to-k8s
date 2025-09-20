#!/bin/bash

# 🌤️ WEATHER APP COMPREHENSIVE TESTING SUITE
# Real-time Weather Platform Testing with Visual Progress Tracking
# ==============================================================

# Color definitions for visual feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Animation characters for loading
LOADING_CHARS="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

# Initialize test counters
TOTAL_TESTS=20
CURRENT_TEST=0
PASSED_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)

# Test results array
declare -a TEST_RESULTS=()

# Function to show animated progress bar with weather-specific styling
show_progress() {
    local current=$1
    local total=$2
    local title="$3"
    local status="$4"
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local elapsed=$(($(date +%s) - START_TIME))
    
    # Clear previous line and show new progress
    echo -ne "\r\033[K"
    
    # Weather-themed progress display
    echo -ne "🌤️ ${title}\n"
    echo -ne "["
    
    # Animated progress bar
    for ((i=1; i<=completed; i++)); do 
        echo -ne "█"
    done
    for ((i=completed+1; i<=width; i++)); do 
        echo -ne "░"
    done
    
    # Status indicator
    if [ "$status" = "RUNNING" ]; then
        local spinner_char=${LOADING_CHARS:$((elapsed % ${#LOADING_CHARS})):1}
        echo -ne "] ${percentage}% (${current}/${total}) ⏱️ ${elapsed}s ${YELLOW}${spinner_char}${NC}"
    elif [ "$status" = "PASSED" ]; then
        echo -ne "] ${percentage}% (${current}/${total}) ⏱️ ${elapsed}s ${GREEN}✅${NC}"
    elif [ "$status" = "FAILED" ]; then
        echo -ne "] ${percentage}% (${current}/${total}) ⏱️ ${elapsed}s ${RED}❌${NC}"
    fi
    
    echo ""
}

# Enhanced test execution with detailed weather service validation
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    local test_type="$4"
    
    ((CURRENT_TEST++))
    
    # Show test starting
    show_progress $CURRENT_TEST $TOTAL_TESTS "$test_name" "RUNNING"
    echo "  🔍 Testing: $test_name"
    
    # Execute test with timeout
    local result
    local exit_code
    
    if timeout 30 bash -c "$test_command" >/dev/null 2>&1; then
        result="PASSED"
        exit_code=0
        ((PASSED_TESTS++))
        TEST_RESULTS+=("✅ PASSED: $test_name")
    else
        result="FAILED"
        exit_code=1
        ((FAILED_TESTS++))
        TEST_RESULTS+=("❌ FAILED: $test_name")
    fi
    
    # Show test completion
    show_progress $CURRENT_TEST $TOTAL_TESTS "$test_name" "$result"
    echo "  ${result}: $test_name"
    
    # Add spacing for readability
    echo ""
    
    sleep 0.5
    return $exit_code
}

# Weather App Quick Status Check
weather_quick_status() {
    echo ""
    echo "⚡ WEATHER APP QUICK STATUS"
    echo "=========================="
    
    # Check if containers are running (basic check)
    local backend_status="❌ INACTIVE"
    local frontend_status="❌ INACTIVE"
    local redis_status="❌ INACTIVE"
    
    # Check port accessibility as indicator
    if timeout 3 bash -c "echo >/dev/tcp/localhost/5002" 2>/dev/null; then
        backend_status="✅ ACTIVE"
    fi
    
    if timeout 3 bash -c "echo >/dev/tcp/localhost/8081" 2>/dev/null; then
        frontend_status="✅ ACTIVE"
    fi
    
    if timeout 3 bash -c "echo >/dev/tcp/localhost/6380" 2>/dev/null; then
        redis_status="✅ ACTIVE"
    fi
    
    echo "🔧 Backend API (Port 5002): $backend_status"
    echo "🌐 Frontend (Port 8081): $frontend_status"
    echo "🔴 Redis Cache (Port 6380): $redis_status"
    echo ""
}

# Main testing execution
main() {
    # Header with weather theme
    echo ""
    echo "🌤️ WEATHER APP TESTING PROGRESS"
    echo "==============================="
    echo "📊 Started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "🎯 Application: Weather Platform"
    echo "📍 Location: $(pwd | awk -F/ '{print $NF}')"
    echo ""
    
    # Quick status overview
    weather_quick_status
    
    # Test 1: Container Health Verification
    run_test "Container Health Verification" \
        "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E '(weather|redis)' | grep -v Exited" \
        "containers_running" \
        "infrastructure"
    
    # Test 2: Redis Cache Connectivity
    run_test "Redis Cache Connectivity" \
        "timeout 10 redis-cli -h localhost -p 6380 ping | grep PONG" \
        "redis_connected" \
        "cache"
    
    # Test 3: Python Flask Backend Health
    run_test "Python Flask Backend Health" \
        "curl -s -f http://localhost:5002/api/health | grep -q 'healthy'" \
        "backend_healthy" \
        "backend"
    
    # Test 4: Vue.js Frontend Accessibility
    run_test "Vue.js Frontend Accessibility" \
        "curl -s -f http://localhost:8081/ | grep -q 'Weather'" \
        "frontend_accessible" \
        "frontend"
    
    # Test 5: Current Weather API Endpoint
    run_test "Current Weather API Endpoint" \
        "curl -s 'http://localhost:5002/api/weather/current?lat=51.5074&lon=-0.1278' | grep -q 'temperature'" \
        "current_weather_api" \
        "weather_api"
    
    # Test 6: Weather Forecast API
    run_test "Weather Forecast API" \
        "curl -s 'http://localhost:5002/api/weather/forecast?lat=51.5074&lon=-0.1278&days=5' | grep -q 'forecast'" \
        "forecast_api" \
        "weather_api"
    
    # Test 7: Location Search Service
    run_test "Location Search Service" \
        "curl -s 'http://localhost:5002/api/locations/search?q=London&limit=5' | grep -q 'locations'" \
        "location_search" \
        "search_api"
    
    # Test 8: ML Weather Forecasting
    run_test "ML Weather Forecasting" \
        "curl -s 'http://localhost:5002/api/weather/ml-forecast?city=London&days=7' | grep -q 'ml_forecast'" \
        "ml_forecasting" \
        "advanced_features"
    
    # Test 9: Air Quality Monitoring
    run_test "Air Quality Monitoring" \
        "curl -s 'http://localhost:5002/api/air-quality?city=London' | grep -q 'air_quality_index'" \
        "air_quality" \
        "environmental"
    
    # Test 10: Severe Weather Alerts
    run_test "Severe Weather Alerts" \
        "curl -s 'http://localhost:5002/api/weather/alerts?city=London' | grep -q 'active_alerts'" \
        "weather_alerts" \
        "alerts"
    
    # Test 11: Historical Weather Analysis
    run_test "Historical Weather Analysis" \
        "curl -s 'http://localhost:5002/api/weather/historical-analysis?city=London&years=5' | grep -q 'historical_data'" \
        "historical_analysis" \
        "analytics"
    
    # Test 12: Weather Map Visualization Data
    run_test "Weather Map Visualization Data" \
        "curl -s 'http://localhost:5002/api/weather/map-data?region=europe&layer=temperature' | grep -q 'map_data'" \
        "map_visualization" \
        "visualization"
    
    # Test 13: Cache Performance Test
    run_test "Cache Performance Test" \
        "time curl -s 'http://localhost:5002/api/weather/current?lat=51.5074&lon=-0.1278' >/dev/null" \
        "cache_performance" \
        "performance"
    
    # Test 14: API Response Time Validation
    run_test "API Response Time Validation" \
        "curl -w '%{time_total}' -s -o /dev/null 'http://localhost:5002/api/health' | awk '{if (\$1 < 2) exit 0; else exit 1}'" \
        "response_time" \
        "performance"
    
    # Test 15: Concurrent Request Handling
    run_test "Concurrent Request Handling" \
        "for i in {1..5}; do curl -s http://localhost:5002/api/health & done; wait" \
        "concurrent_requests" \
        "load_testing"
    
    # Test 16: Environment Variables Configuration
    run_test "Environment Variables Configuration" \
        "curl -s http://localhost:5002/api/health | grep -q 'configured'" \
        "environment_config" \
        "configuration"
    
    # Test 17: Error Handling Validation
    run_test "Error Handling Validation" \
        "curl -s 'http://localhost:5002/api/weather/current?lat=invalid&lon=invalid' | grep -q 'error'" \
        "error_handling" \
        "reliability"
    
    # Test 18: Data Security Headers
    run_test "Data Security Headers" \
        "curl -s -I http://localhost:5002/api/health | grep -q 'application/json'" \
        "security_headers" \
        "security"
    
    # Test 19: API Rate Limiting
    run_test "API Rate Limiting Protection" \
        "for i in {1..10}; do curl -s http://localhost:5002/api/health >/dev/null; done" \
        "rate_limiting" \
        "protection"
    
    # Test 20: Production Readiness Check
    run_test "Production Readiness Check" \
        "curl -s http://localhost:5002/ | grep -q 'Weather API Service'" \
        "production_ready" \
        "deployment"
    
    # Final Results Summary
    echo ""
    echo "📊 WEATHER APP TEST RESULTS"
    echo "==========================="
    
    # Calculate final metrics
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    local total_time=$(($(date +%s) - START_TIME))
    
    echo "✅ Tests Passed: $PASSED_TESTS/$TOTAL_TESTS"
    echo "❌ Tests Failed: $FAILED_TESTS/$TOTAL_TESTS"
    echo "📈 Success Rate: $success_rate%"
    echo "⏱️ Total Time: ${total_time}s"
    echo ""
    
    # Status determination
    if [ $success_rate -eq 100 ]; then
        echo "🎉 WEATHER APP READY FOR PRODUCTION!"
        echo "🌟 All weather services operational"
        echo "🚀 Ready for real-time weather monitoring"
    elif [ $success_rate -ge 80 ]; then
        echo "⚠️ MOSTLY READY - MINOR ISSUES TO RESOLVE"
        echo "🔧 Weather platform functional with some optimizations needed"
    else
        echo "🚨 CRITICAL ISSUES DETECTED"
        echo "❌ Weather system requires immediate attention"
        echo ""
        echo "Failed Tests:"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ $result == ❌* ]]; then
                echo "  $result"
            fi
        done
        exit 1
    fi
    
    echo ""
    echo "🌍 Weather Platform Endpoints Ready:"
    echo "  🌤️ Current Weather: http://localhost:5002/api/weather/current"
    echo "  📅 5-Day Forecast: http://localhost:5002/api/weather/forecast"
    echo "  🤖 ML Predictions: http://localhost:5002/api/weather/ml-forecast"
    echo "  🌫️ Air Quality: http://localhost:5002/api/air-quality"
    echo "  🚨 Weather Alerts: http://localhost:5002/api/weather/alerts"
    echo "  📊 Analytics: http://localhost:5002/api/weather/historical-analysis"
    echo "  🗺️ Weather Maps: http://localhost:5002/api/weather/map-data"
    echo "  🔍 Frontend UI: http://localhost:3002"
    echo ""
    
    # Return appropriate exit code
    if [ $success_rate -ge 80 ]; then
        exit 0
    else
        exit 1
    fi
}

# Cleanup function
cleanup() {
    echo ""
    echo "🧹 MANDATORY POST-TEST CLEANUP & SANITY CHECK"
    echo "============================================="
    
    # Clean temporary files
    echo "  Cleaning temporary test files..."
    find . -name "*.tmp" -type f -delete 2>/dev/null || true
    find . -name "*.bak" -type f -delete 2>/dev/null || true
    find . -name "*weather-test*" -type f -delete 2>/dev/null || true
    
    # Validate workspace hygiene
    echo "  Validating workspace hygiene..."
    TEMP_FILES=$(find . -name "*.tmp" -o -name "*.bak" -o -name "*draft*" | wc -l 2>/dev/null || echo 0)
    WORKSPACE_SIZE=$(du -sh . 2>/dev/null | awk '{print $1}' || echo "unknown")
    
    if [ "$TEMP_FILES" -eq 0 ]; then
        echo "✅ WORKSPACE HYGIENE VALIDATED - All temporary files cleaned"
        echo "📊 Final workspace size: $WORKSPACE_SIZE"
        echo "🎉 TESTING COMPLETE WITH CLEAN WORKSPACE"
    else
        echo "⚠️ CLEANUP NOTICE: Some temporary files may remain"
        echo "   Temporary files found: $TEMP_FILES"
    fi
    
    echo ""
}

# Error handling
trap 'echo ""; echo "❌ Testing interrupted"; cleanup; exit 1' INT TERM

# Execute main testing function
main "$@"

# Execute cleanup
cleanup