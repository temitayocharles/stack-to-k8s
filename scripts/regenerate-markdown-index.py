#!/usr/bin/env python3
"""Regenerate the markdown file inventory, excluding build artifacts."""

from pathlib import Path
from datetime import datetime

EXCLUDE_PATTERNS = {
    '.git', '.venv', 'node_modules', 'venv', 'dist', 'build', 
    '__pycache__', '.pytest_cache', 'coverage', '.next'
}

def should_exclude(path: Path) -> bool:
    """Check if path should be excluded."""
    return any(pattern in path.parts for pattern in EXCLUDE_PATTERNS)

def main():
    ws = Path(__file__).parent.parent
    md_files = sorted([
        f.relative_to(ws) 
        for f in ws.rglob('*.md') 
        if not should_exclude(f)
    ])
    
    output = ws / 'docs' / 'MARKDOWN-INDEX.md'
    with open(output, 'w') as idx:
        idx.write('# 📚 Markdown File Inventory\n\n')
        idx.write(f'**Generated**: {datetime.now().strftime("%Y-%m-%d %H:%M")}\n\n')
        idx.write(f'**Total files**: {len(md_files)}\n\n')
        idx.write('| Path | Purpose |\n|------|--------|\n')
        
        for f in md_files:
            idx.write(f'| `{f}` | |\n')
    
    print(f'✅ Inventory regenerated — {len(md_files)} markdown files indexed')
    print(f'📄 Output: {output}')

if __name__ == '__main__':
    main()
