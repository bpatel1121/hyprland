-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-day, which LazyVim ships (tokyonight is its default
-- colorscheme plugin), so like the other light theme it needs no plugin added
-- on the provisioning side. Day is the light variant whose type is INK rather
-- than pastel — dark, saturated keywords and strings on a near-white field —
-- which is the closest a stock scheme gets to pigment on paper. One fixup:
-- the current line number wears the gold — an INK digit on the filigree
-- (6.7:1; a paper digit on gold is 2.1:1 and vanishes), the same block the
-- terminal's cursor is.
return {
    colorscheme = "tokyonight-day",
    highlights = {
        CursorLineNr = { fg = "#1c1b14", bg = "#c89a3e", bold = true },
    },
}
