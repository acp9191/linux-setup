#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# From the repository set up by install-apt-repos.sh (same packages as get.docker.com).
ensure_tool "Docker" docker sudo apt-get install -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now --quiet docker

# Cap container logs (the default json-file driver grows without limit).
# Merged into any existing daemon.json, validated, and only restarts Docker
# when something changed. Applies to containers created after the change.
daemon_json=/etc/docker/daemon.json
merged="$(mktemp)"

if [ -s "$daemon_json" ]; then
    jq -s '.[0] * .[1]' "$daemon_json" "$REPO/docker/daemon.json" >"$merged"
else
    jq . "$REPO/docker/daemon.json" >"$merged"
fi

if [ -f "$daemon_json" ] && cmp -s "$merged" "$daemon_json"; then
    ok "Docker logs" "10 MB × 3 per container"
elif ! sudo dockerd --validate --config-file "$merged" >/dev/null 2>&1; then
    fail "Docker logs" "merged daemon.json is invalid; left unchanged"
    exit 1
else
    sudo install -D -m 644 "$merged" "$daemon_json"
    step "Docker logs" "10 MB × 3 per container · new" sudo systemctl restart docker
fi

rm -f "$merged"

getent group docker >/dev/null 2>&1 || sudo groupadd docker

if grep -qw docker <<<"$(id -nG "$USER")"; then
    ok "Docker group" "member"
else
    sudo usermod -aG docker "$USER"
    warn "Docker group" "added; log out and back in to use it"
fi
