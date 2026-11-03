#!/usr/bin/env bash
# Initialize xdg-desktop-portal for wlroots / sway across distributions

pkill -f xdg-desktop-portal >/dev/null 2>&1

WLR_PORTAL=""
for p in /usr/libexec/xdg-desktop-portal-wlr /usr/lib/xdg-desktop-portal-wlr /usr/lib/x86_64-linux-gnu/xdg-desktop-portal-wlr; do
    if [ -x "$p" ]; then
        WLR_PORTAL="$p"
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

if [ -n "$WLR_PORTAL" ]; then
    "$WLR_PORTAL" &
    sleep 1
fi

if [ -n "$CORE_PORTAL" ]; then
    "$CORE_PORTAL" &
fi
