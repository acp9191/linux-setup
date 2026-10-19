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

# --unattended is the weekly systemd run: no sudo, and nothing that can change
# behavior under you. apt is left to unattended-upgrades, and runtime upgrades
# (e.g. a new Node LTS major) stay a manual ./update.sh.
unattended=false

case "${1:-}" in
    --unattended) unattended=true ;;
    "") ;;
    *)
        echo "Usage: ./update.sh [--unattended]" >&2
        exit 2
        ;;
esac

if [ "$unattended" = true ]; then
    banner "Linux VM Update" "Scheduled tool updates"
else
    banner "Linux VM Update" "Updating your development environment"

    keep_sudo_alive

    section "System packages"

    # Also repairs repos disabled by a release upgrade, before apt reads them.
    "$REPO/scripts/install-apt-repos.sh"
    step "Package lists" "updated" sudo apt update

    upgradable="$(apt-get -s upgrade 2>/dev/null | grep -c '^Inst ' || true)"

    if [ "$upgradable" -eq 0 ]; then
        ok "Packages" "up to date"
    else
        step "Packages" "$upgradable upgraded" sudo apt upgrade -y
    fi
fi

section "Development tools"

update_tool "mise" mise mise self-update -y

if [ "$unattended" = false ]; then
    step "mise tools" "upgraded" mise upgrade
fi

update_tool "uv" uv uv self update
step "uv tools" "upgraded" uv tool upgrade --all
update_tool "Bun" bun bun upgrade
update_tool "OpenCode" opencode opencode upgrade

section "Shell"

update_repo "Oh My Zsh" "$HOME/.oh-my-zsh"
update_repo "Autosuggestions" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
update_repo "Syntax highlighting" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

finish "Update complete"
