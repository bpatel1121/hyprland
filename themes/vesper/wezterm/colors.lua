-- Vesper · dusk terminal palette (peach on the sky's cobalt)
--
-- Background is `surface`, not `ground`: the cobalt a shade up from the night
-- side of the sky, so a terminal reads as a pane of the theme rather than a
-- hole in it. Every normal slot clears 4.5:1 on it (ratios in the comments)
-- and every bright but one clears 6:1 — WezTerm brightens bold text to the
-- bright slot by default, so the brights have to read as text, not just as
-- swatches. The one is the frame slot: the rim is 4.3:1 here, a rim and not
-- a text color, and what prints in it is short — the branch, fastfetch's keys.
-- The slot convention holds: bright magenta is the FRAME (the rim, where the
-- fastfetch keys land), cyan is the READOUT (peach — cyan-coded output such
-- as symlinks and fastfetch's title prints peach here, as the bar's readouts
-- do), bright cyan is readoutBright.
-- The literals that are not roles are each named where they sit: the lighter
-- brights and the white slot are a role printed a step up or down, and three
-- need a reason. `urgent` (the crimson) is 3.8:1 here, fine for a glyph on
-- the bar but not for an error line, so the red slot is the crimson a notch
-- up; the picture has no green — `ok` is the lit sky, and that IS the blue
-- slot — but green-coded output (diff +, executables) has to stay green, so
-- green is a jade chosen to sit with the cobalt; and magenta is the rose of
-- the low clouds (#b87c82), the one spare color in the picture, lifted to
-- text weight.
return {
    foreground    = "#f3e6dd",           -- text (cloud)
    background    = "#102a4e",           -- surface (cobalt)
    cursor_bg     = "#f25a3c",           -- frame: a rim-red block...
    cursor_border = "#f25a3c",
    cursor_fg     = "#0a1c36",           -- ...with night under it (5.1:1)
    selection_bg  = "#e48c74",           -- launcher: the rim's lit skin over the selection, as on the launcher's selected row
    selection_fg  = "#0a1c36",           -- night on the lit skin (6.7:1)
    ansi = {
        "#0a1c36", -- black   = ground (night)
        "#f4688a", -- red     = urgent, the crimson a notch up to clear 4.5:1 (4.9:1)
        "#8fcf9a", -- green   = a jade chosen to sit with the cobalt; not in the picture (7.9:1)
        "#f2c96b", -- yellow  = warn, the rim's gold (9.1:1)
        "#7fbdea", -- blue    = ok, the sky lit: the one state role in the ground's hue (7.1:1)
        "#d59aaa", -- magenta = the rose of the low clouds (#b87c82), lifted to text weight (6.2:1)
        "#eebfa6", -- cyan    = readout, peach: the READOUT slot — cyan-coded output
                   --           (symlinks, fastfetch's title) prints peach here, as the
                   --           bar's readouts do (8.6:1)
        "#a4b6c3", -- white   = dormant lifted to body-text weight (6.9:1)
    },
    brights = {
        "#839aab", -- dormant: comments, ghost text (4.9:1)
        "#f88fa6", -- urgent, lighter (6.5:1)
        "#aadfb3", -- the jade, lighter (9.5:1)
        "#f7d98f", -- warn, lighter: the gold nearer the rim's highlight (10.4:1)
        "#a6d4f2", -- ok, lighter: the sky at its brightest (9.1:1)
        "#f25a3c", -- bright magenta = the FRAME slot: the rim. Semantic, like
                   -- gruvbox's orange in the same slot — the fastfetch keys
                   -- (SGR 95) resolve here in every dark theme (4.3:1)
        "#ffe589", -- bright cyan = readoutBright: the rim's yellow highlight, bold readout (11.5:1)
        "#f3e6dd", -- bright white = text
    },
    tab_bar = { background = "#0a1c36" }, -- ground
}
