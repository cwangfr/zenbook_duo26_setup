#!/usr/bin/env bash
set -Eeuo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)" == *UX8407AA* ]] || {
  echo 'Refusing installation: not an ASUS UX8407AA.' >&2
  exit 1
}
for f in /usr/local/sbin/zenbook-bt-recover \
  /etc/systemd/system/zenbook-bt-recover.service \
  /etc/systemd/system/zenbook-bt-recover.timer; do
  if sudo test -e "$f"; then
    echo "Refusing to overwrite existing file: $f" >&2
    exit 1
  fi
done
sudo install -m 0755 "$here/zenbook-bt-recover" /usr/local/sbin/zenbook-bt-recover
sudo install -m 0644 "$here/zenbook-bt-recover.service" /etc/systemd/system/zenbook-bt-recover.service
sudo install -m 0644 "$here/zenbook-bt-recover.timer" /etc/systemd/system/zenbook-bt-recover.timer
sudo systemctl daemon-reload
sudo systemctl enable --now zenbook-bt-recover.timer
echo 'Installed. Recovery checks once per boot; never restarts the system.'
echo 'View: systemctl list-timers zenbook-bt-recover.timer'
echo 'Log: journalctl -b -u zenbook-bt-recover.service --no-pager'
