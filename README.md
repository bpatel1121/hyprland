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
scripts/
├── theme-switch.sh <name>      repoint themes/current → <name>, reload, apply
├── theme-apply.sh              sync wallpaper/waybar/mako/wezterm to current
└── theme-menu.sh               wofi picker (bound to SUPER+T)
themes/
├── current -> cyberpunk        relative symlink — the single source of truth
└── cyberpunk/
    ├── theme.lua               borders, gaps, blur, shadow (read by hyprland.lua)
    ├── wallpaper.webp
    ├── waybar/                 config.jsonc + style.css (floating islands)
    ├── wofi/style.css
    ├── mako/config             theme-apply symlinks ~/.config/mako/config here
    └── wezterm/colors.lua      read by wezterm.lua from linux-setup
```

`hyprland.lua` loads the theme with `dofile` + `pcall`, so a missing or broken
theme falls back to safe defaults instead of a black screen. The `current`
symlink is deliberately **relative** — an absolute one would bake a username and
clone path into the repo.

## Switching

`SUPER+T` for the wofi picker, or:

```
~/.config/hypr/scripts/theme-switch.sh cyberpunk
```

Open wezterm windows recolor live: theme-apply nudges wezterm.lua's mtime,
which triggers WezTerm's config reload.

## Adding a theme

Copy `themes/cyberpunk` to `themes/<name>`, swap the palette and wallpaper,
and it appears in the picker automatically. Only `theme.lua` is required —
every other file degrades gracefully if absent.

## The cyberpunk theme

[Cybrcolors](https://github.com/cybrcore/cybrcolors) palette — neon pink/cyan
on near-black. Waybar runs as three detached "islands" (workspaces+media /
clock / instruments) with glow reserved for the active workspace, the clock,
and alert states. The updates module needs `checkupdates` (`pacman-contrib`);
icons want a Nerd Font (`ttf-jetbrains-mono-nerd`) — both provisioned by
linux-setup.
