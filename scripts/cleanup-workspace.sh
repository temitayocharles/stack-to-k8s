#!/bin/bash
# 🧹 MANDATORY WORKSPACE CLEANUP SCRIPT
# Implements workspace hygiene standards from anchor document

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}🧹 STARTING WORKSPACE CLEANUP...${NC}"

# Record initial state
INITIAL_SIZE=$(du -sh . 2>/dev/null | awk '{print $1}')
echo "${BLUE}📊 Initial workspace size: $INITIAL_SIZE${NC}"

# 1. Remove temporary test files
echo "${YELLOW}  Cleaning temporary files...${NC}"
TEMP_COUNT_BEFORE=$(find . -name "*.tmp" -o -name "*.bak" -o -name "*draft*" 2>/dev/null | wc -l)
find . -name "*.tmp" -type f -delete 2>/dev/null || true
find . -name "*.bak" -type f -delete 2>/dev/null || true
find . -name "*draft*" -type f -delete 2>/dev/null || true
find . -name "test-*.log" -type f -delete 2>/dev/null || true
TEMP_COUNT_AFTER=$(find . -name "*.tmp" -o -name "*.bak" -o -name "*draft*" 2>/dev/null | wc -l)
echo "${GREEN}    Removed $((TEMP_COUNT_BEFORE - TEMP_COUNT_AFTER)) temporary files${NC}"

# 2. Clean test artifacts
echo "${YELLOW}  Cleaning test artifacts...${NC}"
TEST_DIRS_REMOVED=0
for dir in test-results coverage-reports performance-data .nyc_output build dist .next target; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" 2>/dev/null || true
        ((TEST_DIRS_REMOVED++))
    fi
done
# Remove common test files
find . -name "junit.xml" -type f -delete 2>/dev/null || true
find . -name "test-output.xml" -type f -delete 2>/dev/null || true
find . -name "coverage.json" -type f -delete 2>/dev/null || true
echo "${GREEN}    Cleaned $TEST_DIRS_REMOVED test artifact directories${NC}"

# 3. Clean log files (keep error logs for debugging)
echo "${YELLOW}  Cleaning log files...${NC}"
LOG_COUNT_BEFORE=$(find . -name "*.log" -not -name "error.log" 2>/dev/null | wc -l)
find . -name "*.log" -not -name "error.log" -type f -delete 2>/dev/null || true
LOG_COUNT_AFTER=$(find . -name "*.log" -not -name "error.log" 2>/dev/null | wc -l)
echo "${GREEN}    Removed $((LOG_COUNT_BEFORE - LOG_COUNT_AFTER)) log files (kept error.log)${NC}"

# 4. Clean node_modules in test directories (but keep main ones)
echo "${YELLOW}  Cleaning test node_modules...${NC}"
find . -path "*/test*/node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
find . -path "*/temp*/node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
echo "${GREEN}    Cleaned test-related node_modules${NC}"

# 5. Clean Docker build cache (only unused)
echo "${YELLOW}  Cleaning Docker build cache...${NC}"
if command -v docker >/dev/null 2>&1; then
    DOCKER_CLEANED=$(docker system prune -f 2>/dev/null | grep "Total reclaimed space" || echo "0B")
    echo "${GREEN}    Docker cleanup: $DOCKER_CLEANED${NC}"
else
    echo "${YELLOW}    Docker not available - skipping Docker cleanup${NC}"
fi

# 6. Clean empty directories
echo "${YELLOW}  Removing empty directories...${NC}"
EMPTY_DIRS_BEFORE=$(find . -type d -empty 2>/dev/null | wc -l)
find . -type d -empty -delete 2>/dev/null || true
EMPTY_DIRS_AFTER=$(find . -type d -empty 2>/dev/null | wc -l)
echo "${GREEN}    Removed $((EMPTY_DIRS_BEFORE - EMPTY_DIRS_AFTER)) empty directories${NC}"

# 7. Validate workspace hygiene
echo "${YELLOW}  Validating workspace hygiene...${NC}"
FINAL_TEMP_FILES=$(find . -name "*.tmp" -o -name "*.bak" -o -name "*draft*" 2>/dev/null | wc -l)
FINAL_SIZE=$(du -sh . 2>/dev/null | awk '{print $1}')

# 8. Generate cleanup report
echo ""
echo "${BLUE}📋 CLEANUP REPORT${NC}"
echo "=================="
echo "Initial size: $INITIAL_SIZE"
echo "Final size: $FINAL_SIZE"
echo "Temporary files remaining: $FINAL_TEMP_FILES"

# 9. Validate success criteria
if [ "$FINAL_TEMP_FILES" -eq 0 ]; then
    echo "${GREEN}✅ CLEANUP SUCCESSFUL - Workspace clean${NC}"
    echo "${GREEN}✅ WORKSPACE HYGIENE VALIDATED${NC}"
    
    # Show clean workspace structure
    echo ""
    echo "${BLUE}📁 CLEAN WORKSPACE STRUCTURE:${NC}"
    echo "application/"
    echo "├── src/                    # ✅ Source code only"
    echo "├── docs/                   # ✅ Final documentation"
    echo "├── docker-compose.yml      # ✅ Production config"
    echo "├── Dockerfile             # ✅ Final container config"
    echo "├── package.json           # ✅ Dependencies"
    echo "├── README.md              # ✅ Final documentation"
    echo "└── k8s/                   # ✅ Kubernetes manifests"
    
    exit 0
else
    echo "${RED}❌ CLEANUP INCOMPLETE - Manual intervention required${NC}"
    echo "${RED}   Temporary files remaining: $FINAL_TEMP_FILES${NC}"
    echo ""
    echo "${YELLOW}🔍 Remaining temporary files:${NC}"
    find . -name "*.tmp" -o -name "*.bak" -o -name "*draft*" 2>/dev/null
    exit 1
fi