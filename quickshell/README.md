# quickshell/ — the QML shell (scaffold)

A Quickshell bar that mirrors the waybar this desktop runs today. It is a
**scaffold**: nothing starts it, and running it changes nothing permanent.

```
qs -p ~/.config/hypr/quickshell          # run it, Ctrl-C to stop
qs -p ~/.config/hypr/quickshell -d -n    # daemonize, single instance
pkill -x quickshell                      # stop a daemonized one
```

> `pkill -f 'qs -p'` also matches the shell you typed it in. Use `pkill -x quickshell`.

Waybar stays the autostarted bar and is untouched. This shell uses its own
layer-shell namespace (`qs-hypr-bar`) and claims **no** exclusive zone, so it
reserves no screen space and cannot shift a window or disturb waybar's reserved
strip — both can be on screen at once. Because it copies waybar's geometry it
will land directly on top of it, so to actually look at it, stop waybar first
(`pkill -x waybar`; `scripts/theme-apply.sh` brings it back).

## What reads what

```
settings.json              BEHAVIOR  — which modules, where, how often
themes/current/palette.json IDENTITY — color, fonts, island geometry
```

Same behavior-vs-identity split the rest of the repo uses. Both are watched:
edit either one while the shell is running and it re-applies without a restart.

```
shell.qml               ShellRoot; one Bar per screen via Variants
config/
  Paths.qml             repo root + scripts dir, derived from Quickshell.shellDir
  Theme.qml             themes/current/palette.json -> color roles
  Config.qml            settings.json -> bar layout, intervals, toggles
  qmldir                explicit, so the singletons resolve (see below)
bar/
  Bar.qml               PanelWindow, three islands, namespace + zero exclusive zone
  Island.qml            one island: fill, radius and hairline from the palette
  ModuleLoader.qml      "agenda" -> ../modules/Agenda.qml
components/
  Chip.qml              the one repeated shape: glyph + label + state color
  ScriptChip.qml        runs a waybar-*.sh emitter, parses its JSON line
modules/                one file per module, named after its settings key
```

## Module map

Nothing here is invented; each module is backed by a real source.

| module | backed by |
|---|---|
| `workspaces` | `Hyprland.workspaces` |
| `clock` | `SystemClock` |
| `media` | `Mpris.players` |
| `volume` | `Pipewire.defaultAudioSink` |
| `battery` | `UPower.displayDevice` |
| `tray` | `SystemTray.items` |
| `network` | `Networking.devices` |
| `bluetooth` | `Bluetooth.defaultAdapter` |
| `temperature` | `/sys/class/hwmon/*`, resolved by name |
| `agenda`, `todos`, `updates`, `aur`, `cava` | **the existing `scripts/waybar-*.sh`, unchanged** |
| `dnd` | `swaync-client -swb` |
| `launcher`, `power` | the same commands waybar's `on-click` uses |

### The reuse seam

`scripts/waybar-lib.sh` defines `wb_emit`, which prints one line of JSON per
update — `{"text":"…","class":"…","tooltip":"…"}`. `ScriptChip` consumes exactly
that with `Process` + `SplitParser`, so five chips work here with **zero changes
to the scripts**. The khal parsing, the `checkupdates` retry logic, the JSON
escaping and the cava framing all stay in one place, still used by waybar, still
covered by shellcheck in CI.

`class` is the whole styling protocol. The scripts already emit `pending`,
`overdue`, `zero`, `idle`, `quiet`, `live`, and `Theme.classColor()` maps those
onto palette roles.

## Two things that will bite you

**The color singleton is called `Theme`, not `Palette`.** QtQuick exports its own
`Palette` type (`QQuickPalette`) from 6.0 on, and any file importing QtQuick
resolves the bare name to *that*. The symptom is not an import error — it is
every color silently reading as undefined.

**`config/qmldir` and `components/qmldir` are explicit on purpose.** Quickshell
synthesizes a qmldir for directories that lack one, and the synthesized version
did not register the plain (non-singleton) components — every module failed with
`Chip is not a type`. Declaring them by hand fixes that and also satisfies
qmllint.

## Checking it

```
qmllint -I /usr/lib/qt6/qml -I quickshell \
  --uncreatable-type disable --unresolved-type disable \
  quickshell/shell.qml quickshell/{config,bar,components,modules}/*.qml
```

Those two categories are off because qmllint cannot see through Quickshell's
C++-declared types (`PanelWindow` reads as uncreatable, `BluetoothAdapter` as
unresolved); both work at runtime. Everything else, including the `unqualified`
category that catches real delegate-scope bugs, stays on. CI runs this.

## Not done yet

Deliberate gaps, not oversights:

- **Tooltips.** `Chip.tooltip` is plumbed through and populated from every
  script's tooltip field, but nothing draws it — that needs a `PopupWindow`.
- **Tray menus.** Right-clicking a tray item logs instead of opening its menu;
  wiring `SystemTrayItem.menu` needs `Quickshell.DBusMenu`.
- **The other surfaces.** Launcher, notifications, OSD and power menu are still
  wofi / swaync / swayosd / wlogout. Quickshell ships the services for all four
  (`NotificationServer`, `Polkit`, `WlSessionLock`); see `docs/qml-migration.md`.
