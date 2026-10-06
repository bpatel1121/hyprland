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
(omit it for a still border), `dim_strength = <0..1>` dims unfocused windows
so focus reads at a glance, `transition = "<swww type and flags>"` is the
wallpaper sweep a switch *to* this theme makes (`"wipe --transition-angle 45
--transition-duration 1.2"`; everything after the type passes through to
swww, so a theme can be a wave, a wipe, a grow or a plain dissolve), and
`tab_text` / `tab_text_inactive` are the groupbar's title colors when windows
are grouped (SUPER+G); the group border itself reuses `active_border`.

Themes are **dark by default**. A light theme declares itself with one line in
`theme.lua`:

```
polarity = "light",
```

theme-apply.sh reads that and flips the whole desktop's polarity in one go:
`prefer-light`, `adw-gtk3` instead of `-dark`, `Papirus-Light` — and because
Firefox and most websites honor `prefers-color-scheme`, the browser follows
without being told. [graphite](themes/graphite.md), the light monochrome
theme, is the worked example of what else a light palette has to think about:
a near-opaque island fill (a wallpaper frosted through a light fill goes
muddy), `wallpaper.brightness` near 1 so the lock screen and greeter don't dim
a light picture into slate, a frame that is *ink* rather than a hue (a 1px
near-black rim reads as a drawn line on paper where a colored one reads as a
sticker), and terminal-side files whose ANSI table is built for ≥ 4.5:1 on
near-white — the state colors printed down to ink weight, because a brass
that reads as a dot on the bar is unreadable as text on paper.

## The palette contract

`themes/<name>/theme.lua` owns **window chrome** — gaps, border size and colors,
rounding, blur, shadow. Hyprland reads it directly, and `scripts/theme-lib.sh`
scrapes a few scalars out of it with `sed`.

`themes/<name>/palette.json` owns **color as a vocabulary**, and the look of
every surface the shell in `quickshell/` draws. It is hand-written and validated
in CI; nothing generates it.

The twelve roles are not an invention — they are the `@define-color` block that
sat at the top of every theme's old `waybar/style.css`, which both dark themes
had independently converged on (those stylesheets are gone from the tree; the
roles are what survived them). Graphite, the light monochrome one, was written
straight into the vocabulary:

| role | what it is | cyberpunk | gruvbox | glacier | harbor | graphite | inkwash |
|---|---|---|---|---|---|---|---|
| `ground` | the desktop floor | `#030408` | `#1d2021` | `#0b1838` | `#0e1a20` | `#e9e4e8` | `#ebe9e5` |
| `surface` | raised panels, popovers, inputs | `#0A0E1A` | `#282828` | `#15295a` | `#172730` | `#f6f3f5` | `#f6f5f2` |
| `hairline` | separators, unfocused borders | `#212638` | `#3c3836` | `#223b6e` | `#243a44` | `#cfc8cf` | `#d6d3cb` |
| `dim` | de-emphasised text and glyphs | `#4D5A80` | `#665c54` | `#51578c` | `#4f7a84` | `#8f8181` | `#8a8a7a` |
| `frame` | **the identity color** | `#F230B2` | `#fe8019` | `#5bd7fa` | `#e0ab5a` | `#2b2427` | `#c89a3e` |
| `readout` | every telemetry value | `#29BECC` | `#83a598` | `#e8f4ff` | `#f6c870` | `#8a4f96` | `#3f4d2a` |
| `warn` | do-not-disturb; the warning step in the terminal-side ramps | `#F2D230` | `#fabd2f` | `#c3b1f0` | `#f27c35` | `#c0862a` | `#b8641e` |
| `ok` | a charging battery | `#30F291` | `#98971a` | `#8de6ff` | `#7dd3a6` | `#4f8a5a` | `#6f9a3a` |
| `urgent` | low battery, overdue, offline | `#F24848` | `#fb4934` | `#ff6b81` | `#eb4030` | `#c4475c` | `#c0392b` |
| `dormant` | empty workspaces, zeroed counters | `#898D99` | `#928374` | `#7f8fbf` | `#62939f` | `#877c82` | `#7d7d74` |
| `text` | default foreground | `#C8D0E0` | `#ebdbb2` | `#e6eefc` | `#efe6d3` | `#1d1719` | `#1c1b14` |
| `launcher` | the one hue the bar never uses | `#A130F2` | `#d3869b` | `#b6ecf9` | `#82e0fa` | `#92589e` | `#286884` |

Alongside them, the per-surface identity — the structural differences between
the themes, which used to be scattered across four stylesheets:

| block | what it holds |
|---|---|
| `effects` | `glow` (cyberpunk's `text-shadow`, drawn by `GlowText.qml`), `glowRadius`, and `texture` — the overlay every panel fill carries, drawn by `Texture.qml` and clipped to the panel's corners: `scanlines` (gruvbox), `hatch` (graphite's pencil lines), `grain` (inkwash's paper speckle), `sheen` (glacier's light on ice), `horizon` (harbor's lamplight from the bottom edge) or `none` (cyberpunk, whose glow is the signature). `textureAlpha` overrides a kind's resting strength. A theme declares these; no surface guesses from the colors. |
| `bar.island` / `bar.chip` | island fill, opacity, radius, frame weight and alpha, chip radius and tint; `accentLine` is cyberpunk's 2px lit hairline along the inside top edge (0 draws none) |
| `launcher` | window opacity, radius, frame weight, input and row radii, font size |
| `osd` | pill opacity, radius (999 is a full pill), frame weight, track radius |
| `session` | backdrop and tile opacity, tile radius, frame weight and resting alpha, font size |
| `font` | family and two sizes |
| `wallpaper` | `brightness`, shared by `hyprlock.conf` and the SDDM greeter so boot → login → lock read as one design |

This is where "cyberpunk glows, gruvbox scans, graphite hatches" lives:
rounded glass with a pink bloom, versus sharp 4px corners, chunky 2px frames
and scanlines, versus near-opaque paper with a 1px ink rim and pencil
hatching, all come from these numbers, read through `Theme.qml`, and from
nothing in the QML itself. Every theme has exactly one panel texture or
glow as its signature, so a panel is recognizably its theme's even with the
colors covered.

[glacier](themes/glacier.md) frosts: the same numbers pushed the other way —
islands at 0.55 and the launcher at 0.62 over the repo's heaviest blur, 1px
ice-cyan hairlines at low alpha, a quiet cyan `glow` (the one glow theme
besides cyberpunk) and `readoutBright` declared so the active workspace is a
white → ice lozenge, with a white `sheen` from the top edge of every pane.
Frost is low opacity plus blur, not a color.

[harbor](themes/harbor.md) is dusk over water: a teal-black fill under a teal
sky, amber as both the frame and the readout, the smoke's cyan kept for the
launcher, and the `horizon` texture — lamplight in `frame` rising from the
bottom edge of every panel — with the window border turned to 90° so sky
sits over ground on every window.

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
