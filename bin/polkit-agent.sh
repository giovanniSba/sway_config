#!/usr/bin/env bash
# Polkit Authentication Agent Launcher
# Searches for standard polkit agents across distributions and launches the first available one.

AGENTS=(
    # XFCE Polkit
    "/usr/libexec/xfce-polkit"
    "/usr/lib/xfce-polkit/xfce-polkit"
    "/usr/lib/x86_64-linux-gnu/libexec/xfce-polkit"
    # GNOME Polkit
    "/usr/libexec/polkit-gnome-authentication-agent-1"
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
    "/usr/lib/x86_64-linux-gnu/libexec/polkit-gnome-authentication-agent-1"
    # KDE Polkit
    "/usr/lib/polkit-kde-authentication-agent-1"
    "/usr/libexec/polkit-kde-authentication-agent-1"
    "/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1"
    # Hyprland Polkit
    "/usr/libexec/hyprpolkitagent"
    "/usr/lib/hyprpolkitagent"
    # LXPolkit
    "/usr/bin/lxpolkit"
    "/usr/libexec/lxpolkit"
    # Mate Polkit
    "/usr/libexec/polkit-mate-authentication-agent-1"
    "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"
)

# First check if an agent is already running
if pgrep -f "(polkit|hyprpolkitagent)" >/dev/null 2>&1; then
    exit 0
fi

for agent in "${AGENTS[@]}"; do
    if [ -x "$agent" ]; then
        exec "$agent"
    fi
done

echo "Warning: No polkit authentication agent found in standard locations." >&2
exit 1
