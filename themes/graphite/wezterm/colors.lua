-- Graphite · light terminal palette (grey ink on paper, one hue)
--
-- A LIGHT scheme, so the ANSI table is built for legibility on near-white: the
-- normal eight are the roles printed DOWN to >= 4.5:1 on `surface` (the inks),
-- the brights are the roles themselves wherever one already reads (>= 3:1) and
-- a lighter ink where it does not. WezTerm brightens bold text to the bright
-- slot by default (ls directories, bold warnings), so the brights have to read
-- as text too, not just as swatches.
--
-- A MONOCHROME scheme, so the hueless slots are pencil WEIGHTS, not hues: blue
-- and cyan (and their brights) are four greys between `frame` and `dim`, which
-- keeps syntax highlighting legible by weight — a directory in `ls` comes out
-- as hard pencil, a comment as a ghost. The one hue is the violet, in the
-- magenta slots: `readout` reads as-is (5.2:1) and `launcher` is its bright.
-- Brass, tritium and laser (warn/ok/urgent) keep red/green/yellow so a failing
-- test still says so, printed to ink weight for the normal slots.
return {
    foreground    = "#1d1719",           -- text (the visor) — the darkest ink
    background    = "#f6f3f5",           -- surface — the clean sheet
    cursor_bg     = "#2b2427",           -- frame: ink, as a block...
    cursor_border = "#2b2427",
    cursor_fg     = "#e9e4e8",           -- ...with paper print on it (12:1) — the bar's active pill
    selection_bg  = "#9c63a8",           -- launcher: the lit violet — a selection is a thing you act on
    selection_fg  = "#1d1719",           -- ink on violet (4.0:1)
    ansi = {
        "#2b2427", -- black   = frame. "Black" is the ink; inverse-video apps get paper on ink.
        "#ad3d51", -- red     = urgent, printed: laser ink (5.4:1)
        "#3f7049", -- green   = ok, printed: tritium ink (5.3:1)
        "#8f5f1a", -- yellow  = warn, printed: brass ink (5.0:1)
        "#5c5054", -- blue    = hard pencil (7.0:1) — the heaviest grey below ink
        "#8a4f96", -- magenta = readout: the violet eye, which reads unprinted (5.2:1)
        "#74676b", -- cyan    = soft pencil (4.9:1)
        "#a99fa5", -- white   = dormant: the strap grey. Faint on paper by design (2.3:1);
                   --           it is for text on colored fills, where it reads.
    },
    brights = {
        "#8f8181", -- dim: ghost text, comments (3.4:1)
        "#c4475c", -- urgent — laser red
        "#4f8a5a", -- ok — tritium green (3.7:1)
        "#a8731f", -- a lighter brass ink (3.7:1); the raw brass is 2.9:1 and cannot print
        "#857579", -- hard pencil, lighter (4.0:1)
        "#9c63a8", -- bright magenta = launcher: the lit violet (4.0:1). The identity
                   -- accent sits in the magenta slots in every theme; here it is the
                   -- only hue, so fastfetch's title points at 35 and its keys at the
                   -- grey blue slot (34) — see fastfetch/config.jsonc.
        "#928487", -- soft pencil, lighter (3.3:1) — a near neighbour of bright black
                   -- by necessity: eight greys have to fit between ink and paper.
        "#1d1719", -- bright white = text: bold-white emphasis is the strongest ink,
                   -- the gruvbox-light / solarized-light convention.
    },
    tab_bar = { background = "#e9e4e8" }, -- ground
}
