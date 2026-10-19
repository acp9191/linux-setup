#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# Local time, so scheduled jobs (like the 04:00 automatic reboot) happen at
# night where you are. Override with TIMEZONE=Europe/London ./install.sh.
TIMEZONE="${TIMEZONE:-America/New_York}"

if [ "$(timedatectl show --property=Timezone --value)" = "$TIMEZONE" ]; then
    ok "Timezone" "$TIMEZONE"
else
    sudo timedatectl set-timezone "$TIMEZONE"
    ok "Timezone" "$TIMEZONE · new"
fi

# The Mac sends LANG=en_US.UTF-8 over SSH; mosh-server refuses to start
# if that locale doesn't exist here.
if locale -a | grep -qix 'en_US.utf8'; then
    ok "Locale" "en_US.UTF-8"
else
    step "Locale" "en_US.UTF-8 · new" sudo locale-gen en_US.UTF-8
fi
