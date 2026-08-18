#!/usr/bin/env bash
# Install the ACTIVE theme's SDDM greeter theme system-wide.
#
# Separate from theme-apply.sh on purpose: SDDM runs as its own user and reads
# /usr/share/sddm/themes, not ~/.config — so this needs root, and the rest of
# theme switching shouldn't. Run it once per theme you want on the login
# screen:
#   sudo ~/.config/hypr/scripts/sddm-apply.sh
#
# A theme without an sddm/ dir just leaves the login screen as-is, per the
# repo's rule that everything but theme.lua degrades gracefully.
set -euo pipefail

# Repo root from the script's own location — NOT $HOME, which is /root under
# sudo and would resolve to the wrong (nonexistent) clone.
REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CUR="$REPO/themes/current"

[ "$(id -u)" -eq 0 ] || { echo "needs root: sudo $0" >&2; exit 1; }
[ -d "$CUR" ] || { echo "no active theme (themes/current missing)" >&2; exit 1; }

name="hypr-$(basename "$(readlink -f "$CUR")")"

if [ ! -d "$CUR/sddm" ]; then
    echo "theme has no sddm/ dir — login screen left unchanged"
    exit 0
fi

dest="/usr/share/sddm/themes/$name"
mkdir -p "$dest"
cp -f "$CUR/sddm/"* "$dest/"

# Ship the theme's wallpaper next to Main.qml and point theme.conf at it.
wall=$(ls "$CUR"/wallpaper.* 2>/dev/null | head -n1 || true)
if [ -n "${wall:-}" ]; then
    cp -f "$wall" "$dest/"
    sed -i "s|^background=.*|background=$(basename "$wall")|" "$dest/theme.conf"
    # Qt only decodes webp with the imageformats plugin installed.
    case "$wall" in *.webp)
        pacman -Q qt6-imageformats >/dev/null 2>&1 \
            || echo "warn: wallpaper is webp but qt6-imageformats is not installed —" \
                    "the greeter background will be black. Fix: sudo pacman -S qt6-imageformats" >&2
    ;; esac
fi

# Normalize permissions: cp preserves the source's mode, and files that arrive
# owner-only (600) would be unreadable to the sddm user — the greeter then
# silently falls back to its embedded theme with "Permission denied".
chmod 755 "$dest"
chmod 644 "$dest"/*

# Point SDDM at the theme via a drop-in (never edits /etc/sddm.conf itself).
mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=%s\n' "$name" > /etc/sddm.conf.d/10-hypr-theme.conf

echo "installed $dest and set it in /etc/sddm.conf.d/10-hypr-theme.conf"
echo "preview without logging out:  sddm-greeter-qt6 --test-mode --theme $dest"
