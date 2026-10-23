#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine
if [[ -n "$WAYLAND_DISPLAY" || -n "$DISPLAY" ]]; then fail 'Never uninstall Xe while a graphical desktop is running. Boot a safe fallback kernel and use TTY.'; fi
[[ -t 0 ]] || fail 'TTY confirmation required; do not run this from unattended scripts.'
read -r -p 'Confirm fallback boot and safe offline rollback. Type ROLLBACK: ' ack
[[ "$ack" == ROLLBACK ]] || fail 'Not confirmed.'
bash "$STAGE_ROOT/scripts/xe/zenbook_duo_ubuntu_xe_dkms_rollback.sh"
echo 'Original rollback tolerates DKMS remove failures. Verify dkms status, modinfo, initramfs before reboot.'
