#!/usr/bin/env bash
# wofi picker -> theme-switch.sh
set -uo pipefail
# shellcheck source=scripts/theme-lib.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/theme-lib.sh"
style="$CUR/wofi/style.css"
names=$(for d in "$HYPR/themes"/*/; do
    d=${d%/}; d=${d##*/}
    [ "$d" = current ] || printf '%s\n' "$d"
done)
if [ -f "$style" ]; then
    choice=$(printf '%s\n' "$names" | wofi --dmenu --style "$style" -p "Theme")
else
    choice=$(printf '%s\n' "$names" | wofi --dmenu -p "Theme")
fi
[ -n "${choice:-}" ] && "$HYPR/scripts/theme-switch.sh" "$choice"
