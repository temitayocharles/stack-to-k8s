#!/bin/bash
# Intelligent documentation link migration for hierarchical structure
# Handles different source locations with appropriate relative paths

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="${ROOT}/docs"

echo "🔄 Smart documentation link migration..."
echo ""

files_updated=0

# Process each markdown file
find "${DOCS_DIR}" -name "*.md" -type f 2>/dev/null | while read -r file; do
    # Skip if not a text file
    if ! file "$file" | grep -q "text"; then
        continue
    fi
    
    original=$(cat "$file")
    updated="$original"
    
    # Determine the depth of the current file to calculate correct relative paths
    # Files in docs root (depth 1): ../
    # Files in docs/XX-folder/ (depth 2): ../../
    # Files in docs/XX-folder/subfolder/ (depth 3): ../../../
    
    depth=$(echo "$file" | sed 's|[^/]||g' | wc -c)
    
    # Specific path conversions based on file location
    
    # For files in 00-introduction/
    if [[ "$file" == *"/00-introduction/"* ]]; then
        # ../setup/ → ../../10-setup/
        updated=$(echo "$updated" | sed 's|\.\./setup/|../../10-setup/|g')
        # ../learning/ → ../../20-labs/
        updated=$(echo "$updated" | sed 's|\.\./learning/|../../20-labs/|g')
        # ../reference/ → ../../30-reference/
        updated=$(echo "$updated" | sed 's|\.\./reference/|../../30-reference/|g')
        # ../troubleshooting/ → ../../40-troubleshooting/
        updated=$(echo "$updated" | sed 's|\.\./troubleshooting/|../../40-troubleshooting/|g')
    fi
    
    # For files in 20-labs/
    if [[ "$file" == *"/20-labs/"* ]]; then
        # ../setup/ → ../../10-setup/
        updated=$(echo "$updated" | sed 's|\.\./setup/|../../10-setup/|g')
        # ../learning/ → ./  (same folder)
        updated=$(echo "$updated" | sed 's|\.\./learning/|./|g')
        # ../reference/ → ../../30-reference/
        updated=$(echo "$updated" | sed 's|\.\./reference/|../../30-reference/|g')
        # troubleshooting.md → ../40-troubleshooting/troubleshooting-index.md
        updated=$(echo "$updated" | sed 's|troubleshooting/troubleshooting\.md|../40-troubleshooting/troubleshooting-index.md|g')
    fi
    
    # For files in 30-reference/deep-dives/
    if [[ "$file" == *"/30-reference/deep-dives/"* ]]; then
        # ../troubleshooting/troubleshooting.md → ../../40-troubleshooting/troubleshooting-index.md
        updated=$(echo "$updated" | sed 's|../troubleshooting/troubleshooting\.md|../../40-troubleshooting/troubleshooting-index.md|g')
        # Reference to sibling in same reference folder: kubectl-cheatsheet.md → ../cheatsheets/kubectl-cheatsheet.md
        updated=$(echo "$updated" | sed 's|\([[(]\)kubectl-cheatsheet\.md|\1../cheatsheets/kubectl-cheatsheet.md|g')
        # decision-trees.md → ../cheatsheets/decision-trees.md
        updated=$(echo "$updated" | sed 's|\([[(]\)decision-trees\.md|\1../cheatsheets/decision-trees.md|g')
        # ../../labs/ → ../../20-labs/
        updated=$(echo "$updated" | sed 's|../../labs/|../../20-labs/|g')
    fi
    
    # For files in 30-reference/cheatsheets/
    if [[ "$file" == *"/30-reference/cheatsheets/"* ]]; then
        # Nothing usually needs updating here as they're reference docs
        # But handle cross-references if needed
        updated=$(echo "$updated" | sed 's|\([[(]\)resource-requirements\.md|\1../deep-dives/resource-requirements.md|g')
    fi
    
    # For files in 40-troubleshooting/
    if [[ "$file" == *"/40-troubleshooting/"* ]]; then
        # ../reference/ → ../../30-reference/
        updated=$(echo "$updated" | sed 's|\.\./reference/|../../30-reference/|g')
        # ../20-labs/ → ../../20-labs/
        updated=$(echo "$updated" | sed 's|\.\./20-labs/|../../20-labs/|g')
    fi
    
    # Global conversions for files in docs root
    if [[ "$file" == "$DOCS_DIR"/*.md ]]; then
        # setup/ → 10-setup/
        updated=$(echo "$updated" | sed 's|\([[(]\)setup/|\110-setup/|g')
        # learning/ → 20-labs/
        updated=$(echo "$updated" | sed 's|\([[(]\)learning/|\120-labs/|g')
        # reference/ → 30-reference/
        updated=$(echo "$updated" | sed 's|\([[(]\)reference/|\130-reference/|g')
        # troubleshooting/ → 40-troubleshooting/
        updated=$(echo "$updated" | sed 's|\([[(]\)troubleshooting/|\140-troubleshooting/|g')
        # labs/ → 20-labs/
        updated=$(echo "$updated" | sed 's|\([[(]\)labs/|\120-labs/|g')
    fi
    
    # Check if file changed
    if [[ "$updated" != "$original" ]]; then
        echo "$updated" > "$file"
        ((files_updated++))
        echo "✅ Updated: ${file#${ROOT}/}"
    fi
done

echo ""
echo "✅ Migration complete! Updated ${files_updated} files."
echo ""
echo "Next steps:"
echo "1. Review changes: git diff docs/"
echo "2. Test links: bash ./scripts/run-link-check-full.sh"
