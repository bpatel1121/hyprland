# The verdigris theme

Candlelit stone, from a painted dark-fantasy scene — a gothic castle of
black-green stone in a mountain pass, its windows and gates lit a pale
witch-green, a stone bridge over green-lit water, a dragon in the olive sky,
the sun a pale yellow-green glow at the top centre, two gargoyles on the left
cliff — and, like harbor and glacier, no upstream palette: every role is
sampled from the picture, and `tokens` in `palette.json` names each after
what it is there (the rock, the stone, the cliff, the moss, the dragon, the
witchlight, the window, the sun). It is the first green theme — nothing else
in the set is green, murky or gothic — and the roles follow the picture's one
light: the two-tone rule, gothic edition: **witchlight** (the gates' green) is
the frame — the islands' rim, the window border, the notification edge,
btop's boxes, the lock input's ring — **bone** (the window light,
desaturated) is every readout and the clock, and the **sun**'s pale
yellow-green is the launcher, the one surface that covers the bar and the one
lit thing that is not green-white. The readouts are pale on purpose: the risk
with green is reading sickly or muddy, so the type is the window light lifted
to bone-green, never a terminal green, and nothing on the shell is warm.
`readoutBright` is the lit windows' white, so the active workspace is an
emissive **bone lozenge**. The ground is the foreground rock, the raised
surfaces the shadowed green-grey stone. State keeps its meanings in the one
hue where it can: `ok` is the witchlight **lit** (a charging bolt, cava's
rising step), so ok reads as more light rather than a foreign green, as
glacier's ok is lit ice; `warn` is the olive sky saturated a little so it
reads as a state (do-not-disturb, the prompt's dirty dot, the middle step of
btop's ramps) — the one gold thing in a green picture; and `urgent` is a dull
**ember**, the only role not in the picture, chosen for contrast on `surface`
because nothing there is red. Pending updates light up in the readout bone
like everything else. The bridge moss and the dragon are the quiet family
(`dim`, `dormant`), printed up for contrast because every surface that
carries them is stone (as painted they read 2.4:1 and 2.9:1 on `surface`).

Measured (WCAG) on `surface`, on the bar island composite (`#0f1210` at 0.82
over the olive-grey strip the bar covers, `#4e563e` → `#1a1e18`) and on the
launcher window (`ground` at 0.88 over the picture's centre, `#435341` →
`#1b1e18`):

| role | `surface` | island | launcher |
|---|---|---|---|
| `dim` | 3.6 | 4.1 | 4.1 |
| `dormant` | 5.0 | 5.6 | 5.6 |
| `frame` | 5.4 | 6.1 | 6.1 |
| `readout` | 10.4 | 11.8 | 11.8 |
| `readoutBright` | 13.2 | 15.0 | 14.9 |
| `warn` | 7.4 | 8.4 | 8.4 |
| `ok` | 9.2 | 10.4 | 10.4 |
| `urgent` | 3.9 | 4.4 | 4.4 |
| `text` | 10.7 | 12.1 | 12.1 |
| `launcher` | 11.5 | 13.1 | 13.0 |

`ground` on `readout` (the lozenge's digit) is 12.6:1, `ground` on `frame`
6.5:1, and the launcher's selected row (`launcher` on its own 18% tint) 8.0:1.

What changes is the identity: where cyberpunk is neon glass, gruvbox a CRT,
glacier frost and harbor a still evening, verdigris is **stone lit by a
candle**, and its signature is the **vignette** (`effects.texture`
`vignette`, `textureAlpha` 0.5): black closing in from the corners of every
panel, clear at the centre — stone lit from the middle, drawn by
`Texture.qml`. 0.5 rather than the kind's resting 0.35, because the fill is
dark and the vignette has to show over the olive blur. There is no text glow
(`effects.glow` off): candlelight does not bloom like neon. The islands may
carry one faint thing, a witchlight bloom (`bar.island.glow` 0.12 over 16px),
light leaking from a gate; no accent line. The islands are near-black
(`#0f1210`, a shade under `ground`) at 0.82: the strip the bar covers is the
olive sky at the top of the picture, *lighter* than most of it, so the fill
has to be dark and fairly opaque where harbor's could be a silhouette — at
18% show-through the composite lands at `#1a1e18`, `dim` 4.1:1. 6px corners,
and **one radius for the theme**: islands, launcher, OSD, power tiles, the
lock input, the greeter's password box, swaync's cards and the window
`rounding` all use 6 (a gothic arch is not a round corner; 6 keeps it from
gruvbox's 4), chips and GTK menus 4. A 1px witchlight rim at 40%. The
launcher is dark stone at 0.88 in a 1px sun frame; the OSD a slab, not a pill
(as inkwash's is), with a witchlight frame and a bone track; the power tiles
6px with a 1px witchlight edge at 45% over a 0.75 rock scrim. The window
border runs witchlight → bone (`frame` → `readout`) at 45°, the gate's light
meeting the window's, and drifts at `border_motion = 180`, the slowest in the
set — light moving along wet stone. The shadow is pure black (`0x80000000`,
the hueless exemption; range 20): this is the darkest theme and its windows
sit in deep shadow, and candlelight casts no green. The blur is moderate with
little vibrancy (size 8, three passes, 0.10), so the islands show the olive
sky as damp stone rather than glass. The cursor is `Bibata-Modern-Classic`,
the dark pointer the light themes already install, and the wallpaper sweep on
a switch is a slow `grow` from the centre — the witchlight spreading out from
the gate.

The terminal side is stone and bone with the gate's green as its one accent:
wezterm's background is `surface` rather than `ground` (the shadowed stone,
not a hole in the desktop), every normal ANSI slot clears 4.5:1 on it — the
red slot is the ember a notch up, since `urgent` as painted is 3.9:1 there —
and the slot convention holds: bright magenta is the witchlight, cyan is
bone, so `fastfetch`'s keys print witchlight and its title bone, and
already-printed output recolors correctly on `SUPER+T`. The four ANSI hues
the picture does not have — red, yellow, blue, magenta — are chosen to sit
with the olive: the ember, the olive sky (`warn`), a slate blue, a dusty
heather; each is named and measured in `wezterm/colors.lua`. GTK takes the
witchlight for both accent and selection — the sun belongs to the launcher
alone, and a yellow highlight in every file dialog would be the one warm
thing on a desktop that has none. The editor is `tokyonight-night`, which
LazyVim already ships (it ships no green scheme), with the current line
number wearing the frame (rock on witchlight). btop's ramps climb bone →
witchlight lit or olive gold → ember, so a hot CPU still reads as an alarm;
cava does not: its gradient climbs bone → lit witchlight → witchlight
(`readout` → `ok` → `frame`), light rising rather than an alert, as
glacier's does.

The lock screen and greeter put their stack on the **left third, over the
cliff** rather than centered: the castle fills the right half of the picture
(x ≈ 55–85%), the dragon is top-centre-right, the gargoyles top-left, and the
bridge and the lit water are bottom-centre, so the other dark themes'
centered clock would cross the gate's light. At x ≈ 20% (`position = -570`
in `hyprlock.conf`, `-root.width * 0.3` in `sddm/Main.qml`), vertically
centred, the whole stack sits over the dark cliff face, where nothing is lit:
measured over the dimmed, blurred picture, the clock (`readout`) holds
12.7:1 everywhere in its box, the date (`dormant`) 6.0:1, `locked` 5.9:1,
the ring (`frame`) 5.9:1 and the failure line (`urgent`) 4.2:1 — the
brightest pixel under the stack is darker than `surface`. The greeter, which
cannot blur, needs neither harbor's date outline (dormant holds 5.0:1 on the
sharp rock) nor its power-row pane (that corner is the foreground rock, the
darkest thing in the picture: 5.7:1 resting, 4.4:1 for red); it outlines
only the failure line, the one role that dips to 3.4:1 unblurred. Both keep
the `1 - brightness` scrim at `wallpaper.brightness` 0.55 with an 8px blur,
the dark themes' resting numbers: the picture is already night. One note on
the picture: the wallpaper is 4096×2389, almost the panel's 16:10, so swww,
hyprlock and the greeter crop only ~137px off each side and lose nothing;
on a 2880×1800 panel it scales down 1.42×. On the desktop the castle sits
under the windows and the islands; the lock screen is where you see it.

---

[← docs index](../README.md) · [repo root](../../README.md)
