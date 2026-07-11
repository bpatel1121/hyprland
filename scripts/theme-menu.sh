#!/usr/bin/env bash
# wofi picker -> theme-switch.sh
set -uo pipefail
HYPR="$HOME/.config/hypr"
style="$HYPR/themes/current/wofi/style.css"
names=$(ls "$HYPR/themes" 2>/dev/null | grep -vx current)
if [ -f "$style" ]; then
    choice=$(printf '%s\n' "$names" | wofi --dmenu --style "$style" -p "Theme")
else
    choice=$(printf '%s\n' "$names" | wofi --dmenu -p "Theme")
fi
[ -n "${choice:-}" ] && "$HYPR/scripts/theme-switch.sh" "$choice"
