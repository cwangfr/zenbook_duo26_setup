#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine; need_ubuntu_2604; need_runtime_pin
if bash "$STAGE_ROOT/scripts/check-mok.sh"; then
  echo 'Exact local signing key already enrolled. No enrollment needed.'
  exit 0
fi
say 'Request MOK enrollment (interactive). This DOES NOT reboot.'
cd "$HOME/zenbook-duo26-Ubuntu26.04/ux8407aa-asus-nb-wmi-quirk"
bash scripts/enroll-mok.sh
echo 'MANUAL: reboot once, choose Enroll MOK > Continue > Yes > password, then run stage 32.'
