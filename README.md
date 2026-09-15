# hyprland
![demo](hypr-demo.gif)

![ci](https://github.com/bpatel1121/hyprland/actions/workflows/ci.yml/badge.svg)

My Hyprland desktop as a theme system. This repo's root **is** `~/.config/hypr` —
[linux-setup](https://github.com/bpatel1121/linux-setup) clones it there during
provisioning; nothing to symlink.

One config, swappable skins: `hyprland.lua` holds layout, binds, and behavior,
and everything visual lives in `themes/<name>/`. Switching themes re-skins
Hyprland, waybar, wofi, swaync, wezterm, and the wallpaper together.

## Quickstart

```
SUPER+Q          terminal            SUPER+R    launcher
SUPER+T          theme picker        SUPER+A    calendar
SUPER+ESCAPE     power menu          SUPER+CTRL+L  lock
```

Switch theme: `SUPER+T`, or `scripts/theme-switch.sh <name>`.

## Session keys

| bind | action |
|---|---|
| `SUPER+CTRL+L` | lock (hyprlock) — **not** `SUPER+L`, which is `focus right` |
| `SUPER+ESCAPE` | power menu (wlogout) |
| `SUPER+SHIFT+N` | notification center (swaync) |
| `SUPER+A` | calendar — ikhal's month grid, floating (see "The calendar") |
| `SUPER+SHIFT+A` | todos — todoman's list, floating (see "The calendar") |
| `SUPER+F1..F3 / F5,F6` | volume / brightness, with a themed OSD pill (swayosd) |

Idle is handled by `hypridle`, started at login: backlight dims at 5 min, the
session locks at 10, the screen sleeps at 15.

## Docs

| | |
|---|---|
| [Architecture](docs/architecture.md) | what loads what, and the behavior-vs-identity split |
| [Theming](docs/theming.md) | switching, adding a theme, the `theme.lua` and `palette.json` contracts |
| [The bar](docs/bar.md) | the three islands, the watchdog chips, border motion |
| [The calendar](docs/calendar.md) | khal + todoman, and the alert daemon |
| [Notifications & OSD](docs/notifications.md) | swaync, swayosd |
| [Login screen](docs/sddm.md) | the SDDM greeter, and installing it |
| [Plugins](docs/plugins.md) | the hyprpm steps, done by hand on purpose |
| [QML migration](docs/qml-migration.md) | the Quickshell shell: what exists, what switching would take |
| **Themes** | [cyberpunk](docs/themes/cyberpunk.md) · [gruvbox](docs/themes/gruvbox.md) |

## The QML shell

`quickshell/` holds a [Quickshell](https://quickshell.org) bar that mirrors the
waybar above. It is a **scaffold**: nothing starts it, it reserves no screen
space, and waybar remains the bar this desktop actually runs.

```
qs -p ~/.config/hypr/quickshell
```

See [quickshell/README.md](quickshell/README.md) for what each file does, and
[docs/qml-migration.md](docs/qml-migration.md) for the state of the migration.
