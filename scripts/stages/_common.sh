#!/usr/bin/env bash
# Helpers used by the staged Ubuntu recovery scripts.
set -Eeuo pipefail
STAGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
say() { printf '\n>>> %s\n' "$*"; }
need_user() { (( EUID != 0 )) || fail 'Run as the logged-in desktop user; do not use sudo to launch this script.'; }
need_apply() { [[ "$#" == 1 && "$1" == --apply ]] || fail 'This stage changes the system. Explicitly pass --apply; see docs/STAGES.md.'; need_user; }
need_machine() {
  [[ "$(cat /sys/class/dmi/id/sys_vendor)" == ASUS && "$(cat /sys/class/dmi/id/product_name)" == 'Zenbook Duo UX8407AA' ]] || fail 'This stage only supports ASUS Zenbook Duo UX8407AA.';
}
need_ubuntu_2604() {
  [[ -r /etc/os-release ]] || fail 'Missing /etc/os-release';
  (. /etc/os-release; [[ "$ID" == ubuntu && "$VERSION_ID" == 26.04 ]]) || fail 'Expected Ubuntu 26.04. Read compatibility notes before installing.';
}
need_runtime_pin() {
  local dest="$HOME/zenbook-duo26-Ubuntu26.04"
  [[ -d "$dest/.git" ]] || fail "Missing pinned runtime checkout: $dest. Run stage 20 first."
  [[ "$(git -C "$dest" rev-parse HEAD)" == e0b11760ad23898761e7acedd322dc412ced604a ]] || fail 'Runtime HEAD differs from verified pin; do not overwrite local work.';
  [[ -z "$(git -C "$dest" status --porcelain --untracked-files=normal)" ]] || fail 'Pinned runtime checkout has local changes; review, do not overwrite.';
}
need_cargo() {
  export PATH="$HOME/.cargo/bin:$PATH"
  [[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
  command -v cargo >/dev/null 2>&1 && cargo --version || fail 'Cargo unavailable: run stage 50.';
}
