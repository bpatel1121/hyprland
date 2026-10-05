-- Glacier · frost (no upstream palette — every color is lifted from the painting)
-- One hue, navy to ice, for the ice-throne wallpaper. Same design language as
-- the other dark themes — one frame color, one readout color, everything else
-- is state — but the temperament is cold and quiet: ICE CYAN (the swords) is
-- the frame, WHITE (the cap) is the readout, and the frost is structural
-- rather than painted on: heavy blur, translucent islands, a thin hairline.
-- Border runs ice cyan -> pale cyan, the two tones of a sword's edge; glow
-- is the one cold one (cyberpunk's is the other), and the shadow carries none
-- of it.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(5bd7faff)", "rgba(b6ecf9ff)" }, angle = 45 },
    inactive_border = "rgba(223b6eff)",              -- hairline (iceEdge)
    rounding = 12, rounding_power = 2,
    active_opacity = 1.0, inactive_opacity = 0.94,
    -- The frost. Biggest blur of any theme, and the most vibrancy: the layer
    -- rules push the bar's and launcher's translucent fills through this, so
    -- the painting reads as ice behind glass rather than a dimmed photo.
    blur   = { enabled = true, size = 10, passes = 3, vibrancy = 0.25 },
    -- Neutral: a plain cold shadow for depth, no color cast. The cyan glow is
    -- the bar's (palette.json bar.island.glow) and text's; windows stay on the
    -- ice, they don't light it.
    shadow = { enabled = true, range = 18, render_power = 3, color = 0x59000000 },
    cursor = "Bibata-Modern-Ice",                    -- cold white-blue pointer
    polarity = "dark",
    dim_strength = 0.12,                             -- unfocused windows step back
    -- Border motion at a slow drift, like light moving through ice — slower
    -- than gruvbox's lantern crawl, nowhere near cyberpunk's neon spin.
    border_motion = 140,
}
