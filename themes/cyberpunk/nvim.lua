-- nvim for this theme — read through themes/current/ by linux-setup's
-- config/nvim/lua/plugins/colorscheme.lua (the generic mechanism; the colors
-- live HERE, with the theme, like every other surface).
--
-- Base is cyberdream (closest maintained neon scheme), retinted to the
-- Cybrcolors vocabulary the whole desktop speaks: pink = structure
-- (keywords — the bulk of the pop), cyan = readouts (functions, strings),
-- amber = literals. Green stays a STATE color, exactly like the bar.
local pink, cyan, amber = "#F230B2", "#29BECC", "#F2D230"
return {
    colorscheme = "cyberdream",
    highlights = {
        Keyword = { fg = pink },            ["@keyword"] = { fg = pink },
        Statement = { fg = pink },          ["@keyword.function"] = { fg = pink },
        Conditional = { fg = pink },        Repeat = { fg = pink },
        Function = { fg = cyan, bold = true },
        ["@function"] = { fg = cyan, bold = true },
        String = { fg = cyan },             ["@string"] = { fg = cyan },
        Constant = { fg = amber },          Number = { fg = amber },
        Boolean = { fg = amber },
        CursorLineNr = { fg = pink, bold = true },
    },
}
