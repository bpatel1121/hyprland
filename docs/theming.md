# Theming

How the theme system works from the outside: switching between themes,
and adding one of your own.

## Switching

`SUPER+T` for the wofi picker, or:

```
~/.config/hypr/scripts/theme-switch.sh cyberpunk
```

Open wezterm windows recolor live: theme-apply nudges wezterm.lua's mtime,
which triggers WezTerm's config reload.

## Adding a theme

Copy `themes/cyberpunk` to `themes/<name>`, swap the palette and wallpaper,
and it appears in the picker automatically. Only `theme.lua` is required —
every other file degrades gracefully if absent. A new theme inherits the shared
bar behavior, power-menu layout, and notification layout for free, so in
practice it needs a palette, a wallpaper, and a `waybar/style.css`.

To change bar *behavior* for one theme only, restate the key in that theme's
`waybar/config.jsonc`. The merge is per top-level key rather than deep, so
overriding one workspace glyph means restating the whole `hyprland/workspaces`
object — each theme's overlay ships that as a commented-out example.

Beyond the visual table, `theme.lua` takes optional identity keys:
`border_motion = <deciseconds/revolution>` runs the border gradient in motion
(omit it for a still border), and `dim_strength = <0..1>` dims unfocused
windows so focus reads at a glance.

Themes are **dark by default**. A light theme declares itself with one line in
`theme.lua`:

```
polarity = "light",
```

theme-apply.sh reads that and flips the whole desktop's polarity in one go:
`prefer-light`, `adw-gtk3` instead of `-dark`, `Papirus-Light` — and because
Firefox and most websites honor `prefers-color-scheme`, the browser follows
without being told. (No light theme ships right now — the machinery is here
for whenever one does.)

## The palette contract

`themes/<name>/theme.lua` owns **window chrome** — gaps, border size and colors,
rounding, blur, shadow. Hyprland reads it directly, and `scripts/theme-lib.sh`
scrapes a few scalars out of it with `sed`.

`themes/<name>/palette.json` owns **color as a vocabulary**, and is what the QML
shell in `quickshell/` reads. It is hand-written and validated in CI; nothing
generates it.

The twelve roles are not an invention — they are the `@define-color` block that
was already at the top of every theme's `waybar/style.css`, which both themes had
independently converged on:

| role | what it is | cyberpunk | gruvbox |
|---|---|---|---|
| `ground` | the desktop floor | `#030408` | `#1d2021` |
| `surface` | raised panels, popovers, inputs | `#0A0E1A` | `#282828` |
| `hairline` | separators, unfocused borders | `#212638` | `#3c3836` |
| `dim` | de-emphasised text and glyphs | `#4D5A80` | `#665c54` |
| `frame` | **the identity color** | `#F230B2` | `#fe8019` |
| `readout` | every telemetry value | `#29BECC` | `#83a598` |
| `warn` | pending repo updates | `#F2D230` | `#fabd2f` |
| `ok` | AUR pending, charging | `#30F291` | `#98971a` |
| `urgent` | low battery, overdue, offline | `#F24848` | `#fb4934` |
| `dormant` | empty workspaces, zeroed counters | `#898D99` | `#928374` |
| `text` | default foreground | `#C8D0E0` | `#ebdbb2` |
| `launcher` | the one hue the bar never uses | `#A130F2` | `#d3869b` |

Alongside them: `font` (family and two sizes), `bar.island` / `bar.chip` (the
geometry that makes cyberpunk rounded glass and gruvbox a sharp CRT panel), and
`wallpaper.brightness`, shared by `hyprlock.conf` and the SDDM greeter so boot →
login → lock read as one design.

`schema/palette.schema.json` describes all of it; the `$schema` key at the top of
each palette gives editors completion and inline validation.

### Two rules CI enforces

- **`name` must match the directory.** A mismatch silently loads the wrong
  palette through the `current` symlink.
- **Every color `theme.lua` names must be a role in `palette.json`.** This is the
  only thing stopping the two files drifting, since the stylesheets still carry
  their own literals. A hueless shadow (`0x59000000`, as gruvbox uses — it has no
  glow by design) is exempt: absence of color is not a palette choice.

### What is NOT in palette.json

The stylesheets. `waybar/style.css`, `wofi/style.css`, `gtk/gtk.css` and the rest
still hold their own hex literals, and are still the files you edit to change how
waybar looks. Generating them from the palette would mean rewriting three dozen
hand-tuned files whose comments document real layer-shell rendering bugs. The
palette is the source of truth for the *QML* shell today, and the CI cross-check
is what keeps it honest about the rest.

---

[← docs index](README.md) · [repo root](../README.md)
