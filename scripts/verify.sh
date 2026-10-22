#!/usr/bin/env bash
# Read-only checks; never request a display change.
set -u
if [[ "${1:-}" == --help ]]; then echo 'Usage: verify.sh (read-only, no modeset)'; exit 0; fi
root="$(cd "$(dirname "$0")/.." && pwd)"
bash "$root/scripts/preflight.sh"
printf '\n=== Lower panel ===\n'
for d in /sys/class/drm/card*-eDP-2; do
  [[ -d "$d" ]] || continue
  echo "$d"; cat "$d/status" "$d/enabled"
done
printf '\n=== Ownership ===\n'
sudo python3 - <<'PY'
import json
from pathlib import Path
p=Path('/var/lib/zenbook-duo/state.json')
if not p.is_file():
    print('No runtime state file.')
else:
    d=json.loads(p.read_text())
    for k in ('secondaryPanelDisabledByRuntime','secondaryPanelDisabledByRuntimeBootId'):
        print(k, '=', d.get(k))
    print('status =',d.get('status'))
PY
printf '\n=== Runtime decisions ===\n'
sudo tail -n 120 /var/lib/zenbook-duo/daemon.log 2>/dev/null | grep -Ei 'dock|secondary|skipping|replay|verify|status transition' || true
printf '\n=== Display errors ===\n'
sudo journalctl -k -b --no-pager | grep -Ei 'PHY B|AUX B|DDI B|flip_done|DSB.*timed out|TCSS.*(fail|timeout|not acknowledged)|xe.*(error|fail)' | tail -n 60 || true
echo 'This is not a physical-screen PASS. Unknown-disabled state requires investigation.'
