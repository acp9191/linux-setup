#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

if command -v bun >/dev/null 2>&1; then
    success "Bun already installed: $(bun --version)"
else
    info "Installing Bun"
    curl -fsSL https://bun.com/install | bash
    success "Bun installed"
fi

