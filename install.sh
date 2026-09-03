#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing Zsh configuration"

ln -sf "$REPO/home/.zshrc" "$HOME/.zshrc"

echo "==> Done!"
