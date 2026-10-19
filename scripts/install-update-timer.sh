#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/scripts/lib.sh"

unit_dir="$HOME/.config/systemd/user"
mkdir -p "$unit_dir"

sed "s|@REPO@|$REPO|g" "$REPO/systemd/linux-setup-update.service" \
    >"$unit_dir/linux-setup-update.service"
cp "$REPO/systemd/linux-setup-update.timer" "$unit_dir/linux-setup-update.timer"

# Lingering keeps the user's systemd running while logged out, so the timer
# fires on schedule rather than only during an SSH session.
sudo loginctl enable-linger "$USER"

# Without a login session (e.g. CI), point systemctl at the lingering manager.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

for _ in $(seq 20); do
    [ -S "$XDG_RUNTIME_DIR/bus" ] && break
    sleep 0.5
done

if ! spin "Tool updates" bash -c \
    'systemctl --user daemon-reload && systemctl --user enable --now linux-setup-update.timer'; then
    fail "Tool updates" "could not enable timer"
    show_log
    exit 1
fi

ok "Tool updates" "weekly · journalctl --user -u linux-setup-update"
