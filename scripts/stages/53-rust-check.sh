#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_machine
say 'Installed Rust system service'
systemctl status --no-pager zenbook-duo-rust-daemon.service || true
say 'Lifecycle (active/exited can be expected)'
systemctl show zenbook-duo-rust-lifecycle.service -p ActiveState -p SubState -p Result -p ExecMainStatus
say 'User GNOME agent'
systemctl --user status --no-pager zenbook-duo-session-agent.service || true
say 'Dock/ownership diagnostics; no display changes'
bash "$STAGE_ROOT/scripts/verify.sh"
echo 'Manually check physical panels, keyboard dock/undock x3, cold boot and resume. UNKNOWN/O=false must not be forced.'
