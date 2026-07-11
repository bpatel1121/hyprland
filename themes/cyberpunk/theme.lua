-- Cyberpunk · Cybrcolors palette (github.com/cybrcore/cybrcolors, GPL-3.0)
-- Neon on near-black. pi0 pink -> cy0 cyan gradient border, pink glow shadow.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border   = { colors = { "rgba(f230b2ff)", "rgba(29beccff)" }, angle = 45 },
    inactive_border = "rgba(212638ff)",              -- me1
    rounding = 12, rounding_power = 2,
    active_opacity = 1.0, inactive_opacity = 0.92,
    blur   = { enabled = true, size = 8, passes = 3, vibrancy = 0.20 },
    shadow = { enabled = true, range = 22, render_power = 3, color = 0xccf230b2 }, -- pi0 glow
}
