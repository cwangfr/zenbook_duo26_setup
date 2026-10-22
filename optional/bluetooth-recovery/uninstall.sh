#!/usr/bin/env bash
set -Eeuo pipefail
sudo systemctl disable --now zenbook-bt-recover.timer 2>/dev/null || true
sudo systemctl stop zenbook-bt-recover.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/zenbook-bt-recover.service \
  /etc/systemd/system/zenbook-bt-recover.timer \
  /usr/local/sbin/zenbook-bt-recover
sudo systemctl daemon-reload
echo 'Zenbook Bluetooth recovery timer and service removed.'
