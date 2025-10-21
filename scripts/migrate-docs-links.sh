#!/bin/bash
# Migrate documentation links after restructuring to numbered folders
# This script updates relative paths for the new folder hierarchy

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="${ROOT}/docs"

echo "🔄 Starting documentation link migration..."
echo "Root: ${ROOT}"
echo "Docs: ${DOCS_DIR}"

files_updated=0

# Function to update links in a file
update_file_links() {
    local file="$1"
    local original_content
    local updated_content
    
    # Skip if not a text markdown file
    if ! file "$file" | grep -q "text"; then
        return
    fi
    
    original_content=$(cat "$file")
    updated_content="$original_content"
    
    # Update relative links based on file location
    # Pattern: Update setup/ references to 10-setup/
    updated_content=$(echo "$updated_content" | sed 's|\([[(]\)setup/|\1../10-setup/|g')
    
    # Update learning/ references to 20-labs/
    updated_content=$(echo "$updated_content" | sed 's|\([[(]\)learning/|\1../20-labs/|g')
    
    # Update reference/ references to 30-reference/
    updated_content=$(echo "$updated_content" | sed 's|\([[(]\)reference/|\1../30-reference/|g')
    
    # Update troubleshooting/ references to 40-troubleshooting/
    updated_content=$(echo "$updated_content" | sed 's|\([[(]\)troubleshooting/|\1../40-troubleshooting/|g')
    
    # For files in 00-introduction/, update labs reference
    if [[ "$file" == *"00-introduction"* ]]; then
        updated_content=$(echo "$updated_content" | sed 's|\.\.\/labs/|../20-labs/|g')
    fi
    
    # For files in 20-labs/, reference KUBERNETES-LABS in same folder
    if [[ "$file" == *"20-labs"* ]]; then
        updated_content=$(echo "$updated_content" | sed 's|../KUBERNETES-LABS.md|./KUBERNETES-LABS.md|g')
    fi
    
    # Check if file changed
    if [[ "$updated_content" != "$original_content" ]]; then
        echo "$updated_content" > "$file"
        ((files_updated++))
        echo "✅ Updated: ${file#${ROOT}/}"
    fi
}

# Find and update all markdown files
echo ""
echo "Updating links in all markdown files..."
while IFS= read -r file; do
    update_file_links "$file"
done < <(find "${DOCS_DIR}" -name "*.md" -type f 2>/dev/null)

echo ""
echo "✅ Migration complete!"
echo "Files updated: ${files_updated}"
echo ""
echo "Next steps:"
echo "1. Review changes with: git diff docs/"
echo "2. Test links: ./scripts/run-link-check-full.sh"
