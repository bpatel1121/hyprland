#!/usr/bin/env bash
# Sync external apps (wallpaper, swaync, GTK, ...) to the ACTIVE theme.
# Does NOT reload Hyprland — hyprland.lua reads the theme itself via dofile.
# Does NOT restart the shell either: quickshell/ reads themes/current/palette.json
# itself and is told to re-read it at the end of this script.
set -uo pipefail
# HYPR, CUR, theme_key() and theme_wallpaper() all come from here.
# shellcheck source=scripts/theme-lib.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/theme-lib.sh"

# The `current` symlink is gitignored machine state — a fresh clone doesn't
# have it. Create it on first run so the repo works out of the box.
[ -e "$CUR" ] || ln -sfn cyberpunk "$CUR"

# --- First: the two surfaces that recolor instantly -----------------------------
# The shell and open terminals both re-read their colors in well under a second,
# so they go before anything that can block (the wallpaper daemon handshake and
# the transition below). Nothing after this point depends on either of them.

# --- WezTerm (recolor open terminals) ---
# WezTerm reloads when a WATCHED file's contents change. Its config dofile()s
# the theme colors and watches that path — but a watch resolves the `current`
# symlink once, to the file it pointed at then, and repointing the symlink
# changes nothing about that file. A touch on wezterm.lua was the old nudge and
# did not reliably fire either. So the colors are RENDERED to a stable path
# whose contents really do change on every switch (same idea as hyprlock.conf);
# wezterm.lua reads and watches $HYPR/wezterm-colors.lua. Gitignored.
if [ -f "$CUR/wezterm/colors.lua" ]; then
    cp -f "$CUR/wezterm/colors.lua" "$HYPR/wezterm-colors.lua"
fi

# --- The shell (quickshell/) --------------------------------------------------
# Nothing to restart. The shell reads themes/current/palette.json and
# quickshell/settings.json itself, but its file watchers follow the file the
# symlink RESOLVED to when it started, so repointing `current` is invisible
# to them until asked. One IPC call re-reads both; every surface rebinds live.
# Guarded: this script also runs at login, when the shell may not be up yet —
# it reads the right theme on its own first start anyway.
if command -v qs >/dev/null 2>&1; then
    qs ipc -p "$HYPR/quickshell" call theme reload >/dev/null 2>&1 || true
fi

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
# wallpaper transition and the bar restart the old waybar setup needed — so the
# pointer visibly changed several seconds after the rest of the theme.
# Nothing below depends on it, so it goes first and lands instantly.
#
# The theme may declare `cursor = "Name"` in theme.lua; it is used when it is
# actually installed, else the stock `default` (capitaine is no longer shipped).
want_cursor=$(theme_key cursor)
cursor="default"
[ -n "$want_cursor" ] && { [ -d "/usr/share/icons/$want_cursor" ] \
    || [ -d "$HOME/.icons/$want_cursor" ] \
    || [ -d "$HOME/.local/share/icons/$want_cursor" ]; } && cursor="$want_cursor"
# Loud rather than silent: a theme asking for a cursor that isn't installed used
# to fall back with no trace, which reads exactly like "the cursor never
# switches". Say so instead.
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
        # The sweep is the theme's own: theme.lua `transition` holds the swww
        # type and every flag after it in one string ("wipe --transition-angle
        # 45 --transition-duration 1.2"), word-split on purpose, so a theme can
        # pick wave or wipe or a plain dissolve and tune it without this script
        # knowing. A theme that omits it gets the old wave.
        read -r -a sweep <<<"$(theme_key transition)"
        [ "${#sweep[@]}" -gt 0 ] || sweep=(wave --transition-angle 30 --transition-duration 1.8)
        "$SWWW" img "$wall" \
            --transition-fps 60 --transition-type "${sweep[@]}" >/dev/null 2>&1 || true
    else
        for _ in 1 2 3 4 5 6; do hyprctl hyprpaper listloaded >/dev/null 2>&1 && break; sleep 0.3; done
        hyprctl hyprpaper unload all         >/dev/null 2>&1 || true
        hyprctl hyprpaper preload "$wall"    >/dev/null 2>&1 || true
        hyprctl hyprpaper wallpaper ",$wall" >/dev/null 2>&1 || true
    fi
fi

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

# --- cava / fastfetch (plain symlinks) ---
# Each is guarded: a theme that doesn't ship one just keeps whatever is there,
# per the README's promise that everything but theme.lua degrades gracefully.
if [ -f "$CUR/cava/config" ]; then
    mkdir -p "$HOME/.config/cava"
    ln -sfn "$CUR/cava/config" "$HOME/.config/cava/config"
    # cava reloads its config on SIGUSR1 — no need to restart a running one.
    # Only the standalone visualizer, though: the bar's soundwave runs its own
    # cava from a temp config that scripts/waybar-cava.sh deletes after the
    # first frame, so a reload there finds no file and cava exits — which is
    # how the wave used to die on every theme switch.
    while read -r pid; do
        grep -qz "waybar-cava" "/proc/$pid/cmdline" 2>/dev/null || kill -USR1 "$pid" 2>/dev/null || true
    done < <(pgrep -x cava)
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

# btop reads its theme by NAME from btop.conf. Link every theme in under one
# fixed name, then point btop.conf at that name. btop rewrites btop.conf on
# exit (it saves its own state there), so the file is not managed as a whole:
# the two keys this needs are set in place, and anything else in it is left
# to btop. theme_background off lets the terminal's own pane show through.
if [ -f "$CUR/btop/theme.theme" ]; then
    mkdir -p "$HOME/.config/btop/themes"
    ln -sfn "$CUR/btop/theme.theme" "$HOME/.config/btop/themes/current.theme"
    conf="$HOME/.config/btop/btop.conf"
    [ -f "$conf" ] || : > "$conf"
    for kv in 'color_theme = "current"' 'theme_background = False'; do
        k=${kv%% *}
        if grep -q "^$k " "$conf"; then
            sed -i "s|^$k .*|$kv|" "$conf"
        else
            printf '%s\n' "$kv" >> "$conf"
        fi
    done
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
