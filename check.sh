#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/scripts/lib.sh"

banner "Linux VM Check" "Verifying your development environment"

failures=0
skipped=0

check_fail() {
    fail "$@"
    failures=$((failures + 1))
}

check_skip() {
    warn "$@"
    skipped=$((skipped + 1))
}

check_command() {
    local name="$1"
    local command="$2"
    local version

    if command -v "$command" >/dev/null 2>&1; then
        version="$(version_of "$command")"
        ok "$name" "${version:-installed}"
    else
        check_fail "$name" "not installed"
    fi
}

check_symlink() {
    local name="$1"
    local target="$2"
    local expected="$3"

    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$expected" ]; then
        ok "$name" "linked"
    else
        check_fail "$name" "not linked to the repository"
    fi
}

check_runtime() {
    local name="$1"
    shift

    if mise exec -- "$@" >/dev/null 2>&1; then
        ok "$name" "$(mise exec -- "$@" | sed -E 's/^(go version go|Python |v)//')"
    else
        check_fail "$name" "not available through mise"
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
check_command "OpenCode" opencode

section "Languages"

check_runtime "Go" go version
check_runtime "Node" node --version
check_runtime "Python" python --version

section "Data & Networking"

check_command "jq" jq
check_command "yq" yq
check_command "Tailscale" tailscale

section "Containers"

check_command "Docker" docker

if docker compose version >/dev/null 2>&1; then
    ok "Compose" "$(docker compose version --short)"
else
    check_fail "Compose" "not available"
fi

if docker info >/dev/null 2>&1; then
    ok "Docker access" "without sudo"
else
    check_fail "Docker access" "requires sudo"
fi

section "System"

auto_upgrade=""
eval "$(apt-config shell auto_upgrade APT::Periodic::Unattended-Upgrade 2>/dev/null)"

if [ "$auto_upgrade" = "1" ] \
    && systemctl is-enabled --quiet apt-daily-upgrade.timer 2>/dev/null; then
    ok "Auto updates" "enabled"
else
    check_fail "Auto updates" "disabled"
fi

if [ -L "$HOME/.config/systemd/user/timers.target.wants/linux-setup-update.timer" ] \
    && [ "$(loginctl show-user "$USER" --property=Linger --value 2>/dev/null)" = "yes" ]; then
    ok "Tool updates" "weekly"
else
    check_fail "Tool updates" "timer not enabled"
fi

if [ -f /etc/ssh/sshd_config.d/10-linux-setup.conf ]; then
    ok "SSH" "key-only logins"
elif [ ! -s "$HOME/.ssh/authorized_keys" ]; then
    check_skip "SSH" "skipped until an SSH key is authorized"
else
    check_fail "SSH" "password logins allowed"
fi

if grep -qx 'ENABLED=yes' /etc/ufw/ufw.conf 2>/dev/null; then
    ok "Firewall" "enabled"
elif ! tailscale status >/dev/null 2>&1; then
    check_skip "Firewall" "skipped until Tailscale is connected"
else
    check_fail "Firewall" "disabled"
fi

section "Configuration"

check_symlink ".zshrc" "$HOME/.zshrc" "$REPO/home/.zshrc"
check_symlink ".tmux.conf" "$HOME/.tmux.conf" "$REPO/home/.tmux.conf"
check_symlink ".gitconfig" "$HOME/.gitconfig" "$REPO/home/.gitconfig"
check_symlink "mise config" "$HOME/.config/mise/config.toml" "$REPO/mise/config.toml"

if [ "$(git config --global commit.gpgsign)" = "true" ]; then
    ok "GPG signing" "enabled"
else
    check_fail "GPG signing" "disabled"
fi

if gh auth status >/dev/null 2>&1; then
    ok "GitHub CLI auth" "authenticated"
else
    check_fail "GitHub CLI auth" "not authenticated (gh auth login)"
fi

if [ "$failures" -gt 0 ]; then
    printf "\n${RED}${BOLD}✗ %s check(s) failed${RESET}\n\n" "$failures"
    exit 1
elif [ "$skipped" -gt 0 ]; then
    printf "\n${GREEN}${BOLD}✓ All checks passed${RESET} ${DIM}· %s skipped${RESET}\n\n" "$skipped"
else
    printf "\n${GREEN}${BOLD}✓ All checks passed${RESET}\n\n"
fi
