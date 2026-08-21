#!/usr/bin/env bash
# Next-event chip for the bar — "<event> in 45m". Renders ONLY when something
# is within the horizon; empty text otherwise, so the resting bar stays quiet.
# Emits waybar JSON (class carries the styling) via waybar-lib.sh, which does
# the escaping — event titles are user-authored and routinely contain quotes.
set -uo pipefail
_lib="$(dirname -- "${BASH_SOURCE[0]}")"
. "$_lib/calendar-lib.sh"
. "$_lib/waybar-lib.sh"

HORIZON=$(( 8 * 3600 ))   # show nothing further out than 8h

now=$(date +%s)
events=$(cal_upcoming)   # ONE khal invocation — reused for chip and tooltip
next=$(printf '%s\n' "$events" | awk -F'|' -v now="$now" '$1 >= now - 90 { print; exit }')

[ -n "$next" ] || { wb_emit "" idle; exit 0; }

IFS='|' read -r epoch _lead title <<< "$next"
delta=$(( epoch - now ))
[ "$delta" -le "$HORIZON" ] || { wb_emit "" idle; exit 0; }

# short title for the bar; full agenda in the tooltip
short=$title
[ ${#short} -gt 20 ] && short="${short:0:19}…"
if [ "$delta" -le 0 ]; then
    when="now"
elif [ "$delta" -lt 5400 ]; then
    when="in $(( (delta + 59) / 60 ))m"
else
    when="in $(( (delta + 1799) / 3600 ))h"
fi

# Real newlines here; wb_emit folds them into the \n escape waybar renders as
# line breaks. Command substitution eats the trailing one.
tooltip=$(printf '%s\n' "$events" | head -n 6 | while IFS='|' read -r e _l t; do
    printf '%s  %s\n' "$(date -d "@$e" '+%a %H:%M')" "$t"
done)

wb_emit "󰃭 $short $when" upcoming "$tooltip"
