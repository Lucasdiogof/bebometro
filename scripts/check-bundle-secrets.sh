#!/usr/bin/env bash
# Fails if the web bundle contains privileged keys. Usage: check-bundle-secrets.sh build/web
set -euo pipefail
DIR="${1:-build/web}"
[ -d "$DIR" ] || { echo "No $DIR"; exit 1; }
bad=0
# service_role JWTs / secret keys
if grep -rEl 'sb_secret_[A-Za-z0-9_-]+|service_role' "$DIR" --include='*.js' --include='*.json' --include='*.html' 2>/dev/null; then
  echo "FAIL: privileged Supabase key marker found in bundle"; bad=1
fi
# JWTs whose payload decodes to role=service_role
for t in $(grep -rhoE 'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}' "$DIR" 2>/dev/null | sort -u); do
  p=$(echo "$t" | cut -d. -f2); p="$p$(printf '=%.0s' 1 2 3)"
  if echo "$p" | tr '_-' '/+' | base64 -d 2>/dev/null | grep -q service_role; then echo "FAIL: service_role JWT"; bad=1; fi
done
[ $bad -eq 0 ] && echo "OK: no privileged keys in $DIR"
exit $bad
