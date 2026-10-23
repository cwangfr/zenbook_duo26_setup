#!/usr/bin/env bash
# Optional in Try Ubuntu LiveUSB, only opens GNOME Displays settings.
set -Eeuo pipefail
echo 'LIVEUSB: detach keyboard, use a wired keyboard/mouse and rotate the upper physical display.'
echo 'In Settings > Displays select upper panel > Landscape (flipped) > Apply > Keep Changes.'
echo 'No GNOME XML, GDM, Xe, or GRUB changes are made by this helper.'
command -v gnome-control-center >/dev/null || { echo 'GNOME settings unavailable: use the installer UI; do not guess connector names.' >&2; exit 1; }
exec gnome-control-center display
