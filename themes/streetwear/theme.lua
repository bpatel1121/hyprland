-- Streetwear · light (no upstream palette — every color is lifted from the wallpaper)
-- Off-white paper panels over a flat periwinkle sky; the first LIGHT theme.
-- Same design language as the other two — one frame color, one readout color,
-- everything else is state — but printed, not lit: the yellow OFF-WHITE TAG is
-- the frame, NAVY (the bob, the tag's print) is the readout, and the
-- holographic PINK is the launcher. No glow, no scanlines: paper doesn't emit.
-- Border runs tag yellow -> holo pink, the two stickers on the jacket.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(e9b92aff)", "rgba(d66676ff)" }, angle = 45 },
    inactive_border = "rgba(e3dcd0ff)",              -- jacketSeam (hairline)
    rounding = 10, rounding_power = 2,  -- medium: a sticker's corner, not glass, not CRT
    active_opacity = 1.0, inactive_opacity = 0.96,
    blur   = { enabled = true, size = 6, passes = 2, vibrancy = 0.1 },
    -- Flat print: a faint neutral shadow for lift, no color cast. Light windows
    -- over a light sky need less shadow than dark ones, not more — 0x33 is a
    -- paper edge, where gruvbox's 0x59 is a lamp.
    shadow = { enabled = true, range = 14, render_power = 3, color = 0x33000000 },
    cursor = "Bibata-Modern-Classic",                -- dark pointer for a light desktop (AUR: bibata-cursor-theme-bin)
    polarity = "light",                              -- theme-apply.sh flips GTK/icons/prefers-color-scheme on this
    -- Border motion at a crawl: the yellow->pink edge drifts like a holographic
    -- sticker tilting in the light. Slower than gruvbox's lantern (110).
    dim_strength = 0.08,                             -- unfocused windows step back, lightly — dimming paper goes gray fast
    border_motion = 160,
}
