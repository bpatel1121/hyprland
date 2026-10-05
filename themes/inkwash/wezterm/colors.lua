-- Inkwash · light terminal palette (ink on paper)
--
-- A LIGHT scheme, so the ANSI table is built for legibility on white paper:
-- the normal eight are the roles printed DOWN to >= 4.5:1 on `surface` (the
-- inks), the brights are the roles themselves wherever one already reads
-- (>= 3:1) and a lighter ink where it does not — the filigree's gold is 2.4:1
-- on paper and would vanish as text, so neither yellow slot carries it raw.
-- WezTerm brightens bold text to the bright slot by default (ls directories,
-- bold warnings), so the brights have to read as text too, not just as
-- swatches. Ratios were computed, not eyeballed; re-run the math if a role moves.
return {
    foreground    = "#1c1b14",           -- text — the ink
    background    = "#f6f5f2",           -- surface — the whiter paper
    cursor_bg     = "#c89a3e",           -- frame: the gold filigree, as a block...
    cursor_border = "#c89a3e",
    cursor_fg     = "#1c1b14",           -- ...with ink print on it (6.7:1)
    selection_bg  = "#2a8ca6",           -- launcher: the cyan burst
    selection_fg  = "#1c1b14",           -- ink on the burst (4.4:1)
    ansi = {
        "#3f4d2a", -- black   = readout. "Black" is the olive ink; inverse-video apps get olive on paper (8.4:1).
        "#c0392b", -- red     = urgent, the sigil — already an ink (5.0:1)
        "#56782c", -- green   = ok, printed: the cape's ink (4.7:1)
        "#8a6a2a", -- yellow  = frame, printed: the gold ink (4.6:1)
        "#2e5c8a", -- blue    = the burst's deep water, inked bluer (6.4:1) — the painting has no blue but this
        "#8a3d58", -- magenta = wine: the sigil's red cooled (6.7:1). The one slot the painting
                   --           has no pigment for; apps that expect a magenta still get one.
        "#286884", -- cyan    = burstDeep, launcher printed (5.7:1)
        "#6f6f62", -- white   = dim, printed (4.7:1) — the gruvbox-light convention: "white" on
                   --           paper is a grey ink, so inverse-video and faint text both read.
    },
    brights = {
        "#8a8a7a", -- dim: ghost text, comments — the smoke (3.2:1)
        "#d04c3b", -- the sigil, lifted (4.0:1)
        "#6f9a3a", -- ok — the cape itself (3.0:1)
        "#a8822f", -- a lighter gold ink (3.3:1); the raw filigree cannot print
        "#3d76ad", -- the deep water, lifted (4.4:1)
        "#a85270", -- wine, lifted (4.7:1)
        "#2a8ca6", -- bright cyan = launcher, the burst as painted (3.6:1). The frame slot the
                   -- dark themes keep for their identity accent is gold here, which cannot
                   -- carry text on paper — so the terminal's accent is the burst, and
                   -- fastfetch's keys point at the gold ink slot (33) instead.
        "#1c1b14", -- bright white = text: bold-white emphasis is the strongest ink,
                   -- the gruvbox-light / solarized-light convention.
    },
    tab_bar = { background = "#ebe9e5" }, -- ground
}
