-- Streetwear · light terminal palette (ink on paper)
--
-- A LIGHT scheme, so the ANSI table is built for legibility on off-white: the
-- normal eight are the roles printed DOWN to >= 4.5:1 on `surface` (the inks),
-- the brights are the roles themselves wherever one already reads (>= 3:1) and
-- a lighter ink where it does not — the tag's yellow is 1.7:1 on paper and
-- would vanish as text, so neither yellow slot carries it. WezTerm brightens
-- bold text to the bright slot by default (ls directories, bold warnings), so
-- the brights have to read as text too, not just as swatches.
return {
    foreground    = "#1b2630",           -- text (tag print) — navy ink
    background    = "#fbf8f2",           -- surface — the whiter paper
    cursor_bg     = "#e9b92a",           -- frame: the yellow tag, as a block...
    cursor_border = "#e9b92a",
    cursor_fg     = "#13202a",           -- ...with navy print on it (9:1)
    selection_bg  = "#d66676",           -- launcher: the holographic sticker
    selection_fg  = "#13202a",           -- navy on pink (4.7:1)
    ansi = {
        "#13202a", -- black   = readout. "Black" is the ink; inverse-video apps get navy on paper.
        "#b83d5c", -- red     = urgent, printed (5.1:1)
        "#27755f", -- green   = ok, printed (5.2:1)
        "#8a6b0e", -- yellow  = frame, printed: the tag ink (4.7:1)
        "#3f6ca8", -- blue    = the sky, printed (5.1:1)
        "#c04a60", -- magenta = launcher, printed: the holo ink (4.5:1)
        "#1e6f7c", -- cyan    = the eyes, printed (5.5:1)
        "#98a4b6", -- white   = dormant: the quiet gray. Faint on paper by design (2.4:1);
                   --           it is for text on colored fills, where it reads.
    },
    brights = {
        "#7d8aa0", -- dim: ghost text, comments (3.3:1)
        "#d6476a", -- urgent
        "#2f8f74", -- ok — the eyes
        "#a67f0f", -- a lighter tag ink (3.5:1); the raw tag yellow cannot print
        "#5a84bb", -- the sky, barely inked (3.6:1)
        "#d66676", -- bright magenta = launcher pink. NOT the frame slot the other
                   -- two themes keep here: on paper the frame (yellow) is unreadable
                   -- as text, so the terminal's identity accent is the holo pink and
                   -- fastfetch's keys point at the ochre yellow slot (33) instead.
        "#2a8a98", -- the eyes, lighter (3.8:1)
        "#1b2630", -- bright white = text: bold-white emphasis is the strongest ink,
                   -- the gruvbox-light / solarized-light convention.
    },
    tab_bar = { background = "#f4efe8" }, -- ground
}
