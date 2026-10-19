#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/scripts/lib.sh"

banner "Linux VM Setup" "Provisioning your development environment"

keep_sudo_alive

section "System packages"

mapfile -t packages < <(sed 's/[[:space:]]*#.*$//' "$REPO/packages/apt.txt" | grep -vE '^[[:space:]]*$')

step "Package lists" "updated" sudo apt update
step "Packages" "${#packages[@]} installed" sudo apt install -y "${packages[@]}"

section "Shell"

"$REPO/scripts/install-zsh.sh"
link_config ".zshrc" "$REPO/home/.zshrc" "$HOME/.zshrc"
link_config ".tmux.conf" "$REPO/home/.tmux.conf" "$HOME/.tmux.conf"

section "Development tools"

"$REPO/scripts/install-uv.sh"
"$REPO/scripts/install-bun.sh"
"$REPO/scripts/install-mise.sh"
"$REPO/scripts/install-tailscale.sh"
"$REPO/scripts/install-docker.sh"
"$REPO/scripts/install-opencode.sh"

mkdir -p "$HOME/.config/mise"
link_config "mise config" "$REPO/mise/config.toml" "$HOME/.config/mise/config.toml"
step "mise tools" "installed" mise install

section "Git"

link_config ".gitconfig" "$REPO/home/.gitconfig" "$HOME/.gitconfig"

mkdir -p "$HOME/.config/git"
link_config "allowed_signers" "$REPO/home/.config/git/allowed_signers" "$HOME/.config/git/allowed_signers"

section "System"

"$REPO/scripts/install-auto-updates.sh"
"$REPO/scripts/install-update-timer.sh"
"$REPO/scripts/install-security.sh"

finish "Setup complete"
