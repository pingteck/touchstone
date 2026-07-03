#!/usr/bin/env bash
# Asserts the "Improving this skill" pointer block is present and byte-identical
# across all host skills (spec §8 / F9). Exit 0 = in sync, 1 = drift.
set -euo pipefail
cd "$(dirname "$0")/.."

HOSTS=(skills/decision-panel/SKILL.md skills/red-team/SKILL.md)
# Capture from the pointer heading until the next `## ` section (or EOF), so the
# lint stays correct even if a host skill gains a section after the pointer.
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
