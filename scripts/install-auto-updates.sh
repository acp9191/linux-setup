#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# Copied rather than symlinked: apt runs these as root, so they must be root-owned.
sudo install -m 644 -o root -g root \
    "$REPO/apt/20auto-upgrades" /etc/apt/apt.conf.d/20auto-upgrades
sudo install -m 644 -o root -g root \
    "$REPO/apt/52unattended-upgrades-local" /etc/apt/apt.conf.d/52unattended-upgrades-local

if ! spin "Auto updates" sudo systemctl enable --now \
    unattended-upgrades.service apt-daily.timer apt-daily-upgrade.timer; then
    fail "Auto updates" "could not enable timers"
    show_log
    exit 1
fi

reboot=""
reboot_time=""
eval "$(apt-config shell \
    reboot Unattended-Upgrade::Automatic-Reboot \
    reboot_time Unattended-Upgrade::Automatic-Reboot-Time)"

if [ "$reboot" = "true" ]; then
    ok "Auto updates" "daily · reboots at $reboot_time when needed"
else
    ok "Auto updates" "daily"
fi
