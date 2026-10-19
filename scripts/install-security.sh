#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

# Tailscale addresses: 100.64.0.0/10 and fd7a:115c:a1e0::/48.
is_tailscale_ip() {
    local ip="$1"

    if [[ "$ip" =~ ^100\.([0-9]+)\. ]]; then
        local octet="${BASH_REMATCH[1]}"
        [ "$octet" -ge 64 ] && [ "$octet" -le 127 ]
    else
        [[ "$ip" == fd7a:115c:a1e0:* ]]
    fi
}

# SSH: disable password logins, but only once a key is in place.
if [ -s "$HOME/.ssh/authorized_keys" ]; then
    sudo install -m 644 -o root -g root \
        "$REPO/ssh/10-linux-setup.conf" /etc/ssh/sshd_config.d/10-linux-setup.conf
    sudo sshd -t
    sudo systemctl try-reload-or-restart ssh
    ok "SSH" "key-only logins"
else
    warn "SSH" "password logins allowed until ~/.ssh/authorized_keys has a key"
fi

# Firewall: allow SSH only over Tailscale. Skipped until Tailscale is connected,
# and when this session arrived over the public internet, so it can't lock you out.
ssh_client="${SSH_CONNECTION:-}"
ssh_client="${ssh_client%% *}"

if ! tailscale status >/dev/null 2>&1; then
    warn "Firewall" "off until Tailscale is connected (sudo tailscale up, then ./install.sh)"
elif [ -n "$ssh_client" ] && ! is_tailscale_ip "$ssh_client"; then
    warn "Firewall" "off: this session is over the public internet (reconnect over Tailscale, then ./install.sh)"
else
    sudo ufw default deny incoming >/dev/null
    sudo ufw default allow outgoing >/dev/null
    sudo ufw allow in on tailscale0 >/dev/null
    sudo ufw allow 41641/udp comment 'Tailscale direct connections' >/dev/null

    # Remove any public SSH rules from an earlier setup.
    for rule in OpenSSH 22/tcp 22; do
        sudo ufw delete allow "$rule" >/dev/null 2>&1 || true
    done

    sudo ufw --force enable >/dev/null
    ok "Firewall" "SSH only over Tailscale"
fi
