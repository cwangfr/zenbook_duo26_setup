#!/usr/bin/env bash
# Read-only inventory; no installation or modeset.
set -u
if [[ "${1:-}" == --help ]]; then echo 'Usage: preflight.sh (read-only)'; exit 0; fi
run() { printf '\n=== %s ===\n' "$*"; "$@" 2>&1 || true; }
run cat /sys/class/dmi/id/sys_vendor /sys/class/dmi/id/product_name
run cat /etc/os-release
run uname -r
printf '\nSession: %s / desktop: %s\n' "${XDG_SESSION_TYPE:-unknown}" "${XDG_CURRENT_DESKTOP:-unknown}"
run cat /proc/cmdline
run mokutil --sb-state
run dkms status
run modinfo -n xe
run cat /sys/module/xe/parameters/zenbook_duo_edp2_tcss
run systemctl is-active zenbook-duo-rust-daemon.service
run systemctl show zenbook-duo-rust-lifecycle.service -p ActiveState -p SubState -p Result -p ExecMainStatus
run systemctl --user is-active zenbook-duo-session-agent.service
run timeout 10 gdctl show
run rfkill list
run timeout 8 bluetoothctl list
echo 'Inventory only: this does NOT certify physical displays or safe ownership.'
