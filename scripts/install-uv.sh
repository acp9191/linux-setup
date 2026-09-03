#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

if command -v uv >/dev/null 2>&1; then
    success "uv already installed: $(uv --version)"
else
    info "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    success "uv installed"
fi

