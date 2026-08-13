#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Use: $0 /path/to/wallpaper [shader_path] [monitor_target]"
	exit 1
fi

WALLPAPER="$1"
SHADER="$2"
MONITOR="${3:-ALL}"

if [ "$MONITOR" = "ALL" ]; then
    pkill -x "mpvpaper" 2>/dev/null
else
    pgrep -x mpvpaper | while read -r pid; do
        if ps -p "$pid" -o args= | grep -q "$MONITOR"; then
            kill "$pid" 2>/dev/null
        fi
    done
fi
SOCKET="${XDG_RUNTIME_DIR:-/tmp}/pangu/mpv-${MONITOR}.sock"
mkdir -p "$(dirname "$SOCKET")"

MPV_OPTS="no-audio loop hwdec=auto scale=bilinear interpolation=no video-sync=display-resample panscan=1.0 video-scale-x=1.0 video-scale-y=1.0 load-scripts=no input-ipc-server=$SOCKET"

if [ -n "$SHADER" ] && [ -f "$SHADER" ]; then
	MPV_OPTS="$MPV_OPTS glsl-shaders=$SHADER"
fi

nohup mpvpaper -o "$MPV_OPTS" "$MONITOR" "$WALLPAPER" >/dev/null 2>&1 &
