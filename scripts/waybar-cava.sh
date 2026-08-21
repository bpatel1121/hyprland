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
#
# That last rule had a sharp edge. waybar's `exec` children do not die with
# it: theme-apply.sh kills the bar with `pkill -x waybar`, which matches the
# exact name only, so this script was reparented to init instead. It should
# then have died of SIGPIPE on its next write — but in silence it never
# writes, so it never took the signal. Every theme switch stranded one more
# copy, each holding a live PulseAudio capture stream. The `kill -0` guard
# below is the fix; theme-apply.sh also kills this script by path now.
set -uo pipefail

bars=8
cfg=$(mktemp "${TMPDIR:-/tmp}/waybar-cava.XXXXXX")
# EXIT alone is NOT enough: theme-apply.sh reaps this script with `pkill`, and
# bash runs no EXIT trap when it dies to an untrapped signal — so the cleanup
# was skipped on exactly the path that matters, and cava outlived it anyway.
# Trapping the signals and exiting from the handler routes them back through
# EXIT, so there is still only one cleanup path.
cleanup() {
    rm -f "$cfg"
    [ -n "${cava_pid:-}" ] && kill "$cava_pid" 2>/dev/null
    return 0
}
trap cleanup EXIT
# PIPE belongs in this list and is the subtle one. When waybar dies, the next
# frame this script prints raises SIGPIPE — whose default action kills bash
# outright, EXIT trap and all, leaving cava behind. It was intermittent for a
# reason that reads like nonsense until you see it: the dedup rule above means
# a frame is only written when it CHANGES, so a switch during silence cleaned
# up properly and a switch during playback leaked. Catch it and route it back
# through EXIT like the rest.
trap 'exit 0' TERM INT HUP PIPE
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

parent=$PPID   # waybar

last=""
silent_run=0
frame=0
status="Stopped"
# A process substitution rather than `cava | while`, for two reasons that both
# matter here:
#   1. It yields cava's PID, so the EXIT trap can kill it outright. Closing the
#      pipe is NOT sufficient — cava only notices on its next write, and a cava
#      whose audio source has gone idle blocks without writing, so it never
#      takes the SIGPIPE. That is how the orphans survived: reader gone, pipe
#      readerless, cava asleep in the input path forever.
#   2. The loop body runs in THIS shell instead of a subshell, so `exit` really
#      does end the script (and fire the trap) rather than just the subshell.
exec 3< <(cava -p "$cfg" 2>/dev/null)
cava_pid=$!

started=0
while IFS=';' read -ra vals <&3; do
    # The first frame proves cava has parsed its config, so the file has done
    # its whole job and can go now rather than in the trap. That makes the
    # temp file's lifetime independent of HOW this script dies — the kill
    # paths that bypass traps were leaving one behind every time.
    if [ "$started" -eq 0 ]; then
        rm -f "$cfg"
        started=1
    fi
    # Waybar gone -> so are we. Backstop for every path theme-apply's pkill
    # doesn't cover: waybar crashing, or a hand-typed `pkill waybar`.
    # `kill -0` is a builtin, so this costs nothing at 12fps.
    kill -0 "$parent" 2>/dev/null || exit 0
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
