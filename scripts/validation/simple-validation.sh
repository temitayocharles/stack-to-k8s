#!/bin/bash
# 🔍 SIMPLE WORKSPACE VALIDATION
# Validates core workspace structure and functionality
# Author: Temitayo Charles Akinniranye | TCA-InfraForge

set -e

# 🎨 Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# 📊 Test counters
PASSED=0
FAILED=0
TOTAL=0

# Function to run validation check
run_check() {
    local description="$1"
    local command="$2"
    local expected="$3"
    
    TOTAL=$((TOTAL + 1))
    printf "%-50s" "$description"
    
    if eval "$command" &>/dev/null; then
        if [[ "$expected" == "success" ]]; then
            echo -e " ${GREEN}✅ PASS${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e " ${RED}❌ FAIL${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        if [[ "$expected" == "fail" ]]; then
            echo -e " ${GREEN}✅ PASS${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e " ${RED}❌ FAIL${NC}"
            FAILED=$((FAILED + 1))
        fi
    fi
}

# Function to show results
show_results() {
    local percentage=$((PASSED * 100 / TOTAL))
    
    echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}VALIDATION RESULTS${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}Passed: $PASSED${NC}"
    echo -e "${CYAN}║${NC} ${RED}Failed: $FAILED${NC}"
    echo -e "${CYAN}║${NC} ${WHITE}Total:  $TOTAL${NC}"
    echo -e "${CYAN}║${NC} ${BLUE}Success Rate: $percentage%${NC}"
    echo -e "${CYAN}║${NC}"
    
    if [[ $percentage -ge 90 ]]; then
        echo -e "${CYAN}║${NC} ${GREEN}🎉 EXCELLENT! Workspace is production ready${NC}"
    elif [[ $percentage -ge 80 ]]; then
        echo -e "${CYAN}║${NC} ${YELLOW}⚠️  GOOD! Minor issues to address${NC}"
    else
        echo -e "${CYAN}║${NC} ${RED}❌ NEEDS WORK! Major issues found${NC}"
    fi
    
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Main validation function
main() {
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                        ║"
    echo "║        🔍 WORKSPACE VALIDATION 🔍                                                      ║"
    echo "║                                                                                        ║"
    echo "║        Comprehensive validation of workspace structure and functionality               ║"
    echo "║                                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    echo -e "${BLUE}Running comprehensive workspace validation...${NC}\n"
    
    # Core Files Validation
    echo -e "${YELLOW}🗂️  CORE FILES VALIDATION${NC}"
    run_check "README.md exists" "test -f README.md" "success"
    run_check "Smart setup script exists" "test -f smart-setup.sh" "success"
    run_check "Smart setup is executable" "test -x smart-setup.sh" "success"
    run_check "Docker build script exists" "test -f scripts/build-and-push-images.sh" "success"
    run_check "Learning platform exists" "test -f scripts/learn-kubernetes.sh" "success"
    
    # Documentation Validation
    echo -e "\n${YELLOW}📚 DOCUMENTATION VALIDATION${NC}"
    run_check "Start guide exists" "test -f docs/START-HERE.md" "success"
    run_check "Setup options exist" "test -f docs/SETUP-OPTIONS.md" "success"
    run_check "README references smart-setup" "grep -q 'smart-setup.sh' README.md" "success"
    run_check "START-HERE references smart-setup" "grep -q 'smart-setup.sh' docs/START-HERE.md" "success"
    
    # Application Structure Validation
    echo -e "\n${YELLOW}📱 APPLICATION STRUCTURE VALIDATION${NC}"
    local apps=("ecommerce-app" "educational-platform" "medical-care-system" "task-management-app" "weather-app" "social-media-platform")
    
    for app in "${apps[@]}"; do
        run_check "$app directory exists" "test -d $app" "success"
        run_check "$app has README.md" "test -f $app/README.md" "success"
        run_check "$app has docker-compose.yml" "test -f $app/docker-compose.yml" "success"
        run_check "$app has k8s directory" "test -d $app/k8s" "success"
    done
    
    # Scripts Validation
    echo -e "\n${YELLOW}🔧 SCRIPTS VALIDATION${NC}"
    run_check "Scripts directory exists" "test -d scripts" "success"
    run_check "Learn Kubernetes script executable" "test -x scripts/learn-kubernetes.sh" "success"
    run_check "Build images script executable" "test -x scripts/build-and-push-images.sh" "success"
    run_check "Cleanup scripts exist" "test -f scripts/cleanup-workspace.sh" "success"
    
    # Docker Validation
    echo -e "\n${YELLOW}🐳 DOCKER VALIDATION${NC}"
    run_check "Docker is available" "command -v docker" "success"
    run_check "Docker is running" "docker ps" "success"
    run_check "Global docker-compose exists" "test -f global-configs/docker-compose.yml" "success"
    
    # Git Repository Validation
    echo -e "\n${YELLOW}📋 REPOSITORY VALIDATION${NC}"
    run_check "Git repository initialized" "test -d .git" "success"
    run_check "Git remote configured" "git remote -v | grep -q origin" "success"
    run_check "No temporary files" "! find . -name '*.tmp' -o -name '*.bak' | grep -q ." "success"
    run_check "Gitignore exists" "test -f .gitignore" "success"
    
    # Advanced Features Validation
    echo -e "\n${YELLOW}⚙️ ADVANCED FEATURES VALIDATION${NC}"
    run_check "Shared K8s manifests exist" "test -d shared-k8s" "success"
    run_check "Global configs exist" "test -d global-configs" "success"
    run_check "Monitoring configs exist" "test -d shared-k8s/monitoring" "success"
    run_check "Advanced features exist" "test -d shared-k8s/advanced-features" "success"
    
    # Show final results
    show_results
    
    # Exit with appropriate code
    if [[ $FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 All validations passed! Workspace is ready for use.${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some validations failed. Please address the issues above.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"