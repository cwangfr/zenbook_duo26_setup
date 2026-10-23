#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
say 'Full read-only software inventory'
bash "$STAGE_ROOT/scripts/verify.sh"
echo 'MANUAL GATES: detached dual-screen; attached lower off; detach recovery x3; cold boot covered; sleep/wake; rfkill stable; BT controller present.'
echo 'Do not count script completion as manual hardware acceptance.'
