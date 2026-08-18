-- Generated · Material You — rendered by scripts/theme-generate.sh (matugen)
-- Roles derive from the wallpaper: PRIMARY is the frame, SECONDARY the
-- readouts, TERTIARY the launcher. Structure and glow follow cyberpunk.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(ffb596ff)", "rgba(d2c78fff)" }, angle = 45 },
    inactive_border = "rgba(53443eff)",
    rounding = 12, rounding_power = 2,
    active_opacity = 1.0, inactive_opacity = 0.92,
    blur   = { enabled = true, size = 8, passes = 3, vibrancy = 0.20 },
    shadow = { enabled = true, range = 18, render_power = 3, color = 0x99ffb596 },
    dim_strength = 0.12,
    border_motion = 240,
}
