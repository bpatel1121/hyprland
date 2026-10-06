# The gruvbox theme

[Gruvbox dark](https://github.com/morhetz/gruvbox) over a pixel-art alley at
dusk — the same design language as cyberpunk with the temperament flipped from
neon to matte. The role assignments carry over one-to-one: **orange** is the
frame (islands' hairline, window border, notification edge, btop's boxes), **muted sky blue** (`#83a598`, the alley's twilight)
is every readout, and state colors keep their meanings — yellow for
do-not-disturb, green for a charging battery, red for alerts, purple
reserved for the launcher; pending updates light up in the readout blue. What changes is the
identity: where cyberpunk is rounded neon glass, gruvbox is a **CRT
terminal** — near-sharp 4px corners everywhere (the bar's islands and chips,
the launcher, the OSD, the power tiles, tooltips, the lock input), chunky 2px
orange frames like TUI boxes, faint **scanlines** riding every panel fill
(`effects.texture` `scanlines`, drawn by `Texture.qml`: a canvas clipped
inside the frame, exactly where the old repeating background-image sat), and the active workspace drawn as a solid
orange **block cursor**. No glow anywhere; the red alert pulse is the only
one, and it is the one glow both themes draw. Cyberpunk glows; gruvbox scans —
and all of it is a few radii, frame widths and two booleans in `palette.json` (`effects`,
`bar`, `launcher`, `osd`, `session`), the same QML as cyberpunk underneath.
The two themes don't merely share their bar structure and power-menu layout —
they share the *file*: `quickshell/settings.json` is the behavior for both,
and a theme is a palette and a wallpaper. Behavior identical, skin swapped,
which is the repo's thesis, now enforced by the file layout instead of by
discipline.

---

[← docs index](../README.md) · [repo root](../../README.md)
