#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
say 'Static script checks (no hardware modifications)'
bash "$STAGE_ROOT/scripts/test-static.sh"
say 'Hardware and session inventory (read-only)'
bash "$STAGE_ROOT/scripts/preflight.sh"
echo 'Review all outputs; preflight is NOT a physical display PASS.'
