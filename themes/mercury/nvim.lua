-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-night, which LazyVim ships (lua/lazyvim/plugins/
-- colorscheme.lua declares folke/tokyonight.nvim and catppuccin/nvim, and
-- nothing else), so like glacier, harbor, verdigris and vesper it needs no
-- plugin added on the provisioning side. Neither shipped family has a
-- monochrome style — tokyonight's four and catppuccin's four all spend a hue
-- set on the page — so this is NOT the mono scheme the rest of the theme is:
-- it is the darkest shipped one, and the hues it keeps are the same
-- exception the terminal makes (code is not legible by weight alone). One
-- fixup: the current line number wears the FRAME — black on chrome (15.6:1),
-- the solid block the bar's white lozenge is the emissive cousin of — which
-- is also what tells this editor from the other four on the same base.
return {
    colorscheme = "tokyonight-night",
    highlights = {
        CursorLineNr = { fg = "#000000", bg = "#dedede", bold = true },
    },
}
