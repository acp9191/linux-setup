#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

ensure_tool "Docker" docker bash -c 'curl -fsSL https://get.docker.com | sh'

getent group docker >/dev/null 2>&1 || sudo groupadd docker

if grep -qw docker <<<"$(id -nG "$USER")"; then
    ok "Docker group" "member"
else
    sudo usermod -aG docker "$USER"
    warn "Docker group" "added; log out and back in to use it"
fi
