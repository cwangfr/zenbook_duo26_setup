#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_user; need_runtime_pin; need_cargo
say 'Execute locked Rust library runtime tests; may build dependencies'
cd "$HOME/zenbook-duo26-Ubuntu26.04/ui-tauri-react/src-tauri"
cargo test --locked --lib runtime::
