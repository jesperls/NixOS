#!/usr/bin/env bash

for dep in grim slurp zbarimg wl-copy notify-send; do
    if ! command -v $dep &> /dev/null; then
        notify-send "QR Scan Error" "Missing dependency: $dep" -u critical
        exit 1
    fi
done

REGION=$(slurp)
if [ -z "$REGION" ]; then
    exit 0  # User cancelled
fi

RESULT=$(grim -g "$REGION" - | zbarimg -q --raw -)

if [ -n "$RESULT" ]; then
    echo -n "$RESULT" | wl-copy
    notify-send "QR/Barcode Result" "Content copied to clipboard" -i qr-code
else
    notify-send "QR/Barcode Result" "No code detected" -u low -i dialogue-error
fi
