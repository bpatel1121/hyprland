# Architecture

```
hyprland.lua                    behavior + binds; dofiles the active theme
quickshell/                     QML shell (SCAFFOLD — nothing starts it)
├── settings.json               bar layout, module list, intervals, toggles
└── shell.qml                   `qs -p ~/.config/hypr/quickshell`
schema/                         JSON Schemas for palette.json + settings.json
waybar/config.jsonc             bar behavior: modules, execs, intervals (shared)
wlogout/layout                  power-menu buttons + keybinds (shared)
swaync/config.json              notification-center layout (shared; styles are per-theme)
hypridle.conf                   dim 5m -> lock 10m -> screen off 15m
scripts/
├── theme-switch.sh <name>      repoint themes/current → <name>, reload, apply
├── theme-apply.sh              sync wallpaper/waybar/swaync/wezterm to current
├── theme-menu.sh               wofi picker (bound to SUPER+T)
├── theme-lib.sh                repo root + theme.lua key lookup (sourced)
├── waybar-lib.sh               waybar JSON emit + escaping (sourced)
├── calendar-lib.sh             khal wrapper shared by the calendar scripts (sourced)
├── waybar-updates.sh pacman|aur   update counters, as waybar JSON
├── waybar-cava.sh              streaming soundwave for the now-playing chip
├── border-motion.sh            rotates the border gradient (see "Motion")
├── calendar-notify.sh          event alert daemon (see "The calendar")
├── calendar-menu.sh            ikhal in a themed floating terminal (SUPER+A)
├── waybar-agenda.sh            next-event chip for the bar
├── todo-menu.sh                todoman list, floating (SUPER+SHIFT+A)
├── waybar-todos.sh             due-soon todo chip for the bar
├── sddm-apply.sh               install the theme's SDDM greeter (sudo, see below)
themes/
├── current -> <theme>          relative symlink — the single source of truth
│                               (gitignored: the ACTIVE theme is machine
│                               state; theme-apply creates it if missing)
├── gruvbox/                    dark · pixel alley (see "The gruvbox theme")
└── cyberpunk/
    ├── theme.lua               borders, gaps, blur, shadow (read by hyprland.lua)
    ├── palette.json            CANONICAL color roles (read by the QML shell)
    ├── wallpaper.webp
    ├── waybar/                 style.css (skin) + a thin config.jsonc overlay
    ├── wofi/style.css
    ├── swaync/style.css        notifications + control center (SUPER+SHIFT+N)
    ├── swayosd/style.css       volume/brightness overlay pill
    ├── hyprlock.conf           TEMPLATE — rendered, not symlinked (see below)
    ├── wlogout/style.css       power-menu skin (layout is shared, at the root)
    ├── cava/config             visualizer, VU-meter gradient
    ├── fastfetch/config.jsonc  pink keys, cyan values
    ├── gtk/                    gtk.css + settings.ini -> GTK3 *and* GTK4
    ├── btop/theme.theme        linked in as themes/current.theme
    ├── starship.toml           minimal one-line prompt
    ├── lazygit/config.yml      panel accents for the repo TUI
    ├── nvim.lua                colorscheme + highlight token (read by linux-setup's nvim)
    ├── sddm/                   login greeter (QML) — installed by sddm-apply.sh
    └── wezterm/colors.lua      read by wezterm.lua from linux-setup
```

Behavior is shared, identity is per-theme. The bar's module list, the power
menu's buttons, and the notification center's layout are the same no matter
which skin is on, so they live once at the repo root (`waybar/config.jsonc`,
`wlogout/layout`, `swaync/config.json`) rather than being copied into every
theme. A theme still overrides any of them by shipping its own copy; waybar
does it natively, via an `include` whose *including* file wins.

Everything above is symlinked into place by `theme-apply.sh` — except
`hyprlock.conf`, which is **rendered** with `sed`, substituting the active
wallpaper path for `@WALLPAPER@`. hyprlang can't be relied on to expand `$HOME`,
and tracked files here must not contain absolute user paths, so the output lands
at `~/.config/hypr/hyprlock.conf` and is gitignored.

Theming reaches outside Hyprland too. `theme-apply.sh` links the theme's
`gtk/` into both `~/.config/gtk-3.0` and `~/.config/gtk-4.0` and then drives
`gsettings` (dark scheme, adw-gtk3-dark, Papirus-Dark, and whichever cursor
the theme declares — `capitaine-cursors` is only the fallback). The
css and the ini are deliberately redundant: GTK3 apps started outside a
portal/dconf session read the ini and never consult gsettings. Both theme
names degrade — a machine without `adw-gtk-theme` or Papirus falls back to
built-in `Adwaita-dark` rather than going white.

Two helpers are picked at runtime rather than hardcoded, so the repo works on
machines that lack them: the wallpaper daemon (`swww`, its renamed successor
`awww`, else `hyprpaper`) and `starship` (the prompt is skipped if absent).

`hyprland.lua` loads the theme with `dofile` + `pcall`, so a missing or broken
theme falls back to safe defaults instead of a black screen. The `current`
symlink is deliberately **relative** — an absolute one would bake a username and
clone path into the repo.

---

[← docs index](README.md) · [repo root](../README.md)
