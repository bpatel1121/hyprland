#!/usr/bin/env bash
# Switch the active theme: theme-switch.sh <cyberpunk|zen|hacker|professional>
set -uo pipefail
HYPR="$HOME/.config/hypr"
name="${1:?usage: theme-switch.sh <name>}"
[ -d "$HYPR/themes/$name" ] || { echo "no such theme: $name"; exit 1; }

ln -sfn "$HYPR/themes/$name" "$HYPR/themes/current"   # 1. repoint symlink
hyprctl reload >/dev/null 2>&1 || true                # 2. re-run hyprland.lua (dofile picks up theme)
"$HYPR/scripts/theme-apply.sh"                        # 3. sync wallpaper/waybar/mako
command -v notify-send >/dev/null 2>&1 && notify-send "Theme" "Switched to $name" || true
