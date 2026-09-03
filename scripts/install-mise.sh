#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

if command -v mise >/dev/null 2>&1; then
    success "mise already installed: $(mise --version)"
else
    info "Installing mise"
    curl https://mise.run | sh
    success "mise installed"
fi
