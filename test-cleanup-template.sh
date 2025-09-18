#!/bin/bash

# 🧹 MANDATORY TEST CLEANUP & SANITY CHECK TEMPLATE
# Copy this script to each application for consistent cleanup

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 STARTING MANDATORY POST-TEST CLEANUP & SANITY CHECK${NC}"
echo "============================================================"

# 1. PRE-CLEANUP WORKSPACE ANALYSIS
echo -e "\n${YELLOW}📊 PRE-CLEANUP ANALYSIS${NC}"
INITIAL_SIZE=$(du -sh . | awk '{print $1}')
INITIAL_TEMP_FILES=$(find . -name "*.tmp" -o -name "*.bak" -o -name "*draft*" | wc -l)
INITIAL_CONTAINERS=$(docker ps -q | wc -l)

echo "  Initial workspace size: $INITIAL_SIZE"
echo "  Initial temporary files: $INITIAL_TEMP_FILES"
echo "  Initial running containers: $INITIAL_CONTAINERS"

# 2. REMOVE TEMPORARY TEST FILES
echo -e "\n${YELLOW}🗑️  CLEANING TEMPORARY FILES${NC}"
echo "  Removing .tmp files..."
find . -name "*.tmp" -type f -delete 2>/dev/null || true

echo "  Removing .bak files..."
find . -name "*.bak" -type f -delete 2>/dev/null || true

echo "  Removing draft files..."
find . -name "*draft*" -type f -delete 2>/dev/null || true

echo "  Removing test logs..."
find . -name "test-*.log" -type f -delete 2>/dev/null || true
find . -name "*.test.log" -type f -delete 2>/dev/null || true

# 3. CLEAN TEST ARTIFACTS
echo -e "\n${YELLOW}📁 CLEANING TEST ARTIFACTS${NC}"
echo "  Removing test results..."
rm -rf test-results/ coverage-reports/ performance-data/ 2>/dev/null || true
rm -rf .nyc_output/ junit.xml test-output.xml coverage/ 2>/dev/null || true
rm -rf node_modules/.cache/ .pytest_cache/ 2>/dev/null || true

echo "  Removing build artifacts..."
rm -rf build/ dist/ target/ .next/ 2>/dev/null || true

# 4. STOP AND REMOVE TEST CONTAINERS
echo -e "\n${YELLOW}🐳 CLEANING TEST CONTAINERS${NC}"
echo "  Stopping docker-compose services..."
docker-compose down -v --remove-orphans 2>/dev/null || true

echo "  Pruning stopped containers..."
docker container prune -f 2>/dev/null || true

echo "  Pruning unused images..."
docker image prune -f 2>/dev/null || true

echo "  Pruning unused volumes..."
docker volume prune -f 2>/dev/null || true

# 5. VALIDATE WORKSPACE HYGIENE
echo -e "\n${YELLOW}✅ VALIDATING WORKSPACE HYGIENE${NC}"
FINAL_SIZE=$(du -sh . | awk '{print $1}')
FINAL_TEMP_FILES=$(find . -name "*.tmp" -o -name "*.bak" -o -name "*draft*" | wc -l)
FINAL_CONTAINERS=$(docker ps -q | wc -l)
UNCOMMITTED_FILES=$(git status --porcelain | wc -l)

echo "  Final workspace size: $FINAL_SIZE"
echo "  Final temporary files: $FINAL_TEMP_FILES"
echo "  Final running containers: $FINAL_CONTAINERS"
echo "  Uncommitted files: $UNCOMMITTED_FILES"

# 6. VALIDATION RESULTS
echo -e "\n${BLUE}📋 CLEANUP VALIDATION RESULTS${NC}"
CLEANUP_SUCCESS=true

if [ "$FINAL_TEMP_FILES" -eq 0 ]; then
    echo -e "  ${GREEN}✅ TEMPORARY FILES: Clean (0 files)${NC}"
else
    echo -e "  ${RED}❌ TEMPORARY FILES: Found $FINAL_TEMP_FILES files${NC}"
    CLEANUP_SUCCESS=false
fi

if [ "$FINAL_CONTAINERS" -eq 0 ]; then
    echo -e "  ${GREEN}✅ CONTAINERS: Clean (0 running)${NC}"
else
    echo -e "  ${RED}❌ CONTAINERS: $FINAL_CONTAINERS still running${NC}"
    CLEANUP_SUCCESS=false
fi

# Check for required production files
REQUIRED_FILES=("README.md" "docker-compose.yml")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅ REQUIRED FILE: $file present${NC}"
    else
        echo -e "  ${YELLOW}⚠️  REQUIRED FILE: $file missing${NC}"
    fi
done

# 7. FINAL RESULT
echo -e "\n${BLUE}🎯 FINAL CLEANUP VALIDATION${NC}"
if [ "$CLEANUP_SUCCESS" = true ]; then
    echo -e "${GREEN}🎉 CLEANUP SUCCESSFUL - WORKSPACE HYGIENE VALIDATED${NC}"
    echo -e "${GREEN}📊 Workspace optimized from $INITIAL_SIZE to $FINAL_SIZE${NC}"
    echo -e "${GREEN}🧹 All temporary files and containers removed${NC}"
    echo -e "${GREEN}✨ Ready for next development cycle${NC}"
    exit 0
else
    echo -e "${RED}❌ CLEANUP VALIDATION FAILED${NC}"
    echo -e "${RED}🚨 Manual intervention required${NC}"
    echo ""
    echo "REMEDIATION STEPS:"
    if [ "$FINAL_TEMP_FILES" -gt 0 ]; then
        echo "  1. Manually remove temporary files:"
        find . -name "*.tmp" -o -name "*.bak" -o -name "*draft*"
    fi
    if [ "$FINAL_CONTAINERS" -gt 0 ]; then
        echo "  2. Stop running containers:"
        echo "     docker ps"
        echo "     docker stop \$(docker ps -q)"
    fi
    exit 1
fi