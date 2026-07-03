#!/usr/bin/env bash
# Bootstrap the background agent's environment.
set -euo pipefail

# Confirm a working Python interpreter is available before proceeding.
if command -v python3 >/dev/null 2>&1; then
  echo "python3 found: $(command -v python3)"
else
  echo "ERROR: python3 not found" >&2
  exit 1
fi

echo "Bootstrap complete."
