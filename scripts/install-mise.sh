#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

if command -v mise >/dev/null 2>&1; then
    # Not fatal: an offline machine can still use the installed version.
    update_tool "mise" mise mise self-update -y || true
else
    ensure_tool "mise" mise bash -c 'curl -fsSL https://mise.run | sh'
fi
