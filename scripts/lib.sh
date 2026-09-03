#!/usr/bin/env bash

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
