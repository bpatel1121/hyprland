# The manga theme

A printed page — the **purely black and white** theme, with no upstream
palette and no hue: every role is a grey lifted from the wallpaper itself, a
black-ink line drawing of a girl in a uniform with blades, right of centre,
on a flat off-white page (the page, the ink, the screentone greys in the
shadow). That is the whole rule, and it is what separates it from the two
other light themes: graphite is grey ink on paper with one violet eye,
inkwash has its gold filigree and cyan burst, and manga has **nothing** —
not even for state. The **ink** (`#111111`) is the frame — the islands' rim,
the window border, the notification edge, btop's boxes, the OSD slab, the
lock input's ring — the heaviest line on the page; the **drawing's ink** one
weight under it (`#2e2e2e`) is every readout on the bar; a **mid ink**
(`#4a4a4a`) is the launcher, the one surface that covers the bar, and its
selected row, a focused input, a hovered button, a selected row in a file
dialog. State keeps its meanings but is told by *weight*, not hue: `warn`
(pending updates, do-not-disturb) is a mid grey, `ok` (a charging battery,
a Spotify title) is the lightest ink, and `urgent` is pure black, the one
thing darker than the frame — so a pending count reads as a lighter figure
than the clock, an overdue one as a heavier one, a low battery as the
blackest thing on the bar, and the alert itself is the **pulse** `Chip.qml`
draws, not a color. `dim`/`dormant` are the page's own pencil greys for quiet
type and empty workspaces — two pencil *weights*, both printed to ≥ 3:1 on
the page *and* on the cardstock, because a grey that is merely a tint reads
as nothing on near-white (the brief's `#8a8a8a` was 2.8:1 on `ground`, so
`dim` is `#858585`; `ok` carries type too and was printed from `#9a9a9a` to
`#8e8e8e` for the same reason, one step lighter than `dim`).

Measured (WCAG) on `surface`, on the bar island composite (`#f5f5f5` at
0.94 over the page's top strip, which is flat `#f6f6f6` → `#f5f5f5`), on the
launcher window (`ground` at 0.96 over the picture's centre, `#f6f6f6` →
`#e9e9e9`) and on `ground`, the terminal:

| role | `surface` | island | launcher | `ground` |
|---|---|---|---|---|
| `dim` | 3.4 | 3.4 | 3.0 | 3.0 |
| `dormant` | 4.2 | 4.2 | 3.7 | 3.7 |
| `frame` | 17.3 | 17.3 | 15.6 | 15.4 |
| `readout` | 12.5 | 12.5 | 11.2 | 11.1 |
| `launcher` | 8.1 | 8.1 | 7.3 | 7.2 |
| `warn` | 6.1 | 6.1 | 5.5 | 5.5 |
| `ok` | 3.0 | 3.0 | 2.7 | 2.7 |
| `urgent` | 19.3 | 19.3 | 17.3 | 17.1 |
| `text` | 16.6 | 16.6 | 14.9 | 14.8 |

`ground` on `frame` (the active workspace's digit) is 15.4:1, the launcher's
selected row (`launcher` on its own 18% tint, `#cccccc`) 5.5:1, and the page
on the mid ink (the terminal's selection, GTK's accent print) 8.1:1. `ok`
never sits on cardstock.

What is structurally different: it is light, it is still, and it is
*printed*. Where graphite is a drawn card and inkwash a brush edge, manga is
a **printed panel** — near-opaque page islands (`bar.island.opacity` 0.94,
the fill is `surface`, because a line drawing frosted through a light fill
just goes grey), **4px corners** everywhere a panel has one (a printed
panel's corner is nearly square; gruvbox is 4 too, but gruvbox is a dark
CRT) and **one radius for the theme**: islands, launcher, power tiles, the
lock input, the greeter's card and password box, swaync's cards, the OSD
slab and the window `rounding` all use 4, chips and inputs 3, GTK menus 2;
**1px ink rims** at 90% on the islands, tiles, cards and greeter — an inked
panel border, heavier than graphite's 70% pencil rim; no glow (ink doesn't
emit) but **screentone** on every panel fill (`effects.texture` `halftone`,
`textureAlpha` 0.12: a grid of `frame` ink dots, one every 4px, offset every
other row, drawn by `Texture.qml` inside the rim — the shading of a printed
page, 0.12 rather than the kind's resting 0.10 because over near-opaque
white at 1.5× the dots have to read as tone, not vanish); and the active
workspace drawn as a solid **ink block** with its digit in `ground`
(`readoutBright` is deliberately not declared, which is what makes
`Workspaces.qml` pick the solid-frame block over the emissive lozenge — a
printed panel number). The launcher is cardstock at 0.96 in a 1px mid-ink
frame; the OSD a 4px slab with an ink frame and a track in the drawing's
ink; the power tiles 4px with a 1px ink edge at 90% over a 0.85 cardstock
scrim. The window border runs ink → mid ink (`frame` → `launcher`) at 45°
and does **not** move: `theme.lua` declares no `border_motion`, so
`theme-apply.sh` starts no cycler — ink is still. Blur is the lightest in the
set (size 4, two passes, `vibrancy` 0: paper barely frosts, and there is no
hue to pull through), the shadow a faint neutral `0x26000000` (the page has
no cast; lighter than graphite's pencil edge), `dim_strength` 0.06 because
dimming paper goes grey fast, and the wallpaper sweep on a switch is a short
`simple` dissolve — a page turned.

`polarity = "light"` in `theme.lua` is the line that makes it a light theme:
`theme-apply.sh` reads it and flips GTK to `adw-gtk3` / `Papirus-Light` /
`prefer-light`, so Firefox and every site that honors `prefers-color-scheme`
follow for free; the cursor is `Bibata-Modern-Classic` (a dark pointer for a
light desktop). The terminal is the **one place a real hue is allowed**: the
desktop is black and white, but `wezterm/colors.lua` keeps ink-dark hues
because `ls` and `git` are not legible without them — a diff, a listing and
a failing test say what they say by red, green, yellow and blue, and a page
with one ink cannot carry that by weight. So the six hue slots are muted
real hues, each desaturated toward grey and printed to ≥ 4.5:1 on `ground`
(a brick red `#9e4a4a`, a bottle green `#3f6e4a`, an ochre `#7c5f24`, a slate
blue `#4a6684`, a plum `#875483`, a teal `#2f6e70`), the brights the same
hues a step lighter (≥ 3:1, since WezTerm brightens bold text), and the
hueless slots are ink weights — black is the frame, white the mid ink,
bright black pencil, bright white the type. The slot convention holds in
spirit: bright magenta is the frame (ink), so `fastfetch`'s title prints
ink and its keys step down to the mid ink in the white slot, and the cyan
slot, the readout's in the dark themes, is the teal. The background is
`ground`, the cardstock, not the page (a full screen of `surface` is glare);
the cursor an ink block with cardstock print, the selection the mid ink with
page print, the same objects as the bar's active block and the launcher's
selected row. Those eleven hue literals (bright magenta is the ink) are the only non-role colors under
`themes/manga`: starship speaks in slot names (ink at three weights, with
the dirty dot and the failed arrow as the terminal's two hues), and btop,
cava, lazygit, swaync, GTK and fastfetch are greys only, their ramps by
weight — pencil → mid grey → pure ink (`dim` → `warn` → `urgent`), a ramp
that gets darker as it gets worse, like ink, so a hot CPU is the heaviest
figure on the page and cava's wave climbs pencil → mid ink → ink. The editor
is `tokyonight-day`: LazyVim ships only tokyonight and catppuccin and
neither has a monochrome style, so the editor keeps the terminal's
exception (code is not legible by weight alone) on the lightest shipped
page, with the current line number wearing the ink block.

The lock screen and greeter put their stack **left of centre, on blank
page** rather than centered: the figure stands right of centre (x ≈ 70–94%
of the panel's 16:10 crop, a stray line to 98%, y ≈ 19–97%), so the dark
themes' centered stack would cross her blades and graphite's lower-right one
her skirt. At x ≈ 25% (`position = -480` in `hyprlock.conf`,
`-root.width * 0.25` in `sddm/Main.qml`) and vertically centred, the stack
spans x 17–33%, clears her by more than a third of the screen, and every
pixel under it is the paper (`#f6f6f6`, measured). `wallpaper.brightness` is
0.95 — graphite's reasoning, dimming paper makes slate, and this page is
flatter and whiter than graphite's — so every label is ink on the lit page:
the clock (`frame`) 15.7:1, the date and `locked` (`text`) 15.0:1, the mid
ink 7.4:1, the placeholder (`dim`, on the `surface` input) 3.4:1. State on
the lock ring is weight: it goes to the mid grey (`warn`) while the password
is checked and pure ink on failure. The greeter keeps the `1 - brightness`
scrim — a 5% ink wash — puts the inputs on a cardstock card (`session`'s
tile numbers, the launcher's window/input split), doubles the password
box's line to 2px of pure ink on failure, and sets the power row straight on
the page, which in that corner is blank paper: 7.4:1 resting, 15.8:1
touched. One note on the picture: the wallpaper is 1920×1080, so on the
2880×1800 panel swww, hyprlock and the greeter upscale it 1.67× — it is flat
line art on a flat page, so it survives that — and the 16:9 → 16:10 cover
crop loses ~160 panel pixels off each side, all of it blank page.

---

[← docs index](../README.md) · [repo root](../../README.md)
