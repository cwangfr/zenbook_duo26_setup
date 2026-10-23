#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_machine
say 'Check enrolled MOK certificate and key (no private key is exported)'
bash "$STAGE_ROOT/scripts/check-mok.sh"
say 'WMI module inventory'
dkms status -m asus-nb-wmi-ux8407aa || true
modinfo -n asus_nb_wmi || true
echo 'Also test attaching/detaching the keyboard and verify rfkill does not toggle.'
