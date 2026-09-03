#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating apt"
sudo apt update

echo "==> Installing packages"
xargs sudo apt install -y < "$REPO/packages/apt.txt"

echo "==> Installing Zsh"
"$REPO/scripts/install-zsh.sh"

echo "==> Installing Zsh configuration"
ln -sf "$REPO/home/.zshrc" "$HOME/.zshrc"

echo "==> Done!"
