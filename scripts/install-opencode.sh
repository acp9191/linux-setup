#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

ensure_tool "OpenCode" opencode bash -c 'curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path'
