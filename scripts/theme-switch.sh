#!/usr/bin/env bash
# Switch the active theme: theme-switch.sh <name> — any directory in themes/
set -uo pipefail
# shellcheck source=scripts/theme-lib.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/theme-lib.sh"
name="${1:?usage: theme-switch.sh <name>}"
[ -d "$HYPR/themes/$name" ] || { echo "no such theme: $name"; exit 1; }

# RELATIVE symlink, deliberately. An absolute target would bake this machine's
# username and clone path into a tracked path and break on any box where
# either differs. "cyberpunk" resolves relative to themes/ and is portable.
ln -sfn "$name" "$HYPR/themes/current"                # 1. repoint symlink
hyprctl reload >/dev/null 2>&1 || true                # 2. re-run hyprland.lua (dofile picks up theme)
"$HYPR/scripts/theme-apply.sh"                        # 3. sync wallpaper/waybar/...
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Theme" "Switched to $name" 2>/dev/null || true
fi
