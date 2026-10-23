#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine; need_ubuntu_2604; need_runtime_pin; need_cargo
echo 'Recovery from previous gobject-sys build failure ONLY: build/install Rust runtime services.'
echo 'Do not use this as a replacement for first-time setup-gnome.sh (udev/input/touch/GRUB setup).'
[[ -t 0 ]] || fail 'Interactive confirmation required.'
read -r -p 'Have GNOME setup steps already run? Type RESUME: ' ack
[[ "$ack" == RESUME ]] || fail 'Not confirmed.'
cd "$HOME/zenbook-duo26-Ubuntu26.04"
./install-rust-runtime.sh
echo 'Only Rust runtime stage was retried. Confirm earlier setup-gnome steps are already complete.'
