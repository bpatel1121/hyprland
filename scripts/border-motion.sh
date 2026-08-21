#!/usr/bin/env bash
# Rotate the active-border gradient continuously.
#
# Hyprland's own `borderangle ... loop` animation is the right tool for this,
# but it's broken upstream (rotates once then freezes — the #9251/#9313
# regression lineage, still frozen on 0.56.2 even though `hyprctl animations`
# shows the loop registered). So this daemon does it manually: one step every
# TICK seconds, each advancing the gradient angle via `hyprctl eval`. The
# `border` animation leaf (speed 5.39 in hyprland.lua) eases every step, which
# is what turns discrete jumps into a smooth sweep.
#
# Managed by theme-apply.sh: killed and (re)started on every theme switch,
# only started when the active theme declares `border_motion` in theme.lua.
# Exits on its own when Hyprland goes away.
#
# TICK IS SLOW ON PURPOSE. Every config write cancels in-flight animations —
# at 10 ticks/sec it was clipping every workspace slide and window popin.
# One step every 2s, eased by the `border` animation, reads as a pulse and
# leaves animations long clear windows to finish.
#
# Usage: border-motion.sh <deciseconds-per-revolution>  (e.g. 240 = 24s/rev)
set -uo pipefail
motion="${1:?usage: border-motion.sh <deciseconds-per-revolution>}"

TICK=2   # seconds between steps
# steps per revolution = (motion/10)/TICK  ->  step angle = 7200/motion
step=$(( 7200 / motion )); [ "$step" -lt 1 ] && step=1; [ "$step" -gt 90 ] && step=90

angle=0
fails=0
while :; do
    # All the theme knowledge stays in Lua: re-dofile the active theme so the
    # gradient's colors are always current, override only the angle.
    if hyprctl eval "local t = dofile(os.getenv('HOME')..'/.config/hypr/themes/current/theme.lua'); local b = t.active_border; b.angle = $angle; hl.config({ general = { col = { active_border = b } } })" >/dev/null 2>&1; then
        fails=0
    else
        fails=$(( fails + 1 ))
        [ "$fails" -ge 10 ] && exit 0   # Hyprland is gone — die quietly
    fi
    angle=$(( (angle + step) % 360 ))
    sleep "$TICK"
done
