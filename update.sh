#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/scripts/lib.sh"

# Pull a git checkout and print "old → new" commits or "up to date".
update_repo() {
    local name="$1"
    local dir="$2"
    local before
    local after

    before="$(git -C "$dir" rev-parse --short HEAD)"

    if spin "$name" git -C "$dir" pull --ff-only; then
        after="$(git -C "$dir" rev-parse --short HEAD)"

        if [ "$before" = "$after" ]; then
            ok "$name" "up to date"
        else
            ok "$name" "$before → $after"
        fi
    else
        fail "$name" "update failed"
        show_log
        return 1
    fi
}

banner "Linux VM Update" "Updating your development environment"

keep_sudo_alive

section "System packages"

step "Package lists" "updated" sudo apt update

upgradable="$(apt-get -s upgrade 2>/dev/null | grep -c '^Inst ' || true)"

if [ "$upgradable" -eq 0 ]; then
    ok "Packages" "up to date"
else
    step "Packages" "$upgradable upgraded" sudo apt upgrade -y
fi

section "Development tools"

update_tool "mise" mise mise self-update -y
step "mise tools" "upgraded" mise upgrade
update_tool "uv" uv uv self update
step "uv tools" "upgraded" uv tool upgrade --all
update_tool "Bun" bun bun upgrade
update_tool "OpenCode" opencode opencode upgrade

section "Shell"

update_repo "Oh My Zsh" "$HOME/.oh-my-zsh"
update_repo "Autosuggestions" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
update_repo "Syntax highlighting" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

finish "Update complete"
