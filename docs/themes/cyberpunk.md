# The cyberpunk theme

[Cybrcolors](https://github.com/cybrcore/cybrcolors) palette — neon noir on
near-black. The bar is **two-tone at rest** — a cyan instrument panel in a pink
frame. Pink is the frame and the light: waybar's island hairline and edge,
running straight into Hyprland's window bloom just beneath. Cyan is every
readout. The wofi launcher is violet — the one surface that covers the bar
rather than living in it, so it gets its own color. Every other color is
state rather than decoration and shows up only
when something is actually true — amber for pending repo updates (and nothing
else), green for pending AUR updates or a charging battery, red for low and
critical. Pink and cyan are kept apart by the island edge and never blended
into one gradient: that blend is what made the original palette read as candy
rather than cyberpunk.

Waybar runs as three detached "islands" (workspaces+media / clock / instruments)
sharing one pink accent hairline, frosted by the `waybar-blur` layer rule in
`hyprland.lua`. Glow is selective — the active workspace, the clock, and alert
states — and is built only from `text-shadow` and inset shadows: an outer
`box-shadow` on a layer-shell surface composites as a black halo in GTK3, which
is the bug the stylesheet header warns about at length.

The right island carries two update counters: a **Pac-Man** for repo updates
(`pacman` → Pac-Man, and Pac-Man is yellow anyway) and a **party popper** for
the AUR (`yay` → yay). Both stay on screen at zero and gray out there, so the
resting bar really is one color. They need `checkupdates` (`pacman-contrib`)
and `yay` respectively; icons want a Nerd Font (`ttf-jetbrains-mono-nerd`) —
all provisioned by linux-setup. Refresh either instantly with
`pkill -RTMIN+8 waybar` (repos) or `-RTMIN+9` (AUR). Note `RTMIN`, not
`SIGRTMIN`: procps rejects the `SIG` prefix on real-time signals, so the
longer spelling is a silent no-op. Refreshing by hand is rarely needed
anyway, since linux-setup installs a pacman hook that signals both counters
after every transaction, so they clear whether you update from the bar, a
shell, or `yay`. Both checks are wrapped in `timeout` for the same reason:
an uncapped network call inside a waybar module leaves it running, and
waybar will not spawn a second copy of a module still in flight, so every
refresh signal is dropped until it returns.

The session and screenshot pieces need `hyprlock hypridle fastfetch cava` from
`extra` and `wlogout` from the AUR. The desktop-wide theming adds
`adw-gtk-theme papirus-icon-theme capitaine-cursors qt6ct starship awww`,
all in `extra` — note upstream renamed `adw-gtk3` to
`adw-gtk-theme` and `swww` to `awww`, so the old names no longer resolve.

---

[← docs index](../README.md) · [repo root](../../README.md)
