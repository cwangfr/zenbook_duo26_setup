#!/usr/bin/env bash
# One manual invocation, one reload of the known Intel PCIe controller.
set -Eeuo pipefail
if [[ "${1:-}" == --help ]]; then echo 'Usage: bluetooth-reload.sh --apply (wired input required)'; exit 0; fi
[[ "${1:-}" == --apply ]] || { echo 'Explicit --apply required.' >&2; exit 1; }
[[ "$(cat /sys/class/dmi/id/product_name 2>/dev/null)" == 'Zenbook Duo UX8407AA' ]] || exit 1
export LC_ALL=C
dev=/sys/bus/pci/devices/0000:00:14.7
[[ "$(cat "$dev/vendor" 2>/dev/null)" == 0x8086 && "$(cat "$dev/device" 2>/dev/null)" == 0xe476 ]] || { echo 'Expected PCIe controller absent.' >&2; exit 1; }
controllers="$(timeout 8 bluetoothctl list 2>/dev/null || true)"
if grep -Eq '^Controller[[:space:]]' <<<"$controllers"; then echo 'Controller available; no reload.'; exit 0; fi
for p in /sys/class/rfkill/rfkill*; do
  [[ -r "$p/type" ]] || continue
  [[ "$(cat "$p/type")" == bluetooth ]] || continue
  if [[ "$(cat "$p/soft")" == 1 || "$(cat "$p/hard")" == 1 ]]; then echo 'RFKill blocked; no automatic unblock/reset.' >&2; exit 1; fi
done
log="$(sudo journalctl -k -b -o cat --no-pager)"
grep -F 'Intel Soft Reset failed (-62)' <<<"$log" >/dev/null || { echo 'No matching failure; diagnose first.' >&2; exit 1; }
echo 'Bluetooth input will disconnect. Use wired input; no Wi-Fi or Xe module is touched.'
sudo systemctl stop bluetooth.service
trap 'sudo systemctl start bluetooth.service || true' EXIT
sudo modprobe -r btintel_pcie
sudo modprobe btintel_pcie
sudo systemctl start bluetooth.service
trap - EXIT
sleep 2
bluetoothctl list
echo 'No second reload. A listing is not a long-term stability guarantee.'
