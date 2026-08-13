#!/usr/bin/env bash

LOCKFILE="${XDG_RUNTIME_DIR:-/tmp}/pangu/sleep_monitor.lock"
if [ -e "$LOCKFILE" ]; then
	PID=$(cat "$LOCKFILE")
	if kill -0 "$PID" 2>/dev/null; then
		exit 0
	fi
fi
mkdir -p "$(dirname "$LOCKFILE")"
echo $$ >"$LOCKFILE"

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/pangu/config/system.json"

get_cmd() {
	local type=$1
	if [ -f "$CONFIG_FILE" ]; then
		if [ "$type" == "before" ]; then
			jq -r '.idle.general.before_sleep_cmd // "loginctl lock-session"' "$CONFIG_FILE"
		else
			jq -r '.idle.general.after_sleep_cmd // "pangu screen on"' "$CONFIG_FILE"
		fi
	else
		if [ "$type" == "before" ]; then
			echo "loginctl lock-session"
		else
			echo "pangu screen on"
		fi
	fi
}

dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" |
	grep --line-buffered "boolean" |
	while read -r line; do
		if echo "$line" | grep -q "true"; then
			echo "SUSPEND"
			CMD=$(get_cmd "before")
			if [ -n "$CMD" ]; then
				sh -c "$CMD" &
			fi
		elif echo "$line" | grep -q "false"; then
			echo "WAKE"
			CMD=$(get_cmd "after")
			if [ -n "$CMD" ]; then
				sh -c "$CMD" &
			fi
		fi
	done
