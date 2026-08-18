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
    rounding = 10, rounding_power = 2,
    active_opacity = 1.0, inactive_opacity = 0.94,
    blur   = { enabled = true, size = 6, passes = 3, vibrancy = 0.12 },
    -- Ember, not bloom: neutral orange at modest alpha and a tighter range than
    -- cyberpunk's pink. Windows should look lit by the wallpaper's lanterns,
    -- not radiating their own light.
    shadow = { enabled = true, range = 14, render_power = 3, color = 0x59d65d0e }, -- d65d0e ember
}
