# hyprland

My Hyprland desktop as a theme system. This repo's root **is** `~/.config/hypr` —
[linux-setup](https://github.com/bpatel1121/linux-setup) clones it there during
provisioning; nothing to symlink.

One config, swappable skins: `hyprland.lua` holds layout, binds, and behavior,
and everything visual lives in `themes/<name>/`. Switching themes re-skins
Hyprland, waybar, wofi, mako, wezterm, and the wallpaper together.

## How it works

```
hyprland.lua                    behavior + binds; dofiles the active theme
hypridle.conf                   dim 5m -> lock 10m -> screen off 15m
scripts/
├── theme-switch.sh <name>      repoint themes/current → <name>, reload, apply
├── theme-apply.sh              sync wallpaper/waybar/mako/wezterm to current
├── theme-menu.sh               wofi picker (bound to SUPER+T)
├── waybar-updates.sh pacman|aur   update counters, as waybar JSON
├── waybar-cava.sh              streaming soundwave for the now-playing chip
├── border-motion.sh            rotates the border gradient (see "Motion")
├── sddm-apply.sh               install the theme's SDDM greeter (sudo, see below)
themes/
├── current -> <theme>          relative symlink — the single source of truth
│                               (gitignored: the ACTIVE theme is machine
│                               state; theme-apply creates it if missing)
├── gruvbox/                    dark · pixel alley (see "The gruvbox theme")
└── cyberpunk/
    ├── theme.lua               borders, gaps, blur, shadow (read by hyprland.lua)
    ├── wallpaper.webp
    ├── waybar/                 config.jsonc + style.css (floating islands)
    ├── wofi/style.css
    ├── mako/config             theme-apply symlinks ~/.config/mako/config here
    ├── hyprlock.conf           TEMPLATE — rendered, not symlinked (see below)
    ├── wlogout/                layout + style.css (power menu)
    ├── cava/config             visualizer, VU-meter gradient
    ├── fastfetch/config.jsonc  pink keys, cyan values
    ├── gtk/                    gtk.css + settings.ini -> GTK3 *and* GTK4
    ├── btop/theme.theme        linked in as themes/current.theme
    ├── starship.toml           minimal one-line prompt
    ├── sddm/                   login greeter (QML) — installed by sddm-apply.sh
    └── wezterm/colors.lua      read by wezterm.lua from linux-setup
```

Everything above is symlinked into place by `theme-apply.sh` — except
`hyprlock.conf`, which is **rendered** with `sed`, substituting the active
wallpaper path for `@WALLPAPER@`. hyprlang can't be relied on to expand `$HOME`,
and tracked files here must not contain absolute user paths, so the output lands
at `~/.config/hypr/hyprlock.conf` and is gitignored.

Theming reaches outside Hyprland too. `theme-apply.sh` links the theme's
`gtk/` into both `~/.config/gtk-3.0` and `~/.config/gtk-4.0` and then drives
`gsettings` (dark scheme, adw-gtk3-dark, Papirus-Dark, capitaine-cursors). The
css and the ini are deliberately redundant: GTK3 apps started outside a
portal/dconf session read the ini and never consult gsettings. Both theme
names degrade — a machine without `adw-gtk-theme` or Papirus falls back to
built-in `Adwaita-dark` rather than going white.

Three helpers are picked at runtime rather than hardcoded, so the repo works on
machines that lack them: the wallpaper daemon (`swww`, its renamed successor
`awww`, else `hyprpaper`), `starship` (the prompt is skipped if absent), and
`hyprexpo` (its keybind routes through `hyprctl dispatch`, so it is inert
rather than a config error when the plugin isn't built).

`hyprland.lua` loads the theme with `dofile` + `pcall`, so a missing or broken
theme falls back to safe defaults instead of a black screen. The `current`
symlink is deliberately **relative** — an absolute one would bake a username and
clone path into the repo.

## Session keys

| bind | action |
|---|---|
| `SUPER+CTRL+L` | lock (hyprlock) — **not** `SUPER+L`, which is `focus right` |
| `SUPER+ESCAPE` | power menu (wlogout) |
| `SUPER+TAB` | workspace overview (hyprexpo, if built — see below) |

Idle is handled by `hypridle`, started at login: backlight dims at 5 min, the
session locks at 10, the screen sleeps at 15.

## Switching

`SUPER+T` for the wofi picker, or:

```
~/.config/hypr/scripts/theme-switch.sh cyberpunk
```

Open wezterm windows recolor live: theme-apply nudges wezterm.lua's mtime,
which triggers WezTerm's config reload.

## The bar, and motion

Waybar is three frosted islands. Left: an Arch chip that opens the launcher,
then workspaces 1–5 (always visible; dormant ones dim). Center: the media
island — now-playing chip with a live **soundwave fused to its edge**
(`scripts/waybar-cava.sh` streams cava frames as block glyphs, so it needs no
waybar build flags and vanishes in silence), and the clock. Right: instrument
chips — update counters, volume, network, bluetooth, battery — and a power
glyph that only goes red when you hover it. `SUPER+R` (or the Arch chip)
opens wofi as a two-column icon grid.

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

## The login screen (SDDM)

SDDM is the one surface theme-apply.sh cannot reach: it runs as its own user
and reads `/usr/share/sddm/themes`, not `~/.config`. So the greeter is themed
by a separate, root-requiring step you run once per theme (not on every
switch):

```
sudo ~/.config/hypr/scripts/sddm-apply.sh
```

That copies `themes/current/sddm/` plus the theme's wallpaper into
`/usr/share/sddm/themes/hypr-<name>` and points SDDM at it via a drop-in in
`/etc/sddm.conf.d/` — `/etc/sddm.conf` itself is never touched. Preview it
without logging out:

```
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-cyberpunk
```

The greeter mirrors hyprlock — same wallpaper (dimmed the same amount), same
input-field geometry and colors, pink frame / cyan content / red only on
failure — so boot → login → lock reads as one design. It is plain Qt Quick,
no Qt5Compat/GraphicalEffects dependency. One caveat: Qt decodes the `.webp`
wallpaper only with `qt6-imageformats` installed (the script warns if it's
missing). A theme without an `sddm/` dir simply leaves the login screen alone.

## Adding a theme

Copy `themes/cyberpunk` to `themes/<name>`, swap the palette and wallpaper,
and it appears in the picker automatically. Only `theme.lua` is required —
every other file degrades gracefully if absent.

Beyond the visual table, `theme.lua` takes optional identity keys:
`border_motion = <deciseconds/revolution>` runs the border gradient in motion
(omit it for a still border), and `dim_strength = <0..1>` dims unfocused
windows so focus reads at a glance.

Themes are **dark by default**. A light theme declares itself with one line in
`theme.lua`:

```
polarity = "light",
```

theme-apply.sh reads that and flips the whole desktop's polarity in one go:
`prefer-light`, `adw-gtk3` instead of `-dark`, `Papirus-Light` — and because
Firefox and most websites honor `prefers-color-scheme`, the browser follows
without being told. (No light theme ships right now — the machinery is here
for whenever one does.)

## The cyberpunk theme

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
`pkill -SIGRTMIN+8 waybar` (repos) or `-SIGRTMIN+9` (AUR).

The session and screenshot pieces need `hyprlock hypridle fastfetch cava` from
`extra` and `wlogout` from the AUR. The desktop-wide theming adds
`adw-gtk-theme papirus-icon-theme capitaine-cursors qt6ct starship awww`,
all in `extra` — note upstream renamed `adw-gtk3` to
`adw-gtk-theme` and `swww` to `awww`, so the old names no longer resolve.

## The gruvbox theme

[Gruvbox dark](https://github.com/morhetz/gruvbox) over a pixel-art alley at
dusk — the same design language as cyberpunk with the temperament flipped from
neon to matte. The role assignments carry over one-to-one: **orange** is the
frame (islands' hairline, window border, mako's edge, btop's boxes), **muted sky blue** (`#83a598`, the alley's twilight)
is every readout, and state colors keep their meanings — yellow for pending
repo updates (Pac-Man stays yellow in every theme), green for AUR/charging,
red for alerts, purple reserved for wofi. What changes is the identity:
where cyberpunk is rounded neon glass, gruvbox is a **CRT terminal** —
near-sharp 4px corners everywhere (waybar panels, popovers, the lock input),
chunky 2px orange borders like TUI boxes, faint **scanlines** across the bar's
islands (a repeating background-image, so it's halo-safe), and the active
workspace drawn as a solid orange **block cursor**. No glow anywhere; the red
alert pulse is the only text-shadow in the theme. Cyberpunk glows; gruvbox
scans. The two themes share their waybar structure and wlogout `layout`; the
waybar configs diverge only in glyphs (neon dots vs indicator squares for
workspaces) — behavior identical, skin swapped, which is the repo's thesis.

`hyprexpo` is the one piece not installed by a package manager. It builds
out-of-tree via `hyprpm`, which needs a superuser prompt, so run it by hand:

```
hyprpm update && hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
```

Be aware it is compiled against one exact Hyprland version and breaks on every
Hyprland upgrade until `hyprpm update` is re-run.
