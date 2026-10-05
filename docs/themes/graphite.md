# The graphite theme

Grey ink on near-white paper — the **light monochrome** theme, with no
upstream palette: every role is lifted from the wallpaper itself, an ink
sketch of a figure in tactical gear aiming a rifle (warm-grey paper that
darkens toward the edges, pencil hatching, the heavy ink of the barrel) that is
greyscale except for **one** thing, a violet eye. That is the whole rule:
everything is grey ink on paper, and exactly one hue exists. The **ink** is
the frame — the islands' rim, the window border, the notification edge, btop's
boxes, the OSD pill, the lock input's outline — all drawn lines, near-black,
not a color. The **violet** marks the thing you act on: every readout on the
bar, the launcher (the one surface that covers the bar), a hovered tile or
button, a focused input, the prompt's arrow, a selected row in a file dialog.
Where cyberpunk and gruvbox pick a frame hue *and* a readout hue, graphite has
one hue and spends it on readout and launcher both (`#8a4f96` as the readout,
`#92589e`, the eye where the light catches it — one step lighter, no more, so
the launcher's selected row still reads on its own tint — as the launcher);
the frame is the thing that gives it up. State colors keep their meanings — brass for
pending repo updates, tritium green for AUR/charging, laser red for alerts —
and are absent from the picture by design: they show only when something is
true, and `dim`/`dormant` are the paper's own pencil greys for quiet type and
empty workspaces — two pencil *weights*, both printed to ≥ 3:1 on the paper
surfaces, because a grey that is merely a tint reads as nothing on near-white.

What is structurally different: it is light, and it is still. Where cyberpunk
is rounded neon glass and gruvbox a CRT, graphite is a **drawn card** —
near-opaque paper islands (`bar.island.opacity` 0.92, the fill is `surface`
rather than `ground`, because a grey sketch frosted through a light fill just
goes grey), 8px corners (6 on the chips and inputs, 10 on the launcher and
the power tiles), **1px ink rims** at 70% on the islands, tiles, cards and
greeter, no glow and no scanlines (`effects` both off: ink doesn't emit and
paper has no raster), and the active workspace drawn as a solid **black
pill** with its digit in `ground` (`readoutBright` is deliberately not
declared, which is what makes `Workspaces.qml` pick the solid-frame block over
the emissive lozenge). The window border runs ink → violet and does **not**
move: `theme.lua` declares no `border_motion`, so `theme-apply.sh` starts no
cycler — a drawn line holds still. Blur is faint (`vibrancy` 0.05: no hue to
pull through), the shadow is a neutral `0x2e000000` pencil edge, and
`dim_strength` is 0.06, because dimming paper goes grey fast.

`polarity = "light"` in `theme.lua` is the line that makes it a light theme:
`theme-apply.sh` reads it and flips GTK to `adw-gtk3` / `Papirus-Light` /
`prefer-light`, so Firefox and every site that honors `prefers-color-scheme`
follow for free; the cursor is `Bibata-Modern-Classic` (a dark pointer for a
light desktop; AUR `bibata-cursor-theme-bin`). The terminal-side files
(wezterm, starship, btop, fastfetch, lazygit, nvim) carry the monochrome rule
into the ANSI table: the violet sits in both magenta slots (`readout` reads at
5.2:1 on the sheet with no darkening; `launcher` is its bright), red, green
and yellow are the three state colors printed down to ink weight (`#ad3d51`,
`#3f7049`, `#8f5f1a`, each ≥ 4.5:1), and blue and cyan — which have no hue to
carry — are **pencil weights**, four greys between `frame` and `dim`, so
syntax highlighting reads by weight and a directory in `ls` comes out as hard
pencil. The cursor is an ink block with paper print, the same object as the
bar's active pill. The editor is `tokyonight-day`, which LazyVim already
ships, with the current line number wearing the ink block. The lock screen and
greeter keep their stack in the **lower right** rather than centered: the
figure fills the left and center of the sketch, and the rifle runs on through
the right third at mid-height, so the stack sits in the clean paper below the
barrel (`position = 480` and 210px down in `hyprlock.conf`, the same offsets
as screen fractions in `sddm/Main.qml`). The greeter puts the inputs on a paper card
(`session`'s tile numbers), the power row on a smaller one (the sketch's paper
darkens toward its corners, and the violet and red touch states are under
2.5:1 straight on that hatching), and keeps the `1 - brightness` scrim — at
`wallpaper.brightness` 0.92 that is an 8% ink wash, where the dark themes'
0.55 would turn the paper to slate.

The wallpaper is 3840×2159, so on the 2880×1800 panel swww, hyprlock and the
greeter scale it down and crop a sliver — the 16:9 picture is 2880×1620 at
width, so it fills height instead and loses ~160px off each side, all of it
paper margin. No upscaling, no softening of the pencil line.

---

[← docs index](../README.md) · [repo root](../../README.md)
