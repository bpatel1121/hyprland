-- Mercury · dark terminal palette (silver on the metal's shadow side, hues only where they mean something)
--
-- The desktop is black and white; the terminal keeps muted real hues because
-- `ls` and `git` are not legible without them: a diff, a directory listing
-- and a failing test say what they say by red, green, yellow and blue, and a
-- screen with one metal cannot carry that by weight. So this is the ONE
-- place in the theme a real hue is allowed, and it is kept metallic — the
-- six hue slots are muted real hues (a dull red, a sage, a sand, a steel
-- blue, a mauve, a grey-teal), each pulled toward grey so they read as
-- tinted metal and printed to >= 4.5:1 on `surface`; the brights are the
-- same hues a step lighter (>= 6:1 — WezTerm brightens bold text to the
-- bright slot by default, so the brights have to read as text too, not just
-- as swatches). Every ratio below is on `surface`. This is manga's rule,
-- mirrored for a dark ground.
--
-- Background is `surface`, the metal's shadow side, not `ground`: on an OLED
-- `ground` is the panel switched off, and a terminal that is a hole in the
-- desktop has no edge against the gaps. The hueless slots are metal
-- WEIGHTS: black is the void, white the silver (the readout's weight — the
-- arrow, the venv chip, fastfetch's title), bright black the tarnish (dim),
-- bright white the type. The slot convention holds in spirit: bright magenta
-- is the FRAME (chrome — the identity slot in every theme, where fastfetch's
-- keys land), and the cyan slot, the readout's in the other dark themes, is
-- the grey-teal: cyan-coded output (symlinks) is the readout's cousin, the
-- one cool metal. The eleven hue literals (six normal, five bright — bright
-- magenta is the chrome) are the only non-role colors under themes/mercury.
return {
    foreground    = "#ececec",           -- text (speck)
    background    = "#101010",           -- surface — the shadow side, not the void
    cursor_bg     = "#dedede",           -- frame: a chrome block...
    cursor_border = "#dedede",
    cursor_fg     = "#000000",           -- ...with black under it (15.6:1) — the bar's lozenge one step under white
    selection_bg  = "#9a9a9a",           -- launcher: the lit mid tone — a selection is a thing you act on, as on the launcher's selected row
    selection_fg  = "#000000",           -- black on the mid tone (7.5:1)
    ansi = {
        "#000000", -- black   = ground (void). Inverse-video apps get silver on black.
        "#ad7272", -- red     = dull red, pulled toward grey (4.9:1) — not a role; the terminal's exception
        "#748c6e", -- green   = sage (5.2:1) — not a role
        "#9e8f68", -- yellow  = sand (6.0:1) — not a role
        "#728ca8", -- blue    = steel blue (5.5:1) — not a role
        "#9f829f", -- magenta = mauve (5.6:1) — not a role
        "#649494", -- cyan    = grey-teal (5.6:1) — not a role; the readout slot's cousin
        "#b4b4b4", -- white   = readout: the silver (9.2:1) — the arrow's weight in starship,
                   --           fastfetch's title; one step under the type, never faint
    },
    brights = {
        "#6a6a6a", -- dim: the tarnish — ghost text, comments (3.5:1)
        "#c68e8e", -- dull red, lighter (6.9:1) — not a role
        "#92aa8b", -- sage, lighter (7.6:1) — not a role
        "#bcae87", -- sand, lighter (8.6:1) — not a role
        "#90a9c3", -- steel blue, lighter (7.8:1) — not a role
        "#dedede", -- bright magenta = the FRAME slot: chrome (14.1:1). The identity sits
                   -- in this slot in every theme — fastfetch's keys (SGR 95) resolve
                   -- here, and the branch in starship.
        "#86b3b3", -- grey-teal, lighter (8.3:1) — not a role
        "#ececec", -- bright white = text: bold-white emphasis is the brightest type,
                   -- a step under the chrome.
    },
    tab_bar = { background = "#000000" }, -- ground: the void under the panes
}
