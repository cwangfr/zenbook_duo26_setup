#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/_common.sh"
need_apply "$@"; need_machine; need_ubuntu_2604
say 'Install git/python3; apt does not perform full-upgrade'
sudo apt-get update
sudo apt-get install -y git python3
say 'Fetch and check pinned runtime + Xe patch sources'
bash "$STAGE_ROOT/scripts/fetch-upstream.sh" runtime
bash "$STAGE_ROOT/scripts/fetch-upstream.sh" xe
echo 'Read the locked commits in config/sources.lock.json before further stages.'
