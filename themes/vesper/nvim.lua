-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-night, which LazyVim ships (lua/lazyvim/plugins/
-- colorscheme.lua declares folke/tokyonight.nvim), so like glacier, harbor
-- and verdigris it needs no plugin added on the provisioning side — and of
-- the two LazyVim ships it is the one whose ground is a night blue, which is
-- this theme's ground too, so the editor sits with the cobalt without a
-- fixup to its background. The rim is the fixup: the current line number
-- wears the FRAME — night on rim red (5.1:1), the solid block the bar's lit
-- lozenge is the emissive cousin of — which is also what tells this editor
-- from glacier's, harbor's and verdigris's on the same base.
return {
    colorscheme = "tokyonight-night",
    highlights = {
        CursorLineNr = { fg = "#0a1c36", bg = "#f25a3c", bold = true },
    },
}
