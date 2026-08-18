#!/usr/bin/env bash
# SUPER+A — the calendar. Opens ikhal (khal's interactive month view) floating
# in the themed terminal: gcal's shape, this desktop's clothes. The float rule
# lives in hyprland.lua (class "ikhal").
set -uo pipefail
. "$(dirname -- "${BASH_SOURCE[0]}")/calendar-lib.sh"
cal_ensure_file

if command -v khal >/dev/null 2>&1; then
    exec wezterm start --class ikhal -- ikhal
fi
notify-send "Calendar" "khal is not installed (pacman -S khal)" 2>/dev/null || true
