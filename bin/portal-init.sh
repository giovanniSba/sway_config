#!/usr/bin/env bash
# ==============================================================================
# Initialize xdg-desktop-portal for wlroots / sway across distributions
# ==============================================================================

# Ensure portal config directories exist
mkdir -p "$HOME/.config/xdg-desktop-portal"
mkdir -p "$HOME/.config/xdg-desktop-portal-wlr"

# Export Wayland and desktop environment to DBus
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM="wayland;xcb"
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export NO_AT_BRIDGE=1
export XDG_CURRENT_DESKTOP=sway

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --all >/dev/null 2>&1
fi

# Link portal configurations from Sway dotfiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTALS_SRC="$(cd "$SCRIPT_DIR/.." && pwd)/portals"

if [ -f "$PORTALS_SRC/sway-portals.conf" ]; then
    ln -sf "$PORTALS_SRC/sway-portals.conf" "$HOME/.config/xdg-desktop-portal/sway-portals.conf"
    ln -sf "$PORTALS_SRC/sway-portals.conf" "$HOME/.config/xdg-desktop-portal/portals.conf"
fi

if [ -f "$PORTALS_SRC/wlr-config" ]; then
    ln -sf "$PORTALS_SRC/wlr-config" "$HOME/.config/xdg-desktop-portal-wlr/config"
    ln -sf "$PORTALS_SRC/wlr-config" "$HOME/.config/xdg-desktop-portal-wlr/sway"
fi

# Stop previous portal instances
pkill -f xdg-desktop-portal >/dev/null 2>&1
sleep 0.5

# Find portal backends
WLR_PORTAL=""
for p in /usr/libexec/xdg-desktop-portal-wlr /usr/lib/xdg-desktop-portal-wlr /usr/lib/x86_64-linux-gnu/xdg-desktop-portal-wlr; do
    if [ -x "$p" ]; then
        WLR_PORTAL="$p"
        break
    fi
done

GTK_PORTAL=""
for p in /usr/libexec/xdg-desktop-portal-gtk /usr/lib/xdg-desktop-portal-gtk /usr/lib/x86_64-linux-gnu/xdg-desktop-portal-gtk; do
    if [ -x "$p" ]; then
        GTK_PORTAL="$p"
        break
    fi
done

CORE_PORTAL=""
for p in /usr/libexec/xdg-desktop-portal /usr/lib/xdg-desktop-portal /usr/lib/x86_64-linux-gnu/xdg-desktop-portal; do
    if [ -x "$p" ]; then
        CORE_PORTAL="$p"
        break
    fi
done

# Start backends first
if [ -n "$WLR_PORTAL" ]; then
    "$WLR_PORTAL" &
fi

if [ -n "$GTK_PORTAL" ]; then
    "$GTK_PORTAL" &
fi

sleep 1

# Start core portal frontend
if [ -n "$CORE_PORTAL" ]; then
    "$CORE_PORTAL" &
fi
