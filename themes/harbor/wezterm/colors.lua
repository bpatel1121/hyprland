-- Harbor · dusk terminal palette (lamplight on the skyline's teal-navy)
--
-- Background is `surface`, not `ground`: the skyline's teal-navy, a shade up
-- from the sky's teal-black so a terminal reads as a pane of the theme rather
-- than a hole in it. Every normal slot clears 4.5:1 on it and the brights
-- clear 6:1 (ratios in the comments) — WezTerm brightens bold text to the
-- bright slot by default, so the brights have to read as text, not just as
-- swatches.
-- The readout slot convention BENDS here, because the readout is warm. The
-- frame slot holds (bright magenta = the hoodie's amber, where the fastfetch
-- keys land), but the cyan slot is the SMOKE (`launcher`), not the readout:
-- cyan-coded output (symlinks, fastfetch's title) must stay cyan, and the
-- smoke is the picture's one cyan. The amber readout has no slot of its own.
-- The literals that are not roles are each named where they sit: the lighter
-- brights and the white slot are a role printed a step up or down, and four
-- need a reason. `urgent` (the hair's red) is 3.9:1 here, fine for a glyph on
-- the bar but not for an error line, so the red slot is that red a notch up;
-- the picture has no blue or magenta light, so those two slots are the
-- water's ripple blue lifted to text weight and a dusk rose, the one hue not
-- in the picture; and bright cyan is the smoke lit (#b5ecfb), the bold weight
-- of the cyan slot.
return {
    foreground    = "#efe6d3",           -- text (cream)
    background    = "#172730",           -- surface (skyline)
    cursor_bg     = "#e0ab5a",           -- frame: an amber block...
    cursor_border = "#e0ab5a",
    cursor_fg     = "#0e1a20",           -- ...with dusk under it (8.5:1)
    selection_bg  = "#82e0fa",           -- launcher: the smoke over the selection, as on the launcher's selected row
    selection_fg  = "#0e1a20",           -- dusk on smoke (11.8:1)
    ansi = {
        "#0e1a20", -- black   = ground (dusk)
        "#ee5c4f", -- red     = urgent, the hair's red a notch up to clear 4.5:1 (4.6:1);
                   --           same hue, still apart from the pavement's orange next door
        "#7dd3a6", -- green   = ok, sea glass (8.6:1)
        "#f27c35", -- yellow  = warn, the lamplit pavement (5.6:1)
        "#7595d7", -- blue    = the water's ripple blue (#414f6e), lifted to text weight (5.1:1)
        "#d47da8", -- magenta = a dusk rose; the one hue not in the picture (5.3:1)
        "#82e0fa", -- cyan    = launcher, the smoke: cyan-coded output (symlinks,
                   --           fastfetch's title) prints the smoke here, the one cool
                   --           thing, as the launcher does (10.2:1)
        "#95b4bb", -- white   = dormant lifted to body-text weight (7.0:1)
    },
    brights = {
        "#62939f", -- dormant: comments, ghost text (4.5:1)
        "#f2877d", -- urgent, lighter (6.2:1)
        "#a3e3c0", -- ok, lighter (10.5:1)
        "#f79a5f", -- warn, lighter: the pavement nearer the lamp (7.1:1)
        "#90abdf", -- the ripple blue, lit (6.6:1)
        "#e0ab5a", -- bright magenta = the FRAME slot: the hoodie's amber. Semantic,
                   -- like gruvbox's orange in the same slot — the fastfetch keys
                   -- (SGR 95) resolve here in every dark theme (7.4:1)
        "#b5ecfb", -- bright cyan = the smoke lit: bold cyan output (11.9:1)
        "#efe6d3", -- bright white = text
    },
    tab_bar = { background = "#0e1a20" }, -- ground
}
