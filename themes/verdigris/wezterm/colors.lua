-- Verdigris · candlelit terminal palette (bone on the castle's shadowed stone)
--
-- Background is `surface`, not `ground`: the shadowed green-grey stone, a
-- shade up from the rock so a terminal reads as a pane of the theme rather
-- than a hole in it. Every normal slot clears 4.5:1 on it and the brights
-- clear 5.5:1 (ratios in the comments) — WezTerm brightens bold text to the
-- bright slot by default, so the brights have to read as text, not just as
-- swatches.
-- The slot convention holds: bright magenta is the FRAME (the witchlight,
-- where the fastfetch keys land), cyan is the READOUT (bone — cyan-coded
-- output such as symlinks and fastfetch's title prints bone here, as the
-- bar's readouts do), bright cyan is readoutBright.
-- The literals that are not roles are each named where they sit: the lighter
-- brights and the white slot are a role printed a step up or down, and the
-- four ANSI hues the picture does not have — red, yellow, blue, magenta —
-- are chosen to sit with the olive rather than against it. `urgent` (the
-- ember) is 3.9:1 here, fine for a glyph on the bar but not for an error
-- line, so the red slot is the ember a notch up; yellow is `warn`, the olive
-- sky, already a role; blue is a slate blue, the overcast's grey cooled, the
-- one hue not in the picture; magenta is a dusty heather, the olive's
-- complement muted until it sits with it.
return {
    foreground    = "#d9dcc8",           -- text (bone)
    background    = "#202928",           -- surface (stone)
    cursor_bg     = "#7ea763",           -- frame: a witchlight block...
    cursor_border = "#7ea763",
    cursor_fg     = "#151712",           -- ...with rock under it (6.5:1)
    selection_bg  = "#e3e894",           -- launcher: the sun over the selection, as on the launcher's selected row
    selection_fg  = "#151712",           -- rock on sun (14.0:1)
    ansi = {
        "#151712", -- black   = ground (rock)
        "#e07062", -- red     = urgent, the ember a notch up to clear 4.5:1 (4.7:1)
        "#a6d98a", -- green   = ok, the witchlight lit (9.2:1)
        "#c9b85a", -- yellow  = warn, the olive sky saturated (7.4:1)
        "#7d9bb3", -- blue    = a slate blue, the overcast's grey cooled; not in the picture (5.1:1)
        "#b58aa6", -- magenta = a dusty heather, the olive's complement muted; not in the picture (5.1:1)
        "#cfdcc3", -- cyan    = readout, bone: the READOUT slot — cyan-coded output
                   --           (symlinks, fastfetch's title) prints bone here, as the
                   --           bar's readouts do (10.4:1)
        "#aab59c", -- white   = dormant lifted to body-text weight (6.9:1)
    },
    brights = {
        "#8c9a74", -- dormant: comments, ghost text (5.0:1)
        "#e6857a", -- urgent, lighter (5.7:1)
        "#bfe6aa", -- ok, lighter: the witchlight at its brightest (10.7:1)
        "#dccd7e", -- warn, lighter: the sky nearer the sun (9.3:1)
        "#9db6c9", -- the slate blue, lit (7.1:1)
        "#7ea763", -- bright magenta = the FRAME slot: the witchlight. Semantic,
                   -- like gruvbox's orange in the same slot — the fastfetch keys
                   -- (SGR 95) resolve here in every dark theme (5.4:1)
        "#eef3e6", -- bright cyan = readoutBright: the lit windows, bold readout (13.2:1)
        "#d9dcc8", -- bright white = text
    },
    tab_bar = { background = "#151712" }, -- ground
}
