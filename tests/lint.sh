#!/usr/bin/env bash
# Single entrypoint for all repo lints. Add new lints here so none is silently dropped.
set -euo pipefail
cd "$(dirname "$0")/.."
./tests/lint-pointer-sync.sh
./tests/lint-plugin-manifest.sh
./tests/lint-verifier-sync.sh
echo "OK: all lints passed"
