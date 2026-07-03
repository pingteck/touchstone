#!/usr/bin/env bash
# Asserts the plugin manifest is valid and consistent with skills/ on disk.
# (The marketplace lives in a separate repo, pingteck/claude-code-marketplace.)
# Exit 0 = OK, 1 = drift/invalid.
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { echo "FAIL: $1"; exit 1; }

PLG=.claude-plugin/plugin.json

[ -f "$PLG" ] || fail "missing $PLG"

python3 -m json.tool "$PLG" >/dev/null 2>&1 || fail "$PLG is not valid JSON"

# plugin.json: name == touchstone, and NO version key (per-commit SHA versioning)
python3 - "$PLG" <<'PY' || exit 1
import json, sys
p = json.load(open(sys.argv[1]))
assert p.get("name") == "touchstone", f"plugin name must be 'touchstone', got {p.get('name')!r}"
assert "version" not in p, "plugin.json must OMIT 'version' (per-commit SHA versioning)"
PY

# Every skills/*/ that has a SKILL.md must be an expected skill; _shared must have none.
expected="decision-panel red-team report-skill-gap"
for d in skills/*/; do
  name="$(basename "$d")"
  if [ -f "$d/SKILL.md" ]; then
    case " $expected " in
      *" $name "*) ;;
      *) fail "unexpected discoverable skill: $name (update lint if intentional)";;
    esac
  fi
done
[ ! -f skills/_shared/SKILL.md ] || fail "skills/_shared must NOT contain a SKILL.md (would be mis-discovered)"

echo "OK: plugin manifest valid and consistent with skills/ ($expected)"
