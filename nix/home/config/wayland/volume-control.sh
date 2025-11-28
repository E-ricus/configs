#!/usr/bin/env bash

# Get the action (raise, lower, or toggle-mute)
ACTION=$1

# Change volume
if [ "$ACTION" = "raise" ]; then
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
elif [ "$ACTION" = "lower" ]; then
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
elif [ "$ACTION" = "toggle-mute" ]; then
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
fi

# Get current volume and mute status
VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Parse the volume output (format: "Volume: 0.50" or "Volume: 0.50 [MUTED]")
if echo "$VOLUME" | grep -q "MUTED"; then
  MUTED=true
  PERCENT=$(echo "$VOLUME" | awk '{printf "%.0f", $2 * 100}')
  notify-send -u low -h string:x-canonical-private-synchronous:volume \
    -h int:value:$PERCENT "Volume" "Muted ($PERCENT%)"
else
  MUTED=false
  PERCENT=$(echo "$VOLUME" | awk '{printf "%.0f", $2 * 100}')
  notify-send -u low -h string:x-canonical-private-synchronous:volume \
    -h int:value:$PERCENT "Volume" "$PERCENT%"
fi
