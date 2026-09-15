# QML migration

The plan for moving this desktop's shell surfaces from five separate GTK
programs to one QML shell, and where that has actually got to.

**Status: scaffold.** `quickshell/` holds a working bar. Nothing starts it,
nothing depends on it, and waybar is still the bar this desktop runs. CI has a
step that fails if that stops being true.

## Why

Five programs, five config languages, five theming mechanisms: waybar (JSONC +
GTK CSS), wofi (CSS), swaync (JSON + CSS), swayosd (CSS), wlogout (a JSON object
stream + CSS). Every one of them is skinned separately in every theme, which is
why a theme is eighteen files and a new color is eighteen edits.

One QML shell collapses that to one language, one config file, and one palette —
and QML can express things GTK CSS on a layer-shell surface cannot (the outer
`box-shadow` ban in the stylesheets exists because of exactly that limit).

## What had to exist first

| | |
|---|---|
| `themes/<name>/palette.json` | Color was only ever hex literals inside CSS, Lua, TOML and YAML. QML can read none of those. |
| `quickshell/settings.json` | Bar geometry, module list and intervals were baked into `waybar/config.jsonc`. |
| `schema/` | So both files have completion and validation rather than being folklore. |

Both are done. The twelve roles in `palette.json` were not invented — they are
the `@define-color` block already at the top of every theme's
`waybar/style.css`, which both themes had independently converged on.

## Surface by surface

| surface | today | QML replacement | Quickshell provides |
|---|---|---|---|
| bar | waybar | **`quickshell/bar/` — built** | `PanelWindow`, `Hyprland`, `Mpris`, `Pipewire`, `UPower`, `SystemTray` |
| launcher | wofi | `Launcher.qml` (not started) | `DesktopEntries`, `PopupWindow`, `HyprlandFocusGrab` |
| notifications | swaync | `Notifications.qml` (not started) | `Quickshell.Services.Notifications` (`NotificationServer`) |
| OSD | swayosd | `Osd.qml` (not started) | `Pipewire` + a timed `PanelWindow` |
| power menu | wlogout | `SessionMenu.qml` (not started) | plain QML + `Quickshell.execDetached` |
| lock | hyprlock | *keep* | `WlSessionLock` + `Quickshell.Services.Pam` exist, but hyprlock works and a broken lock screen locks you out |
| login | SDDM (already QML) | *keep* | runs as its own user; outside this shell entirely |
| wallpaper | swww/awww | *keep* | cross-fade on theme switch is the whole point of it |
| idle | hypridle | *keep* | not a shell surface |

The bar is deliberately first: it is the surface with the most modules, so it is
where the palette and settings contracts get proven before anything depends on
them.

## What switching the bar over would take

None of this is done, and none of it should be done while the shell is a
scaffold. Listed so it is a checklist rather than a rediscovery:

1. **Blur the layer.** `hyprland.lua` frosts `^waybar$`; the QML bar's namespace
   is `qs-hypr-bar`. Add a matching rule:
   ```lua
   hl.layer_rule({
       name = "qs-bar-blur",
       match = { namespace = "^qs-hypr-bar$" },
       blur = true,
       ignore_alpha = 0.35,
   })
   ```
2. **Reserve space.** The scaffold sets `exclusionMode: ExclusionMode.Ignore` and
   `exclusiveZone: 0` precisely so it cannot disturb the running desktop. A real
   bar must reserve its strip — drop both lines and let Quickshell derive the
   zone from the anchors.
3. **Autostart it.** One `hl.exec_cmd("qs -p " .. home .. "/.config/hypr/quickshell -d -n")`
   in the `hyprland.start` block, and remove waybar's launch from
   `scripts/theme-apply.sh`.
4. **Stop restarting waybar on theme switch.** `theme-apply.sh` kills and relaunches
   waybar, then waits `sleep 0.9` for the wallpaper wave. The QML shell needs
   none of it: `FileView.watchChanges` re-reads `palette.json` through the
   `current` symlink on its own. That whole choreography block, and the cava
   reaping that goes with it, can go.
5. **Delete the CI guard** in `.github/workflows/ci.yml` that asserts nothing
   autostarts the shell — it will have become false on purpose.

Steps 1–2 are what make it a real bar. Step 4 is the one that actually pays: it
removes the most delicate sequencing in the repo.

## Known gaps in the scaffold

- **Tooltips are not drawn.** `Chip.tooltip` is populated from every script's
  tooltip field but nothing renders it; that needs a `PopupWindow`.
- **Tray menus are not wired.** Right-click logs instead of opening the item's
  menu. Needs `Quickshell.DBusMenu`.
- **No per-theme QML.** A theme can currently change the bar's colors and island
  geometry through `palette.json`, but not its *structure*. Cyberpunk's glow and
  gruvbox's scanlines are stylesheet tricks with no equivalent here yet. If
  structural per-theme overrides turn out to be needed, the precedent to follow
  is waybar's: a shared default at the root, an optional per-theme file that wins.

## Reference

The scripts in `scripts/waybar-*.sh` are **not** waybar-specific despite the
name. They emit one line of JSON (`wb_emit`, in `scripts/waybar-lib.sh`) that
both waybar and `ScriptChip.qml` consume. They survive the migration untouched;
only the name is now misleading, and renaming them would break `waybar/config.jsonc`
for no gain while both bars exist.

---

[← docs index](README.md) · [repo root](../README.md)
