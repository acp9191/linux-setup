#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

if command -v tailscale >/dev/null 2>&1; then
    success "Tailscale already installed: $(tailscale version | head -1)"
else
    info "Installing Tailscale"
    curl -fsSL https://tailscale.com/install.sh | sh
    success "Tailscale installed"
fi
