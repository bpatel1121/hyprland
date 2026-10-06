# The glacier theme

One hue, navy to ice, over a painting — a blue-haired figure in a white cap on
an ice throne, ice swords, snowflakes, stars — and, like the light themes, no
upstream palette: every role is lifted from the picture, and `tokens` in
`palette.json` names each after what it is there (the sky, the deep ice, the
swords, the cap). The role assignments follow the same two-tone rule as the
other themes, in one cold hue: **ice cyan** (the swords) is the frame — the
islands' hairline, the window border, the notification edge, btop's boxes,
the lock input's ring — **white** (the cap) is every readout, and **pale
cyan** (the near-white ice) is the launcher, the one surface that covers the
bar. Warm never appears at rest: yellow for do-not-disturb, green for a
charging battery, red for alerts, and they are the only warm pixels on the
desktop, which is what makes them read as state; pending updates light up in
the readout white like every other figure, not in a color of their own. `readoutBright` is declared
(pure white), so the active workspace is the emissive **white → ice
lozenge** — a lit snowflake — rather than the solid block gruvbox and the
light themes draw.

What changes is the identity: where cyberpunk is neon glass, gruvbox a CRT
and graphite ink on paper, glacier is **frost** — and the frost is
structural, not a color. The islands are the most translucent of any theme
(`bar.island.opacity` 0.55 over a navy fill a shade under `ground` — the top
of the painting is bright ice, and a lighter fill composited to a mid blue
the quiet type could not sit on), the launcher 0.62, the OSD
pill 0.7, the power tiles 0.7 over a 0.6 scrim, and `theme.lua` runs the
biggest blur in the repo (size 10, three passes, vibrancy 0.25), so the
painting shows through every surface as ice behind glass rather than a dimmed
photo. The edges are thin — 1px everywhere the dark themes used 2 — at 35% on
the islands and 50% on the tiles, ice-cyan hairlines at low alpha. Glow is on,
the one cold one (cyberpunk's is the other): `effects.glowRadius` 10 with a
faint cyan bloom around each island (`bar.island.glow` 0.22 over 20px), a
white clock in an ice-cyan halo on the lock screen, and nothing louder. The
panel texture is a **sheen** (`effects.texture` `sheen`, at 0.2): a bright
catch light along the top edge of every pane and a white wash under it, gone
by mid-height — light on ice, drawn by `Texture.qml`. The window shadow is neutral (`0x59000000`, the same hueless
exemption gruvbox uses) because the cyan is the bar's and the text's, not the
windows'. The border runs ice cyan → pale cyan, a sword's edge, and drifts at
`border_motion = 140` — slower than gruvbox's lantern, like light moving
through ice. The cursor is `Bibata-Modern-Ice`, the one cyberpunk already
uses.

The terminal side is blue with white readouts and cyan accents, and nothing
warm until something is true: wezterm's background is `surface` rather than
`ground` (a pane of deep ice, not a hole in the desktop), every normal ANSI
slot clears 4.5:1 on it, and the slot convention holds — bright magenta is
the frame, cyan is the readout, so `fastfetch`'s keys print ice cyan and its
title white, and already-printed output recolors correctly on `SUPER+T`. The
editor is `tokyonight-night`, which LazyVim already ships, with the current
line number wearing the frame (navy on ice cyan). cava is the one place the
frame enters the data: its gradient climbs white → pale cyan → ice cyan, ice
getting brighter rather than warmer, because a loud song is not an alert.

The lock screen and greeter keep their stack in the **lower third** rather
than centered: the figure sits dead center, and the other dark themes'
centered clock would land across her chest and the input across her lap, so
the whole stack moves down (210px in `hyprlock.conf`, `root.height * 0.2` in
`sddm/Main.qml`) and crosses only her legs and the ice floor, leaving the cap,
the face and the hair clear. The greeter's power row sits on a frosted pane
(deep ice at 0.85, the notification card's numbers) because its corner is the
lit floor, where dormant type is 1.6:1 even at half brightness. Both keep the
`1 - brightness` scrim at `wallpaper.brightness` 0.5 with a 10px blur — a
notch darker and softer than the other dark themes, because the picture is
already bright ice. One note on the picture: the wallpaper is 3840×2160 and
the panel is 16:10, so swww, hyprlock and the greeter crop 192px off each
side and lose none of the figure. On the desktop she sits under the windows
and the frosted islands; the lock screen is where you see her.

---

[← docs index](../README.md) · [repo root](../../README.md)
