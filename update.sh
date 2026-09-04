#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/scripts/lib.sh"

printf "\n"
printf "${BOLD}Linux VM Update${RESET}\n"
printf "${DIM}Updating your development environment${RESET}\n\n"

sudo -v

header "System packages"

run_with_spinner "Updating package lists" sudo apt update
run_with_spinner "Upgrading system packages" sudo apt upgrade -y

section_done

header "Development tools"

run_with_spinner "Updating mise" mise self-update
run_with_spinner "Upgrading mise tools" mise upgrade
run_with_spinner "Updating uv tools" uv tool upgrade --all

section_done

header "Shell"

run_with_spinner \
    "Updating Oh My Zsh" \
    bash -c 'git -C "$HOME/.oh-my-zsh" pull --ff-only'

run_with_spinner \
    "Updating zsh-autosuggestions" \
    bash -c 'git -C "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" pull --ff-only'

run_with_spinner \
    "Updating zsh-syntax-highlighting" \
    bash -c 'git -C "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" pull --ff-only'

section_done

printf "\n${GREEN}${BOLD}✓ Update complete!${RESET}\n\n"
