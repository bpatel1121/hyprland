# The cyberpunk theme

[Cybrcolors](https://github.com/cybrcore/cybrcolors) palette — neon noir on
near-black. The bar is **two-tone at rest** — a cyan instrument panel in a pink
frame. Pink is the frame and the light: the bar's island hairline and edge,
the OSD pill's frame, the power menu's tile edges, running straight into
Hyprland's window bloom just beneath. Cyan is every readout, and the OSD's
track. The launcher is violet — the one surface that covers the bar rather
than living in it, so it gets its own color. Every other color is
state rather than decoration and shows up only
when something is actually true — amber for do-not-disturb (and nothing
else), green for a charging battery, red for low and critical. Pink and cyan are kept apart by the island edge and never blended
into one gradient: that blend is what made the original palette read as candy
rather than cyberpunk.

The bar is three detached "islands" (workspaces+media / clock / instruments)
sharing one pink accent hairline — the 2px line along each island's inside top
edge, `bar.island.accentLine` in `palette.json` — frosted by the `qs-bar-blur`
layer rule in `hyprland.lua`. Glow is selective — the active workspace, the
clock, the launcher chip, a hovered power tile, the OSD readout, and alert
states — and is one palette switch, `effects.glow`, drawn by `GlowText.qml` as
a zero-offset drop shadow. The old stylesheets built it from `text-shadow`
alone because an outer `box-shadow` on a layer-shell surface composited as a
black halo in GTK3; QML has no such limit, but the glow stays on text, where
it was. Everything structural here — radius 14 glass, the 1px lit edge, the
hairline — is the `bar`, `launcher`, `osd` and `session` blocks of
`palette.json`, not a line of QML.

The right island carries two update counters: a **Pac-Man** for repo updates
(`pacman` → Pac-Man) and a **party popper** for the AUR (`yay` → yay). Both
stay on screen at zero and gray out there, and light up in the readout color
when there is something to install — the glyphs tell them apart, not a hue —
so the bar really is one color at rest and still one color when busy. They need `checkupdates` (`pacman-contrib`)
and `yay` respectively; icons want a Nerd Font (`ttf-jetbrains-mono-nerd`) —
all provisioned by linux-setup. Clicking either opens the upgrade in a
terminal, and the chip re-runs its script the moment that terminal exits —
no signal, no bar name inside a shell command (the old `pkill -RTMIN+8 waybar`
is gone with waybar, and linux-setup's pacman hook that sent it is now a
no-op; the counters otherwise refresh on their `intervalSec` from
`quickshell/settings.json`). Both checks are wrapped in `timeout` for the same
reason as ever: an uncapped network call inside a bar module leaves it running
and the counter frozen.

The session and screenshot pieces need `hyprlock hypridle fastfetch cava` from
`extra`; the shell needs `quickshell` (the power menu, launcher and OSD are
its, so `wlogout`, `wofi` and `swayosd` are no longer needed). The desktop-wide
theming adds
`adw-gtk-theme papirus-icon-theme capitaine-cursors qt6ct starship awww`,
all in `extra` — note upstream renamed `adw-gtk3` to
`adw-gtk-theme` and `swww` to `awww`, so the old names no longer resolve.

---

[← docs index](../README.md) · [repo root](../../README.md)
