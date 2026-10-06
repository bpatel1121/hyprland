# QML migration

Moving this desktop's shell surfaces from five separate GTK programs to one QML
shell, and where that has actually got to.

**Status: done for everything that was going to move.** `quickshell/` is the
bar, the launcher, the theme picker, the volume/brightness OSD and the power
menu. `hyprland.lua` autostarts it, every bind that used to launch wofi,
wlogout or swayosd now asks it over IPC, and waybar, wofi, swayosd and wlogout
are gone from the tree along with their stylesheets. Notifications (swaync) and
the lock screen (hyprlock) stay, on purpose — see the table. CI has a step that
fails if the shell stops being autostarted or a bind names an IPC target that
no QML file declares.

## Why

Five programs, five config languages, five theming mechanisms: waybar (JSONC +
GTK CSS), wofi (CSS), swaync (JSON + CSS), swayosd (CSS), wlogout (a JSON object
stream + CSS). Every one of them was skinned separately in every theme, which is
why a theme was eighteen files and a new color was eighteen edits.

One QML shell collapses that to one language, one config file, and one palette —
and QML can express things GTK CSS on a layer-shell surface cannot (the outer
`box-shadow` ban the old stylesheets carried existed because of exactly that
limit; the glow is now a real drop shadow that spills past its item).

## What had to exist first

| | |
|---|---|
| `themes/<name>/palette.json` | Color was only ever hex literals inside CSS, Lua, TOML and YAML. QML can read none of those. |
| `quickshell/settings.json` | Bar geometry, module list and intervals were baked into `waybar/config.jsonc`; the power menu's buttons into `wlogout/layout`. |
| `schema/` | So both files have completion and validation rather than being folklore. |

The twelve roles in `palette.json` were not invented — they are the
`@define-color` block that sat at the top of every theme's `waybar/style.css`,
which both themes had independently converged on. The per-surface blocks
(`effects`, `bar`, `launcher`, `osd`, `session`) came later, when the other
three surfaces turned out to differ between themes in *structure* — glow versus
scanlines, 14px glass versus 4px CRT — and not only in color.

## Surface by surface

| surface | was | is | Quickshell provides |
|---|---|---|---|
| bar | waybar | `quickshell/bar/` | `PanelWindow`, `Hyprland`, `Mpris`, `Pipewire`, `UPower`, `SystemTray`, `PopupWindow` (tooltips) |
| launcher | wofi | `quickshell/launcher/` | `DesktopEntries`, `HyprlandFocusGrab`, `IconImage` |
| theme picker | `scripts/theme-menu.sh` (then a mode of the launcher) | `quickshell/themes/` | `ClippingRectangle`, `HyprlandFocusGrab`, `FileView`, `Process` |
| OSD | swayosd | `quickshell/osd/` | `Pipewire` + a timed `PanelWindow`; `brightnessctl` via `Process` |
| power menu | wlogout | `quickshell/session/` | plain QML + `Quickshell.execDetached` |
| notifications | swaync | *keep* | `NotificationServer` exists, but swaync's center, DND and sliders are a lot of surface to rebuild for one fewer stylesheet |
| lock | hyprlock | *keep* | `WlSessionLock` + `Quickshell.Services.Pam` exist, but hyprlock works and a broken lock screen locks you out |
| login | SDDM (already QML) | *keep* | runs as its own user; outside this shell entirely |
| wallpaper | swww/awww | *keep* | cross-fade on theme switch is the whole point of it |
| idle | hypridle | *keep* | not a shell surface |

The bar went first: it is the surface with the most modules, so it is where the
palette and settings contracts were proven before anything depended on them.

## What switching took

Kept as a record, because each step was a place the old setup bit:

1. **Blur rules.** `^waybar$` became `^qs-hypr-bar$` (`ignore_alpha` 0.35, so
   the gaps between islands stay clear); wofi, swayosd and wlogout's three rules
   became one for `^qs-hypr-(launcher|osd|session)$` at 0.2. Every surface draws
   on a fully transparent window, which is what gives `ignore_alpha` an edge.
2. **Reserve space.** The bar dropped its `exclusiveZone: 0` and lets Quickshell
   derive the strip from its anchors and margins — the same 36 + 8 px waybar
   reserved.
3. **Autostart.** One `qs -p … -d -n` in `hyprland.start`. `-n` refuses a second
   copy, so a config reload does not stack shells.
4. **Binds.** `SUPER+R`, `SUPER+T` and `SUPER+ESCAPE` call `launcher toggle`,
   `themes toggle` and `session toggle`. The F-keys call the `osd` target with
   a `|| wpctl …` / `|| brightnessctl …` fallback, so a keypress still lands
   when the shell is down — same action, silent.
5. **Theme switch.** `theme-apply.sh` lost the whole kill-waybar / wait / reap
   cava / `sleep 0.9` / relaunch choreography — the most delicate sequencing in
   the repo — and the swayosd restart and wlogout symlinks with it. It ends with
   one `qs ipc … call theme reload`, needed because the shell's file watchers
   follow the inode `current` resolved to at startup, not the symlink.
6. **CI.** The "nothing may autostart the scaffold" guard inverted into "the
   shell is autostarted and every IPC function the binds name is declared".
   The waybar/wofi/wlogout/swayosd CSS and JSON checks went with the files;
   qmllint now covers `launcher/`, `osd/`, `session/` and `themes/`.
7. **Delete.** `waybar/`, `wlogout/`, `scripts/theme-menu.sh`, and every theme's
   `waybar/`, `wofi/`, `wlogout/` and `swayosd/` directory. The stylesheets were
   the spec the QML was matched against, rule by rule; the matching is cited
   inline in each QML file, and the originals are in git history.

## Known gaps

What is still open, as opposed to deliberately kept:

- **Notifications are swaync.** The one surface still skinned by CSS
  (`themes/<name>/swaync/style.css`) and still symlinked by `theme-apply.sh`.
- **The lock screen is hyprlock.** Its `hyprlock.conf` template is still
  rendered per theme.
- **OSD brightness drops a press that lands while the previous `brightnessctl`
  is still running** (a few ms). Marked `ponytail:` in `quickshell/osd/Osd.qml`;
  queue the deltas if key-repeat ever shows it.

Closed since the scaffold: tooltips are drawn (a `PopupWindow` per hovered
chip, via `LazyLoader`), and tray menus open natively through
`SystemTrayItem.display()`.

## Reference

The scripts in `scripts/waybar-*.sh` are **not** waybar-specific despite the
name. They emit one line of JSON (`wb_emit`, in `scripts/waybar-lib.sh`) that
`ScriptChip.qml` consumes, and they survived the migration untouched. The name
is historical: waybar is gone and the shell is their only reader now. A rename
would touch every module that names one and buy nothing.

---

[← docs index](README.md) · [repo root](../README.md)
