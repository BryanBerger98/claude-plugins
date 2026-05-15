#!/usr/bin/env bash
# Structural sanity for .claude-plugin/marketplace.json
# Validates required top-level keys + per-plugin keys.
# Exit codes: 0 ok, 1 invalid.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="${ROOT}/.claude-plugin/marketplace.json"

[ -f "$FILE" ] || { echo "ERROR: $FILE not found" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "ERROR: jq required" >&2; exit 1; }

fail=0
expect_string() {
  local path="$1"
  local val
  val=$(jq -r "$path // empty" "$FILE")
  if [ -z "$val" ]; then
    echo "  KO  missing or empty: $path"
    fail=1
  else
    echo "  OK  $path = $val"
  fi
}

echo "[top-level]"
expect_string '.name'
expect_string '.owner.name'
expect_string '.owner.email'
expect_string '.metadata.description'

count=$(jq '.plugins | length' "$FILE")
echo "[plugins] count=$count"
[ "$count" -ge 1 ] || { echo "  KO  no plugins listed"; fail=1; }

for i in $(seq 0 $((count - 1))); do
  echo "[plugin $i]"
  expect_string ".plugins[$i].name"
  expect_string ".plugins[$i].description"
  expect_string ".plugins[$i].version"
  expect_string ".plugins[$i].license"
  src_type=$(jq -r ".plugins[$i].source | type" "$FILE")
  if [ "$src_type" = "string" ]; then
    echo "  OK  .plugins[$i].source = string (relative path)"
  elif [ "$src_type" = "object" ]; then
    expect_string ".plugins[$i].source.source"
    case "$(jq -r ".plugins[$i].source.source" "$FILE")" in
      github)
        expect_string ".plugins[$i].source.repo"
        ;;
      url)
        expect_string ".plugins[$i].source.url"
        ;;
      *) ;;
    esac
  else
    echo "  KO  .plugins[$i].source unexpected type: $src_type"
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo ""
  echo "FAIL"
  exit 1
fi
echo ""
echo "PASS"
