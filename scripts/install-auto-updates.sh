#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

if dpkg -s unattended-upgrades >/dev/null 2>&1; then
    success "unattended-upgrades already installed"
else
    info "Installing unattended-upgrades"
    sudo apt install -y unattended-upgrades
    success "unattended-upgrades installed"
fi

# Copied rather than symlinked: apt runs these as root, so they must be root-owned.
sudo install -m 644 -o root -g root \
    "$REPO/apt/20auto-upgrades" /etc/apt/apt.conf.d/20auto-upgrades
sudo install -m 644 -o root -g root \
    "$REPO/apt/52unattended-upgrades-local" /etc/apt/apt.conf.d/52unattended-upgrades-local
success "Automatic update configuration"

sudo systemctl enable --now unattended-upgrades.service apt-daily.timer apt-daily-upgrade.timer >/dev/null 2>&1
success "Automatic update timers enabled"
