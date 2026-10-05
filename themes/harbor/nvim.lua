-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-night, which LazyVim ships (lua/lazyvim/plugins/
-- colorscheme.lua declares folke/tokyonight.nvim), so like glacier it needs
-- no plugin added on the provisioning side. LazyVim ships no warm scheme on
-- a teal ground (its two are tokyonight and catppuccin), so the base stays
-- the deepest of its grounds and the warmth is the fixup: the current line
-- number wears the FRAME — dusk on amber (8.5:1), the solid block the bar's
-- lit lozenge is the emissive cousin of — which is also what tells this
-- editor from glacier's on the same base.
return {
    colorscheme = "tokyonight-night",
    highlights = {
        CursorLineNr = { fg = "#0e1a20", bg = "#e0ab5a", bold = true },
    },
}
