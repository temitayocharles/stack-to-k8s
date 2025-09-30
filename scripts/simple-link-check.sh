#!/bin/bash
# Simple Documentation Link Validation

echo "🔗 DOCUMENTATION LINK VALIDATION"
echo "================================="

BROKEN_LINKS=0
TOTAL_LINKS=0

# Function to check if a file exists
check_link() {
    local file="$1"
    local link="$2"
    
    # Skip external links
    if [[ "$link" =~ ^https?:// ]]; then
        return 0
    fi
    
    # Get directory of source file
    local dir=$(dirname "$file")
    
    # Resolve link path
    local target_path
    if [[ "$link" =~ ^\.\./ ]]; then
        target_path="$dir/$link"
    elif [[ "$link" =~ ^\.\/ ]]; then
        target_path="$dir/$link"
    elif [[ "$link" =~ ^docs/ ]]; then
        target_path="$link"
    else
        target_path="$dir/$link"
    fi
    
    # Normalize path
    target_path=$(realpath -m "$target_path" 2>/dev/null || echo "$target_path")
    
    if [ ! -f "$target_path" ] && [ ! -d "$target_path" ]; then
        echo "❌ BROKEN: $file -> $link (resolved: $target_path)"
        BROKEN_LINKS=$((BROKEN_LINKS + 1))
        return 1
    fi
    
    return 0
}

# Check all markdown files
echo "Checking documentation files..."

find . -name "*.md" -type f | while read file; do
    echo "Checking: $file"
    
    # Extract markdown links [text](url)
    grep -o '\[.*\]([^)]*)' "$file" 2>/dev/null | while read link_match; do
        TOTAL_LINKS=$((TOTAL_LINKS + 1))
        
        # Extract just the URL part
        link=$(echo "$link_match" | sed 's/.*(\([^)]*\)).*/\1/')
        
        check_link "$file" "$link"
    done
done

echo ""
echo "📊 SUMMARY"
echo "=========="
echo "Total links checked: $TOTAL_LINKS"
echo "Broken links found: $BROKEN_LINKS"

if [ $BROKEN_LINKS -eq 0 ]; then
    echo "✅ All links are valid!"
else
    echo "❌ Found $BROKEN_LINKS broken links"
fi