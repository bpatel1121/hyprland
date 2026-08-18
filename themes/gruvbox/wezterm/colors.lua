-- Gruvbox dark terminal palette (morhetz/gruvbox, the canonical assignments)
return {
    foreground    = "#ebdbb2",
    background    = "#1d2021",           -- bg0_h (hard) — matches the desktop ground
    cursor_bg     = "#fe8019",           -- orange, the frame color
    cursor_border = "#fe8019",
    cursor_fg     = "#1d2021",
    selection_bg  = "#83a598",           -- muted blue, the readout color
    selection_fg  = "#1d2021",
    ansi = {
        "#282828", -- black   (bg0)
        "#cc241d", -- red
        "#98971a", -- green
        "#d79921", -- yellow
        "#458588", -- blue
        "#b16286", -- magenta
        "#689d6a", -- cyan (aqua)
        "#a89984", -- white (fg4)
    },
    brights = {
        "#928374", -- gray
        "#fb4934",
        "#b8bb26",
        "#fabd2f",
        "#83a598",
        "#fe8019", -- bright magenta = the FRAME slot: gruvbox's orange.
                   -- Semantic, like cyberpunk's pink in the same slot — the
                   -- fastfetch keys (SGR 95) resolve here in every theme.
        "#8ec07c",
        "#ebdbb2",
    },
    tab_bar = { background = "#1d2021" },
}
