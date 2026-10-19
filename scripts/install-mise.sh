#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# Don't let mise print its "new version available" warning; we update below instead.
export MISE_HIDE_UPDATE_WARNING=1

if command -v mise >/dev/null 2>&1; then
    run_with_spinner "Updating mise" mise self-update -y || warning "mise self-update failed; continuing"
    success "mise already installed: $(mise --version)"
else
    info "Installing mise"
    curl https://mise.run | sh
    success "mise installed"
fi
