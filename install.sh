#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/scripts/lib.sh"

printf "\n"
printf "${BOLD}Linux VM Setup${RESET}\n"
printf "${DIM}Provisioning your development environment${RESET}\n"

sudo -v

header "System packages"

run_with_spinner "Updating package lists" sudo apt update
run_with_spinner \
    "Installing system packages" \
    bash -c "sed 's/[[:space:]]*#.*\$//' '$REPO/packages/apt.txt' | grep -vE '^[[:space:]]*$' | xargs sudo apt install -y"

section_done

header "Shell"

"$REPO/scripts/install-zsh.sh"

ln -sf "$REPO/home/.zshrc" "$HOME/.zshrc"
success "Zsh configuration"

ln -sf "$REPO/home/.tmux.conf" "$HOME/.tmux.conf"
success "tmux configuration"

section_done

header "Development tools"

"$REPO/scripts/install-uv.sh"
"$REPO/scripts/install-bun.sh"
"$REPO/scripts/install-mise.sh"
"$REPO/scripts/install-tailscale.sh"
"$REPO/scripts/install-docker.sh"
"$REPO/scripts/install-opencode.sh"

mkdir -p "$HOME/.config/mise"
ln -sf "$REPO/mise/config.toml" "$HOME/.config/mise/config.toml"
success "mise configuration"

run_with_spinner \
    "Installing mise tools" \
    mise install
section_done

header "Git & GPG"

ln -sf "$REPO/home/.gitconfig" "$HOME/.gitconfig"
success "Git configuration"

mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
ln -sf "$REPO/home/.gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
chmod 600 "$HOME/.gnupg/gpg-agent.conf"
gpgconf --kill gpg-agent 2>/dev/null || true
success "GPG agent configuration"

section_done

printf "\n${GREEN}${BOLD}✓ Setup complete!${RESET}\n\n"
