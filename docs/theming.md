# Theming

How the theme system works from the outside: switching between themes,
and adding one of your own.

## Switching

`SUPER+T` opens the shell's launcher in **themes mode**: one row per directory
in `themes/`, each with its wallpaper as the thumbnail and its twelve palette
roles as a swatch strip, so you see what you are about to get. Nothing applies
until Enter; Escape leaves everything as it was. Or, from a shell:

```
~/.config/hypr/scripts/theme-switch.sh cyberpunk
```

Either way it is `theme-switch.sh` that runs: repoint `themes/current`, reload
Hyprland, then `theme-apply.sh` for everything outside Hyprland. The shell is
not restarted — the script's last line is a `qs ipc … call theme reload`, and
every surface rebinds to the new palette in place. Open wezterm windows recolor
live too: theme-apply nudges wezterm.lua's mtime, which triggers WezTerm's
config reload.

## Adding a theme

Copy `themes/cyberpunk` to `themes/<name>`, swap the palette and wallpaper,
and it appears in the picker automatically. Only `theme.lua` is required —
every other file degrades gracefully if absent. A new theme inherits the shell's
behavior (bar modules, launcher grid, power-menu buttons) and the notification
layout for free, so in practice it needs a `palette.json` and a wallpaper. The
palette is the whole look of the bar, launcher, OSD and power menu: the twelve
roles plus the `effects`, `bar`, `launcher`, `osd` and `session` blocks (see
below). There is no stylesheet to write.

Behavior is not per-theme any more. Bar modules, intervals, the launcher's grid
and the power menu's buttons live once in `quickshell/settings.json`; a theme
decides how they look, not what they do.

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

`themes/<name>/palette.json` owns **color as a vocabulary**, and the look of
every surface the shell in `quickshell/` draws. It is hand-written and validated
in CI; nothing generates it.

The twelve roles are not an invention — they are the `@define-color` block that
sat at the top of every theme's old `waybar/style.css`, which both themes had
independently converged on (those stylesheets are gone from the tree; the roles
are what survived them):

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

Alongside them, the per-surface identity — the structural differences between
the two themes, which used to be scattered across four stylesheets:

| block | what it holds |
|---|---|
| `effects` | `glow` (cyberpunk's `text-shadow`, drawn by `GlowText.qml`), `glowRadius`, `scanlines` (gruvbox's CRT stripes, drawn by `Scanlines.qml`). A theme switches each on or off; no surface guesses from the colors. |
| `bar.island` / `bar.chip` | island fill, opacity, radius, frame weight and alpha, chip radius and tint; `accentLine` is cyberpunk's 2px lit hairline along the inside top edge (0 draws none) |
| `launcher` | window opacity, radius, frame weight, input and row radii, font size |
| `osd` | pill opacity, radius (999 is a full pill), frame weight, track radius |
| `session` | backdrop and tile opacity, tile radius, frame weight and resting alpha, font size |
| `font` | family and two sizes |
| `wallpaper` | `brightness`, shared by `hyprlock.conf` and the SDDM greeter so boot → login → lock read as one design |

This is where "cyberpunk glows, gruvbox scans" lives: rounded glass with a pink
hairline versus sharp 4px corners, chunky 2px frames and scanlines come from
these numbers, read through `Theme.qml`, and from nothing in the QML itself.

`schema/palette.schema.json` describes all of it; the `$schema` key at the top of
each palette gives editors completion and inline validation.

### Two rules CI enforces

- **`name` must match the directory.** A mismatch silently loads the wrong
  palette through the `current` symlink.
- **Every color `theme.lua` names must be a role in `palette.json`.** Window
  chrome sits pixel-adjacent to the bar and is not drawn by the shell, so this
  is what stops a border color and a bar frame drifting apart. A hueless shadow
  (`0x59000000`, as gruvbox uses — it has no glow by design) is exempt: absence
  of color is not a palette choice.

### What is NOT in palette.json

Everything the shell does not draw. The bar, launcher, OSD and power menu have no
stylesheet any more — `palette.json` is their only source, and a hue that is
not a role in it cannot appear on them (the QML holds no hex literal outside
`Theme.qml`'s fallbacks). The files that still carry their own hex
literals are the ones belonging to other programs: `theme.lua` (Hyprland's
borders and shadow), `gtk/gtk.css`, `swaync/style.css`, `hyprlock.conf`,
`sddm/Main.qml`, `wezterm/colors.lua`, `starship.toml`, `btop/theme.theme`,
`cava/config`, `fastfetch/config.jsonc` and `nvim.lua`. Each is hand-tuned to
its program's own quirks; generating them from the palette would mean rewriting
a dozen files for a vocabulary most of their formats cannot express. The
`theme.lua` cross-check above is the one place CI holds a literal-carrying file
to the palette, because it is the one that sits pixel-adjacent to the shell.

---

[← docs index](README.md) · [repo root](../README.md)
