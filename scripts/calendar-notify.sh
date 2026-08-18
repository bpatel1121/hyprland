#!/usr/bin/env bash
# Calendar alert daemon — fires themed notifications through swaync.
#
# Two alerts per event: one at T-minus-lead ("in N minutes") and one at T
# ("now"). A fired-keys file dedupes across restarts, pruned as it goes.
# Single instance; started from hyprland.lua's autostart; dies with the
# session (notify-send failures accumulate and exit).
set -uo pipefail
. "$(dirname -- "${BASH_SOURCE[0]}")/calendar-lib.sh"

FIRED="$CAL_DIR/.fired"
cal_ensure_file
touch "$FIRED"

# single instance
if pgrep -f "hypr/scripts/calendar-notify.sh" | grep -qv "^$$\$"; then
    for p in $(pgrep -f "hypr/scripts/calendar-notify.sh"); do
        [ "$p" != "$$" ] && exit 0
    done
fi

fails=0
while :; do
    now=$(date +%s)
    while IFS='|' read -r epoch lead title; do
        [ -n "${epoch:-}" ] || continue
        t_lead=$(( epoch - lead * 60 ))
        # lead alert window: the minute containing t_lead
        if [ "$now" -ge "$t_lead" ] && [ "$now" -lt $(( t_lead + 60 )) ]; then
            key="$epoch:$lead:lead"
            if ! grep -qxF "$key" "$FIRED"; then
                notify-send -t 15000 "󰃭  $title" "in $lead minutes" 2>/dev/null \
                    && echo "$key" >> "$FIRED" || fails=$(( fails + 1 ))
            fi
        fi
        # at-event alert window
        if [ "$now" -ge "$epoch" ] && [ "$now" -lt $(( epoch + 60 )) ]; then
            key="$epoch:now"
            if ! grep -qxF "$key" "$FIRED"; then
                notify-send -t 20000 "󰃭  $title" "now" 2>/dev/null \
                    && echo "$key" >> "$FIRED" || fails=$(( fails + 1 ))
            fi
        fi
    done < <(cal_upcoming)

    # prune fired keys older than 2 days; die if the session is gone
    awk -F: -v cutoff=$(( now - 172800 )) '$1 >= cutoff' "$FIRED" > "$FIRED.tmp" \
        && mv "$FIRED.tmp" "$FIRED"
    [ "$fails" -ge 10 ] && exit 0

    sleep $(( 60 - $(date +%s) % 60 ))   # stay minute-aligned
done
