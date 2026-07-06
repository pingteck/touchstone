#!/usr/bin/env bash
# Asserts the "Improving this skill" pointer block is present and byte-identical
# across all host skills. Hosts are AUTO-DISCOVERED: every skills/*/SKILL.md not in
# EXCLUDE. A new skill missing the block therefore FAILS this lint (add it to
# EXCLUDE only if it should intentionally carry no pointer). Exit 0 = in sync.
set -euo pipefail
cd "$(dirname "$0")/.."

# Skills that intentionally carry NO pointer block (e.g. the feedback producer itself).
EXCLUDE="report-skill-gap"

HOSTS=()
for d in skills/*/; do
  name="$(basename "$d")"
  [ -f "${d}SKILL.md" ] || continue
  case " $EXCLUDE " in *" $name "*) continue;; esac
  HOSTS+=("${d}SKILL.md")
done
if [ "${#HOSTS[@]}" -lt 1 ]; then echo "FAIL: no host skills discovered"; exit 1; fi

# Capture from the pointer heading until the next `## ` section (or EOF).
extract() { awk '/^## Improving this skill$/{f=1; print; next} /^## /{f=0} f{print}' "$1"; }

ref="$(extract "${HOSTS[0]}")"
if [ -z "$ref" ]; then echo "FAIL: no pointer block in ${HOSTS[0]}"; exit 1; fi

status=0
for h in "${HOSTS[@]}"; do
  cur="$(extract "$h")"
  if [ -z "$cur" ]; then echo "FAIL: pointer block missing in $h"; status=1; continue; fi
  if [ "$cur" != "$ref" ]; then echo "FAIL: pointer block in $h differs from ${HOSTS[0]}"; status=1; fi
done
[ "$status" -eq 0 ] && echo "OK: pointer block present and byte-identical across ${#HOSTS[@]} host skills"
exit "$status"
