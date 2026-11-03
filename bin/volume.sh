#!/usr/bin/env bash
# ==============================================================================
# Safe Volume Controller
# Supports PipeWire (via wpctl) and PulseAudio (via pactl) with a hard 100% limit.
# ==============================================================================

ACTION="$1"
STEP="${2:-5%}"

if command -v wpctl >/dev/null 2>&1; then
    case "$ACTION" in
        up)
            # Enforce 100% max limit (1.0)
            wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ "$STEP+"
            ;;
        down)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "$STEP-"
            ;;
        mute)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            ;;
        mic-mute)
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
            ;;
        *)
            echo "Usage: $0 {up|down|mute|mic-mute} [step]"
            exit 1
            ;;
    esac
elif command -v pactl >/dev/null 2>&1; then
    case "$ACTION" in
        up)
            # Read current volume, don't exceed 100%
            CURRENT=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]\+%' | head -1 | tr -d '%')
            if [ -n "$CURRENT" ] && [ "$CURRENT" -lt 100 ]; then
                pactl set-sink-volume @DEFAULT_SINK@ "+$STEP"
            fi
            ;;
        down)
            pactl set-sink-volume @DEFAULT_SINK@ "-$STEP"
            ;;
        mute)
            pactl set-sink-mute @DEFAULT_SINK@ toggle
            ;;
        mic-mute)
            pactl set-source-mute @DEFAULT_SOURCE@ toggle
            ;;
        *)
            echo "Usage: $0 {up|down|mute|mic-mute} [step]"
            exit 1
            ;;
    esac
fi
