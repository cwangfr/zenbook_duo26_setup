#!/usr/bin/env bash
# Static tests only; never installs or operates the target laptop.
set -Eeuo pipefail
if [[ "${1:-}" == --help ]]; then echo 'Usage: test-static.sh (offline checks only)'; exit 0; fi
root="$(cd "$(dirname "$0")/.." && pwd)"
while IFS= read -r -d '' p; do bash -n "$p"; done < <(find "$root/scripts" "$root/optional" -type f -name '*.sh' -print0)
bash -n "$root/optional/bluetooth-recovery/zenbook-bt-recover"
python3 "$root/tests/test_scripts.py"
echo 'Static checks passed. No kernel build, hardware test or service deployment was performed.'
