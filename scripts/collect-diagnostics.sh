#!/usr/bin/env bash
# Writes local evidence only; redact before sharing.
set -Eeuo pipefail
if [[ "${1:-}" == --help ]]; then echo 'Usage: collect-diagnostics.sh [NEW_PRIVATE_DIRECTORY]'; exit 0; fi
(( EUID != 0 )) || { echo 'Run as the desktop user.' >&2; exit 1; }
root="$(cd "$(dirname "$0")/.." && pwd)"
umask 077
out="${1:-$HOME/zenbook-diagnostics-$(date +%Y%m%dT%H%M%S)}"
[[ ! -e "$out" ]] || { echo 'Refusing to overwrite previous evidence.' >&2; exit 1; }
mkdir -p "$out"; chmod 700 "$out"
bash "$root/scripts/preflight.sh" >"$out/preflight.txt" 2>&1
sudo journalctl -k -b --no-pager >"$out/kernel-current-boot.txt"
sudo journalctl -b -u zenbook-duo-rust-daemon.service -u zenbook-duo-rust-lifecycle.service -u bluetooth.service --no-pager >"$out/system-services.txt"
journalctl --user -b -u zenbook-duo-session-agent.service --no-pager >"$out/user-agent.txt" 2>&1 || true
for f in state.json daemon.log; do
  if sudo test -f "/var/lib/zenbook-duo/$f"; then sudo cat "/var/lib/zenbook-duo/$f" >"$out/$f"; fi
done
lspci -nnk >"$out/lspci.txt" 2>&1 || true
lsusb >"$out/lsusb.txt" 2>&1 || true
printf 'Evidence saved privately: %s\n' "$out"
echo 'May contain usernames, addresses and device identifiers. Never commit automatically.'
