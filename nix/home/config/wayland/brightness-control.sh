#!/usr/bin/env bash

# Get the action (raise or lower)
ACTION=$1

# Get list of devices
DEVICES=$(brightnessctl --list | grep -oP "Device '\\K[^']+")
DEVICE_COUNT=$(echo "$DEVICES" | wc -l)

# Select device
if [ "$DEVICE_COUNT" -eq 1 ]; then
  DEVICE=""  # Use default device
else
  # Multiple devices, find the one with "amd" in the name
  DEVICE=$(echo "$DEVICES" | grep -i amd | head -n1)
  if [ -z "$DEVICE" ]; then
    # Fallback to first device if no AMD found
    DEVICE=$(echo "$DEVICES" | head -n1)
  fi
  DEVICE="-d $DEVICE"
fi

# Change brightness
if [ "$ACTION" = "raise" ]; then
  brightnessctl $DEVICE set +5%
elif [ "$ACTION" = "lower" ]; then
  brightnessctl $DEVICE set 5%-
fi

# Get current brightness percentage
BRIGHTNESS=$(brightnessctl $DEVICE get)
MAX=$(brightnessctl $DEVICE max)
PERCENT=$((BRIGHTNESS * 100 / MAX))

# Send notification
notify-send -u low -h string:x-canonical-private-synchronous:brightness \
  -h int:value:$PERCENT "Brightness" "$PERCENT%"
