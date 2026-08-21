#!/usr/bin/env bash
# Open-task chip for the bar — count of todos due within 24h (todoman, which
# stores VTODOs in the same khal vdir the calendar uses). Hidden at zero so
# the resting bar stays quiet; goes red the moment anything is overdue.
# Emits waybar JSON (class carries the styling) via waybar-lib.sh.
set -uo pipefail
. "$(dirname -- "${BASH_SOURCE[0]}")/waybar-lib.sh"

command -v todo >/dev/null 2>&1 || { wb_emit "" zero; exit 0; }

now=$(date +%s)
count=0
overdue=0
lines=$(todo list --due 24 2>/dev/null | grep -E '^\[ \]' || true)
while IFS= read -r line; do
    [ -n "$line" ] || continue
    count=$(( count + 1 ))
    # due stamp per todoman config: "YYYY-MM-DD HH:MM"
    if [[ "$line" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2})\ ([0-9]{2}:[0-9]{2}) ]]; then
        due=$(date -d "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}" +%s 2>/dev/null) || continue
        [ "$due" -lt "$now" ] && overdue=$(( overdue + 1 ))
    fi
done <<< "$lines"

[ "$count" -gt 0 ] || { wb_emit "" zero; exit 0; }

class="pending"
[ "$overdue" -gt 0 ] && class="overdue"

# Raw lines — wb_emit escapes them and folds the newlines. Task summaries are
# user-authored, so quotes and backslashes are expected, not exceptional.
wb_emit "󰄲 $count" "$class" "$(printf '%s' "$lines" | head -n 8)"
