-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is catppuccin-latte, which LazyVim ships (lua/lazyvim/plugins/
-- colorscheme.lua declares catppuccin/nvim alongside tokyonight), so unlike
-- gruvbox and cyberdream it needs no plugin added on the provisioning side.
-- Latte is the light scheme whose accents already speak this palette — a
-- pink, a teal, a mustard yellow on off-white — where tokyonight-day is blue
-- on blue-gray. One fixup: the current line number wears the TAG — navy print
-- on the yellow, the same solid-frame block the bar's active workspace gets.
return {
    colorscheme = "catppuccin-latte",
    highlights = {
        CursorLineNr = { fg = "#13202a", bg = "#e9b92a", bold = true },
    },
}
