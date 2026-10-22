#!/usr/bin/env bash
# Fresh recovery wrapper around the byte-preserved v3 installer.
set -Eeuo pipefail
if [[ "${1:-}" == --help ]]; then echo 'Usage: install-xe.sh --apply (exact ABI only)'; exit 0; fi
[[ "${1:-}" == --apply ]] || { echo 'Read docs/REINSTALL.md; explicit --apply required.' >&2; exit 1; }
(( EUID != 0 )) || { echo 'Run as desktop user, not root.' >&2; exit 1; }
[[ "$(uname -r)" == 7.0.0-38-generic ]] || { echo 'Unsupported kernel. Do not bypass ABI checks.' >&2; exit 1; }
[[ "$(cat /sys/class/dmi/id/sys_vendor)" == ASUS && "$(cat /sys/class/dmi/id/product_name)" == 'Zenbook Duo UX8407AA' ]] || exit 1
root="$(cd "$(dirname "$0")/.." && pwd)"
bash "$root/scripts/fetch-upstream.sh" xe
bash "$root/scripts/check-mok.sh"
bash "$root/scripts/xe/zenbook_duo_ubuntu_xe_dkms_install_v3.sh"
listing="$(sudo lsinitramfs "/boot/initrd.img-$(uname -r)")"
if ! grep -Eq '/updates/dkms/xe\.ko(\.[[:alnum:]]+)?$' <<<"$listing"; then
  echo 'Patched Xe not in initramfs. DO NOT reboot; collect logs and review rollback.' >&2; exit 1
fi
if grep -Eq '/kernel/drivers/gpu/drm/xe/xe\.ko(\.[[:alnum:]]+)?$' <<<"$listing"; then
  echo 'Both stock and patched Xe in initramfs. DO NOT reboot before review.' >&2; exit 1
fi
echo 'Disk/initramfs checks passed. Reboot manually after saving work.'
echo 'Then require /sys/module/xe/parameters/zenbook_duo_edp2_tcss = Y.'
