-- Gruvbox · dark (github.com/morhetz/gruvbox, MIT/X11)
-- Warm retro-terminal noir for the pixel-alley wallpaper. Same design language
-- as cyberpunk — one frame color, one readout color, everything else is state —
-- but the temperament flips from neon to matte: ORANGE is the frame (the
-- lantern light), AQUA is the readout, and glow is dialed way down because
-- gruvbox is lamplight, not neon. Border runs orange -> yellow, the two hues
-- of the alley's lit signage.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(fe8019ff)", "rgba(fabd2fff)" }, angle = 45 },
    inactive_border = "rgba(3c3836ff)",              -- bg1
    rounding = 4, rounding_power = 2,   -- near-sharp: CRT panels, softened one notch
    active_opacity = 1.0, inactive_opacity = 0.94,
    blur   = { enabled = true, size = 6, passes = 3, vibrancy = 0.12 },
    -- Full matte: a plain dark shadow for depth, no color cast. Gruvbox is
    -- pigment, not light — windows sit ON the alley, they don't glow over it.
    shadow = { enabled = true, range = 12, render_power = 3, color = 0x59000000 },
    cursor = "Bibata-Modern-Amber",                  -- warm amber pointer
    -- Border motion, but at a crawl: lantern-light drift, not neon spin.
    dim_strength = 0.10,                             -- unfocused windows step back
    border_motion = 110,
}
