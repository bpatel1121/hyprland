#!/usr/bin/env bash
# SUPER+SHIFT+A — the todo list. Opens todoman in the themed floating terminal
# (float rule lives in hyprland.lua, class "todos") with the list printed and a
# shell waiting underneath for `todo new` / `todo done N`.
set -uo pipefail

if command -v todo >/dev/null 2>&1; then
    # shellcheck disable=SC2016  # $SHELL must expand inside the spawned sh
    exec wezterm start --class todos -- sh -c '
        todo list
        printf "\n  todo new \"task\" --due \"fri 17:00\"   ·   todo done N   ·   todo list\n\n"
        exec "${SHELL:-bash}"'
fi
notify-send "Todos" "todoman is not installed (pacman -S todoman)" 2>/dev/null || true
