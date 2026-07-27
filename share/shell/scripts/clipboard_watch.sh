#!/usr/bin/env bash

CHECK_SCRIPT="$1"
DB_PATH="$2"
INSERT_SCRIPT="$3"
DATA_DIR="$4"

check_clipboard() {
	cat >/dev/null

	if "$CHECK_SCRIPT" "$DB_PATH" "$INSERT_SCRIPT" "$DATA_DIR"; then
		echo "REFRESH_LIST"
	else
		echo "Check failed with code $?" >&2
	fi
}

export -f check_clipboard
export CHECK_SCRIPT DB_PATH INSERT_SCRIPT DATA_DIR

exec wl-paste --watch bash -c 'check_clipboard'
