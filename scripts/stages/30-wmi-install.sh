#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine; need_ubuntu_2604; need_runtime_pin
if dkms status -m asus-nb-wmi-ux8407aa 2>/dev/null | grep -q '0.1.0'; then
  fail 'WMI DKMS 0.1.0 already registered; verify it rather than force reinstall.'
fi
say 'Build/install the fixed ASUS WMI keyboard rfkill quirk'
cd "$HOME/zenbook-duo26-Ubuntu26.04/ux8407aa-asus-nb-wmi-quirk"
bash scripts/install.sh
echo 'If Secure Boot is enabled, proceed to stage 31 and enroll MOK before reboot.'
