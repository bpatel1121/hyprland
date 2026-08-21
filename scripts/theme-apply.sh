#!/usr/bin/env bash
# Sync external apps (wallpaper, waybar, swaync, ...) to the ACTIVE theme.
# Does NOT reload Hyprland — hyprland.lua reads the theme itself via dofile.
set -uo pipefail
# HYPR, CUR, theme_key() and theme_wallpaper() all come from here.
# shellcheck source=scripts/theme-lib.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/theme-lib.sh"

# The `current` symlink is gitignored machine state — a fresh clone doesn't
# have it. Create it on first run so the repo works out of the box.
[ -e "$CUR" ] || ln -sfn cyberpunk "$CUR"

# --- Polarity (dark|light) ---------------------------------------------------
# Themes may declare `polarity = "light"` in theme.lua; anything else (or
# nothing) means dark. See theme_key() for why this is sed and not Lua.
polarity=$(theme_key polarity '"\(light\|dark\)"')
[ "$polarity" = light ] || polarity=dark

# --- Border motion ------------------------------------------------------------
# Themes opt in with `border_motion = <speed>` in theme.lua (deciseconds per
# revolution; bigger = slower). Upstream's borderangle loop animation is
# broken (registers, never ticks), so scripts/border-motion.sh rotates the
# gradient angle itself. One instance max: kill any old cycler, start a new
# one only if the incoming theme asks for motion.
pkill -f "hypr/scripts/border-motion.sh" 2>/dev/null || true
motion=$(theme_key border_motion '\([0-9]\+\)')
if [ -n "$motion" ]; then
    "$HYPR/scripts/border-motion.sh" "$motion" >/dev/null 2>&1 &
    disown 2>/dev/null || true
fi

# --- Cursor -------------------------------------------------------------------
# FIRST, deliberately. This used to live down in the GTK block at the bottom of
# the script, which put it behind the swww daemon wait (up to 1.8s), the
# wallpaper transition, `sleep 0.9`, and the waybar/swaync/swayosd restarts —
# so the pointer visibly changed several seconds after the rest of the theme.
# Nothing below depends on it, so it goes first and lands instantly.
#
# The theme may declare `cursor = "Name"` in theme.lua. Fallback chain:
# declared theme -> capitaine -> default, checking what's actually installed.
want_cursor=$(theme_key cursor)
cursor="default"
[ -d /usr/share/icons/capitaine-cursors ] && cursor="capitaine-cursors"
[ -n "$want_cursor" ] && { [ -d "/usr/share/icons/$want_cursor" ] \
    || [ -d "$HOME/.icons/$want_cursor" ] \
    || [ -d "$HOME/.local/share/icons/$want_cursor" ]; } && cursor="$want_cursor"
# Loud rather than silent: a theme asking for a cursor that isn't installed used
# to fall back to capitaine with no trace, which reads exactly like "the cursor
# never switches". Say so instead.
if [ -n "$want_cursor" ] && [ "$cursor" != "$want_cursor" ]; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical "Cursor theme missing" \
            "$want_cursor is not installed — using $cursor" 2>/dev/null || true
    fi
fi

# Three consumers, three mechanisms — all needed:
#   1. hyprctl setcursor  — Hyprland's own pointer + every client using
#      cursor-shape-v1 (GTK4, modern GTK3, Firefox, Electron). Switches live.
#   2. env                — XCursor-loading clients (XWayland, wezterm, Qt
#      without cursor-shape) read this ONCE at process start. Setting it here
#      means apps launched after the switch are correct; already-running ones
#      keep the old pointer until relaunched. That is an XCursor limitation,
#      not something this script can fix.
#   3. ~/.icons/default   — how XWayland and legacy X11 clients resolve the
#      "default" theme name. Without it they ignore both of the above.
hyprctl setcursor "$cursor" 24 >/dev/null 2>&1 || true
hyprctl keyword env XCURSOR_THEME,"$cursor" >/dev/null 2>&1 || true
hyprctl keyword env HYPRCURSOR_THEME,"$cursor" >/dev/null 2>&1 || true
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nName=default\nComment=managed by hypr/scripts/theme-apply.sh\nInherits=%s\n' \
    "$cursor" > "$HOME/.icons/default/index.theme"

# --- Choreography: the bar dips out first, the wallpaper washes over, and
# the bar returns last, dressed in the new theme (layersIn fades it back).
pkill -x waybar 2>/dev/null || true

# The bar's `exec` children do NOT die with it: -x matches the exact name only,
# and waybar-cava.sh stops writing to stdout in silence (its dedup rule), so it
# never takes the SIGPIPE that would otherwise reap it. Every switch used to
# strand one more cava holding a live PulseAudio capture.
#
# WAIT for waybar to actually be gone before reaping them. It respawns any
# `exec` module that exits, so killing the streamer while the bar is still up
# just gets a fresh one a moment later — which is the leak, one per switch.
for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -x waybar >/dev/null 2>&1 || break
    sleep 0.1
done
# By SCRIPT PATH — never `pkill -x cava`, which would also kill the standalone
# visualizer the themes ship a config for.
pkill -f "hypr/scripts/waybar-cava.sh" 2>/dev/null || true
# Belt and braces: sweep any cava still holding one of OUR generated configs.
# The script traps the signals that normally reap it, but a stranded streamer
# still turned up now and then, and one live PulseAudio capture per switch is
# not something to leave to a race. Matching on the waybar-cava.* config path
# is what keeps this from ever touching a cava the user started themselves —
# that one reads ~/.config/cava/config.
pkill -f "cava -p .*/waybar-cava\." 2>/dev/null || true

# --- Wallpaper -------------------------------------------------------------
# Prefer swww/awww: it cross-fades between wallpapers, which is what makes a
# theme switch look like a transition rather than a snap. Falls back to
# hyprpaper's IPC if it isn't installed, so this script still works on a box
# that only has hyprpaper.
#
# The upstream project renamed itself from `swww` to `awww` (github -> codeberg;
# the Arch package `awww` carries `Replaces: swww`), so detect whichever binary
# is actually present rather than hardcoding one name.
wall=$(theme_wallpaper "$CUR")
if [ -n "${wall:-}" ]; then
    SWWW=""
    for c in swww awww; do command -v "$c" >/dev/null 2>&1 && { SWWW="$c"; break; }; done

    if [ -n "$SWWW" ]; then
        # Start the daemon if it isn't up, then wait for it to answer.
        "$SWWW" query >/dev/null 2>&1 || { "${SWWW}-daemon" >/dev/null 2>&1 & disown; }
        for _ in 1 2 3 4 5 6; do "$SWWW" query >/dev/null 2>&1 && break; sleep 0.3; done
        # `wave` sweeps the new wallpaper in behind a moving wavy edge — the
        # most cinematic transition swww has. Angle keeps it off-axis.
        "$SWWW" img "$wall" \
            --transition-type wave --transition-angle 30 \
            --transition-duration 1.8 --transition-fps 60 >/dev/null 2>&1 || true
    else
        for _ in 1 2 3 4 5 6; do hyprctl hyprpaper listloaded >/dev/null 2>&1 && break; sleep 0.3; done
        hyprctl hyprpaper unload all         >/dev/null 2>&1 || true
        hyprctl hyprpaper preload "$wall"    >/dev/null 2>&1 || true
        hyprctl hyprpaper wallpaper ",$wall" >/dev/null 2>&1 || true
    fi
fi

# --- Waybar (launched with the theme's config/style if present) ---
# Killed above, before the wallpaper transition; the pause lets the wave land
# before the bar fades back in with the new skin.
sleep 0.9
# Behavior lives once at the repo root; the theme ships a thin overlay that
# `include`s it and overrides only what it wants to look different. A theme
# that ships no overlay at all still gets the shared bar — that middle branch
# is what keeps "only theme.lua is required" true for the bar too.
bar_cfg="$HYPR/waybar/config.jsonc"
[ -f "$CUR/waybar/config.jsonc" ] && bar_cfg="$CUR/waybar/config.jsonc"

if [ -f "$bar_cfg" ] && [ -f "$CUR/waybar/style.css" ]; then
    waybar -c "$bar_cfg" -s "$CUR/waybar/style.css" >/dev/null 2>&1 &
elif [ -f "$bar_cfg" ]; then
    waybar -c "$bar_cfg" >/dev/null 2>&1 &   # modules, but waybar's own css
else
    waybar >/dev/null 2>&1 &                 # nothing here at all: pure defaults
fi
disown 2>/dev/null || true

# --- WezTerm (recolor open terminals) ---
# WezTerm auto-reloads when its main config file changes. The theme colors are
# pulled in via dofile behind the `current` symlink, and repointing a symlink
# doesn't reliably trip the file watcher — so nudge wezterm.lua's mtime.
# (It's a symlink into linux-setup; touch follows it. mtime doesn't dirty git.)
touch -c "$HOME/.config/wezterm/wezterm.lua" 2>/dev/null || true

# --- swaync (notification center) --------------------------------------------
# Behavior (the layout json) is shared repo-wide at swaync/config.json; only
# the style is per-theme. Reload config then style on switch.
if [ -f "$CUR/swaync/style.css" ]; then
    mkdir -p "$HOME/.config/swaync"
    ln -sfn "$HYPR/swaync/config.json" "$HOME/.config/swaync/config.json"
    ln -sfn "$CUR/swaync/style.css"    "$HOME/.config/swaync/style.css"
    # CSS reload only — NEVER `swaync-client -R` here: the config is shared
    # across themes (nothing to reload), and swaync's config reload re-adds
    # the mpris player card without clearing the old one, so every theme
    # switch stacked a duplicate now-playing card in the center.
    swaync-client -rs 2>/dev/null || true
fi

# --- swayosd (volume/brightness OSD) ------------------------------------------
# The server reads its stylesheet at startup, so restyle = restart. Cheap.
if [ -f "$CUR/swayosd/style.css" ]; then
    mkdir -p "$HOME/.config/swayosd"
    ln -sfn "$CUR/swayosd/style.css" "$HOME/.config/swayosd/style.css"
    if command -v swayosd-server >/dev/null 2>&1; then
        pkill -x swayosd-server 2>/dev/null || true
        swayosd-server >/dev/null 2>&1 &
        disown 2>/dev/null || true
    fi
fi

# --- wlogout / cava / fastfetch (plain symlinks) ---
# Each is guarded: a theme that doesn't ship one just keeps whatever is there,
# per the README's promise that everything but theme.lua degrades gracefully.
#
# wlogout follows the same split as waybar and swaync: the layout is behavior
# (which buttons, which actions, which keybinds) and was byte-identical across
# themes, so it moved to the repo root; style.css stays identity. A theme's own
# layout still wins, and the guard fires on either half so a theme with no
# wlogout/ dir still gets the shared one.
if [ -d "$CUR/wlogout" ] || [ -f "$HYPR/wlogout/layout" ]; then
    mkdir -p "$HOME/.config/wlogout"
    layout="$HYPR/wlogout/layout"
    [ -f "$CUR/wlogout/layout" ] && layout="$CUR/wlogout/layout"  # optional-override
    [ -f "$layout" ]                && ln -sfn "$layout"                "$HOME/.config/wlogout/layout"
    [ -f "$CUR/wlogout/style.css" ] && ln -sfn "$CUR/wlogout/style.css" "$HOME/.config/wlogout/style.css"
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

# lazygit reads its config at startup only — open instances keep the old
# colors until relaunched. That's fine; it's a transient surface.
if [ -f "$CUR/lazygit/config.yml" ]; then
    mkdir -p "$HOME/.config/lazygit"
    ln -sfn "$CUR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
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
    # $cursor was resolved at the top of the script and applied there; the
    # gsettings write below is just the GTK-side echo of it.
    if command -v gsettings >/dev/null 2>&1; then
        gs() { gsettings set org.gnome.desktop.interface "$1" "$2" 2>/dev/null || true; }
        gs color-scheme "$scheme"
        gs gtk-theme    "$gtktheme"
        gs icon-theme   "$icons"
        gs cursor-theme "$cursor"
        gs cursor-size  24
        gs font-name    'JetBrainsMono Nerd Font 11'
    fi
fi

# --- hyprlock (RENDERED, not symlinked) ---
# The theme file is a template with an @WALLPAPER@ placeholder. It's rendered
# rather than linked because hyprlang can't be relied on to expand $HOME, and
# tracked files in this repo must not contain absolute user paths. The output
# is gitignored. `|` as the sed delimiter since the path contains slashes.
#
# Anchored to the `path =` line, not global: unanchored, the substitution also
# rewrote @WALLPAPER@ where the template's own header comment names it, leaving
# an absolute path in the rendered file's prose.
if [ -f "$CUR/hyprlock.conf" ]; then
    sed "/^[[:space:]]*path[[:space:]]*=/ s|@WALLPAPER@|${wall:-}|g" \
        "$CUR/hyprlock.conf" > "$HYPR/hyprlock.conf"
fi
