#!/bin/bash
# 🔍 FINAL PUBLIC REPOSITORY VALIDATION
# Ensures repository is ready for public use with no internal development artifacts

echo "╔══════════════════════════════════════════════════════════════════════════════════╗"
echo "║ 🔍 FINAL PUBLIC REPOSITORY VALIDATION"
echo "║ Ensuring repository is ready for public use"
echo "╚══════════════════════════════════════════════════════════════════════════════════╝"

# Initialize counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
ISSUES_FOUND=0

# Function to run check
run_check() {
    local check_name="$1"
    local check_command="$2"
    local expected_result="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo "🔍 Checking: $check_name"
    
    if eval "$check_command"; then
        if [[ "$expected_result" == "success" ]]; then
            echo "✅ PASS: $check_name"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ FAIL: $check_name (unexpected success)"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        if [[ "$expected_result" == "fail" ]]; then
            echo "✅ PASS: $check_name (correctly not found)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ FAIL: $check_name"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    fi
}

echo ""
echo "🧹 Phase 1: Internal Development File Cleanup"
echo "============================================="

# Check for internal development files that shouldn't be public
run_check "No SESSION_LOG.md files" "! find . -name 'SESSION_LOG.md' -type f | grep -q ." "success"
run_check "No internal docs" "! find . -name '*-internal.md' -type f | grep -q ." "success"  
run_check "No temporary scripts" "! find . -name '*-temp.sh' -type f | grep -q ." "success"
run_check "No debug files" "! find . -name 'debug-*.md' -type f | grep -q ." "success"
run_check "No validation reports" "! find . -name '*VALIDATION-REPORT.md' -type f | grep -q ." "success"

echo ""
echo "📚 Phase 2: Critical Infrastructure"
echo "==================================="

# Check critical files exist
run_check "Smart setup script exists" "test -f smart-setup.sh" "success"
run_check "Smart setup is executable" "test -x smart-setup.sh" "success"
run_check "Main README exists" "test -f README.md" "success"
run_check "DevOps challenges exist" "test -f docs/DEVOPS-CHALLENGES.md" "success"
run_check "Chaos engineering guide exists" "test -f docs/CHAOS-ENGINEERING.md" "success"

echo ""
echo "🎯 Phase 3: Application Completeness"
echo "===================================="

# Check all applications exist
applications=("ecommerce-app" "educational-platform" "medical-care-system" "task-management-app" "weather-app" "social-media-platform")

for app in "${applications[@]}"; do
    run_check "$app directory exists" "test -d $app" "success"
    run_check "$app README exists" "test -f $app/README.md" "success"
    run_check "$app docker-compose exists" "test -f $app/docker-compose.yml" "success"
done

echo ""
echo "📊 VALIDATION SUMMARY"
echo "===================="

echo "Total Checks Run: $TOTAL_CHECKS"
echo "Checks Passed: $PASSED_CHECKS"
echo "Issues Found: $ISSUES_FOUND"

# Calculate success rate
if [ $TOTAL_CHECKS -gt 0 ]; then
    SUCCESS_RATE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    echo "Success Rate: $SUCCESS_RATE%"
    
    if [ $SUCCESS_RATE -eq 100 ]; then
        echo ""
        echo "🎉 REPOSITORY VALIDATION PASSED!"
        echo "✅ Repository is ready for public use"
        echo ""
        echo "🚀 READY FOR GIT PUSH TO PUBLIC REPOSITORY"
        exit 0
    elif [ $SUCCESS_RATE -ge 90 ]; then
        echo ""
        echo "⚠️  REPOSITORY MOSTLY READY (Minor Issues)"
        echo "📝 Address remaining issues before public release"
        exit 1
    else
        echo ""
        echo "❌ REPOSITORY NOT READY FOR PUBLIC USE"
        echo "🔧 Significant issues need to be resolved"
        exit 1
    fi
else
    echo ""
    echo "❌ NO CHECKS WERE RUN"
    exit 1
fi