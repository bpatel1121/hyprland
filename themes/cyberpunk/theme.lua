-- Cyberpunk · Cybrcolors palette (github.com/cybrcore/cybrcolors, GPL-3.0)
-- Amber on near-black, ye0 amber -> pi0 pink gradient border over a pink glow:
-- neon noir. The window chrome stays entirely warm so nothing sits next to the
-- bloom in teal — cy0 cyan is reserved for waybar's telemetry readouts, where
-- it's far enough from the pink to read as cold data rather than cotton candy.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(f2d230ff)", "rgba(f230b2ff)" }, angle = 45 },
    inactive_border = "rgba(212638ff)",              -- me1
    rounding = 12, rounding_power = 2,
    active_opacity = 1.0, inactive_opacity = 0.92,
    blur   = { enabled = true, size = 8, passes = 3, vibrancy = 0.20 },
    -- Glow is pi0 pink. Amber leads the window border gradient (amber -> pink);
    -- waybar's frame/hairline is pink (see waybar/style.css rule 5), and
    -- pink owns the bloom — amber-and-magenta neon noir, not the pink->teal
    -- gradient that read as cotton candy. Pink is much less searing than amber
    -- at the same alpha, so it can carry a wide, generous range.
    shadow = { enabled = true, range = 22, render_power = 3, color = 0xc4f230b2 }, -- pi0 glow
}
