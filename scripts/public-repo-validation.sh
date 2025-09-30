#!/bin/bash
# 🔍 FINAL PUBLIC REPOSITORY VALIDATION
# Ensures repository is ready for public use with no internal development artifacts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

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
    echo -e "\n${BLUE}🔍 Checking: $check_name${NC}"
    
    if eval "$check_command"; then
        if [[ "$expected_result" == "success" ]]; then
            echo -e "${GREEN}✅ PASS: $check_name${NC}"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo -e "${RED}❌ FAIL: $check_name (unexpected success)${NC}"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    else
        if [[ "$expected_result" == "fail" ]]; then
            echo -e "${GREEN}✅ PASS: $check_name (correctly not found)${NC}"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo -e "${RED}❌ FAIL: $check_name${NC}"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    fi
}

echo -e "\n${PURPLE}🧹 Phase 1: Internal Development File Cleanup${NC}"
echo -e "${PURPLE}=============================================${NC}"

# Check for internal development files that shouldn't be public
run_check "No SESSION_LOG.md files" "! find . -name 'SESSION_LOG.md' -type f | grep -q ." "success"
run_check "No internal docs" "! find . -name '*-internal.md' -type f | grep -q ." "success"  
run_check "No temporary scripts" "! find . -name '*-temp.sh' -type f | grep -q ." "success"
run_check "No debug files" "! find . -name 'debug-*.md' -type f | grep -q ." "success"
run_check "No validation reports" "! find . -name '*VALIDATION-REPORT.md' -type f | grep -q ." "success"
run_check "No test runners" "! find . -name 'real-functionality-test-runner.sh' -type f | grep -q ." "success"

echo -e "\n${PURPLE}📚 Phase 2: Documentation Completeness${NC}"
echo -e "${PURPLE}======================================${NC}"

# Check critical documentation exists
run_check "Smart setup script exists" "test -f smart-setup.sh" "success"
run_check "Smart setup is executable" "test -x smart-setup.sh" "success"
run_check "Main README exists" "test -f README.md" "success"
run_check "Central documentation exists" "test -f docs/START-HERE.md" "success"
run_check "DevOps challenges exist" "test -f docs/DEVOPS-CHALLENGES.md" "success"
run_check "Chaos engineering guide exists" "test -f docs/CHAOS-ENGINEERING.md" "success"

echo -e "\n${PURPLE}🎯 Phase 3: Application Completeness${NC}"
echo -e "${PURPLE}====================================${NC}"

# Check all applications exist with proper documentation
applications=("ecommerce-app" "educational-platform" "medical-care-system" "task-management-app" "weather-app" "social-media-platform")

for app in "${applications[@]}"; do
    run_check "$app directory exists" "test -d $app" "success"
    run_check "$app README exists" "test -f $app/README.md" "success"
    run_check "$app GET-STARTED exists" "test -f $app/GET-STARTED.md" "success"
    run_check "$app docker-compose exists" "test -f $app/docker-compose.yml" "success"
    run_check "$app k8s manifests exist" "test -d $app/k8s" "success"
done

echo -e "\n${PURPLE}🔗 Phase 4: Smart Setup Integration${NC}"
echo -e "${PURPLE}===================================${NC}"

# Check smart setup is properly referenced
run_check "README references smart-setup" "grep -q 'smart-setup.sh' README.md" "success"
run_check "START-HERE references smart-setup" "grep -q 'smart-setup.sh' docs/START-HERE.md" "success"
run_check "Smart setup has proper permissions" "ls -la smart-setup.sh | grep -q '^-rwx'" "success"

echo -e "\n${PURPLE}🎮 Phase 5: DevOps Learning Content${NC}"
echo -e "${PURPLE}===================================${NC}"

# Check DevOps content is properly integrated
run_check "DevOps challenges referenced in START-HERE" "grep -q 'DEVOPS-CHALLENGES' docs/START-HERE.md" "success"
run_check "Chaos engineering referenced" "grep -q 'CHAOS-ENGINEERING' docs/START-HERE.md" "success"
run_check "Progressive difficulty mentioned" "grep -q 'Progressive' docs/DEVOPS-CHALLENGES.md" "success"
run_check "Troubleshooting opportunities exist" "grep -q 'Break.*Fix' docs/CHAOS-ENGINEERING.md" "success"

echo -e "\n${PURPLE}⚙️ Phase 6: Repository Configuration${NC}"
echo -e "${PURPLE}====================================${NC}"

# Check repository is properly configured for public use
run_check "Gitignore properly configured" "test -f .gitignore && grep -q 'SESSION_LOG' .gitignore" "success"
run_check "No large binary files" "! find . -size +50M -type f | grep -q ." "success"
run_check "No personal credentials" "! grep -r 'password.*=' . --include='*.md' --include='*.yml' | grep -v 'your-password' | grep -q ." "success"

echo -e "\n${PURPLE}🚀 Phase 7: User Experience Validation${NC}"
echo -e "${PURPLE}=====================================${NC}"

# Check user experience is optimized
run_check "Smart setup has colorful output" "grep -q 'RED=.*033' smart-setup.sh" "success"
run_check "Smart setup is interactive" "grep -q 'read.*choice' smart-setup.sh" "success"
run_check "Documentation is bite-sized" "! find docs/ -name '*.md' -exec wc -w {} + | awk '{if(\$1>1500) print \$2}' | grep -q ." "success"
run_check "Clear difficulty progression" "grep -q '⭐⭐' README.md" "success"

echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC} ${BOLD}📊 VALIDATION SUMMARY${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${BLUE}Total Checks Run: $TOTAL_CHECKS${NC}"
echo -e "${GREEN}Checks Passed: $PASSED_CHECKS${NC}"
echo -e "${RED}Issues Found: $ISSUES_FOUND${NC}"

# Calculate success rate
if [ $TOTAL_CHECKS -gt 0 ]; then
    SUCCESS_RATE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    echo -e "${CYAN}Success Rate: $SUCCESS_RATE%${NC}"
    
    if [ $SUCCESS_RATE -eq 100 ]; then
        echo -e "\n${GREEN}🎉 REPOSITORY VALIDATION PASSED!${NC}"
        echo -e "${GREEN}✅ Repository is ready for public use${NC}"
        echo -e "${GREEN}✅ All internal development files cleaned${NC}"
        echo -e "${GREEN}✅ Smart setup properly integrated${NC}"
        echo -e "${GREEN}✅ DevOps learning content comprehensive${NC}"
        echo -e "${GREEN}✅ User experience optimized${NC}"
        
        echo -e "\n${CYAN}🚀 READY FOR GIT PUSH TO PUBLIC REPOSITORY${NC}"
        exit 0
    elif [ $SUCCESS_RATE -ge 90 ]; then
        echo -e "\n${YELLOW}⚠️  REPOSITORY MOSTLY READY (Minor Issues)${NC}"
        echo -e "${YELLOW}📝 Address remaining issues before public release${NC}"
        exit 1
    else
        echo -e "\n${RED}❌ REPOSITORY NOT READY FOR PUBLIC USE${NC}"
        echo -e "${RED}🔧 Significant issues need to be resolved${NC}"
        exit 1
    fi
else
    echo -e "\n${RED}❌ NO CHECKS WERE RUN${NC}"
    exit 1
fi