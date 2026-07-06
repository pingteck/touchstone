#!/usr/bin/env bash
# Asserts each skill's references/verifier-contract.md is byte-identical to the
# canonical skills/_shared/verifier-contract.md. Auto-discovers copies; requires the
# two known carriers to exist. Exit 0 = in sync, 1 = drift/missing.
set -euo pipefail
cd "$(dirname "$0")/.."

CANON=skills/_shared/verifier-contract.md
[ -f "$CANON" ] || { echo "FAIL: missing $CANON"; exit 1; }

# Skills REQUIRED to carry a copy.
REQUIRED="red-team decision-panel"

status=0
for s in $REQUIRED; do
  c="skills/$s/references/verifier-contract.md"
  if [ ! -f "$c" ]; then echo "FAIL: missing required copy $c"; status=1; fi
done

# Every copy that exists (including future skills') must match the canonical file.
n=0
for c in skills/*/references/verifier-contract.md; do
  [ -f "$c" ] || continue
  n=$((n+1))
  if ! cmp -s "$CANON" "$c"; then echo "FAIL: $c differs from $CANON"; status=1; fi
done

[ "$status" -eq 0 ] && echo "OK: verifier contract byte-identical across canonical + $n copies"
exit "$status"
