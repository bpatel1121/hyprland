# The harbor theme

Dusk over water, from a flat, cel-shaded night scene — a figure in a
cream-amber hoodie leaning on a waterfront railing, cigarette smoke curling
pale cyan, a teal-slate sky over the harbor, a lit skyline across the water,
a full moon, a street lamp, orange lamplit pavement in the foreground — and,
like glacier, no upstream palette: every role is sampled from the picture,
and `tokens` in `palette.json` names each after what it is there (the dusk,
the skyline, the hoodie, the smoke, the pavement). The picture's identity is
teal and amber, and the roles follow it — the two-tone rule, dusk edition:
**amber** (the hoodie) is the frame AND every readout, one hue at two
weights, the way graphite is ink and one violet. The mid amber is the
islands' hairline, the window border, the notification edge, btop's boxes;
the hoodie lit is every bar figure and the clock; and `readoutBright` is the
lamp's halo, so the active workspace is an emissive **amber lozenge**. The
**smoke** is the launcher, the one cool thing: cyan survives in exactly two
places, the launcher's frame and selected row (the one surface that covers
the bar) and the top of the window border. The ground is the sky's own
**teal-black**, the raised surfaces the skyline's teal-navy. State keeps its
meanings: the lamplit pavement's orange for pending repo updates (a lit
stretch of ground), the hair's red for alerts (pushed redder than the
pavement so the two never read as one hue), and a sea-glass green for
AUR/charging — the picture has no green, so `ok` is chosen to sit with the
teal, as glacier's was. The sky itself, the picture's dominant color, is the
quiet family (`dim`, `dormant`), printed up for contrast because every
surface that carries it is teal-black. It is not glacier, which an earlier
cut of it resembled: glacier's bar text is white and ice cyan on navy, and
the bar text is what you look at — harbor's is lamplight on teal.

Measured (WCAG) on `surface`, on the bar island composite (`#0b1519` at 0.78
over the teal strip of sky the bar covers, `#375a62` → `#152429`) and on the
launcher window (`ground` at 0.8 over the picture's centre → `#1a2125`):

| role | `surface` | island | launcher |
|---|---|---|---|
| `dim` | 3.25 | 3.38 | 3.45 |
| `dormant` | 4.52 | 4.71 | 4.81 |
| `frame` | 7.4 | 7.7 | 7.9 |
| `readout` | 9.8 | 10.2 | 10.4 |
| `readoutBright` | 11.9 | 12.4 | 12.6 |
| `warn` | 5.6 | 5.9 | 6.0 |
| `ok` | 8.6 | 8.9 | 9.1 |
| `urgent` | 3.9 | 4.0 | 4.1 |
| `text` | 12.4 | 12.9 | 13.1 |
| `launcher` | 10.2 | 10.6 | 10.9 |

`ground` on `readout` (the lozenge's digit) is 11.3:1, `ground` on `frame`
8.5:1, and the launcher's selected row (`launcher` on its own 18% tint) 6.9:1.

What changes is the identity: where cyberpunk is neon glass, gruvbox a CRT and
glacier frost, harbor is **a still evening**, and its signature is the
**horizon** (`effects.texture` `horizon`, `textureAlpha` 0.28): `frame` amber
rising from the bottom edge of every panel, gone by mid-height — lamplight on
the pavement under a dark sky, drawn by `Texture.qml`. 0.28 rather than the
kind's resting 0.18, because the horizon is the signature and at 0.22 it was
too shy. There is no glow at all (`effects.glow` off, `bar.island.glow` 0, no
accent line): this is a street lamp, not neon. The islands are teal-black a
shade under `ground` at 0.78 — a railing is a silhouette, not frost — over
the strip the bar covers, the teal sky, the brightest band of the picture;
the darker fill buys the quiet type its margin (`dim` 3.4:1 on the composite,
where `ground` would leave 3.2). 12px corners, a thin 1px amber hairline at
40% — a railing, not a neon tube. The launcher is teal-black glass at 0.82 in
a 1px smoke-cyan frame, the OSD a full pill with an amber frame and an amber
track, the power tiles 12px with a 1px amber edge at 40% over a 0.7
teal-black scrim. The window border IS the horizon: smoke cyan → amber
(`launcher` → `frame`) at **90°**, so every window has sky over lamplight,
and it is **still** — there is no `border_motion` key, because motion would
spin the horizon. The shadow is a faint amber cast (`frame` at 25%),
lamplight pooling under each window; `rounding` is 12, the islands' radius,
one corner for the whole desktop; the blur is moderate (size 8, three passes,
vibrancy 0.15) so the islands show the teal sky as dusk rather than frost.
The cursor is `Bibata-Modern-Amber`, the one gruvbox already uses.

The terminal side is teal-navy and amber with one cool slot: wezterm's
background is `surface` rather than `ground` (the skyline, not a hole in the
desktop), every normal ANSI slot clears 4.5:1 on it — the red slot is the
hair's red a notch up, since `urgent` as painted is 3.9:1 there — and the
frame slot holds: bright magenta is the hoodie's amber, so `fastfetch`'s keys
print amber. The readout slot bends, because the readout is warm and
cyan-coded output has to stay cyan: the cyan slot is the smoke, so
`fastfetch`'s title prints smoke cyan. The slots themselves are unchanged, so
already-printed output still recolors correctly on `SUPER+T`. GTK takes amber
for both accent and selection — amber on teal is the picture's own pairing,
and a cyan highlight in every file dialog would be glacier again. The editor
is `tokyonight-night`, which LazyVim already ships, with the current line
number wearing the frame (teal-black on amber). btop's graphs and cava climb
amber → lamplit orange → red (readout → warn → urgent), quiet rising to loud
as cyberpunk's and gruvbox's meters do.

The lock screen and greeter keep their stack **centre-right, over the water**
rather than centered: the figure stands left of centre (her body at x 12–36%,
the arm with the can reaching 49%), and the skyline fills the band where the
other dark themes' centered clock would land, so the whole stack moves right
and a little down (`position = 230` and 210px down in `hyprlock.conf`,
`root.width * 0.12` and `root.height * 0.2` in `sddm/Main.qml`) and crosses
only dark water and the railing in front of it — clear of her, the skyline,
the lamp and the lit pavement. The greeter, which cannot blur, outlines the
date and the failure line in the ground so the railing's lit edges never
touch a glyph, and puts its power row on a teal-navy pane (the notification
card's numbers) because its corner is the lamplit pavement, where dormant
type is 2.0:1 even at the dimmed brightness. Both keep the `1 - brightness`
scrim at `wallpaper.brightness` 0.55 with an 8px blur, the dark themes'
resting numbers: the picture is already dusk. One note on the picture: the
wallpaper is 2760×1410, just under the panel's 2880 width, so on a 2880×1800
panel swww, hyprlock and the greeter upscale it 1.28× and crop ~320px off each
side, losing none of the figure. On the desktop she sits under the windows
and the islands; the lock screen is where you see her.

---

[← docs index](../README.md) · [repo root](../../README.md)
