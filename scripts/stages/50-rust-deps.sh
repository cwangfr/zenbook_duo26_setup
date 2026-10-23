#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine; need_ubuntu_2604
say 'Install Tauri 2 / gobject-sys build prerequisites (not Xe or GDM)'
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libglib2.0-dev libgtk-3-dev libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev libssl-dev libxdo-dev file curl ca-certificates
export PATH="$HOME/.cargo/bin:$PATH"
if [[ -r "$HOME/.cargo/env" ]]; then source "$HOME/.cargo/env"; fi
if ! cargo --version >/dev/null 2>&1; then
  say 'Install official rustup in this desktop user account'
  t="$(mktemp -d)"
  trap 'rm -rf "$t"' EXIT
  curl --fail --location --show-error --silent --proto '=https' --tlsv1.2 https://sh.rustup.rs -o "$t/rustup-init.sh"
  sh "$t/rustup-init.sh" -y
  export PATH="$HOME/.cargo/bin:$PATH"
  if [[ -r "$HOME/.cargo/env" ]]; then source "$HOME/.cargo/env"; fi
fi
cargo --version
rustc --version
pkg-config --modversion gobject-2.0
pkg-config --modversion gtk+-3.0
pkg-config --modversion webkit2gtk-4.1
echo 'Rust/GTK prerequisite checks succeeded; if Cargo fails later collect the FULL build stderr.'
