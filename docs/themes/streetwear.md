# The streetwear theme

Off-white paper over a flat periwinkle sky — the first **light** theme, and
the first with no upstream palette: every role is lifted from the wallpaper
itself (an anime figure in an Off-White jacket, black bob, teal eyes, a yellow
`OFF-WHITE` tag on the sword, holographic pink stickers). The role assignments
follow the same two-tone rule as the other two, printed rather than lit: the
**yellow tag** is the frame (islands' hairline, window border, notification
edge, btop's boxes, the OSD pill, the lock input's outline), **navy** is every
readout — and, this being paper, navy is also the text, so a readout is ink
rather than a second hue — and the **holographic pink** is the launcher, the
one surface that covers the bar. State colors keep their meanings: orange for
pending repo updates, teal (the eyes) for AUR/charging, pink-red for alerts,
`dim`/`dormant` are the sky inked down for quiet type and empty workspaces.
What changes is the identity: where cyberpunk is rounded neon glass and
gruvbox a CRT, streetwear is a **lookbook page** — opaque-ish paper islands
(`bar.island.opacity` 0.90, the fill is `surface` rather than `ground`,
because periwinkle frosted through a light fill goes muddy), medium 10px
corners (7 on the chips, 12 on the launcher, 14 on the power tiles), 1px
frames, no glow and no scanlines (`effects` both off: paper doesn't emit and
has no raster), and the active workspace drawn as a solid yellow **tag**
(`readoutBright` is deliberately not declared, which is what makes
`Workspaces.qml` pick the solid-frame block over the emissive lozenge). The
window border runs tag yellow → holo pink and crawls at `border_motion = 160`,
slower than gruvbox's lantern: a sticker tilting in the light.

`polarity = "light"` in `theme.lua` is the line that makes it a light theme:
`theme-apply.sh` reads it and flips GTK to `adw-gtk3` / `Papirus-Light` /
`prefer-light`, so Firefox and every site that honors `prefers-color-scheme`
follow for free; the cursor is `Bibata-Modern-Classic` (a dark pointer for a
light desktop; AUR `bibata-cursor-theme-bin`). The terminal-side files
(wezterm, starship, btop, fastfetch, lazygit, nvim) carry one rule the dark
themes never needed: the tag's yellow is 1.7:1 on paper and cannot carry
*text*, so where the other themes print their frame color they print its ink —
`#8a6b0e`, the yellow darkened to 4.7:1 — and yellow itself stays for lines,
fills, the cursor block and selected rows (navy on yellow is 9:1). The editor
is `catppuccin-latte`, which LazyVim already ships, with the current line
number wearing the tag. The lock screen and greeter keep their layout in the
**left third** rather than centered: the figure stands dead center, and the
other themes' centered input would land across her eyes. The greeter puts the
inputs on a paper card (`session`'s tile numbers) and keeps the
`1 - brightness` scrim — at `wallpaper.brightness` 0.9 that is a 10% navy
wash, where the dark themes' 0.55 would turn the sky to mud.

One caveat on the picture: the wallpaper is 1920×1080 on a 2880×1800 panel,
so swww, hyprlock and the greeter upscale it ~1.67× and crop 160px off each
side. It holds up because it is a flat field with one line-art figure, but a
4K copy of the same image would be the real fix.

---

[← docs index](../README.md) · [repo root](../../README.md)
