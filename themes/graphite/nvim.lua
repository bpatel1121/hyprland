-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-day, which LazyVim ships (lua/lazyvim/plugins/
-- colorscheme.lua declares folke/tokyonight.nvim as its default), so unlike
-- gruvbox and cyberdream it needs no plugin added on the provisioning side.
-- Day is the light tokyonight: a near-white page with cool grey comments and
-- a violet/blue accent family — the closest shipped scheme to grey-ink-plus-
-- one-hue, where catppuccin-latte spends a dozen hues on the same page. One
-- fixup: the current line number wears the INK — paper on near-black, the
-- same solid-frame block the bar's active workspace pill gets.
return {
    colorscheme = "tokyonight-day",
    highlights = {
        CursorLineNr = { fg = "#e9e4e8", bg = "#2b2427", bold = true },
    },
}
