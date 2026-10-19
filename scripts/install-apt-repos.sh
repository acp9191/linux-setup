#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# Third-party apt repositories, rewritten on every run so they always match the
# running Ubuntu release. do-release-upgrade disables these and leaves them
# pointing at the old release; running ./install.sh (or ./update.sh) afterwards
# restores them. Runs before `apt update`, so a stale definition can't break it.

source /etc/os-release
codename="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
arch="$(dpkg --print-architecture)"
sources_dir=/etc/apt/sources.list.d

if ! command -v curl >/dev/null 2>&1; then
    step "Package lists" "updated" apt_get update
    step "curl" "installed · new" apt_get install -y curl ca-certificates
fi

setup_repo() {
    local name="$1"
    local base="$2"
    local uri="$3"
    local component="$4"
    local key_url="$5"
    local keyring="/etc/apt/keyrings/$6"
    local target="$sources_dir/$base.sources"
    local code
    local tmp
    local detail="$codename"

    code="$(curl -sSL -o /dev/null -w '%{http_code}' "$uri/dists/$codename/Release" || true)"

    case "$code" in
        200) ;;
        404)
            warn "$name repo" "no packages for $codename yet; left unchanged"
            return 0
            ;;
        *)
            fail "$name repo" "could not reach $uri"
            return 1
            ;;
    esac

    tmp="$(mktemp)"
    curl -fsSL "$key_url" -o "$tmp"
    sudo install -D -m 644 "$tmp" "$keyring"

    cat >"$tmp" <<EOF
# Managed by linux-setup (scripts/install-apt-repos.sh); rewritten on install.
Types: deb
URIs: $uri
Suites: $codename
Components: $component
Architectures: $arch
Signed-By: $keyring
EOF

    if [ -f "$target" ] && ! cmp -s "$tmp" "$target"; then
        detail="$codename · repaired"
    elif [ ! -f "$target" ]; then
        detail="$codename · new"
    fi

    sudo install -m 644 "$tmp" "$target"
    rm -f "$tmp"

    # Drop every other definition of this repository: installer-written .list
    # files, upgrade leftovers (.distUpgrade, .save), or manual copies. A
    # duplicate with a different Signed-By makes `apt update` fail outright.
    local other
    while IFS= read -r other; do
        if [ "$other" != "$target" ]; then
            sudo rm -f "$other"
            detail="$codename · repaired"
        fi
    done < <(
        find "$sources_dir" -maxdepth 1 -type f -name "$base.*" 2>/dev/null
        grep -rlF "$uri" "$sources_dir" 2>/dev/null || true
    )

    ok "$name repo" "$detail"
}

setup_repo "Docker" docker \
    https://download.docker.com/linux/ubuntu stable \
    https://download.docker.com/linux/ubuntu/gpg docker.asc

setup_repo "Tailscale" tailscale \
    https://pkgs.tailscale.com/stable/ubuntu main \
    "https://pkgs.tailscale.com/stable/ubuntu/$codename.noarmor.gpg" tailscale.gpg
