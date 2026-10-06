-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-night, which LazyVim ships (lua/lazyvim/plugins/
-- colorscheme.lua declares folke/tokyonight.nvim), so like glacier and harbor
-- it needs no plugin added on the provisioning side. LazyVim ships no green
-- scheme (its two are tokyonight and catppuccin; everforest would be a plugin
-- on the provisioning side, which is not this repo), so the base stays the
-- deepest of its grounds — the one whose comments are quietest, which is the
-- temperament here — and the green is the fixup: the current line number
-- wears the FRAME — rock on witchlight (6.5:1), the solid block the bar's
-- lit lozenge is the emissive cousin of — which is also what tells this
-- editor from glacier's and harbor's on the same base.
return {
    colorscheme = "tokyonight-night",
    highlights = {
        CursorLineNr = { fg = "#151712", bg = "#7ea763", bold = true },
    },
}
