#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# From the repository set up by install-apt-repos.sh.
ensure_tool "Tailscale" tailscale apt_get install -y tailscale
sudo systemctl enable --now --quiet tailscaled
