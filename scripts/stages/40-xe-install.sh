#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine; need_ubuntu_2604
[[ "$(uname -r)" == 7.0.0-38-generic ]] || fail 'Xe v3 is ONLY for 7.0.0-38-generic.'
say 'Check Secure Boot MOK before kernel module replacement'
bash "$STAGE_ROOT/scripts/check-mok.sh"
say 'Install Xe TCSS DKMS v3 with ABI/initramfs safeguards. NO automatic reboot.'
mkdir -p "$HOME/zenbook-recovery-logs"
bash "$STAGE_ROOT/scripts/install-xe.sh" --apply 2>&1 | tee "$HOME/zenbook-recovery-logs/40-xe-install.log"
echo 'Save work and reboot manually ONLY after checking successful module/initramfs output.'
