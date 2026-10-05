# Architecture

```
hyprland.lua                    behavior + binds; dofiles the active theme; autostarts the shell
quickshell/                     THE shell: bar, launcher, OSD, power menu (one process)
├── settings.json               behavior: bar layout, modules, intervals, surface settings, power-menu buttons
├── shell.qml                   `qs -p ~/.config/hypr/quickshell -d -n`
├── bar/ launcher/ osd/ session/   one directory per surface, each owning its IPC target
└── README.md                   file map, IPC table, module map
schema/                         JSON Schemas for palette.json + settings.json
swaync/config.json              notification-center layout (shared; styles are per-theme)
hypridle.conf                   dim 5m -> lock 10m -> screen off 15m
scripts/
├── theme-switch.sh <name>      repoint themes/current → <name>, reload, apply
├── theme-apply.sh              sync wallpaper/swaync/GTK/wezterm to current; poke the shell
├── theme-lib.sh                repo root + theme.lua key lookup (sourced)
├── waybar-lib.sh               one-line JSON emit + escaping for the bar's script chips (sourced)
├── calendar-lib.sh             khal wrapper shared by the calendar scripts (sourced)
├── waybar-updates.sh pacman|aur   update counters, as one-line JSON
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
├── glacier/                    dark · frost, ice throne (see "The glacier theme")
├── graphite/                   LIGHT · grey ink on paper, one violet (see "The graphite theme")
├── inkwash/                    LIGHT · ink-wash painting, gold and cyan (see "The inkwash theme")
└── cyberpunk/
    ├── theme.lua               borders, gaps, blur, shadow (read by hyprland.lua)
    ├── palette.json            color roles + the look of every shell surface (read by quickshell/)
    ├── wallpaper.webp
    ├── swaync/style.css        notifications + control center (SUPER+SHIFT+N)
    ├── hyprlock.conf           TEMPLATE — rendered, not symlinked (see below)
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
menu's buttons, the launcher's grid and the notification center's layout are
the same no matter which skin is on, so they live once at the repo root —
`quickshell/settings.json` for everything the shell draws, `swaync/config.json`
for notifications — rather than being copied into every theme. What a theme
*looks* like is its `palette.json`: the twelve color roles, the font, and a
block per surface (`effects`, `bar`, `launcher`, `osd`, `session`) holding the
radii, frame weights and opacities that make cyberpunk rounded neon glass and
gruvbox a sharp CRT panel. Those two files are the shell's whole configuration,
and it watches both, so editing either re-applies live. There is no per-theme
override of behavior any more (the old waybar `include` overlay went with
waybar): a theme is a palette, not a fork.

Everything above is symlinked into place by `theme-apply.sh` — except
`palette.json`, which the shell reads through `themes/current/` itself, and
`hyprlock.conf`, which is **rendered** with `sed`, substituting the active
wallpaper path for `@WALLPAPER@`. hyprlang can't be relied on to expand `$HOME`,
and tracked files here must not contain absolute user paths, so the output lands
at `~/.config/hypr/hyprlock.conf` and is gitignored. The shell is never
restarted on a switch: its file watchers follow the inode `current` resolved to
when it started, so repointing the symlink is invisible to them, and the last
line of `theme-apply.sh` is one `qs ipc … call theme reload` that makes every
surface re-read both files.

Theming reaches outside Hyprland too. `theme-apply.sh` links the theme's
`gtk/` into both `~/.config/gtk-3.0` and `~/.config/gtk-4.0` and then drives
`gsettings` (dark scheme, adw-gtk3-dark, Papirus-Dark, and whichever cursor
the theme declares, with the stock `default` as the only fallback). The
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
