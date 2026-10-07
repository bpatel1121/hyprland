-- Mercury · liquid metal on true black (no upstream palette — every color is
-- a grey lifted from the wallpaper). A render of a liquid-metal figure, head
-- and shoulders, on pure black with faint white specks: purely black and
-- white, with chrome highlights, no hue anywhere, not even for state. Same
-- design language as the other dark themes — one frame color, one readout
-- color, everything else is state — but told by WEIGHT, the dark half of
-- manga's rule: the frame is CHROME (#dedede, the specular edge), the readout
-- is brushed silver one weight under it, the launcher the metal's lit mid
-- tone, and urgent is pure white, the only thing brighter than the frame —
-- the ramp runs brighter as it gets worse, metal heating white. The ground
-- is TRUE BLACK: the panel is an OLED and a black pixel is off. Border runs
-- chrome -> silver, the frame and the readout, and it moves: liquid metal.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(dededeff)", "rgba(b4b4b4ff)" }, angle = 45 }, -- frame -> readout
    inactive_border = "rgba(2a2a2aff)",              -- seam (hairline)
    rounding = 10, rounding_power = 2,   -- the islands' radius: one corner for the whole desktop
    active_opacity = 1.0, inactive_opacity = 0.94,
    -- Glacier's blur size with no vibrancy at all: there is nothing to
    -- saturate, and black glass over black should show the specks as soft
    -- points of light, not a tint.
    blur   = { enabled = true, size = 10, passes = 3, vibrancy = 0.0 },
    -- A WHITE halo: the chrome catching light, pooling under each window.
    -- White is the hueless exemption CI allows (pure black or white need no
    -- role); on true black a dark shadow would be invisible anyway.
    shadow = { enabled = true, range = 16, render_power = 3, color = 0x40ffffff },
    -- The wallpaper sweep on switch (swww): a fade. Metal does not sweep, it
    -- reflects — the picture changes in place. Flags after the type pass through.
    transition = "fade --transition-duration 1.2",
    -- Tab-group titles (SUPER+G): `text` on the active tab, `dormant` on the rest;
    -- the strip itself wears active_border / inactive_border (hyprland.lua).
    tab_text = "rgba(ecececff)",
    tab_text_inactive = "rgba(8c8c8cff)",
    cursor = "Bibata-Modern-Ice",                    -- cold white pointer on black (glacier's)
    polarity = "dark",
    dim_strength = 0.12,                             -- unfocused windows step back
    -- Border motion: liquid metal moves. A slow swim — faster than glacier's
    -- 140 (ice drifts), nowhere near cyberpunk's neon spin.
    border_motion = 90,
}
