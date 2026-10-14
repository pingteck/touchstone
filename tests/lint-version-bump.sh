#!/usr/bin/env bash
# Asserts plugin.json's "version" was bumped whenever shipped skill content changed.
# The manifest pins the version, so installed users get NO update until it changes —
# a skills/ edit without a bump silently never ships. Compares the working tree against
# the merge-base with origin/main (falls back to main). On main itself there is no diff,
# so this passes. Exit 0 = OK, 1 = skills/ changed but version did not.
set -euo pipefail
cd "$(dirname "$0")/.."

PLG=.claude-plugin/plugin.json

git rev-parse --git-dir >/dev/null 2>&1 || { echo "SKIP: not a git repo"; exit 0; }
ref=origin/main
git rev-parse --verify -q "$ref" >/dev/null || ref=main
base="$(git merge-base HEAD "$ref")"

changed="$(git diff --name-only "$base" -- skills/)"
if [ -z "$changed" ]; then
  echo "OK: no skills/ changes since $ref — no version bump needed"
  exit 0
fi

version_of() { python3 -c 'import json,sys; print(json.load(sys.stdin).get("version",""))'; }
old="$(git show "$base:$PLG" 2>/dev/null | version_of || true)"
new="$(version_of < "$PLG")"

if [ "$old" = "$new" ]; then
  echo "FAIL: skills/ changed since $ref but $PLG version is still '${new}' — bump it, or users never receive the change:"
  echo "$changed" | sed 's/^/  /'
  exit 1
fi
echo "OK: skills/ changed and version bumped ('${old:-<none>}' -> '$new')"
