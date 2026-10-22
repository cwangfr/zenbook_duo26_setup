#!/usr/bin/env bash
# Fixed commits only; never reset or overwrite an existing worktree.
set -Eeuo pipefail
if [[ $# == 0 || "${1:-}" == --help ]]; then echo 'Usage: fetch-upstream.sh runtime|xe'; exit 0; fi
(( EUID != 0 )) || { echo 'Run as the desktop user, not root.' >&2; exit 1; }
root="$(cd "$(dirname "$0")/.." && pwd)"
case "$1" in runtime) key=runtime ;; xe) key=xe_patches ;; *) echo 'Expected runtime or xe.' >&2; exit 1 ;; esac
readarray -t fields < <(python3 - "$root/config/sources.lock.json" "$key" <<'PY'
import json, sys
s=json.load(open(sys.argv[1]))[sys.argv[2]]
for k in ('repository','commit','directory'):
    print(s[k])
PY
)
[[ ${#fields[@]} == 3 ]] || { echo 'Invalid lock file.' >&2; exit 1; }
url="${fields[0]}"; pin="${fields[1]}"; dest="$HOME/${fields[2]}"
[[ "$pin" =~ ^[0-9a-f]{40}$ ]] || exit 1
if [[ -e "$dest" ]]; then
  [[ -d "$dest/.git" ]] || { echo 'Destination is not a Git checkout.' >&2; exit 1; }
  origin="$(git -C "$dest" remote get-url origin)"
  [[ "${origin%.git}" == "$url" ]] || { echo 'Unexpected origin; no changes.' >&2; exit 1; }
  [[ "$(git -C "$dest" rev-parse HEAD)" == "$pin" ]] || { echo 'Existing commit differs. Preserve local work; no reset performed.' >&2; exit 1; }
  [[ -z "$(git -C "$dest" status --porcelain --untracked-files=normal)" ]] || { echo 'Local changes/untracked files present. Review first.' >&2; exit 1; }
else
  git clone --no-checkout "$url.git" "$dest"
  if ! git -C "$dest" cat-file -e "$pin^{commit}" 2>/dev/null; then git -C "$dest" fetch origin "$pin"; fi
  git -C "$dest" checkout --detach "$pin"
fi
[[ "$(git -C "$dest" rev-parse HEAD)" == "$pin" ]] || exit 1
printf 'PIN OK: %s\n%s\n' "$pin" "$dest"
