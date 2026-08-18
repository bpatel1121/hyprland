#!/usr/bin/env bash
# Next-event chip for the bar — "<event> in 45m". Renders ONLY when something
# is within the horizon; empty text otherwise, so the resting bar stays quiet.
# Emits waybar JSON (class carries the styling).
set -uo pipefail
. "$(dirname -- "${BASH_SOURCE[0]}")/calendar-lib.sh"

HORIZON=$(( 8 * 3600 ))   # show nothing further out than 8h

now=$(date +%s)
events=$(cal_upcoming)   # ONE khal invocation — reused for chip and tooltip
next=$(printf '%s\n' "$events" | awk -F'|' -v now="$now" '$1 >= now - 90 { print; exit }')

if [ -z "$next" ]; then
    printf '{"text":"","class":"idle"}\n'; exit 0
fi
IFS='|' read -r epoch _lead title <<< "$next"
delta=$(( epoch - now ))
if [ "$delta" -gt "$HORIZON" ]; then
    printf '{"text":"","class":"idle"}\n'; exit 0
fi

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

tooltip=$(printf '%s\n' "$events" | head -n 6 | while IFS='|' read -r e _l t; do
    printf '%s  %s\\n' "$(date -d "@$e" '+%a %H:%M')" "$t"
done)

printf '{"text":"󰃭 %s %s","class":"upcoming","tooltip":"%s"}\n' \
    "$short" "$when" "${tooltip%\\n}"
