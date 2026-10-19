#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

ensure_tool "Tailscale" tailscale bash -c 'curl -fsSL https://tailscale.com/install.sh | sh'
