#!/bin/bash

# 🧹 WORKSPACE CLEANUP SCRIPT
# Removes all temporary files and draft documents to prevent workspace bloat

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Starting Workspace Cleanup...${NC}"
echo "=================================="

# 1. Remove temporary files
echo -e "\n${YELLOW}🗑️  Removing temporary files...${NC}"
find . -name "*.tmp" -type f -delete 2>/dev/null || true
find . -name "*.bak" -type f -delete 2>/dev/null || true
find . -name "*draft*" -type f -delete 2>/dev/null || true
find . -name "*.log" -type f -delete 2>/dev/null || true
find . -name ".DS_Store" -type f -delete 2>/dev/null || true

# 2. Clean build artifacts
echo -e "${YELLOW}🔨 Cleaning build artifacts...${NC}"
find . -name "build" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".next" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "target" -type d -exec rm -rf {} + 2>/dev/null || true

# 3. Clean test artifacts
echo -e "${YELLOW}🧪 Cleaning test artifacts...${NC}"
find . -name "test-results" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "coverage" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".nyc_output" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "junit.xml" -type f -delete 2>/dev/null || true

# 4. Clean IDE and editor files
echo -e "${YELLOW}💻 Cleaning IDE files...${NC}"
find . -name ".vscode/settings.json" -type f -delete 2>/dev/null || true
find . -name "*.swp" -type f -delete 2>/dev/null || true
find . -name "*.swo" -type f -delete 2>/dev/null || true
find . -name "*~" -type f -delete 2>/dev/null || true

# 5. Display cleanup summary
echo -e "\n${GREEN}✅ Workspace cleanup completed successfully!${NC}"
echo "Removed the following types of files:"
echo "• Temporary files (*.tmp, *.bak, *.log)"
echo "• Draft files (*draft*)"
echo "• Build artifacts (build/, dist/, .next/, target/)"
echo "• Test artifacts (test-results/, coverage/)"
echo "• IDE temporary files"
echo ""

# 6. Show current workspace size
WORKSPACE_SIZE=$(du -sh . 2>/dev/null | cut -f1)
echo -e "${BLUE}📊 Current workspace size: $WORKSPACE_SIZE${NC}"
echo ""
echo -e "${GREEN}🎯 Workspace is now clean and optimized!${NC}"