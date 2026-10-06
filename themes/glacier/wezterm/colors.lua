-- Glacier · frost terminal palette (ice on deep navy)
--
-- Background is `surface`, not `ground`: the deep ice the inputs are made of,
-- a shade up from the desktop floor so a terminal reads as a pane of the
-- theme rather than a hole in it. Every normal slot clears 4.5:1 on it and
-- the brights clear 6:1 (ratios in the comments) — WezTerm brightens bold
-- text to the bright slot by default, so the brights have to read as text,
-- not just as swatches. Cold throughout: the one magenta is a lavender, and
-- warm shows up only in the ANSI red/green/yellow slots, which keep real hues
-- because ls and git mean something by them; the bar's own warn/ok are the
-- palette's lavender and lit ice (palette.json), not these.
return {
    foreground    = "#e6eefc",           -- text (snow)
    background    = "#15295a",           -- surface (deepIce)
    cursor_bg     = "#5bd7fa",           -- frame: an ice-cyan block...
    cursor_border = "#5bd7fa",
    cursor_fg     = "#0b1838",           -- ...with sky under it (10:1)
    selection_bg  = "#b6ecf9",           -- launcher: frost over the selection
    selection_fg  = "#0b1838",           -- sky on frost (13.6:1)
    ansi = {
        "#0b1838", -- black   = ground (sky)
        "#ff6b81", -- red     = urgent (5.1:1)
        "#7bd389", -- green   = the terminal's own green (7.7:1); not a bar role
        "#e9c46a", -- yellow  = the terminal's own yellow (8.4:1); not a bar role
        "#5aa0e6", -- blue    = the painting's mid blue, a notch up to clear 4.5:1 (5.1:1)
        "#b39df5", -- magenta = a cold lavender; the one hue not in the painting (6.1:1)
        "#e8f4ff", -- cyan    = readout, white ice: the READOUT slot — cyan-coded output
                   --           (symlinks, fastfetch's title) prints white here, as the
                   --           bar's readouts do (12.6:1)
        "#a9b6d9", -- white   = dormant lifted to body-text weight (6.9:1)
    },
    brights = {
        "#7f8fbf", -- dormant: comments, ghost text (4.4:1)
        "#ff8fa0", -- urgent, lighter (6.5:1)
        "#9fe3aa", -- ok, lighter (9.4:1)
        "#f3d58c", -- warn, lighter (9.8:1)
        "#78b4f0", -- the mid blue, lit (6.4:1)
        "#5bd7fa", -- bright magenta = the FRAME slot: ice cyan. Semantic, like
                   -- gruvbox's orange in the same slot — the fastfetch keys
                   -- (SGR 95) resolve here in every dark theme (8.4:1)
        "#ffffff", -- bright cyan = readoutBright: the lit lozenge, bold readout (14:1)
        "#e6eefc", -- bright white = text
    },
    tab_bar = { background = "#0b1838" }, -- ground
}
