#!/usr/bin/env bash

# Tool install locations (mirrors home/.zshrc), so freshly installed tools are
# usable before a new shell has been opened.
export PATH="$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.local/bin:$PATH"

# Keep mise's "new version available" notice out of the output.
export MISE_HIDE_UPDATE_WARNING=1

# Colors
if [ -t 1 ]; then
    RESET='\033[0m'
    BOLD='\033[1m'
    DIM='\033[2m'
    BLUE='\033[34m'
    GREEN='\033[32m'
    RED='\033[31m'
    YELLOW='\033[33m'
else
    RESET=''
    BOLD=''
    DIM=''
    BLUE=''
    GREEN=''
    RED=''
    YELLOW=''
fi

# Output
#
# Every item is one aligned line:
#
#   ✓ Docker               29.9.1
#   ! Firewall             off until Tailscale is connected

banner() {
    printf "\n${BOLD}%s${RESET}\n${DIM}%s${RESET}\n" "$1" "$2"
}

section() {
    printf "\n${BOLD}%s${RESET}\n" "$1"
}

ok() {
    printf "  ${GREEN}✓${RESET} %-20s ${DIM}%s${RESET}\n" "$1" "${2:-}"
}

warn() {
    printf "  ${YELLOW}!${RESET} %-20s %s\n" "$1" "${2:-}"
}

fail() {
    printf "  ${RED}✗${RESET} %-20s %s\n" "$1" "${2:-}"
}

finish() {
    local duration

    if [ "$SECONDS" -ge 60 ]; then
        duration="$((SECONDS / 60))m $((SECONDS % 60))s"
    else
        duration="${SECONDS}s"
    fi

    printf "\n${GREEN}${BOLD}✓ %s${RESET} ${DIM}in %s${RESET}\n\n" "$1" "$duration"
}

# Commands

# Run a command quietly, showing a spinner on interactive terminals. On
# failure, its output is kept for show_log.
spin() {
    local label="$1"
    shift

    SPIN_LOG="$(mktemp)"
    "$@" >"$SPIN_LOG" 2>&1 &
    local pid=$!

    if [ -t 1 ]; then
        local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        local i=0

        while kill -0 "$pid" 2>/dev/null; do
            printf "\r  ${BLUE}%s${RESET} %s" "${frames:i++%${#frames}:1}" "$label"
            sleep 0.1
        done

        printf "\r\033[K"
    fi

    if wait "$pid"; then
        rm -f "$SPIN_LOG"
        return 0
    fi

    return 1
}

show_log() {
    sed 's/^/      /' "$SPIN_LOG"
    rm -f "$SPIN_LOG"
}

# Run a command with a spinner, then print one result line.
step() {
    local name="$1"
    local detail="$2"
    shift 2

    if spin "$name" "$@"; then
        ok "$name" "$detail"
    else
        fail "$name" "failed"
        show_log
        return 1
    fi
}

link_config() {
    ln -sf "$2" "$3"
    ok "$1" "linked"
}

# Tools

version_of() {
    case "$1" in
        bun) bun --version ;;
        docker) docker --version | sed -E 's/^Docker version ([^,]+).*/\1/' ;;
        mise) mise --version | cut -d' ' -f1 ;;
        opencode) opencode --version ;;
        tailscale) tailscale version | head -1 ;;
        uv) uv --version | cut -d' ' -f2 ;;
    esac 2>/dev/null
}

# Print a tool's version, installing it first if it's missing.
ensure_tool() {
    local name="$1"
    local bin="$2"
    shift 2

    if command -v "$bin" >/dev/null 2>&1; then
        ok "$name" "$(version_of "$bin")"
    elif spin "$name" "$@"; then
        ok "$name" "$(version_of "$bin") · new"
    else
        fail "$name" "install failed"
        show_log
        return 1
    fi
}

# Run a tool's self-update and print "old → new" or "up to date".
update_tool() {
    local name="$1"
    local bin="$2"
    local before
    local after
    shift 2

    before="$(version_of "$bin")"

    if spin "$name" "$@"; then
        after="$(version_of "$bin")"

        if [ "$before" = "$after" ]; then
            ok "$name" "$after · up to date"
        else
            ok "$name" "$before → $after"
        fi
    else
        fail "$name" "update failed"
        show_log
        return 1
    fi
}

# Ask for sudo once, then refresh the timestamp in the background so long runs
# never stop at a password prompt hidden behind a spinner.
keep_sudo_alive() {
    sudo -v

    while kill -0 "$$" 2>/dev/null; do
        sudo -n true 2>/dev/null
        sleep 60
    done >/dev/null 2>&1 &
    SUDO_KEEPALIVE_PID=$!

    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
}
