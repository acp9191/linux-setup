#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# From the repository set up by install-apt-repos.sh (same packages as get.docker.com).
ensure_tool "Docker" docker sudo apt-get install -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now --quiet docker

getent group docker >/dev/null 2>&1 || sudo groupadd docker

if grep -qw docker <<<"$(id -nG "$USER")"; then
    ok "Docker group" "member"
else
    sudo usermod -aG docker "$USER"
    warn "Docker group" "added; log out and back in to use it"
fi
