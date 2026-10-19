#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

ensure_tool "uv" uv bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
