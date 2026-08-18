#!/usr/bin/env bash
# Open-task chip for the bar — count of todos due within 24h (todoman, which
# stores VTODOs in the same khal vdir the calendar uses). Hidden at zero so
# the resting bar stays quiet; goes red the moment anything is overdue.
# Emits waybar JSON (class carries the styling).
set -uo pipefail

command -v todo >/dev/null 2>&1 || { printf '{"text":"","class":"zero"}\n'; exit 0; }

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

if [ "$count" -eq 0 ]; then
    printf '{"text":"","class":"zero"}\n'; exit 0
fi

class="pending"
[ "$overdue" -gt 0 ] && class="overdue"

tooltip=$(printf '%s' "$lines" | head -n 8 | sed 's/"/\\"/g' \
    | awk '{ printf "%s\\n", $0 }')

printf '{"text":"󰄲 %s","class":"%s","tooltip":"%s"}\n' \
    "$count" "$class" "${tooltip%\\n}"
