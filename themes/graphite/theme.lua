-- Graphite · light (no upstream palette — every color is lifted from the wallpaper)
-- Grey ink on near-white paper: the light MONOCHROME theme. Same design
-- language as the others — one frame color, one readout color, everything
-- else is state — but drawn, not lit: the frame is INK (near-black, the
-- barrel's heaviest line), and the one hue in the picture, the VIOLET EYE, is
-- the readout and the launcher — the thing you act on. No glow, no scanlines:
-- a sketch doesn't emit. Border runs ink -> violet, the line and the eye.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(2b2427ff)", "rgba(9c63a8ff)" }, angle = 45 },
    inactive_border = "rgba(cfc8cfff)",              -- paperEdge (hairline)
    rounding = 8, rounding_power = 2,   -- a card's corner: softer than the CRT, tighter than the glass
    active_opacity = 1.0, inactive_opacity = 0.97,
    blur   = { enabled = true, size = 6, passes = 2, vibrancy = 0.05 },
    -- Flat sketch: a faint neutral shadow for lift, no color cast. Light windows
    -- over light paper need less shadow than dark ones, not more — 0x2e is a
    -- pencil edge, where gruvbox's 0x59 is a lamp.
    shadow = { enabled = true, range = 12, render_power = 3, color = 0x2e000000 },
    cursor = "Bibata-Modern-Classic",                -- dark pointer for a light desktop (AUR: bibata-cursor-theme-bin)
    polarity = "light",                              -- theme-apply.sh flips GTK/icons/prefers-color-scheme on this
    -- No border_motion, on purpose: a mono theme holds still. The ink->violet
    -- edge is a drawn line, and a drawn line does not drift.
    dim_strength = 0.06,                             -- unfocused windows step back, lightly — dimming paper goes grey fast
}
