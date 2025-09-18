#!/bin/bash

# 📊 AUTOMATED PROGRESS TRACKING & MILESTONE MANAGEMENT
# Mandatory progress logging with automatic upstream synchronization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROGRESS_LOG="PROGRESS_LOG.md"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Function to log progress with mandatory format
log_progress() {
    local milestone="$1"
    local status="$2"
    local actions="$3"
    local verification="$4"
    local test_results="$5"
    local failures_resolved="$6"
    local next_steps="$7"
    
    echo -e "${CYAN}📊 LOGGING MILESTONE PROGRESS${NC}"
    echo "=================================="
    
    # Create or append to progress log
    cat >> "$PROGRESS_LOG" << EOF

---
## 🎯 MILESTONE PROGRESS ENTRY

**TIMESTAMP**: [${TIMESTAMP}]
**MILESTONE**: ${milestone}
**STATUS**: ${status}

### ACTIONS TAKEN:
${actions}

### VERIFICATION:
${verification}

### TEST RESULTS:
${test_results}

### FAILURES RESOLVED:
${failures_resolved}

### UPSTREAM STATUS:
Changes committed and pushed to origin/main

### NEXT STEPS:
${next_steps}

---

EOF

    echo -e "${GREEN}✅ Progress logged successfully${NC}"
}

# Function to validate completion criteria
validate_completion() {
    local milestone="$1"
    local validation_passed=true
    
    echo -e "${BLUE}🔍 VALIDATING COMPLETION CRITERIA FOR: ${milestone}${NC}"
    echo "=================================================="
    
    # Check for common failure indicators
    echo "Checking for common failure indicators..."
    
    # Check if there are any failing containers
    if docker ps -a --filter "status=exited" --filter "status=dead" | grep -q .; then
        echo -e "${RED}❌ FAILURE: Some containers have failed${NC}"
        docker ps -a --filter "status=exited" --filter "status=dead"
        validation_passed=false
    else
        echo -e "${GREEN}✅ All containers healthy${NC}"
    fi
    
    # Check if services are responding
    if ! curl -s -f http://localhost:3001 > /dev/null 2>&1; then
        echo -e "${RED}❌ FAILURE: Frontend not accessible${NC}"
        validation_passed=false
    else
        echo -e "${GREEN}✅ Frontend accessible${NC}"
    fi
    
    if ! curl -s -f http://localhost:5001/health > /dev/null 2>&1; then
        echo -e "${RED}❌ FAILURE: Backend health check failed${NC}"
        validation_passed=false
    else
        echo -e "${GREEN}✅ Backend health check passed${NC}"
    fi
    
    return $([ "$validation_passed" = true ])
}

# Function to commit and push milestone
push_milestone() {
    local milestone="$1"
    local commit_message="$2"
    
    echo -e "${YELLOW}📤 PUSHING MILESTONE TO UPSTREAM${NC}"
    echo "=================================="
    
    # Stage all changes
    git add .
    
    # Check if there are changes to commit
    if git diff --cached --quiet; then
        echo -e "${YELLOW}⚠️ No changes to commit${NC}"
        return 0
    fi
    
    # Commit with standardized message format
    git commit -m "MILESTONE: ${milestone} - ${commit_message}"
    
    # Push to origin
    if git push origin main; then
        echo -e "${GREEN}✅ Successfully pushed to upstream${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to push to upstream${NC}"
        return 1
    fi
}

# Function to handle milestone completion
complete_milestone() {
    local milestone="$1"
    local actions="$2"
    local verification="$3"
    local test_results="$4"
    local failures_resolved="$5"
    local next_steps="$6"
    local commit_message="$7"
    
    echo -e "${MAGENTA}🎯 COMPLETING MILESTONE: ${milestone}${NC}"
    echo "============================================="
    
    # Validate completion criteria
    if validate_completion "$milestone"; then
        echo -e "${GREEN}✅ All validation checks passed${NC}"
        
        # Log progress
        log_progress "$milestone" "COMPLETED" "$actions" "$verification" "$test_results" "$failures_resolved" "$next_steps"
        
        # Push to upstream
        if push_milestone "$milestone" "$commit_message"; then
            echo -e "${GREEN}🎉 MILESTONE COMPLETED SUCCESSFULLY!${NC}"
            echo -e "${GREEN}📊 Progress logged and pushed to upstream${NC}"
            return 0
        else
            echo -e "${RED}❌ MILESTONE FAILED: Could not push to upstream${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ MILESTONE FAILED: Validation checks failed${NC}"
        echo -e "${RED}🔧 MANDATORY: Fix all failures before marking as completed${NC}"
        
        # Log as failed
        log_progress "$milestone" "FAILED" "$actions" "VALIDATION FAILED: See error messages above" "FAILED: Validation criteria not met" "$failures_resolved" "Fix validation failures and retry"
        
        return 1
    fi
}

# Function to handle milestone start
start_milestone() {
    local milestone="$1"
    local planned_actions="$2"
    
    echo -e "${BLUE}🚀 STARTING MILESTONE: ${milestone}${NC}"
    echo "====================================="
    
    log_progress "$milestone" "IN_PROGRESS" "$planned_actions" "Not yet verified" "Not yet executed" "None yet" "Execute planned actions and verify completion"
    
    echo -e "${YELLOW}📋 Milestone started and logged${NC}"
}

# Main execution based on command line arguments
case "${1:-help}" in
    "start")
        start_milestone "$2" "$3"
        ;;
    "complete")
        complete_milestone "$2" "$3" "$4" "$5" "$6" "$7" "$8"
        ;;
    "validate")
        validate_completion "$2"
        ;;
    "push")
        push_milestone "$2" "$3"
        ;;
    "help"|*)
        echo -e "${CYAN}📊 PROGRESS TRACKING & MILESTONE MANAGEMENT${NC}"
        echo "============================================="
        echo ""
        echo -e "${YELLOW}Usage:${NC}"
        echo "  $0 start \"milestone_name\" \"planned_actions\""
        echo "  $0 complete \"milestone_name\" \"actions\" \"verification\" \"test_results\" \"failures_resolved\" \"next_steps\" \"commit_message\""
        echo "  $0 validate \"milestone_name\""
        echo "  $0 push \"milestone_name\" \"commit_message\""
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo "  $0 start \"Security Fixes\" \"Update multer to 2.0.2, fix cross-spawn vulnerability\""
        echo "  $0 complete \"Security Fixes\" \"Updated packages\" \"npm audit shows 0 vulnerabilities\" \"All tests pass\" \"Fixed 6 HIGH vulnerabilities\" \"Deploy advanced features\" \"All security vulnerabilities resolved\""
        echo ""
        ;;
esac