# Docs

The long-form half of the [README](../README.md). Everything here was in that
file; it grew past the point where a reader could find anything in it.

| | |
|---|---|
| [Architecture](architecture.md) | what loads what, and the behavior-vs-identity split |
| [Theming](theming.md) | switching, adding a theme, the `theme.lua` and `palette.json` contracts |
| [The bar](bar.md) | the three islands, the watchdog chips, border motion |
| [The calendar](calendar.md) | khal + todoman, and the alert daemon |
| [Notifications & OSD](notifications.md) | swaync; the OSD is the shell's |
| [Login screen](sddm.md) | the SDDM greeter, and installing it |
| [Plugins](plugins.md) | the hyprpm steps, done by hand on purpose |
| [QML migration](qml-migration.md) | the Quickshell shell: what was moved, what deliberately was not |

## Themes

| | |
|---|---|
| [cyberpunk](themes/cyberpunk.md) | neon noir — amber and magenta on near-black |
| [gruvbox](themes/gruvbox.md) | matte CRT — orange frame, muted sky readouts |
| [glacier](themes/glacier.md) | frost — ice-cyan frame, white readouts, pale-cyan launcher, the painting showing through every surface |
| [harbor](themes/harbor.md) | dusk over water — amber readouts on teal, smoke-cyan launcher, lamplight rising from the foot of every panel |
| [verdigris](themes/verdigris.md) | candlelit stone — bone readouts in a witchlight frame on black-green stone, a pale sun for the launcher, every panel vignetted from its corners |
| [vesper](themes/vesper.md) | rim light on cobalt — peach readouts in a red-orange frame on a cobalt sky, the rim's lit skin for the launcher, light catching the right edge of every panel |
| [mercury](themes/mercury.md) | black and white, dark — liquid metal on true black: silver readouts in a chrome frame, state by weight, the chrome split on every panel |
| [manga](themes/manga.md) | black and white, light — ink line art on a printed page: ink readouts in an ink frame, state by weight, screentone on every panel |
| [graphite](themes/graphite.md) | light · grey ink on paper — ink frame, one violet for readouts and the launcher |
| [inkwash](themes/inkwash.md) | light · ink-wash painting on paper — gold filigree frame, olive-ink readouts, cyan burst launcher |

## A note on the comments

Much of this repo's real documentation is not here — it is in the files.
`scripts/theme-apply.sh`, `scripts/waybar-cava.sh`, `quickshell/config/Theme.qml`
and the headers of every file under `quickshell/` explain bugs that were fixed
and must not be reintroduced (the `Theme`-not-`Palette` name, the explicit
`qmldir`s, the border-motion tick rate, the reload-before-apply ordering, and
which old CSS rule each pixel value came from). Read those before changing the
code they sit on. The old `waybar/style.css` headers, with their layer-shell
shadow-halo warnings, are gone from the tree and live only in git history.
