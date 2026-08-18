#!/usr/bin/env bash
# Streaming soundwave for waybar — fused onto the mpris chip.
#
# Runs cava in raw-ascii mode and translates each frame into block glyphs,
# emitted as JSON lines for a streaming custom module. Used instead of
# waybar's built-in cava module because that one needs a compile-time flag
# Arch's waybar may not carry; this works on any build, needing only the
# `cava` binary (already provisioned).
#
# Silence -> empty text -> the module collapses to nothing, so the wave only
# exists while sound does.
set -uo pipefail

bars=8
cfg=$(mktemp /tmp/waybar-cava.XXXXXX)
trap 'rm -f "$cfg"' EXIT
cat > "$cfg" <<CFG
[general]
bars = $bars
framerate = 30
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
cava -p "$cfg" 2>/dev/null | while IFS=';' read -ra vals; do
    out=""
    silent=1
    for v in "${vals[@]}"; do
        [ -z "$v" ] && continue
        [ "$v" -gt 0 ] 2>/dev/null && silent=0
        out+="${glyphs[$v]:-▁}"
    done
    if [ "$silent" -eq 1 ]; then
        printf '{"text":""}\n'
    else
        printf '{"text":"%s"}\n' "$out"
    fi
done
