-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Exact palette match: the theme IS gruvbox. One fixup: the stock
-- CursorLineNr is too quiet — re-assert it in the theme's active yellow so
-- the current line number pops.
return {
    colorscheme = "gruvbox",
    highlights = {
        CursorLineNr = { fg = "#fabd2f", bold = true },
    },
}
