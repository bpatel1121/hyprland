-- Manga · light terminal palette (ink on cardstock, hues only where they mean something)
--
-- The desktop is black and white; the terminal keeps ink-dark hues because
-- `ls` and `git` are not legible without them: a diff, a directory listing
-- and a failing test say what they say by red, green, yellow and blue, and a
-- page with one ink cannot carry that by weight. So this is the ONE place in
-- the theme a real hue is allowed, and it is kept inky — the six hue slots
-- are muted real hues (a brick red, a bottle green, an ochre, a slate blue, a
-- plum, a teal), each desaturated toward grey and printed to >= 4.5:1 on
-- `ground`; the brights are the same hues a step lighter (>= 3:1 — WezTerm
-- brightens bold text to the bright slot by default, so the brights have to
-- read as text too, not just as swatches). Every ratio below is on `ground`.
--
-- Background is `ground`, the cardstock under the page islands, not the
-- bright page itself: a full screen of `surface` is glare (graphite found the
-- same). The hueless slots are ink WEIGHTS, the page's own greys: black is
-- the frame's ink, white the mid ink (the launcher's weight), bright black is
-- pencil (dim), bright white the type. The slot convention holds in spirit:
-- bright magenta is the FRAME (ink — the identity slot in every theme, where
-- fastfetch's title lands here), and the cyan slot, the readout's in the
-- dark themes, is the teal:
-- cyan-coded output (symlinks) is the readout's cousin, the one cool ink.
-- The eleven hue literals (six normal, five bright — bright magenta is the
-- ink) are the only non-role colors under themes/manga.
return {
    foreground    = "#161616",           -- text (type) — the darkest ink but one
    background    = "#e8e8e8",           -- ground — cardstock, not the page (glare)
    cursor_bg     = "#111111",           -- frame: ink, as a block...
    cursor_border = "#111111",
    cursor_fg     = "#e8e8e8",           -- ...with cardstock print on it (15.4:1) — the bar's active block
    selection_bg  = "#4a4a4a",           -- launcher: the mid ink — a selection is a thing you act on
    selection_fg  = "#f5f5f5",           -- page on mid ink (8.1:1)
    ansi = {
        "#111111", -- black   = frame. "Black" is the ink; inverse-video apps get cardstock on ink.
        "#9e4a4a", -- red     = brick, desaturated (4.9:1) — not a role; the terminal's exception
        "#3f6e4a", -- green   = bottle green (4.8:1) — not a role
        "#7c5f24", -- yellow  = ochre (4.9:1) — not a role
        "#4a6684", -- blue    = slate (4.9:1) — not a role
        "#875483", -- magenta = plum (4.7:1) — not a role
        "#2f6e70", -- cyan    = teal (4.8:1) — not a role; the readout slot's cousin
        "#4a4a4a", -- white   = launcher: the mid ink (7.2:1) — the branch's weight in starship,
                   --           fastfetch's keys; a step under the type, never faint
    },
    brights = {
        "#858585", -- dim: pencil — ghost text, comments (3.0:1)
        "#b56a6a", -- brick, lighter (3.3:1) — not a role
        "#5a8a64", -- bottle green, lighter (3.3:1) — not a role
        "#9a7a34", -- ochre, lighter (3.3:1) — not a role
        "#6a86a4", -- slate, lighter (3.1:1) — not a role
        "#111111", -- bright magenta = the FRAME slot: ink (15.4:1). The identity sits in
                   -- this slot in every theme; here the identity is the ink, so
                   -- fastfetch's title points at 95 and its keys at white (37) —
                   -- see fastfetch/config.jsonc.
        "#4a8a8c", -- teal, lighter (3.2:1) — not a role
        "#161616", -- bright white = text: bold-white emphasis is the strongest ink,
                   -- the gruvbox-light / solarized-light convention.
    },
    tab_bar = { background = "#cfcfcf" }, -- hairline: a step under the cardstock, as ground is under the page
}
