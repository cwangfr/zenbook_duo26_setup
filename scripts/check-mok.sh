#!/usr/bin/env bash
# Export public certificates only; never export the private signing key.
set -Eeuo pipefail
if [[ "${1:-}" == --help ]]; then echo 'Usage: check-mok.sh (read-only trust check)'; exit 0; fi
export LC_ALL=C
cert=/var/lib/shim-signed/mok/MOK.der
key=/var/lib/shim-signed/mok/MOK.priv
state="$(mokutil --sb-state)"
printf '%s\n' "$state"
[[ "$state" == *'SecureBoot enabled'* ]] || { echo 'Baseline requires Secure Boot enabled.' >&2; exit 1; }
sudo test -f "$cert" && sudo test -f "$key" || { echo 'Expected Ubuntu DKMS keypair absent.' >&2; exit 1; }
tmp="$(mktemp -d)"
trap 'sudo rm -rf -- "$tmp"' EXIT
(cd "$tmp" && sudo mokutil --export)
matched=0
for p in "$tmp"/*.der; do
  sudo test -f "$p" || continue
  if sudo cmp -s "$cert" "$p"; then matched=1; break; fi
done
(( matched == 1 )) || { echo 'Exact certificate not found in enrolled MOK export.' >&2; exit 1; }
a="$(sudo openssl pkey -in "$key" -pubout -outform DER | sha256sum | cut -d' ' -f1)"
b="$(sudo openssl x509 -inform DER -in "$cert" -pubkey -noout | openssl pkey -pubin -outform DER | sha256sum | cut -d' ' -f1)"
[[ "$a" == "$b" ]] || { echo 'Private key and certificate do not match.' >&2; exit 1; }
echo 'MOK verified: exact enrolled certificate and matching local private key.'
