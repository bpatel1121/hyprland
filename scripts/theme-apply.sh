#!/usr/bin/env bash
# Sync external apps (wallpaper, waybar, mako) to the ACTIVE theme.
# Does NOT reload Hyprland — hyprland.lua reads the theme itself via dofile.
set -uo pipefail
HYPR="$HOME/.config/hypr"
CUR="$HYPR/themes/current"

# --- Wallpaper (hyprpaper IPC) ---
wall=$(ls "$CUR"/wallpaper.* 2>/dev/null | head -n1 || true)
if [ -n "${wall:-}" ]; then
    for _ in 1 2 3 4 5 6; do hyprctl hyprpaper listloaded >/dev/null 2>&1 && break; sleep 0.3; done
    hyprctl hyprpaper unload all         >/dev/null 2>&1 || true
    hyprctl hyprpaper preload "$wall"    >/dev/null 2>&1 || true
    hyprctl hyprpaper wallpaper ",$wall" >/dev/null 2>&1 || true
fi

# --- Waybar (launched with the theme's config/style if present) ---
pkill -x waybar 2>/dev/null || true
sleep 0.2
if [ -f "$CUR/waybar/config.jsonc" ] && [ -f "$CUR/waybar/style.css" ]; then
    waybar -c "$CUR/waybar/config.jsonc" -s "$CUR/waybar/style.css" >/dev/null 2>&1 &
else
    waybar >/dev/null 2>&1 &   # falls back to default waybar until you add theme styles
fi
disown 2>/dev/null || true

# --- WezTerm (recolor open terminals) ---
# WezTerm auto-reloads when its main config file changes. The theme colors are
# pulled in via dofile behind the `current` symlink, and repointing a symlink
# doesn't reliably trip the file watcher — so nudge wezterm.lua's mtime.
# (It's a symlink into linux-setup; touch follows it. mtime doesn't dirty git.)
touch -c "$HOME/.config/wezterm/wezterm.lua" 2>/dev/null || true

# --- Mako (symlink the theme's config, then reload) ---
if [ -f "$CUR/mako/config" ]; then
    mkdir -p "$HOME/.config/mako"
    ln -sfn "$CUR/mako/config" "$HOME/.config/mako/config"
    makoctl reload 2>/dev/null || true
fi
