# The gruvbox theme

[Gruvbox dark](https://github.com/morhetz/gruvbox) over a pixel-art alley at
dusk — the same design language as cyberpunk with the temperament flipped from
neon to matte. The role assignments carry over one-to-one: **orange** is the
frame (islands' hairline, window border, notification edge, btop's boxes), **muted sky blue** (`#83a598`, the alley's twilight)
is every readout, and state colors keep their meanings — yellow for pending
repo updates (Pac-Man stays yellow in every theme), green for AUR/charging,
red for alerts, purple reserved for wofi. What changes is the identity:
where cyberpunk is rounded neon glass, gruvbox is a **CRT terminal** —
near-sharp 4px corners everywhere (waybar panels, popovers, the lock input),
chunky 2px orange borders like TUI boxes, faint **scanlines** across the bar's
islands (a repeating background-image, so it's halo-safe), and the active
workspace drawn as a solid orange **block cursor**. No glow anywhere; the red
alert pulse is the only text-shadow in the theme. Cyberpunk glows; gruvbox
scans. The two themes don't merely share their bar structure and power-menu
layout — they share the *files*: both configs had drifted into byte-identical
copies, so the behavior moved to the repo root and each theme kept only a
`style.css` and a thin overlay. Behavior identical, skin swapped, which is the
repo's thesis, now enforced by the file layout instead of by discipline.

---

[← docs index](../README.md) · [repo root](../../README.md)
