#!/usr/bin/env bash
set -euo pipefail

export PANGU_CLIPBOARD_BACKEND="$1" PANGU_CLIPBOARD_DB="$2" PANGU_CLIPBOARD_DATA="$3"
exec wl-paste --watch bash -c '
    cat >/dev/null
    if [ "${CLIPBOARD_STATE:-data}" = data ] && python3 "$PANGU_CLIPBOARD_BACKEND" "$PANGU_CLIPBOARD_DB" capture "$PANGU_CLIPBOARD_DATA"; then
        echo REFRESH_LIST
    fi
'
