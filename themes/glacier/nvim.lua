-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is tokyonight-night, which LazyVim ships (lua/lazyvim/plugins/
-- colorscheme.lua declares folke/tokyonight.nvim), so unlike gruvbox and
-- cyberdream it needs no plugin added on the provisioning side. Night over
-- storm: its ground is the deeper navy, and its accents — a sky blue, an ice
-- cyan, white-ish type — already speak this palette; storm is the same scheme
-- on blue-gray. One fixup: the current line number wears the FRAME — ground
-- on ice cyan, the solid block the bar's lit lozenge is the emissive cousin of.
return {
    colorscheme = "tokyonight-night",
    highlights = {
        CursorLineNr = { fg = "#0b1838", bg = "#5bd7fa", bold = true },
    },
}
