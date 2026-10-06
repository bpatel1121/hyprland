# The vesper theme

Rim light on cobalt, from a painted dusk — a girl in a black uniform floating
above a cloud sea, seen from behind, lit from behind by a sun below the
horizon so every edge of her burns red-orange; a cobalt sky above, peach and
rose at the horizon, blue-grey fog below — and, like harbor and verdigris, no
upstream palette: every role is sampled from the picture, and `tokens` in
`palette.json` names each after what it is there (the night, the cobalt, the
sky, the fog, the rim, the horizon, the highlight). It is the second dusk
after harbor, and the roles follow the picture's one light — the two-tone
rule, dusk edition two: **rim red** is the frame — the islands' rim, the
window border, the notification edge, btop's boxes, the lock input's ring —
**peach** (the horizon) is every readout and the clock, and the **lit skin of
the rim** (the glow on her legs and skirt, the rim's shadow side) is the
launcher, the one surface that covers the bar. The rim is softened one step
from the picture's pure `#ff2f1f` so a 1px edge is not searing; that
red-orange is the identity. `readoutBright` is the rim's yellow highlight, so
the active workspace is an emissive **gold lozenge**. The ground is the night
side of the sky, darker than the deepest cobalt in the picture; the raised
surfaces are that cobalt lifted in steps, kept blue, not navy-grey. State
keeps its meanings: `warn` is the rim's yellow highlight saturated (the one
yellow thing in a red-and-blue picture: something pending); `urgent` is a
crimson shifted toward pink so it never reads as the frame's orange-red; and
`ok` is state in the ground's own hue, as glacier's is lit ice — the sky lit,
because nothing in the picture is green. Pending updates light up in the
readout peach like everything else. The upper sky and the fog are the quiet
family (`dim`, `dormant`): the sky printed up for contrast (as painted it
reads 2.7:1 on `surface`), the fog as it is, because every surface that
carries them is cobalt. What separates it from harbor: harbor is amber on
teal, vesper is red and peach on cobalt — nothing here is amber, nothing is
teal — and the bar sits on a clean cobalt sky where harbor's sits on teal.

Measured (WCAG) on `surface`, on the bar island composite (`#081a33` at 0.80
over the cobalt strip the bar covers, `#0c4277` → `#092241`) and on the
launcher window (`ground` at 0.84 over the picture's centre, `#7b8998` →
`#1c2d46`):

| role | `surface` | island | launcher |
|---|---|---|---|
| `dim` | 3.7 | 4.1 | 3.6 |
| `dormant` | 4.9 | 5.5 | 4.7 |
| `frame` | 4.3 | 4.8 | 4.2 |
| `readout` | 8.6 | 9.6 | 8.4 |
| `readoutBright` | 11.5 | 12.8 | 11.1 |
| `warn` | 9.1 | 10.1 | 8.8 |
| `ok` | 7.1 | 7.9 | 6.9 |
| `urgent` | 3.8 | 4.2 | 3.7 |
| `text` | 11.7 | 13.0 | 11.4 |
| `launcher` | 5.7 | 6.3 | 5.5 |

`ground` on `readout` (the lozenge's digit) is 10.3:1, `ground` on `frame`
5.1:1, and the launcher's selected row (`launcher` on its own 18% tint) 4.1:1.

What changes is the identity: where cyberpunk is neon glass, gruvbox a CRT,
glacier frost, harbor a still evening and verdigris candlelit stone, vesper
is **light on an edge**, and its signature is the **rim** (`effects.texture`
`rim`, `textureAlpha` 0.35): `frame` catching the right edge of every panel
and fading in over the last 18% of its width, with a hairline of it on the
edge itself — the picture's rim light, from the sun behind her, drawn by
`Texture.qml`. 0.35 rather than the kind's resting 0.30, because the fill is
near-opaque over a mid-blue sky and the band has to read as light on an
edge, not a tint. There is no text glow (`effects.glow` off): a sun below
the horizon does not bloom like neon. The islands carry one faint thing, a
red bloom (`bar.island.glow` 0.16 over 18px), the rim's halo; no accent
line. The islands are night a shade under `ground` (`#081a33`) at 0.80: the
strip the bar covers is the cobalt at the very top of the picture, a *mid*
blue brighter than most bar strips, so the fill has to be fairly opaque
where harbor's could be a silhouette — at 20% show-through the composite
lands at `#092241`, `dim` 4.1:1. 10px corners, and **one radius for the
theme**: islands, launcher, power tiles, the lock input, the greeter's
password box, swaync's cards and the window `rounding` all use 10, chips 7
and GTK menus 8; the OSD is a full pill. A 1px rim at 35%. The launcher is
night glass at 0.84 in a 1px frame of the rim's lit skin; the OSD a full
pill with a rim frame and a peach track; the power tiles 10px with a 1px rim
edge at 40% over a 0.72 night scrim. The window border runs rim → peach
(`frame` → `readout`) at **0°**, horizontal: red on the left fading to peach
on the right, light coming from the right the way the rim does — and it is
**still**, there is no `border_motion` key, because she hangs still. The
shadow is a warm halo (`frame` at 28%, `0x48f25a3c`), the rim's glow pooling
under each window — like cyberpunk's bloom but red and lower. The blur is
moderate (size 8, three passes, vibrancy 0.15), harbor's numbers, so the
islands show the cobalt as dusk rather than frost. The cursor is
`Bibata-Modern-Ice`, glacier's cold pointer, on cobalt; and the wallpaper
sweep on a switch is a `wipe` from the left — the way the light crosses her.

The terminal side is cobalt and peach with the rim as its one accent:
wezterm's background is `surface` rather than `ground` (the cobalt, not a
hole in the desktop), every normal ANSI slot clears 4.5:1 on it — the red
slot is the crimson a notch up, since `urgent` as painted is 3.8:1 there —
and the slot convention holds: bright magenta is the rim, cyan is peach, so
`fastfetch`'s keys print rim red and its title peach, and already-printed
output recolors correctly on `SUPER+T`. Three slots are not roles and are
named and measured in `wezterm/colors.lua`: green is a jade chosen to sit
with the cobalt (the picture has no green — `ok` is the lit sky, which is the
blue slot — but green-coded output has to stay green), magenta is the rose of
the low clouds lifted to text weight, and the lighter brights are a role
printed a step up. GTK takes the rim for both accent and selection — the lit
skin belongs to the launcher alone, and the two are close enough in hue that
a salmon highlight in every file dialog would blur the one place it is meant
to be seen. The editor is `tokyonight-night`, which LazyVim already ships and
whose ground is a night blue like this one's, with the current line number
wearing the frame (night on rim red). btop's ramps climb peach → rim gold →
crimson (`readout` → `warn` → `urgent`), so a hot CPU still reads as an
alarm; cava does not: its gradient climbs peach → the rim's lit skin → the
rim (`readout` → `launcher` → `frame`), light moving in from the horizon to
her edge, as glacier's and verdigris's rise rather than alert.

The lock screen and greeter put their stack **left of centre, over the open
sky** rather than centered: the figure hangs right of centre (x ≈ 67–88% of
the panel's crop, her head at the top edge and her feet at y ≈ 90%), so the
other dark themes' centered clock would cross her skirt and harbor's
centre-right stack her legs. At x ≈ 30% (`position = -384` in
`hyprlock.conf`, `-root.width * 0.2` in `sddm/Main.qml`) and a little low,
y ≈ 55% (60px under the centred layout; `root.height * 0.05`), the stack
spans x 22–38%, clears her by a quarter of the screen, and crosses only open
sky and the horizon haze, where nothing is painted. The haze is the catch:
it is the brightest band of the sky, and at the night themes' `brightness`
0.55 dormant type on it is 2.6:1 and the ring 2.1:1 — so this theme dims
deeper, `wallpaper.brightness` 0.35 with the usual 8px blur (dusk going to
night, which is what the name says). Measured over the dimmed, blurred
picture, the clock (`readout`) holds 7.3:1 everywhere in its box, the date
(`dormant`) 4.2:1, `locked` 3.9:1, the ring (`frame`) 3.5:1 and the failure
line (`urgent`) 3.1:1; the brightest pixel under the stack (`#413937`) is a
step above `surface`, which is why 0.35 and not 0.4, where the failure line
is 2.7:1. The greeter, which cannot blur, puts the same 0.65 night scrim
over the sharp picture: the clock holds 4.3:1 on its brightest pixel and
5.6:1 over 95% of its box, the date 3.2:1, and only the failure line dips
(2.3:1), so it alone is outlined in the ground as harbor's is; the power row
sits straight on the fog in the bottom-right corner (4.5:1 resting, 3.9:1
touched, 3.5:1 for crimson), needing no pane. One note on the picture: the
wallpaper is 5640×2400, a 2.35:1 frame much wider than the panel's 16:10, so
swww, hyprlock and the greeter crop ~900px of it off each side (675 panel
pixels on a 2880×1800 panel, where it then scales down 1.33×) — the crop
loses sky at both sides and none of her. On the desktop she sits under the
windows and the islands; the lock screen is where you see her.

---

[← docs index](../README.md) · [repo root](../../README.md)
