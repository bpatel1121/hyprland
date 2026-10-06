# hyprland
![demo](hypr-demo.gif)

![ci](https://github.com/bpatel1121/hyprland/actions/workflows/ci.yml/badge.svg)

My Hyprland desktop as a theme system. This repo's root **is** `~/.config/hypr` —
[linux-setup](https://github.com/bpatel1121/linux-setup) clones it there during
provisioning; nothing to symlink.

One config, swappable skins: `hyprland.lua` holds layout, binds, and behavior,
and everything visual lives in `themes/<name>/`. The bar, launcher, volume and
brightness OSD and power menu are one [Quickshell](https://quickshell.org)
process (`quickshell/`) that reads the theme's `palette.json`. Switching themes
re-skins Hyprland, the shell, swaync, wezterm, and the wallpaper together.

## Quickstart

```
SUPER+Q          terminal            SUPER+R    launcher
SUPER+T          theme picker        SUPER+A    calendar
SUPER+ESCAPE     power menu          SUPER+CTRL+L  lock
```

Switch theme: `SUPER+T` (theme picker — full screen, ←/→ or h/l, type to
filter, Enter applies), or `scripts/theme-switch.sh <name>`.

## Session keys

| bind | action |
|---|---|
| `SUPER+CTRL+L` | lock (hyprlock) — **not** `SUPER+L`, which is `focus right` |
| `SUPER+ESCAPE` | power menu (the shell's session menu) |
| `SUPER+SHIFT+N` | notification center (swaync) |
| `SUPER+A` | calendar — ikhal's month grid, floating (see "The calendar") |
| `SUPER+SHIFT+A` | todos — todoman's list, floating (see "The calendar") |
| `SUPER+F1..F3 / F5,F6` | volume / brightness, with the shell's OSD pill (bare `wpctl`/`brightnessctl` if the shell is down) |
| `Print` / `SUPER+Print` | screenshot the screen / a region to the clipboard, with a camera flash from the shell |
| `SUPER+SHIFT+Print` | screenshot a region and annotate it in satty (arrows, boxes, blur); Enter copies and saves to `~/Pictures/Screenshots` |
| `SUPER+G` / `SUPER+SHIFT+G` | fold the window into a tab group / pull it back out |
| `SUPER+TAB` / `SUPER+SHIFT+TAB` | next / previous tab in the group |

Idle is handled by `hypridle`, started at login: backlight dims at 5 min, the
session locks at 10, the screen sleeps at 15. `hyprsunset` warms the screen to
4200K from 21:00 to 07:30 (`hyprsunset.conf`).

## Docs

| | |
|---|---|
| [Architecture](docs/architecture.md) | what loads what, and the behavior-vs-identity split |
| [Theming](docs/theming.md) | switching, adding a theme, the `theme.lua` and `palette.json` contracts |
| [The bar](docs/bar.md) | the three islands, the watchdog chips, border motion |
| [The calendar](docs/calendar.md) | khal + todoman, and the alert daemon |
| [Notifications & OSD](docs/notifications.md) | swaync; the OSD is the shell's |
| [Login screen](docs/sddm.md) | the SDDM greeter, and installing it |
| [Plugins](docs/plugins.md) | the hyprpm steps, done by hand on purpose |
| [QML migration](docs/qml-migration.md) | the Quickshell shell: what was moved, what deliberately was not |
| **Themes** | [cyberpunk](docs/themes/cyberpunk.md) · [gruvbox](docs/themes/gruvbox.md) · [glacier](docs/themes/glacier.md) · [harbor](docs/themes/harbor.md) · [verdigris](docs/themes/verdigris.md) · [vesper](docs/themes/vesper.md) · [graphite](docs/themes/graphite.md) (light) · [inkwash](docs/themes/inkwash.md) (light) |

## The shell

`quickshell/` is the desktop's shell layer: one Quickshell process holding the
bar, the launcher, the theme picker, the OSD and the power menu. It replaced
waybar, wofi, swayosd and wlogout; `hyprland.lua` autostarts it and every bind
above that used to launch one of those now asks the shell over IPC:

```
qs -p ~/.config/hypr/quickshell -d -n                      # what hyprland.lua runs
qs ipc -p ~/.config/hypr/quickshell call launcher toggle   # what SUPER+R runs
```

Its behavior is `quickshell/settings.json`; its look is the active theme's
`palette.json`. See [quickshell/README.md](quickshell/README.md) for what each
file does, and [docs/qml-migration.md](docs/qml-migration.md) for what was moved
and what stayed (notifications, lock).
