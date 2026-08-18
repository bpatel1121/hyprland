#!/usr/bin/env bash
# Streaming soundwave for waybar — fused onto the mpris chip.
#
# Runs cava in raw-ascii mode and translates each frame into block glyphs,
# emitted as JSON lines for a streaming custom module. Used instead of
# waybar's built-in cava module because that one needs a compile-time flag
# Arch's waybar may not carry; this works on any build, needing only the
# `cava` binary (already provisioned).
#
# Performance rules (each of these was a real bar-lag bug):
#   - 12fps, not 30: every frame is a full waybar redraw + Hyprland re-blur.
#   - Silence NEVER collapses the module: the island reflowing on every
#     quiet passage made the whole center row jump. Instead the wave rests
#     at constant width, dimmed by the `quiet` class (styled per theme).
#   - Identical consecutive frames are not re-emitted — silence costs one
#     redraw, not twelve per second.
set -uo pipefail

bars=8
cfg=$(mktemp /tmp/waybar-cava.XXXXXX)
trap 'rm -f "$cfg"' EXIT
cat > "$cfg" <<CFG
[general]
bars = $bars
framerate = 12
[input]
method = pulse
source = auto
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
CFG

glyphs=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
rest=""
for _ in $(seq "$bars"); do rest+="▁"; done

last=""
silent_run=0
frame=0
status="Stopped"
cava -p "$cfg" 2>/dev/null | while IFS=';' read -ra vals; do
    # The wave exists only while a song is PLAYING: it collapses together
    # with the mpris chip when paused/stopped. Safe now that music lives in
    # the left island — collapse no longer reflows the centered clock. The
    # status check is cached (one playerctl per second, not per frame).
    if [ $(( frame % 12 )) -eq 0 ]; then
        status=$(playerctl status 2>/dev/null || echo Stopped)
    fi
    frame=$(( frame + 1 ))
    if [ "$status" != "Playing" ]; then
        msg='{"text":""}'
        if [ "$msg" != "$last" ]; then printf '%s\n' "$msg"; last=$msg; fi
        continue
    fi
    out=""
    silent=1
    for v in "${vals[@]}"; do
        [ -z "$v" ] && continue
        [ "$v" -gt 0 ] 2>/dev/null && silent=0
        out+="${glyphs[$v]:-▁}"
    done
    if [ "$silent" -eq 1 ]; then
        silent_run=$(( silent_run + 1 ))
    else
        silent_run=0
    fi
    # ~1s of silence before resting — brief dips don't flicker the dim state
    if [ "$silent_run" -ge 12 ]; then
        msg='{"text":"'"$rest"'","class":"quiet"}'
    else
        msg='{"text":"'"$out"'","class":"live"}'
    fi
    if [ "$msg" != "$last" ]; then
        printf '%s\n' "$msg"
        last=$msg
    fi
done
