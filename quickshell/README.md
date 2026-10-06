# quickshell/ — the shell

One Quickshell process that is this desktop's bar, launcher, theme picker,
volume/brightness OSD and power menu. `hyprland.lua` starts it at login; the
binds and the bar's own chips drive it over IPC.

```
qs -p ~/.config/hypr/quickshell -d -n    # what hyprland.lua runs: daemonize, single instance
qs -p ~/.config/hypr/quickshell          # run it in the foreground instead, Ctrl-C to stop
pkill -x quickshell                      # stop a daemonized one; the first line (or `hyprctl reload`) brings it back
```

> `pkill -f 'qs -p'` also matches the shell you typed it in. Use `pkill -x quickshell`.

It owns five layer-shell namespaces — `qs-hypr-bar`, `qs-hypr-launcher`,
`qs-hypr-osd`, `qs-hypr-session`, `qs-hypr-themes` — and `hyprland.lua` blurs
each by name. The bar reserves its strip (height plus top margin); the other
four reserve nothing and exist only while shown.

## What reads what

```
settings.json               BEHAVIOR  — which modules, where, how often; surface settings; power-menu buttons
themes/current/palette.json IDENTITY — color roles, fonts, and the look of every surface
```

Same behavior-vs-identity split the rest of the repo uses. Both are watched:
edit either one while the shell is running and it re-applies without a restart.
A theme *switch* is the one change the watchers cannot see (they follow the
inode `current` resolved to, not the symlink), so `theme-apply.sh` ends with
`qs ipc … call theme reload`.

```
shell.qml               ShellRoot; one Bar per screen via Variants, then Launcher, Osd, SessionMenu, ThemePicker, Flash; the `theme` IPC target
config/
  Paths.qml             repo root + scripts dir, derived from Quickshell.shellDir
  Theme.qml             themes/current/palette.json -> color roles, effects, per-surface geometry
  Config.qml            settings.json -> bar layout, intervals, toggles, Config.surface()
  qmldir                explicit, so the singletons resolve (see below)
bar/
  Bar.qml               PanelWindow, three islands, reserves its strip
  Island.qml            one island: fill, radius, hairline, scanlines, accent line — all from the palette
  ModuleLoader.qml      "agenda" -> ../modules/Agenda.qml
launcher/
  Launcher.qml          the drun grid: frecent card when empty, wofi's two columns when typed
osd/
  Osd.qml               the volume/brightness pill, on the focused monitor
session/
  SessionMenu.qml       the power menu: one dimmed surface per monitor, tiles on the focused one
themes/
  ThemePicker.qml       the theme picker: full screen, a wallpaper carousel with each palette under it, search at the bottom
fx/
  Flash.qml             the screenshot flash: one full-screen sheet per monitor, snaps to 0.55 and fades in 180ms
components/
  Chip.qml              the one repeated shape: glyph + label + state color + hover + tooltip
  ScriptChip.qml        runs a waybar-*.sh emitter, parses its JSON line
  GlowText.qml          Text with the theme's text-shadow glow; a plain Text when Theme.glow is off
  Texture.qml           the theme's panel texture (scanlines, hatch, grain, sheen, horizon), clipped to a rounded rect; paints nothing when off
modules/                one file per bar module, named after its settings key
```

## IPC

```
qs ipc -p ~/.config/hypr/quickshell call <target> <function> [args]
```

| target | functions | who calls it |
|---|---|---|
| `launcher` | `toggle`, `open`, `close` | `SUPER+R` (`toggle`), the Arch chip |
| `session` | `toggle`, `open`, `close` | `SUPER+ESCAPE`, the power chip |
| `themes` | `toggle`, `open`, `close` | `SUPER+T` |
| `fx` | `flash` | the screenshot binds, right after grim has read the pixels |
| `osd` | `volumeRaise`, `volumeLower`, `volumeMute`, `brightnessRaise`, `brightnessLower`, `display <volume\|brightness>` | `SUPER+F1..F3`, `SUPER+F5/F6` |
| `theme` | `reload` | `scripts/theme-apply.sh`, last line |

The F-key binds wrap the `osd` call in `|| wpctl …` / `|| brightnessctl …`, so
a press still lands when the shell is down. CI greps `hyprland.lua` for every
`qs("target", "fn")` and `osd("fn", …)` and fails if no QML file declares that
function.

## Module map

Nothing here is invented; each module is backed by a real source.

| module | backed by |
|---|---|
| `workspaces` | `Hyprland.workspaces` |
| `clock` | `SystemClock` |
| `media` | `Mpris.players` |
| `volume` | `Pipewire.defaultAudioSink` |
| `battery` | `UPower.displayDevice` |
| `tray` | `SystemTray.items`; right-click opens the native menu via `SystemTrayItem.display()` |
| `network` | `Networking.devices` |
| `bluetooth` | `Bluetooth.defaultAdapter` |
| `temperature` | `/sys/class/hwmon/*`, resolved by name |
| `agenda`, `todos`, `updates`, `aur`, `cava` | **the existing `scripts/waybar-*.sh`, unchanged** |
| `dnd` | `swaync-client -swb` |
| `launcher`, `power` | `qs ipc … call launcher toggle` / `session toggle` — the same door the binds use |

Every chip's tooltip is drawn: a `PopupWindow` under the hovered chip, created
by `LazyLoader` only while it is hovered (one window per chip would be a window
each).

### The reuse seam

`scripts/waybar-lib.sh` defines `wb_emit`, which prints one line of JSON per
update — `{"text":"…","class":"…","tooltip":"…"}`. `ScriptChip` consumes exactly
that with `Process` + `SplitParser`, so five chips work here with **zero changes
to the scripts**. The khal parsing, the `checkupdates` retry logic, the JSON
escaping and the cava framing all stay in one place, still covered by shellcheck
in CI. The `waybar-` prefix is historical; the shell is their only reader now.

`class` is the whole styling protocol. The scripts already emit `pending`,
`overdue`, `zero`, `idle`, `quiet`, `live`, and `Theme.classColor()` maps those
onto palette roles.

Where waybar refreshed a counter with `pkill -RTMIN+8 waybar`, `ScriptChip.refresh()`
re-runs the emitter: the Updates and AUR chips call it when the upgrade terminal
they opened exits.

## Two things that will bite you

**The color singleton is called `Theme`, not `Palette`.** QtQuick exports its own
`Palette` type (`QQuickPalette`) from 6.0 on, and any file importing QtQuick
resolves the bare name to *that*. The symptom is not an import error — it is
every color silently reading as undefined.

**`config/qmldir` and `components/qmldir` are explicit on purpose.** Quickshell
synthesizes a qmldir for directories that lack one, and the synthesized version
did not register the plain (non-singleton) components — every module failed with
`Chip is not a type`. Declaring them by hand fixes that and also satisfies
qmllint. (`launcher/`, `osd/`, `session/` and `themes/` need none: `shell.qml`
imports each directory and names its one type.)

## Checking it

```
qmllint -I /usr/lib/qt6/qml -I quickshell \
  --uncreatable-type disable --unresolved-type disable \
  quickshell/shell.qml quickshell/{config,bar,components,modules,launcher,osd,session,themes,fx}/*.qml
```

Those two categories are off because qmllint cannot see through Quickshell's
C++-declared types (`PanelWindow` reads as uncreatable, `BluetoothAdapter` as
unresolved); both work at runtime. Everything else, including the `unqualified`
category that catches real delegate-scope bugs, stays on. CI runs this.

## Not done yet

- **Notifications** are still swaync, and the **lock screen** is still hyprlock.
  Both on purpose — see `docs/qml-migration.md`.
- **OSD brightness** drops a press that lands while the previous `brightnessctl`
  is still running (a few ms). Marked `ponytail:` in `osd/Osd.qml`; queue the
  deltas if key-repeat ever shows it.
