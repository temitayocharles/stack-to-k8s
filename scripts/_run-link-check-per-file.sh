#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
index="$root/docs/MARKDOWN-INDEX.md"
report="$root/scripts/validate-links.report.txt"
rm -f "$report"
echo "Link check run: $(date -u)" > "$report"
grep -E '`[^`]+\.md`' "$index" | sed -n "s/.*\`\([^\`]*\.md\)\`.*/\1/p" | while read -r path; do
  abs="$root/$path"
  if [ ! -f "$abs" ]; then
    echo "MISSING_FILE: $path" >> "$report"
    continue
  fi
  echo "Checking: $path" | tee -a "$report"
  if npx --yes markdown-link-check "$path" -c .github/markdown-link-check.json >> "$report" 2>&1; then
    echo "OK: $path" >> "$report"
  else
    echo "FAIL: $path" >> "$report"
    echo "------------------------" >> "$report"
  fi
done
echo "Report written to $report"
