#!/usr/bin/env bash
# Remove ONLY the experimental Ubuntu Xe DKMS override for UX8407AA.
# Can be executed after booting a different Ubuntu stock kernel from GRUB.
set -Eeuo pipefail
TARGET=7.0.0-38-generic
NAME=zenbook-duo-xe-ubuntu
VER=1.3.0-u70038
sudo dkms remove -m "$NAME" -v "$VER" --all || true
sudo rm -rf "/usr/src/${NAME}-${VER}"
sudo depmod -a "$TARGET"
sudo update-initramfs -u -k "$TARGET"
modinfo -k "$TARGET" -n xe
printf '\nRollback finished; reboot and select Ubuntu %s.\n' "$TARGET"
