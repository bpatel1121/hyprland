-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-day, which LazyVim ships (tokyonight is its default
-- colorscheme plugin), so like the other light theme it needs no plugin added
-- on the provisioning side. Day is the light variant whose type is INK rather
-- than pastel — dark, saturated keywords and strings on a near-white field —
-- which is the closest a stock scheme gets to pigment on paper. One fixup:
-- the current line number wears the gold — a paper digit on the filigree, the
-- same solid-frame block the bar's active workspace gets.
return {
    colorscheme = "tokyonight-day",
    highlights = {
        CursorLineNr = { fg = "#ebe9e5", bg = "#c89a3e", bold = true },
    },
}
