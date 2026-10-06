#!/usr/bin/env bash
# Shared theme plumbing — sourced by theme-apply.sh, theme-menu.sh and
# theme-switch.sh. Not executable, not run directly (same convention as
# calendar-lib.sh and waybar-lib.sh).

# Repo root from THIS FILE's own location rather than $HOME. In a sourced file
# ${BASH_SOURCE[0]} is the library's own path, so this resolves correctly no
# matter which script sources it or from what directory it was invoked. The
# three consumers used to hardcode "$HOME/.config/hypr", which is the same path
# today only because the repo root IS ~/.config/hypr — sddm-apply.sh has always
# derived its root this way because under sudo $HOME is /root.
HYPR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CUR="$HYPR/themes/current"

# theme_key <key> [value-regex] — pull one scalar out of the ACTIVE theme.lua.
#
# sed rather than a Lua interpreter, deliberately: theme switching keeps zero
# runtime dependencies this way. The cost is that the key has to sit at the
# start of its own line, which every theme.lua does — a key that migrates onto
# a shared line silently returns empty, so CI round-trips these against real
# Lua values to keep the constraint honest.
#
# The optional second argument is the value pattern, and it carries each key's
# VALIDATION, not just its extraction: polarity accepts only light|dark, and
# border_motion only digits — that one matters, because the result is fed to
# `$(( 7200 / motion ))` in border-motion.sh. Defaults to a double-quoted
# string, which is what `cursor` is.
theme_key() {
    local pattern="${2:-\"\\([^\"]*\\)\"}"
    sed -n "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*$pattern.*/\\1/p" \
        "$CUR/theme.lua" 2>/dev/null | head -n1
}

# theme_wallpaper <dir> — first wallpaper.* in <dir>, empty when there is none.
#
# A glob loop rather than `ls "$dir"/wallpaper.* | head -n1` (SC2012): ls's
# output is not safely parseable, and the [ -e ] test is what absorbs bash's
# leave-the-glob-literal behavior when nothing matches, without having to touch
# global nullglob state.
theme_wallpaper() {
    local w
    for w in "$1"/wallpaper.*; do
        [ -e "$w" ] && { printf '%s\n' "$w"; return 0; }
    done
    return 0
}
