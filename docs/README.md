# Docs

The long-form half of the [README](../README.md). Everything here was in that
file; it grew past the point where a reader could find anything in it.

| | |
|---|---|
| [Architecture](architecture.md) | what loads what, and the behavior-vs-identity split |
| [Theming](theming.md) | switching, adding a theme, the `theme.lua` and `palette.json` contracts |
| [The bar](bar.md) | the three islands, the watchdog chips, border motion |
| [The calendar](calendar.md) | khal + todoman, and the alert daemon |
| [Notifications & OSD](notifications.md) | swaync, swayosd |
| [Login screen](sddm.md) | the SDDM greeter, and installing it |
| [Plugins](plugins.md) | the hyprpm steps, done by hand on purpose |
| [QML migration](qml-migration.md) | the Quickshell shell: what exists, what switching would take |

## Themes

| | |
|---|---|
| [cyberpunk](themes/cyberpunk.md) | neon noir — amber and magenta on near-black |
| [gruvbox](themes/gruvbox.md) | matte CRT — orange frame, muted sky readouts |

## A note on the comments

Much of this repo's real documentation is not here — it is in the files.
`scripts/theme-apply.sh`, `scripts/waybar-cava.sh`, `waybar/config.jsonc` and
both `waybar/style.css` files carry multi-paragraph headers explaining bugs that
were fixed and must not be reintroduced (layer-shell shadow halos, the
border-motion tick rate, `RTMIN` vs `SIGRTMIN`, the reload-before-apply
ordering). Read those before changing the code they sit on.
