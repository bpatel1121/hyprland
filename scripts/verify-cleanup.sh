#!/usr/bin/env bash
# Read-only audit of the package cleanup. Safe to run at any time — it only
# queries pacman and greps config; it changes nothing and needs no sudo.
#
# Re-run it after each removal step rather than eyeballing pacman's output.
# Exit 0 = everything below is clean. Exit 1 = something still outstanding.
set -uo pipefail

fail=0
ok()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad() { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
hdr() { printf '\n\033[1m%s\033[0m\n' "$1"; }

hdr "1. Target packages removed"
for p in yay-debug wezterm-git-debug wlogout-debug electron39 go \
         qemu-system-aarch64 foot kvantum qt5ct; do
    if pacman -Q "$p" &>/dev/null; then bad "still installed: $p"; else ok "gone: $p"; fi
done
# hyprpaper and jre-openjdk are deliberately NOT listed. hyprpaper is still the
# documented fallback in theme-apply.sh for machines without awww, and nothing
# has yet established what (if anything) needs the JRE.

hdr "2. No orphans"
orph=$(pacman -Qdtq 2>/dev/null || true)
[ -z "$orph" ] && ok "none" || bad "orphans: $(echo "$orph" | tr '\n' ' ')"

hdr "3. No -debug packages"
dbg=$(pacman -Q 2>/dev/null | grep -- '-debug' || true)
[ -z "$dbg" ] && ok "none" \
              || bad "present: $(echo "$dbg" | awk '{print $1}' | tr '\n' ' ')"

hdr "4. makepkg won't regenerate them"
# Anchored to the ACTIVE OPTIONS line on purpose. A plain
# `grep -q '!debug' /etc/makepkg.conf` matches the COMMENTED example on line 87
# of the stock config and reports a false pass while line 101 still says
# `debug`. Verified that failure mode directly — don't "simplify" this back.
opts=$(grep -E '^OPTIONS=' /etc/makepkg.conf 2>/dev/null || true)
if [ -z "$opts" ]; then
    bad "no active OPTIONS= line found in /etc/makepkg.conf"
elif echo "$opts" | grep -qE '(^|[( ])!debug([ )]|$)'; then
    ok "!debug active"
else
    bad "'debug' still active in OPTIONS — AUR builds will re-create them"
fi

hdr "5. Explicits re-marked as dependencies"
for p in libpulse wpa_supplicant nvidia-utils; do
    if pacman -Qe "$p" &>/dev/null; then bad "still explicit: $p"; else ok "dep: $p"; fi
done

hdr "6. Nothing important got dragged out"
# The failure that actually hurts is `pacman -Rns` cascading further than
# intended. linux-headers especially: nothing declares it, but DKMS needs it to
# rebuild nvidia-open-dkms at the next kernel bump, and pacman won't warn you.
missing_important=0
for p in linux-headers efibootmgr nvidia-open-dkms nvidia-utils hyprland \
         waybar wofi mako sddm base-devel cmake meson; do
    pacman -Q "$p" &>/dev/null || { bad "MISSING (should still be here): $p"; missing_important=1; }
done
[ "$missing_important" -eq 0 ] && ok "all present"

hdr "7. Package file integrity (slow-ish)"
broken=$(pacman -Qk 2>/dev/null | grep -v ' 0 missing files' || true)
[ -z "$broken" ] && ok "no missing files" || bad "$(echo "$broken" | head -5)"

hdr "8. Leftover user config from removed packages (cosmetic only)"
left=0
for d in "$HOME/.config/foot" "$HOME/.config/Kvantum" "$HOME/.config/qt5ct" \
         "$HOME/.config/hypr/hyprpaper.conf"; do
    [ -e "$d" ] && { printf '  · leftover: %s\n' "$d"; left=1; }
done
while IFS= read -r f; do printf '  · pacsave: %s\n' "$f"; left=1; done \
    < <(find /etc -name '*.pacsave' -newermt '-7 days' 2>/dev/null)
[ "$left" -eq 0 ] && ok "nothing left behind"

hdr "Not checkable here"
cat <<'EOF'
  · nvidia-open-dkms rebuilding — only shows at the NEXT kernel update.
    Afterwards: `dkms status` (expect installed) and `modinfo nvidia | head -3`
  · the session still coming up — reboot is the only real proof that sddm
    starts and the nvidia module loads. Reboot before stacking more changes.
EOF

printf '\n'
[ $fail -eq 0 ] && printf '\033[32mAll checks passed.\033[0m\n' \
                || printf '\033[31mSome checks outstanding (see ✗ above).\033[0m\n'
exit $fail
