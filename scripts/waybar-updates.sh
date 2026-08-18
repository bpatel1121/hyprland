#!/usr/bin/env bash
# Waybar update counters.  Usage: waybar-updates.sh pacman|aur
#
# Emits waybar JSON rather than plain text so the module can carry a CSS class.
# That's what lets the counters stay on screen at zero and gray out there
# instead of vanishing — color keeps meaning "act on me" rather than burning
# permanently.  Styling lives in the theme's waybar/style.css:
#   .pending -> amber (repos) / green (AUR)      .zero -> dim gray
set -uo pipefail

case "${1:-}" in
    pacman)
        icon="󰮯"                                  # md-pac_man U+F0BAF
        # checkupdates exits 0 = updates, 2 = none, 1 = error. The login-time
        # run can fire before the network is up, and treating that error as
        # empty rendered "up to date" for a whole interval — the counter that
        # "never updated". Retry for up to a minute, then say "?" honestly.
        list=""; rc=1
        for _ in 1 2 3 4 5 6; do
            list=$(checkupdates 2>/dev/null); rc=$?
            { [ "$rc" -eq 0 ] || [ "$rc" -eq 2 ]; } && break
            sleep 10
        done
        if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then
            printf '{"text":"%s ?","class":"zero","tooltip":"update check failed (network?)"}\n' "$icon"
            exit 0
        fi
        ;;
    aur)
        icon="󱁖"                                  # md-party_popper U+F1056
        # -Qua hits the AUR RPC, so cap it: a dead network must not wedge the
        # bar.  yay exits 1 when there's nothing to upgrade — swallow that too.
        list=$(timeout 25 yay -Qua 2>/dev/null || true)
        ;;
    *)
        printf '{"text":"?","class":"zero","tooltip":"usage: waybar-updates.sh pacman|aur"}\n'
        exit 0
        ;;
esac

# grep -c returns "0" *and* exit 1 on empty input; the substitution still
# captures the 0, so `|| true` just keeps pipefail quiet.
count=$(printf '%s' "$list" | grep -c . || true)
count=${count:-0}

if [ "$count" -gt 0 ]; then
    class="pending"
    # JSON-escape the package list for the tooltip; real newlines become \n.
    tooltip=$(printf '%s' "$list" \
        | sed 's/\\/\\\\/g; s/"/\\"/g' \
        | awk 'BEGIN{ORS=""} {print (NR>1 ? "\\n" : "") $0}')
else
    class="zero"
    tooltip="up to date"
fi

printf '{"text":"%s %s","class":"%s","tooltip":"%s"}\n' "$icon" "$count" "$class" "$tooltip"
