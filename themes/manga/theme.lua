-- Manga · light (no upstream palette — every color is a grey lifted from the
-- wallpaper). A printed page: purely black and white, no hue anywhere, not
-- even for state. Same design language as the others — one frame color, one
-- readout color, everything else is state — but told by WEIGHT: the frame is
-- INK (#111111, the heaviest line), the readout is the drawing's ink one
-- weight under it, the launcher a mid ink, and urgent is pure black, the one
-- thing darker than the frame. What separates it from graphite: graphite
-- keeps one violet, manga keeps none. No glow, no scanlines: a page does not
-- emit. Border runs ink -> mid ink, the frame and the launcher.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(111111ff)", "rgba(4a4a4aff)" }, angle = 45 }, -- frame -> launcher
    inactive_border = "rgba(cfcfcfff)",              -- panelRule (hairline)
    rounding = 4, rounding_power = 2,   -- a printed panel's corner, nearly square: the islands' radius, one corner for the whole desktop
    active_opacity = 1.0, inactive_opacity = 0.97,
    -- Paper barely frosts: the lightest blur in the set, no vibrancy (there is
    -- no hue to pull through).
    blur   = { enabled = true, size = 4, passes = 2, vibrancy = 0.0 },
    -- A faint neutral shadow for lift; the page has no cast. Lighter than
    -- graphite's 0x2e — white windows over a white page want the least.
    shadow = { enabled = true, range = 12, render_power = 3, color = 0x26000000 },
    -- The wallpaper sweep on switch (swww): a short dissolve, a page turned.
    -- `simple` is step-based (bigger step = faster); no duration applies.
    transition = "simple --transition-step 16",
    -- Tab-group titles (SUPER+G): `text` on the active tab, `dormant` on the rest;
    -- the strip itself wears active_border / inactive_border (hyprland.lua).
    tab_text = "rgba(161616ff)",
    tab_text_inactive = "rgba(767676ff)",
    cursor = "Bibata-Modern-Classic",                -- dark pointer for a light desktop (AUR: bibata-cursor-theme-bin)
    polarity = "light",                              -- theme-apply.sh flips GTK/icons/prefers-color-scheme on this
    -- No border_motion, on purpose: ink is still. A printed line does not drift.
    dim_strength = 0.06,                             -- unfocused windows step back, lightly — dimming paper goes grey fast
}
