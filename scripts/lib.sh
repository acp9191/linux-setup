#!/usr/bin/env bash

# Tool install locations (mirrors home/.zshrc), so freshly installed tools are
# usable before a new shell has been opened.
export PATH="$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.local/bin:$PATH"

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

info() {
    printf "  ${BLUE}→${RESET} %s\n" "$1"
}

success() {
    printf "  ${GREEN}✓${RESET} %s\n" "$1"
}

warning() {
    printf "  ${YELLOW}!${RESET} %s\n" "$1"
}

error() {
    printf "  ${RED}✗${RESET} %s\n" "$1" >&2
}

header() {
    printf "\n${BOLD}${BLUE}==> %s${RESET}\n\n" "$1"
}

section_done() {
    printf "${DIM}└────────────────────────────────────────${RESET}\n"
}

spinner() {
    local pid=$1
    local message="$2"
    local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        local frame="${frames:i++%${#frames}:1}"
        printf "\r  ${BLUE}${frame}${RESET} %s" "$message"
        sleep 0.1
    done

    printf "\r\033[K"
}

run_with_spinner() {
    local message="$1"
    shift

    "$@" >/tmp/linux-setup-output 2>&1 &
    local pid=$!

    spinner "$pid" "$message"

    if wait "$pid"; then
        success "$message"
        rm -f /tmp/linux-setup-output
    else
        error "$message"
        cat /tmp/linux-setup-output >&2
        rm -f /tmp/linux-setup-output
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
