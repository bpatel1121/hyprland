#!/usr/bin/env bash
# Shared calendar plumbing — sourced by calendar-notify.sh, calendar-menu.sh,
# and waybar-agenda.sh.
#
# Storage is khal: standard iCalendar (.ics) files in a vdir at
# ~/.local/share/khal/calendars/ — portable to every calendar app on earth,
# and syncable to Google/CalDAV later via vdirsyncer. This library is the one
# place that talks to khal; the alert daemon, agenda, and bar chip consume
# its output and don't care where events live.
#
#   add events:   khal new tomorrow 14:00 "Advisor meeting"
#   browse/edit:  ikhal   (SUPER+A)
#
# Lead times: DEFAULT_LEAD minutes before every event, overridable per event
# with a [Nm] tag in the title — `khal new mon 10:00 "C191A [15m]"` warns 15
# minutes out. The tag is stripped for display and travels harmlessly through
# any future sync.

CAL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/hypr-calendar"   # daemon state
DEFAULT_LEAD=10

cal_ensure_file() {   # kept for the daemon's state dir
    mkdir -p "$CAL_DIR"
    mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/khal/calendars/personal"
}

# Echo upcoming events, sorted:  epoch|lead|title
# All-day events surface at 08:00 with "(all day)" appended.
cal_upcoming() {
    command -v khal >/dev/null 2>&1 || return 0
    local when time title lead epoch
    khal list --format "{start-date} {start-time}|{title}" --day-format "" \
        now 14d 2>/dev/null | while IFS='|' read -r when title; do
        [ -n "$when" ] && [ -n "$title" ] || continue
        time=$(echo "$when" | awk '{print $2}')
        if [ -z "$time" ]; then
            when="$(echo "$when" | awk '{print $1}') 08:00"
            title="$title (all day)"
        fi
        epoch=$(date -d "$when" +%s 2>/dev/null) || continue
        # per-event lead override: trailing [Nm] tag in the title
        lead=$DEFAULT_LEAD
        if [[ "$title" =~ \[([0-9]+)m?\][[:space:]]*$ ]]; then
            lead="${BASH_REMATCH[1]}"
            title=$(echo "${title%\[*}" | sed 's/[[:space:]]*$//')
        fi
        printf '%s|%s|%s\n' "$epoch" "$lead" "$title"
    done | sort -n
}
