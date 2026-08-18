#!/usr/bin/env bash
# Sync external apps (wallpaper, waybar, mako) to the ACTIVE theme.
# Does NOT reload Hyprland — hyprland.lua reads the theme itself via dofile.
set -uo pipefail
HYPR="$HOME/.config/hypr"
CUR="$HYPR/themes/current"

# --- Polarity (dark|light) ---------------------------------------------------
# Themes may declare `polarity = "light"` in theme.lua; anything else (or
# nothing) means dark. Extracted with sed rather than a lua interpreter so the
# script keeps zero dependencies — the key just has to sit on its own line.
polarity=$(sed -n 's/^[[:space:]]*polarity[[:space:]]*=[[:space:]]*"\(light\|dark\)".*/\1/p' \
    "$CUR/theme.lua" 2>/dev/null | head -n1)
[ "$polarity" = light ] || polarity=dark

# --- Wallpaper -------------------------------------------------------------
# Prefer swww/awww: it cross-fades between wallpapers, which is what makes a
# theme switch look like a transition rather than a snap. Falls back to
# hyprpaper's IPC if it isn't installed, so this script still works on a box
# that only has hyprpaper.
#
# The upstream project renamed itself from `swww` to `awww` (github -> codeberg;
# the Arch package `awww` carries `Replaces: swww`), so detect whichever binary
# is actually present rather than hardcoding one name.
wall=$(ls "$CUR"/wallpaper.* 2>/dev/null | head -n1 || true)
if [ -n "${wall:-}" ]; then
    SWWW=""
    for c in swww awww; do command -v "$c" >/dev/null 2>&1 && { SWWW="$c"; break; }; done

    if [ -n "$SWWW" ]; then
        # Start the daemon if it isn't up, then wait for it to answer.
        "$SWWW" query >/dev/null 2>&1 || { "${SWWW}-daemon" >/dev/null 2>&1 & disown; }
        for _ in 1 2 3 4 5 6; do "$SWWW" query >/dev/null 2>&1 && break; sleep 0.3; done
        "$SWWW" img "$wall" \
            --transition-type grow --transition-pos 0.5,0.5 \
            --transition-duration 1.5 --transition-fps 60 >/dev/null 2>&1 || true
    else
        for _ in 1 2 3 4 5 6; do hyprctl hyprpaper listloaded >/dev/null 2>&1 && break; sleep 0.3; done
        hyprctl hyprpaper unload all         >/dev/null 2>&1 || true
        hyprctl hyprpaper preload "$wall"    >/dev/null 2>&1 || true
        hyprctl hyprpaper wallpaper ",$wall" >/dev/null 2>&1 || true
    fi
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

# --- wlogout / cava / fastfetch (plain symlinks, same idea as mako) ---
# Each is guarded: a theme that doesn't ship one just keeps whatever is there,
# per the README's promise that everything but theme.lua degrades gracefully.
if [ -d "$CUR/wlogout" ]; then
    mkdir -p "$HOME/.config/wlogout"
    ln -sfn "$CUR/wlogout/layout"    "$HOME/.config/wlogout/layout"
    ln -sfn "$CUR/wlogout/style.css" "$HOME/.config/wlogout/style.css"
fi

if [ -f "$CUR/cava/config" ]; then
    mkdir -p "$HOME/.config/cava"
    ln -sfn "$CUR/cava/config" "$HOME/.config/cava/config"
    # cava reloads its config on SIGUSR1 — no need to restart a running one.
    pkill -SIGUSR1 -x cava 2>/dev/null || true
fi

if [ -f "$CUR/fastfetch/config.jsonc" ]; then
    mkdir -p "$HOME/.config/fastfetch"
    ln -sfn "$CUR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
fi

if [ -f "$CUR/starship.toml" ]; then
    ln -sfn "$CUR/starship.toml" "$HOME/.config/starship.toml"
fi

# btop reads its theme by NAME from btop.conf, which isn't theme-managed. Link
# every theme in under one fixed name so btop.conf can say color_theme =
# "current" once and never be touched again.
if [ -f "$CUR/btop/theme.theme" ]; then
    mkdir -p "$HOME/.config/btop/themes"
    ln -sfn "$CUR/btop/theme.theme" "$HOME/.config/btop/themes/current.theme"
fi

# --- GTK ---------------------------------------------------------------------
# Both the css and the ini go to GTK3 *and* GTK4. The two toolkits read
# different color names out of the same css (it defines both sets), and the ini
# duplicates the gsettings below on purpose: GTK3 apps launched outside a
# portal/dconf session read the ini and never consult gsettings.
if [ -d "$CUR/gtk" ]; then
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    for d in gtk-3.0 gtk-4.0; do
        [ -f "$CUR/gtk/gtk.css" ]      && ln -sfn "$CUR/gtk/gtk.css"      "$HOME/.config/$d/gtk.css"
        [ -f "$CUR/gtk/settings.ini" ] && ln -sfn "$CUR/gtk/settings.ini" "$HOME/.config/$d/settings.ini"
    done

    # Polarity-aware: the theme's declared polarity picks the GTK theme, icon
    # variant, and color-scheme together, so a light theme flips the whole
    # desktop (and everything honoring prefers-color-scheme — Firefox, most
    # websites — follows for free). adw-gtk3/-dark come from the
    # `adw-gtk-theme` package (renamed upstream from adw-gtk3); fall back to
    # GTK's built-ins if it's absent so a fresh machine still matches polarity.
    if [ "$polarity" = light ]; then
        scheme="prefer-light"
        gtktheme="Adwaita"
        for p in /usr/share/themes ~/.themes; do
            [ -d "$p/adw-gtk3" ] && gtktheme="adw-gtk3"
        done
        icons="Adwaita"; [ -d /usr/share/icons/Papirus-Light ] && icons="Papirus-Light"
    else
        scheme="prefer-dark"
        gtktheme="Adwaita-dark"
        for p in /usr/share/themes ~/.themes; do
            [ -d "$p/adw-gtk3-dark" ] && gtktheme="adw-gtk3-dark"
        done
        icons="Adwaita"; [ -d /usr/share/icons/Papirus-Dark ] && icons="Papirus-Dark"
    fi
    cursor="default"; [ -d /usr/share/icons/capitaine-cursors ] && cursor="capitaine-cursors"

    if command -v gsettings >/dev/null 2>&1; then
        gs() { gsettings set org.gnome.desktop.interface "$1" "$2" 2>/dev/null || true; }
        gs color-scheme "$scheme"
        gs gtk-theme    "$gtktheme"
        gs icon-theme   "$icons"
        gs cursor-theme "$cursor"
        gs cursor-size  24
        gs font-name    'JetBrainsMono Nerd Font 11'
    fi
    # Hyprland's own cursor, so the pointer matches over the desktop too.
    hyprctl setcursor "$cursor" 24 >/dev/null 2>&1 || true
fi

# --- hyprlock (RENDERED, not symlinked) ---
# The theme file is a template with an @WALLPAPER@ placeholder. It's rendered
# rather than linked because hyprlang can't be relied on to expand $HOME, and
# tracked files in this repo must not contain absolute user paths. The output
# is gitignored. `|` as the sed delimiter since the path contains slashes.
if [ -f "$CUR/hyprlock.conf" ]; then
    sed "s|@WALLPAPER@|${wall:-}|g" "$CUR/hyprlock.conf" > "$HOME/.config/hypr/hyprlock.conf"
fi
