#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_machine
[[ "$(uname -r)" == 7.0.0-38-generic ]] || fail 'Running kernel differs; inspect ABI before proceeding.'
say 'Loaded Xe module parameter after controlled reboot'
p=/sys/module/xe/parameters/zenbook_duo_edp2_tcss
[[ -r "$p" ]] || fail 'Running patched Xe parameter is missing.'
[[ "$(cat "$p")" == Y ]] || fail 'Running patched Xe parameter != Y.'
modinfo -n xe
modinfo -F signer xe
dkms status -m zenbook-duo-xe-ubuntu
echo 'Physical-screen and cold-boot behavior still require manual verification.'
