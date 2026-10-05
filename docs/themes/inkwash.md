# The inkwash theme

Paper panels over a digital ink-wash painting — a **light** theme with no
upstream palette: every role is lifted from the wallpaper itself (a horned,
armored figure in olive-black ink with gold filigree, a green cape and one
cyan burst, on white-grey paper with a smoke wash down the left edge). The role
assignments follow the same two-tone rule as the other themes, painted rather
than lit: the **gold filigree** is the frame (islands' rim, window border,
notification edge, btop's boxes, the OSD slip, the lock input's outline), the
armor's **olive ink** is every readout — a second, greener ink beside the
black `text`, so a readout is still ink rather than a second hue — and the
**cyan burst** is the launcher, the one lit thing in the picture going to the
one surface that covers the bar. State colors keep their meanings: bronze for
pending repo updates, the cape's green for AUR/charging, the sigil's red for
alerts, `dim`/`dormant` are the smoke wash for quiet type and empty
workspaces. What changes is the identity: where cyberpunk is rounded neon
glass and gruvbox a CRT, inkwash is a **sketchbook page** — opaque-ish white
paper islands (`bar.island.opacity` 0.88, the fill is `surface` rather than
`ground`, because the painting frosted through a light fill goes muddy),
small 6px corners (5 on the chips and the launcher's rows, 8 on the launcher
window and the power tiles), 1px rims everywhere like brush edges, no glow
and no scanlines (`effects` both off: ink doesn't emit and paper has no
raster), and the active workspace drawn as a solid gold **pill** with a paper
digit (`readoutBright` is deliberately not declared, which is what makes
`Workspaces.qml` pick the solid-frame block over the emissive lozenge). The
window border runs filigree gold → cape green and is **still**: there is no
`border_motion` key, because ink is laid once and dries.

`polarity = "light"` in `theme.lua` is the line that makes it a light theme:
`theme-apply.sh` reads it and flips GTK to `adw-gtk3` / `Papirus-Light` /
`prefer-light`, so Firefox and every site that honors `prefers-color-scheme`
follow for free; the cursor is `Bibata-Modern-Classic` (a dark pointer for a
light desktop; AUR `bibata-cursor-theme-bin`). The terminal-side files
(wezterm, starship, btop, fastfetch, lazygit, nvim) carry the light-polarity
rule: the filigree's gold is 2.4:1 on paper and cannot carry *text*, so where
the dark themes print their frame color they print its ink — `#8a6a2a`, the
gold darkened to 4.6:1 — and gold itself stays for lines, fills, the cursor
block and selected rows (ink on gold is 6.7:1). The burst gets the same
treatment where it has to be prose rather than a glyph: `#286884`, its own
deep water, is the cyan slot and the prompt arrow. The editor is
`tokyonight-day`, which LazyVim already ships, with the current line number
as a paper digit on the gold. The lock screen and greeter put their stack in
the **upper left** rather than centered: the figure fills the center, and the
dark themes' centered input would land across his face — and his shoulder
plate reaches a quarter of the way across the screen below the midline, so a
left-third stack at the usual heights would print the clock on black armor.
The smoke wash is clear above that, so the clock, date and input sit there
(`position = -700` and lifted 260px in `hyprlock.conf`, the same offsets as
screen fractions in `sddm/Main.qml`), each label checked against the 0.92-lit
wash at 3.4:1 or better. The greeter puts the inputs on a paper card
(`session`'s tile numbers) and keeps the `1 - brightness` scrim — at
`wallpaper.brightness` 0.92 that is an 8% ink wash, where the dark themes'
0.55 would turn the paper grey.

One caveat on the picture: the wallpaper is 2560×1440 on a 2880×1800 panel,
so swww, hyprlock and the greeter upscale it 1.25× and crop ~130px of source
off each side (16:9 into 16:10) — paper, both times, since the figure fills
the center. It holds up: he sits under the windows on the desktop, and the
lock screen is where you actually see him.

---

[← docs index](../README.md) · [repo root](../../README.md)
