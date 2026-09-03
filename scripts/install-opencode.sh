#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

if command -v opencode >/dev/null 2>&1; then
    success "OpenCode already installed: $(opencode --version)"
else
    info "Installing OpenCode"
    curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
    success "OpenCode installed"
fi
