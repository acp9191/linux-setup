#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/scripts/lib.sh"

printf "\n"
printf "${BOLD}Linux VM Check${RESET}\n"
printf "${DIM}Verifying your development environment${RESET}\n"

failures=0

section() {
    printf "\n${BOLD}%s${RESET}\n" "$1"
}

check_command() {
    local name="$1"
    local command="$2"

    if command -v "$command" >/dev/null 2>&1; then
        printf "  ${GREEN}✓${RESET} %-18s installed\n" "$name"
    else
        printf "  ${RED}✗${RESET} %-18s not installed\n" "$name"
        failures=$((failures + 1))
    fi
}

check_symlink() {
    local name="$1"
    local target="$2"
    local expected="$3"

    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$expected" ]; then
        printf "  ${GREEN}✓${RESET} %-18s configured\n" "$name"
    else
        printf "  ${RED}✗${RESET} %-18s misconfigured\n" "$name"
        failures=$((failures + 1))
    fi
}

section "Shell & Terminal"

check_command "Zsh" zsh
check_command "tmux" tmux
check_command "fzf" fzf
check_command "fd" fdfind
check_command "bat" batcat
check_command "eza" eza
check_command "zoxide" zoxide
check_command "direnv" direnv

section "Development"

check_command "Git" git
check_command "GitHub CLI" gh
check_command "delta" delta
check_command "uv" uv
check_command "Bun" bun
check_command "mise" mise

section "Languages"

if mise exec -- go version >/dev/null 2>&1; then
    printf "  ${GREEN}✓${RESET} %-18s %s\n" \
        "Go" "$(mise exec -- go version | sed 's/^go version //')"
else
    printf "  ${RED}✗${RESET} %-18s not available through mise\n" "Go"
    failures=$((failures + 1))
fi

if mise exec -- node --version >/dev/null 2>&1; then
    printf "  ${GREEN}✓${RESET} %-18s %s\n" \
        "Node" "$(mise exec -- node --version)"
else
    printf "  ${RED}✗${RESET} %-18s not available through mise\n" "Node"
    failures=$((failures + 1))
fi

if mise exec -- python --version >/dev/null 2>&1; then
    printf "  ${GREEN}✓${RESET} %-18s %s\n" \
        "Python" "$(mise exec -- python --version | sed 's/^Python //')"
else
    printf "  ${RED}✗${RESET} %-18s not available through mise\n" "Python"
    failures=$((failures + 1))
fi

section "Data & Networking"

check_command "jq" jq
check_command "yq" yq
check_command "Tailscale" tailscale

section "Containers"

check_command "Docker" docker

if docker compose version >/dev/null 2>&1; then
    printf "  ${GREEN}✓${RESET} %-18s %s\n" \
        "Compose" "$(docker compose version --short)"
else
    printf "  ${RED}✗${RESET} %-18s not available\n" "Compose"
    failures=$((failures + 1))
fi

if docker info >/dev/null 2>&1; then
    printf "  ${GREEN}✓${RESET} %-18s without sudo\n" "Docker access"
else
    printf "  ${RED}✗${RESET} %-18s requires sudo\n" "Docker access"
    failures=$((failures + 1))
fi

section "AI"

check_command "OpenCode" opencode

section "Configuration"

check_symlink ".zshrc" \
    "$HOME/.zshrc" \
    "$REPO/home/.zshrc"

check_symlink ".gitconfig" \
    "$HOME/.gitconfig" \
    "$REPO/home/.gitconfig"

check_symlink ".tmux.conf" \
    "$HOME/.tmux.conf" \
    "$REPO/home/.tmux.conf"

check_symlink "mise config" \
    "$HOME/.config/mise/config.toml" \
    "$REPO/mise/config.toml"

if [ "$(git config --global commit.gpgsign)" = "true" ]; then
    printf "  ${GREEN}✓${RESET} %-18s enabled\n" "GPG signing"
else
    printf "  ${RED}✗${RESET} %-18s disabled\n" "GPG signing"
    failures=$((failures + 1))
fi

if gh auth status >/dev/null 2>&1; then
    printf "  ${GREEN}✓${RESET} %-18s authenticated\n" "GitHub CLI"
else
    printf "  ${RED}✗${RESET} %-18s not authenticated\n" "GitHub CLI"
    failures=$((failures + 1))
fi

printf "\n${DIM}────────────────────────────────────────${RESET}\n"

if [ "$failures" -eq 0 ]; then
    printf "${GREEN}${BOLD}✓ All checks passed${RESET}\n\n"
else
    printf "${RED}${BOLD}✗ %s check(s) failed${RESET}\n\n" "$failures"
    exit 1
fi
