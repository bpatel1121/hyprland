#!/usr/bin/env bash
# Shared waybar-module plumbing — sourced by waybar-agenda.sh, waybar-todos.sh
# and waybar-updates.sh. Not executable, not run directly (same convention as
# calendar-lib.sh).
#
# Every module here emits waybar JSON rather than plain text, because the
# `class` field is what lets a chip stay on screen and gray out instead of
# vanishing — color keeps meaning "act on me". That JSON carries strings the
# user wrote: event titles, todo summaries, package names. Any of them may
# contain a double quote or a backslash, and an unescaped one produces
# malformed JSON, which waybar handles by silently dropping the module. That
# reads exactly like "the chip stopped working" and is impossible to guess at.
#
# So escaping is not optional and must not be reinvented per script — it was,
# and the three copies disagreed: updates escaped both characters, todos only
# the quote, and agenda neither.

# Escape a string for use inside a JSON string literal.
# Backslash FIRST, then quote — reverse the order and the backslashes emitted
# by the quote rule get escaped a second time.
# Real newlines fold to the two-character \n escape, which is what waybar's
# tooltips render as line breaks.
wb_escape() {
    printf '%s' "${1-}" \
        | sed 's/\\/\\\\/g; s/"/\\"/g' \
        | awk 'BEGIN{ORS=""} {print (NR>1 ? "\\n" : "") $0}'
}

# wb_emit <text> [class] [tooltip]
# One line of waybar JSON. The tooltip key is omitted entirely when empty, so
# waybar falls back to no tooltip rather than showing an empty box.
wb_emit() {
    local text class tooltip
    text=$(wb_escape "${1-}")
    class=$(wb_escape "${2-}")
    tooltip=$(wb_escape "${3-}")
    if [ -n "$tooltip" ]; then
        printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
    else
        printf '{"text":"%s","class":"%s"}\n' "$text" "$class"
    fi
}
