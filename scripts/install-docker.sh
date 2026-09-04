#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

if command -v docker >/dev/null 2>&1; then
    success "Docker already installed: $(docker --version)"
else
    info "Installing Docker"

    curl -fsSL https://get.docker.com | sh

    success "Docker installed"
fi

if getent group docker >/dev/null 2>&1; then
    success "Docker group exists"
else
    sudo groupadd docker
    success "Docker group created"
fi

if id -nG "$USER" | grep -qw docker; then
    success "User already in docker group"
else
    sudo usermod -aG docker "$USER"
    warning "Docker group added; log out and back in for it to take effect"
fi
