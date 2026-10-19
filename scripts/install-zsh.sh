#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "Oh My Zsh" "installed"
else
    step "Oh My Zsh" "installed · new" bash -c \
        'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

install_plugin() {
    local name="$1"
    local repo="$2"
    local dir="$ZSH_CUSTOM/plugins/$3"

    if [ -d "$dir" ]; then
        ok "$name" "installed"
    else
        step "$name" "installed · new" git clone "$repo" "$dir"
    fi
}

install_plugin "Autosuggestions" \
    https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
install_plugin "Syntax highlighting" \
    https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting
