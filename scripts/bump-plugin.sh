#!/usr/bin/env bash
# Bump a plugin's version + ref (git tag) in marketplace.json.
# Usage:
#   ./scripts/bump-plugin.sh --plugin=snap --version=1.1.0 [--ref=v1.1.0]
# Defaults --ref to v$VERSION when not passed.
# Prints diff; does NOT commit.
set -euo pipefail

PLUGIN=""
VERSION=""
REF=""

for arg in "$@"; do
  case "$arg" in
    --plugin=*)  PLUGIN="${arg#*=}" ;;
    --version=*) VERSION="${arg#*=}" ;;
    --ref=*)     REF="${arg#*=}" ;;
    -h|--help)
      sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "ERROR: unknown arg $arg" >&2; exit 1 ;;
  esac
done

[ -n "$PLUGIN" ]  || { echo "ERROR: --plugin required" >&2; exit 1; }
[ -n "$VERSION" ] || { echo "ERROR: --version required" >&2; exit 1; }
[ -n "$REF" ]     || REF="v${VERSION}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="${ROOT}/.claude-plugin/marketplace.json"

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq required" >&2; exit 1; }
[ -f "$FILE" ] || { echo "ERROR: $FILE not found" >&2; exit 1; }

idx=$(jq --arg name "$PLUGIN" '.plugins | map(.name == $name) | index(true)' "$FILE")
[ "$idx" != "null" ] || { echo "ERROR: plugin '$PLUGIN' not found in marketplace.json" >&2; exit 1; }

tmp=$(mktemp)
jq \
  --arg name "$PLUGIN" \
  --arg version "$VERSION" \
  --arg ref "$REF" \
  '.plugins |= map(
     if .name == $name then
       .version = $version
       | (if (.source | type) == "object" then .source.ref = $ref else . end)
     else . end
   )' "$FILE" > "$tmp"

mv "$tmp" "$FILE"

echo "[bumped] $PLUGIN → version=$VERSION, source.ref=$REF"
echo ""
git --no-pager diff -- "$FILE" || true
