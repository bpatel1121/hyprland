# The bar, and motion

Waybar is three frosted islands. Left: an Arch chip that opens the launcher,
workspaces 1–5 (always visible; dormant ones dim), then the media chip with a
live **soundwave fused to its edge** (`scripts/waybar-cava.sh` streams cava
frames as block glyphs, so it needs no waybar build flags and vanishes in
silence). Center: the clock, **alone**, so it sits at true screen center and
nothing variable-width can shift it. Right: the glance chips (next event, due
todos) leading the instrument panel — update counters, volume, bluetooth,
battery, tray — plus three watchdogs that render nothing at all until they
have something to say: temperature above 80°, the network when it drops, and
a DND bell while do-not-disturb is on. A power glyph closes the row and only
goes red when you hover it. `SUPER+R` (or the Arch chip) opens wofi as a
two-column icon grid.

Border motion is a daemon, not an animation: Hyprland's `borderangle` loop
is broken upstream (registers, never ticks — the #9251/#9313 regression
lineage), so `scripts/border-motion.sh` steps the gradient angle itself via
`hyprctl eval`, one eased step every 2 seconds — a pulse, not a spin. The
slow tick is load-bearing: every config write cancels in-flight animations,
and at 10 ticks/sec the daemon was clipping every workspace slide (the bug
that looked like "slide doesn't work"). theme-apply starts it only when the
active theme declares `border_motion`, kills it on switch, and it dies with
Hyprland. Workspaces slide; a switch between two empty workspaces shows
nothing moving, which is physics, not a regression.

---

[← docs index](README.md) · [repo root](../README.md)
