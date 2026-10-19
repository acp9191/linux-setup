#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# SHELL=sh stops the installer appending to ~/.zshrc, which is a symlink into
# this repository; .zshrc already sets up Bun's PATH.
ensure_tool "Bun" bun bash -c 'curl -fsSL https://bun.com/install | SHELL=sh bash'

# Zsh completions, which the installer only generates for zsh.
if [ ! -s "$HOME/.bun/_bun" ]; then
    IS_BUN_AUTO_UPDATE=true SHELL=zsh bun completions >/dev/null 2>&1 || true
fi
