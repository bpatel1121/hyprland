# The mercury theme

Liquid metal on true black — the **purely black and white** dark theme, with
no upstream palette and no hue: every role is a grey lifted from the
wallpaper itself, a render of a liquid-metal figure, head and shoulders,
centre-right, on pure black with faint white specks (the black, the metal's
shadow side, its mid tone, the specular whites). That is the whole rule, and
it is manga's rule mirrored for a dark ground: where manga is ink on paper,
mercury is **chrome on black**, and like manga it has **nothing** else — not
even for state. **Chrome** (`#dedede`, the specular edge) is the frame — the
islands' rim, the window border, the notification edge, btop's boxes, the
OSD pill, the lock input's ring — the brightest line the desktop draws;
brushed **silver** one weight under it (`#b4b4b4`) is every readout on the
bar and the clock; the metal's lit **mid tone** (`#9a9a9a`) is the launcher,
the one surface that covers the bar, and its selected row, a focused input,
a hovered button, a selected row in a file dialog. State keeps its meanings
but is told by *weight*, not hue — and because the ground is dark, the ramp
runs the other way from manga's: `warn` (pending updates, do-not-disturb) is
a step *brighter* than the readout, `ok` (a charging battery, a Spotify
title) a step quieter than the launcher, and `urgent` is pure white, the
only thing brighter than the frame — metal heating white. A pending count
reads as a brighter figure than the clock, a low battery as the whitest
thing on the bar, and the alert itself is the **pulse** `Chip.qml` draws,
not a color. `readoutBright` is the highlight, pure white too, so the active
workspace is an emissive **white lozenge** with its digit in `ground`, the
one specular point on the bar; the lozenge and the alert share a hex on
purpose, and what tells them apart is the pulse. The ground is **true
black**: the panel is an OLED, a black pixel is off, and the metal's shadow
side (`#101010`) is the first lit surface above it. `dim`/`dormant` are the
tarnish and the pewter for quiet type and empty workspaces; on true black
the quiet greys read brighter than they would on any other dark ground, so
neither needed printing up (`dim` is 3.5:1 on `surface` as the brief gave
it), and the risk runs the other way — the state greys are kept at least a
weight apart (readout 9.2 → warn 11.4 → urgent 19.0 on `surface`).

Measured (WCAG) on `surface`, on the bar island composite (`#000000` at 0.70
over the top strip, which is pure black — `#000000` measured, p99 = 1 — so
the composite is `#000000`) and on the launcher window (`ground` at 0.80
over the picture's centre, the figure's head, `#262626` → `#080808`):

| role | `surface` | island | launcher |
|---|---|---|---|
| `dim` | 3.5 | 3.9 | 3.7 |
| `dormant` | 5.7 | 6.2 | 6.0 |
| `frame` | 14.1 | 15.6 | 14.9 |
| `readout` | 9.2 | 10.1 | 9.7 |
| `readoutBright` | 19.0 | 21.0 | 20.0 |
| `launcher` | 6.8 | 7.5 | 7.1 |
| `warn` | 11.4 | 12.6 | 12.0 |
| `ok` | 4.7 | 5.2 | 4.9 |
| `urgent` | 19.0 | 21.0 | 20.0 |
| `text` | 16.1 | 17.8 | 17.0 |

`ground` on `readoutBright` (the lozenge's digit) is 21:1, `ground` on
`frame` 15.6:1, the launcher's selected row (`launcher` on its own 18% tint,
`#222222`) 5.7:1, and black on the mid tone (the terminal's selection, GTK's
accent print) 7.5:1.

What changes is the identity: where cyberpunk is neon glass, gruvbox a CRT,
glacier frost, harbor a still evening, verdigris candlelit stone and vesper
light on an edge, mercury is **polished metal**, and its signature is the
**chrome** (`effects.texture` `chrome`, `textureAlpha` 0.2): a white sheen
on the top half of every panel fading to nothing just above the middle, a
hard horizon, shadow deepening on the bottom half — the classic chrome
split, drawn by `Texture.qml`, the bar lit from above. 0.2 rather than the
kind's resting 0.16, because the fill is black glass over black and the
sheen has to read as light on metal, not a grey tint. There is no text glow
(`effects.glow` off): metal catches light, it does not emit. The islands
carry one thing, a **white bloom** (`bar.island.glow` 0.14 over 16px, drawn
in `frame`, which is near-white) — a chrome edge catching light; no accent
line. The islands are `ground` itself (`#000000`) at 0.70, black glass on
black: the strip the bar covers is pure black, so the fill can be well under
opaque and what shows through the blur is the specks. A 1px chrome rim at
50%, the specular edge, is the one lit line on each island. 10px corners,
and **one radius for the theme**: islands, launcher, power tiles, the lock
input, the greeter's password box, swaync's cards and the window `rounding`
all use 10, chips 7 and GTK menus 8; the OSD is a full pill, a drop of
mercury, with a chrome frame and a silver track. The launcher is black
glass at 0.8 in a 1px frame of the mid tone; the power tiles 10px with a 1px
chrome edge at 50% over a 0.8 black scrim (on an OLED most of the screen
simply goes off). The window border runs chrome → silver (`frame` →
`readout`) at 45° and it **moves**: `border_motion` 90, a slow swim —
liquid metal, faster than glacier's 140 drift, nowhere near cyberpunk's
spin. The shadow is a **white halo** (`0x40ffffff`), the chrome catching
light and pooling under each window — white is the hueless exemption CI
allows, and on true black a dark shadow would be invisible anyway. The blur
is glacier's size (10, three passes) with **no vibrancy** (there is nothing
to saturate), so the specks show through black glass as soft points of
light. The cursor is `Bibata-Modern-Ice`, a cold white pointer on black; and
the wallpaper sweep on a switch is a plain `fade` — metal does not sweep, it
reflects.

The terminal is the **one place a real hue is allowed**, as it is in manga:
the desktop is black and white, but `wezterm/colors.lua` keeps muted real
hues because `ls` and `git` are not legible without them — a diff, a
listing and a failing test say what they say by red, green, yellow and
blue, and a screen with one metal cannot carry that by weight. So the six
hue slots are muted real hues, each pulled toward grey so they read as
tinted metal and printed to ≥ 4.5:1 on `surface` (a dull red `#ad7272`, a
sage `#748c6e`, a sand `#9e8f68`, a steel blue `#728ca8`, a mauve `#9f829f`,
a grey-teal `#649494`), the brights the same hues a step lighter (≥ 6:1,
since WezTerm brightens bold text), and the hueless slots are metal weights
— black is the void, white the silver, bright black the tarnish, bright
white the type. The slot convention holds in spirit: bright magenta is the
frame (chrome), so `fastfetch`'s keys print chrome and its title steps down
to the silver in the white slot, and the cyan slot, the readout's in the
other dark themes, is the grey-teal. The background is `surface`, the
metal's shadow side, not `ground` (on an OLED `ground` is the panel switched
off, and a terminal that is a hole in the desktop has no edge against the
gaps); the cursor a chrome block with black print, the selection the mid
tone with black print, the same objects as the bar's lozenge and the
launcher's selected row. Those eleven hue literals (bright magenta is the
chrome) are the only non-role colors under `themes/mercury`: starship speaks
in slot names (metal at three weights, with the dirty dot and the failed
arrow as the terminal's two hues), and btop, cava, lazygit, swaync, GTK and
fastfetch are greys only, their ramps by weight — silver → heated → white
(`readout` → `warn` → `urgent`, `#b4b4b4` → `#c8c8c8` → `#ffffff`), a ramp
that gets brighter as it gets worse, like metal heating white, so a hot CPU
is the whitest figure on the screen and cava's wave climbs tarnish → mid
tone → chrome (`dim` → `launcher` → `frame`), pure white kept out of it
because sound level is not a state. GTK takes the mid tone for accent and
selection, manga's call mirrored: the launcher's weight on the things you
act on, with black print at 7.5:1. The editor is `tokyonight-night`: LazyVim
ships only tokyonight and catppuccin and neither has a monochrome style, so
the editor keeps the terminal's exception (code is not legible by weight
alone) on the darkest shipped ground, with the current line number wearing
the chrome block (black on `#dedede`).

The lock screen and greeter put their stack **left of centre, over pure
black** rather than centered: the figure is centre-right (x ≈ 40–75% of the
panel's 16:10 crop, the head at y ≈ 37–60%, the shoulders running off the
bottom edge), so the other dark themes' centered stack would cross the
face. At x ≈ 22% (`position = -538` in `hyprlock.conf`, `-root.width *
0.28` in `sddm/Main.qml`) and vertically centred, the stack spans x 14–30%,
clears the figure by a tenth of the screen, and every pixel under it is the
black (mean `#000000`, p99.9 = 3) — only the specks, single bright pixels,
lie there, and at `wallpaper.brightness` 0.7 with the usual 8px blur they go
to `#010101`. 0.7 rather than the night themes' 0.55 because black does not
dim — a black pixel at any brightness is still off — and what the brightness
is for is the figure's specular whites, a little, so the lock reads as the
metal under lower light rather than a greyed photo. The ratios under the
stack are therefore the ratios on black: the clock (`readout`) 10.1:1, the
date and `locked` (`dormant`) 6.2:1, the ring (`frame`) 15.6:1, the failure
line (`urgent`) 21:1. State on the ring is weight: it brightens to the
heated grey (`warn`) while the password is checked and goes white-hot on
failure. The greeter, which cannot blur, puts the same 0.3 black scrim over
the sharp picture and reads the same — the one thing the blur would have
hidden is a speck under a glyph, a single pixel — so nothing is outlined;
the power row sits straight on the black in the bottom-right corner (6.2:1
resting, 15.6:1 touched, 21:1 for white), needing no pane. One note on the
picture: the wallpaper is 4625×2600, a 16:9 frame against the panel's
16:10, so swww, hyprlock and the greeter crop ~232px of it off each side
(all of it black, none of the figure), and on a 2880×1800 panel it scales
down 1.44× — no upscale. On the desktop the figure sits under the windows
and the islands; the lock screen is where you see it.

---

[← docs index](../README.md) · [repo root](../../README.md)
