-- Harbor · dusk over water (no upstream palette — every color is sampled from
-- the picture). Amber lamplight on the sky's own teal-black. Same design
-- language as the other dark themes — one frame color, one readout color,
-- everything else is state — but here the two are ONE hue at two weights:
-- AMBER (the hoodie) is the frame, the hoodie lit is every readout, the way
-- graphite is ink and one violet. The SMOKE is the launcher, the one cool
-- thing, and the ground is teal-black, not glacier's navy: that is what keeps
-- this from reading as glacier, whose bar text is white and ice cyan.
-- The border IS the horizon: the smoke over amber, at 90° so the gradient runs
-- top to bottom — sky over lamplight on every window. The top stop is the
-- LAUNCHER role (the smoke) now, not the readout: the readout is amber.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(82e0faff)", "rgba(e0ab5aff)" }, angle = 90 }, -- launcher -> frame
    inactive_border = "rgba(243a44ff)",              -- hairline (clouds)
    rounding = 12, rounding_power = 2,   -- the islands' radius: one corner for the whole desktop
    active_opacity = 1.0, inactive_opacity = 0.94,
    -- Moderate blur: the islands should show the teal sky through them, but as
    -- dusk, not as frost — size 8 and a touch of vibrancy, under glacier's 10/0.25.
    blur   = { enabled = true, size = 8, passes = 3, vibrancy = 0.15 },
    -- A faint amber cast: the frame color at a low alpha, lamplight pooling
    -- under each window the way it pools on the pavement. Low, because this is
    -- a street lamp, not cyberpunk's neon bloom.
    shadow = { enabled = true, range = 16, render_power = 3, color = 0x40e0ab5a },
    -- The wallpaper sweep on switch (swww): a wave, low and slow, water coming
    -- in. Flags after the type pass through.
    transition = "wave --transition-angle 30 --transition-duration 2",
    -- Tab-group titles (SUPER+G): `text` on the active tab, `dormant` on the rest;
    -- the strip itself wears active_border / inactive_border (hyprland.lua).
    tab_text = "rgba(efe6d3ff)",
    tab_text_inactive = "rgba(62939fff)",
    cursor = "Bibata-Modern-Amber",                  -- warm pointer for a warm frame
    polarity = "dark",
    dim_strength = 0.12,                             -- unfocused windows step back
    -- No border_motion, deliberately: a still evening. Motion would spin the
    -- horizon and put the lit ground on top of the sky.
}
