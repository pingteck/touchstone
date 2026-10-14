#!/usr/bin/env bash
# Asserts plugin.json's "version" increased whenever shipped skill content changed.
# The manifest pins the version, so installed users get NO update until it changes —
# a skills/ edit without a bump silently never ships.
# Base to compare against: $LINT_BASE if it names a commit (CI sets it to the pre-push
# commit on pushes to main), else the merge-base with origin/main (falls back to main).
# Changes = tracked diffs from the base to the working tree + untracked files in skills/.
# Exit 0 = OK, 1 = skills/ changed but version did not increase.
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { echo "FAIL: $1"; exit 1; }

PLG=.claude-plugin/plugin.json

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "OK: not a git repo — version-bump check skipped"; exit 0
fi

if [ -n "${LINT_BASE:-}" ] && git rev-parse -q --verify "${LINT_BASE}^{commit}" >/dev/null; then
  base="$LINT_BASE"; label="$LINT_BASE"
else
  ref=""
  for r in origin/main main; do
    if git rev-parse -q --verify "$r^{commit}" >/dev/null; then ref="$r"; break; fi
  done
  [ -n "$ref" ] || fail "no origin/main or main ref to compare against (fetch main, or set LINT_BASE)"
  base="$(git merge-base HEAD "$ref")" || fail "no merge-base between HEAD and $ref (shallow clone? fetch full history)"
  label="$ref"
fi

changed="$( { git diff --name-only "$base" -- skills/; git ls-files --others --exclude-standard -- skills/; } | sort -u)"
if [ -z "$changed" ]; then
  echo "OK: no skills/ changes since $label — no version bump needed"
  exit 0
fi

old_json="$(git show "$base:$PLG" 2>/dev/null || true)"
python3 - "$PLG" "$old_json" "$changed" "$label" <<'PY' || exit 1
import json, re, sys
plg, old_json, changed, label = sys.argv[1:]

def parse(v):
    m = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)", v or "")
    return tuple(map(int, m.groups())) if m else None

try:
    old = json.loads(old_json).get("version", "") if old_json else ""
except ValueError:
    old = ""
new = json.load(open(plg)).get("version", "")
files = "\n".join("  " + f for f in changed.splitlines())

if parse(new) is None:
    print(f"FAIL: {plg} version {new!r} is not X.Y.Z")
    sys.exit(1)
if parse(old) is not None and parse(new) <= parse(old):
    print(f"FAIL: skills/ changed since {label} but {plg} version went '{old}' -> '{new}' "
          f"— it must increase, or users never receive the change:\n{files}")
    sys.exit(1)
print(f"OK: skills/ changed and version bumped ('{old or '<none>'}' -> '{new}')")
PY
