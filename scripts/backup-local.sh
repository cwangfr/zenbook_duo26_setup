#!/usr/bin/env bash
# Local backup only; no automatic restore, no private signing/pairing keys.
set -Eeuo pipefail
if [[ $# == 0 || "${1:-}" == --help ]]; then echo 'Usage: backup-local.sh NEW_PRIVATE_DIRECTORY (prefer external encrypted storage)'; exit 0; fi
(( EUID != 0 )) || { echo 'Run as desktop user.' >&2; exit 1; }
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$1"
[[ ! -e "$out" ]] || { echo 'Refusing to overwrite a backup.' >&2; exit 1; }
umask 077
mkdir -p "$out"; out="$(cd "$out" && pwd)"
[[ "$out" != "$root" && "$out" != "$root/"* ]] || { echo 'Backup must be outside this repository.' >&2; exit 1; }
chmod 700 "$out"; mkdir "$out/files" "$out/sources"
bash "$root/scripts/preflight.sh" >"$out/preflight.txt" 2>&1
k="$(uname -r)"
paths=(
 "$HOME/.config/monitors.xml" "$HOME/.config/zenbook-duo"
 /var/lib/gdm3/seat0/config/monitors.xml /etc/xdg/monitors.xml
 /etc/default/grub /etc/default/grub.d /etc/plymouth/plymouthd.conf
 /etc/systemd/system/zenbook-duo-rust-daemon.service
 /etc/systemd/system/zenbook-duo-rust-lifecycle.service
 /etc/systemd/user/zenbook-duo-session-agent.service
 /usr/local/libexec/zenbook-duo /usr/local/sbin/zenbook-bt-recover
 /etc/systemd/system/zenbook-bt-recover.service
 /etc/systemd/system/zenbook-bt-recover.timer
 "/boot/initrd.img-$k" "/boot/vmlinuz-$k"
 /usr/src/zenbook-duo-xe-ubuntu-1.3.0-u70038 /etc/udev/rules.d
)
for f in "${paths[@]}"; do
 if sudo test -e "$f"; then
  sudo stat -c '%a %u:%g %n' "$f" >>"$out/original-modes.txt"
  sudo cp -a --parents "$f" "$out/files/"
 fi
done
dpkg-query -W -f='${binary:Package}\t${Version}\n' >"$out/packages.txt"
for d in "$HOME/zenbook-duo26-Ubuntu26.04" "$HOME/zenbook-duo-2026-linux"; do
 [[ -d "$d/.git" ]] || continue
 name="$(basename "$d")"
 git -C "$d" rev-parse HEAD >"$out/sources/$name.commit"
 git -C "$d" status --porcelain >"$out/sources/$name.status"
 git -C "$d" diff --binary HEAD >"$out/sources/$name.uncommitted.patch"
 git -C "$d" bundle create "$out/sources/$name.bundle" --all HEAD
done
printf 'Local backup: %s\n' "$out"
echo 'Not a disk image or complete offline package cache. Review untracked files separately.'
echo 'Private signing keys, Bluetooth pairing secrets and network credentials are excluded.'
echo 'Do not replay old ownership, numeric GDM UIDs or initrd on another kernel.'
