-- Inkwash · light (no upstream palette — every color is lifted from the wallpaper)
-- Paper panels over a digital ink-wash painting: a horned, armored figure in
-- olive-black ink with gold filigree, a green cape and one cyan burst, on
-- white-grey paper. Same design language as the other themes — one frame
-- color, one readout color, everything else is state — but painted, not lit:
-- the GOLD FILIGREE is the frame, the armor's OLIVE INK is the readout, and the
-- CYAN BURST is the launcher. No glow, no scanlines: ink doesn't emit.
-- Border runs filigree gold -> cape green, the two pigments laid over the ink.
return {
    gaps_in = 5,
    gaps_out = 14,
    border_size = 2,
    active_border = { colors = { "rgba(c89a3eff)", "rgba(6f9a3aff)" }, angle = 45 },
    inactive_border = "rgba(d6d3cbff)",              -- paperEdge (hairline)
    rounding = 6,                                    -- small: a brush edge, not glass, not CRT
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 0.97,
    blur = { enabled = true, size = 6, passes = 2, vibrancy = 0.05 },
    -- Flat ink: a faint neutral shadow for lift, no color cast. Light windows
    -- over light paper need less shadow than dark ones, not more — 0x33 is a
    -- paper edge, where gruvbox's 0x59 is a lamp.
    shadow = { enabled = true, range = 12, render_power = 3, color = 0x33000000 },
    cursor = "Bibata-Modern-Classic",                -- dark pointer for a light desktop (AUR: bibata-cursor-theme-bin)
    polarity = "light",                              -- theme-apply.sh flips GTK/icons/prefers-color-scheme on this
    dim_strength = 0.08,                             -- unfocused windows step back, lightly — dimming paper goes grey fast
    -- No border_motion, deliberately: ink doesn't move. A brush stroke is laid
    -- once and dries; the gold -> green edge is a still line, not a sign.
}
