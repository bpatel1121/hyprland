-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-day, which LazyVim ships (lua/lazyvim/plugins/
-- colorscheme.lua declares folke/tokyonight.nvim and catppuccin/nvim, and
-- nothing else), so like graphite it needs no plugin added on the
-- provisioning side. Neither shipped family has a monochrome style —
-- tokyonight's four and catppuccin's four all spend a hue set on the page —
-- so this is NOT the mono scheme the rest of the theme is: it is the lightest
-- shipped one, a near-white page with grey comments, and the hues it keeps
-- are the same exception the terminal makes (code is not legible by weight
-- alone). One fixup: the current line number wears the INK — cardstock on
-- #111111, the same solid-frame block the bar's active workspace gets.
return {
    colorscheme = "tokyonight-day",
    highlights = {
        CursorLineNr = { fg = "#e8e8e8", bg = "#111111", bold = true },
    },
}
