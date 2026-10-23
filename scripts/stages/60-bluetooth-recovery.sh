#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine
echo 'OPTIONAL: this may interrupt existing Bluetooth connections. Use a wired keyboard/mouse.'
say 'Delegate one-time guarded PCIe Intel Bluetooth reload'
bash "$STAGE_ROOT/scripts/bluetooth-reload.sh" --apply
bluetoothctl list
echo 'Only needed if hci controller is missing and known reset signature matches. No automatic timer is installed.'
