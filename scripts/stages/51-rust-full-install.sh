#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine; need_ubuntu_2604; need_runtime_pin; need_cargo
[[ "${XDG_SESSION_TYPE:-}" == wayland ]] || fail 'Run from GNOME Wayland user session, not SSH/TTY.'
command -v gdctl >/dev/null || fail 'GNOME gdctl missing.'
echo 'This calls the upstream full GNOME installer: udev/input/sudoers, Rust binaries, system/user services and backlight GRUB drop-in.'
echo 'Run ONLY after Xe is confirmed working, with detached keyboard and both displays physically usable.'
[[ -t 0 ]] || fail 'An interactive session is required for upstream prompts.'
read -r -p 'Type INSTALL to continue: ' ack
[[ "$ack" == INSTALL ]] || fail 'Not confirmed.'
say 'Stop obsolete in-user display helper only'
systemctl --user disable --now zenbook-duo-display.service 2>/dev/null || true
cd "$HOME/zenbook-duo26-Ubuntu26.04"
./install.sh --skip-ui -- --no-usb-media-remap
echo 'No reboot was requested by this wrapper. Review logs, then perform manual validation.'
