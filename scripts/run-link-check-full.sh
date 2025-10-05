#!/usr/bin/env bash
# Robust repo-wide markdown link checker
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX="$ROOT/docs/MARKDOWN-INDEX.md"
OUT="$ROOT/scripts/validate-links.full-report.txt"
rm -f "$OUT"
echo "Full link check run: $(date -u)" > "$OUT"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: index not found at $INDEX" | tee -a "$OUT"
  exit 1
fi

grep -E '`[^`]+\.md`' "$INDEX" | sed -n "s/.*\`\([^\`]*\.md\)\`.*/\1/p" > /tmp/_md_list.txt
while IFS= read -r path; do
  echo "=== FILE: $path ===" | tee -a "$OUT"
  abs="$ROOT/$path"
  if [ ! -f "$abs" ]; then
    echo "MISSING_FILE: $path" | tee -a "$OUT"
    echo >> "$OUT"
    continue
  fi

  # Run markdown-link-check; capture output but do not exit on failure
  npx --yes markdown-link-check "$path" -c .github/markdown-link-check.json >> "$OUT" 2>&1
  rc=$?
  if [ $rc -eq 0 ]; then
    echo "RESULT: OK" >> "$OUT"
  else
    echo "RESULT: FAIL (exit $rc)" >> "$OUT"
  fi
  echo >> "$OUT"
done < /tmp/_md_list.txt

echo "Full report written to $OUT"
