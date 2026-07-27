#!/usr/bin/env bash

if command -v brightnessctl &> /dev/null; then
    DEVICES=$(brightnessctl -l 2>/dev/null | grep "backlight" | awk -F"'" '{print $2}')
    for device in $DEVICES; do
        CURRENT=$(brightnessctl -d "$device" g 2>/dev/null)
        MAX=$(brightnessctl -d "$device" m 2>/dev/null)
        if [ -n "$CURRENT" ] && [ -n "$MAX" ] && [ "$MAX" -gt 0 ]; then
            PERCENT=$(( CURRENT * 100 / MAX ))
            MONITOR_NAME=$(printf "j/monitors" | socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock" 2>/dev/null | jq -r '.[] | select(.name | contains("eDP")) | .name' | head -1)
            if [ -z "$MONITOR_NAME" ]; then
                MONITOR_NAME="eDP-1"
            fi
            echo "${MONITOR_NAME}:${PERCENT}"
        fi
    done
fi

if command -v ddcutil &> /dev/null; then
    CURRENT_BUS=""
    CURRENT_CONNECTOR=""
    
    while IFS= read -r line; do
        if [[ "$line" =~ I2C\ bus:.*-([0-9]+)$ ]]; then
            CURRENT_BUS="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ DRM\ connector:.*card[0-9]+-(.+)$ ]]; then
            CURRENT_CONNECTOR="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^$ ]] && [ -n "$CURRENT_BUS" ] && [ -n "$CURRENT_CONNECTOR" ]; then
            BRIGHTNESS=$(ddcutil -b "$CURRENT_BUS" getvcp 10 --brief 2>/dev/null | awk '{print $4}')
            if [ -n "$BRIGHTNESS" ]; then
                echo "${CURRENT_CONNECTOR}:${BRIGHTNESS}"
            fi
            CURRENT_BUS=""
            CURRENT_CONNECTOR=""
        fi
    done < <(ddcutil detect --brief 2>/dev/null; echo "")
fi
