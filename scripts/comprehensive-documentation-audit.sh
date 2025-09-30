#!/bin/bash
# 🔗 COMPREHENSIVE LINK VALIDATION & DOCUMENTATION AUDIT
# Ensures zero broken links and validates copilot-instructions compliance

echo "🔗 COMPREHENSIVE DOCUMENTATION AUDIT STARTING..."
echo "==================================================="

# Initialize audit results
TOTAL_LINKS=0
BROKEN_LINKS=0
MISSING_FILES=0
FORMAT_VIOLATIONS=0
APP_ISSUES=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if file exists relative to current directory
check_file_exists() {
    local link_path="$1"
    local source_file="$2"
    local source_dir=$(dirname "$source_file")
    
    # Handle different link types
    if [[ "$link_path" =~ ^https?:// ]]; then
        # External link - we'll just note it
        return 0
    elif [[ "$link_path" =~ ^\.\./ ]]; then
        # Relative parent directory link
        local full_path="$source_dir/$link_path"
        if [ -f "$full_path" ] || [ -d "$full_path" ]; then
            return 0
        else
            return 1
        fi
    elif [[ "$link_path" =~ ^\.\/ ]]; then
        # Current directory relative link
        local full_path="$source_dir/$link_path"
        if [ -f "$full_path" ] || [ -d "$full_path" ]; then
            return 0
        else
            return 1
        fi
    elif [[ "$link_path" =~ ^docs/ ]]; then
        # Docs directory link from root
        if [ -f "$link_path" ] || [ -d "$link_path" ]; then
            return 0
        else
            return 1
        fi
    else
        # Check as relative to source file directory
        local full_path="$source_dir/$link_path"
        if [ -f "$full_path" ] || [ -d "$full_path" ]; then
            return 0
        else
            # Try from workspace root
            if [ -f "$link_path" ] || [ -d "$link_path" ]; then
                return 0
            else
                return 1
            fi
        fi
    fi
}

# Function to validate markdown links in a file
validate_links_in_file() {
    local file="$1"
    local file_broken=0
    
    echo -e "${BLUE}Checking: $file${NC}"
    
    # Extract all markdown links [text](url)
    while IFS= read -r link; do
        if [[ -n "$link" ]]; then
            TOTAL_LINKS=$((TOTAL_LINKS + 1))
            
            # Extract URL from [text](url) format
            url=$(echo "$link" | sed -n 's/.*(\([^)]*\)).*/\1/p')
            
            if ! check_file_exists "$url" "$file"; then
                echo -e "  ${RED}❌ BROKEN LINK: $link${NC}"
                echo -e "     File: $file"
                echo -e "     Target: $url"
                BROKEN_LINKS=$((BROKEN_LINKS + 1))
                file_broken=1
            fi
        fi
    done < <(grep -o '\[.*\]([^)]*)' "$file" 2>/dev/null || true)
    
    if [ $file_broken -eq 0 ]; then
        echo -e "  ${GREEN}✅ All links valid${NC}"
    fi
    
    return $file_broken
}

# Function to check documentation format compliance
check_format_compliance() {
    local file="$1"
    local violations=0
    
    echo -e "${BLUE}Format check: $file${NC}"
    
    # Check for mandatory sections based on copilot-instructions
    if ! grep -q "🎯.*What.*Learn\|🎯.*Goal\|🎯.*What.*Get" "$file"; then
        echo -e "  ${YELLOW}⚠️  Missing clear goal/objective section${NC}"
        violations=$((violations + 1))
    fi
    
    # Check for prerequisites section
    if ! grep -q "📋.*Before.*Start\|📋.*Prerequisites\|📋.*Required" "$file"; then
        echo -e "  ${YELLOW}⚠️  Missing prerequisites section${NC}"
        violations=$((violations + 1))
    fi
    
    # Check for step-by-step format
    if ! grep -q "🚀.*Step\|### Step\|## Step" "$file"; then
        echo -e "  ${YELLOW}⚠️  Missing step-by-step format${NC}"
        violations=$((violations + 1))
    fi
    
    # Check file length (should not exceed 1000 words approximately)
    local word_count=$(wc -w < "$file")
    if [ $word_count -gt 1000 ]; then
        echo -e "  ${YELLOW}⚠️  File too long: $word_count words (max 1000)${NC}"
        violations=$((violations + 1))
    fi
    
    if [ $violations -eq 0 ]; then
        echo -e "  ${GREEN}✅ Format compliant${NC}"
    fi
    
    FORMAT_VIOLATIONS=$((FORMAT_VIOLATIONS + violations))
    return $violations
}

# Function to check application-specific documentation
check_application_docs() {
    local app_dir="$1"
    local app_name=$(basename "$app_dir")
    local missing=0
    
    echo -e "${BLUE}=== Checking $app_name Documentation ===${NC}"
    
    # Required files per copilot-instructions
    local required_files=(
        "README.md"
        "GET-STARTED.md"
        "SECRETS-SETUP.md"
        "docs/quick-start.md"
        "docs/troubleshooting.md"
        "docs/architecture.md"
    )
    
    for req_file in "${required_files[@]}"; do
        local full_path="$app_dir/$req_file"
        if [ ! -f "$full_path" ]; then
            echo -e "  ${RED}❌ Missing: $req_file${NC}"
            missing=$((missing + 1))
            MISSING_FILES=$((MISSING_FILES + 1))
        else
            echo -e "  ${GREEN}✅ Found: $req_file${NC}"
            
            # Validate links in existing files
            validate_links_in_file "$full_path"
            
            # Check format compliance
            check_format_compliance "$full_path"
        fi
    done
    
    # Check for application-specific content (not generic)
    if [ -f "$app_dir/README.md" ]; then
        if grep -q "TEMPLATE\|TODO\|PLACEHOLDER\|YOUR_APP_NAME" "$app_dir/README.md"; then
            echo -e "  ${YELLOW}⚠️  README.md contains template/placeholder content${NC}"
            missing=$((missing + 1))
        fi
    fi
    
    if [ $missing -gt 0 ]; then
        APP_ISSUES=$((APP_ISSUES + 1))
    fi
    
    echo ""
}

# Main validation execution
echo "🔍 Phase 1: Validating Central Documentation..."
echo "=============================================="

# Check main documentation files
main_docs=(
    "README.md"
    "docs/START-HERE.md"
    "docs/getting-started/quick-demo.md"
    "docs/getting-started/system-setup.md"
    "docs/getting-started/first-app.md"
    "docs/applications/ecommerce.md"
    "docs/troubleshooting/quick-fixes.md"
)

for doc in "${main_docs[@]}"; do
    if [ -f "$doc" ]; then
        validate_links_in_file "$doc"
        check_format_compliance "$doc"
    else
        echo -e "${RED}❌ Missing central doc: $doc${NC}"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

echo ""
echo "🏢 Phase 2: Validating Application Documentation..."
echo "================================================="

# Check each application
applications=(
    "ecommerce-app"
    "educational-platform"
    "medical-care-system"
    "task-management-app"
    "weather-app"
    "social-media-platform"
)

for app in "${applications[@]}"; do
    if [ -d "$app" ]; then
        check_application_docs "$app"
    else
        echo -e "${RED}❌ Application directory not found: $app${NC}"
        APP_ISSUES=$((APP_ISSUES + 1))
    fi
done

echo "🔗 Phase 3: Cross-Reference Validation..."
echo "========================================"

# Check if central docs properly reference applications
central_app_refs=0
for app in "${applications[@]}"; do
    if grep -r "$app" docs/ --include="*.md" >/dev/null 2>&1; then
        central_app_refs=$((central_app_refs + 1))
        echo -e "  ${GREEN}✅ $app referenced in central docs${NC}"
    else
        echo -e "  ${YELLOW}⚠️  $app not referenced in central docs${NC}"
    fi
done

echo ""
echo "📊 AUDIT SUMMARY"
echo "================"
echo -e "Total links checked: ${BLUE}$TOTAL_LINKS${NC}"
echo -e "Broken links found: ${RED}$BROKEN_LINKS${NC}"
echo -e "Missing files: ${RED}$MISSING_FILES${NC}"
echo -e "Format violations: ${YELLOW}$FORMAT_VIOLATIONS${NC}"
echo -e "Applications with issues: ${RED}$APP_ISSUES${NC}"
echo -e "Applications referenced in central docs: ${GREEN}$central_app_refs${NC}/6"

echo ""
if [ $BROKEN_LINKS -eq 0 ] && [ $MISSING_FILES -eq 0 ] && [ $APP_ISSUES -eq 0 ]; then
    echo -e "${GREEN}🎉 AUDIT PASSED: All documentation is properly linked and formatted!${NC}"
    exit 0
else
    echo -e "${RED}❌ AUDIT FAILED: Issues found that need fixing${NC}"
    echo ""
    echo "RECOMMENDED ACTIONS:"
    if [ $BROKEN_LINKS -gt 0 ]; then
        echo "1. Fix broken links listed above"
    fi
    if [ $MISSING_FILES -gt 0 ]; then
        echo "2. Create missing documentation files"
    fi
    if [ $APP_ISSUES -gt 0 ]; then
        echo "3. Complete application-specific documentation"
    fi
    if [ $FORMAT_VIOLATIONS -gt 0 ]; then
        echo "4. Align documentation format with copilot-instructions standards"
    fi
    
    exit 1
fi