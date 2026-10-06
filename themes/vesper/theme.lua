-- Vesper · rim light on cobalt (no upstream palette — every color is sampled
-- from the picture). A girl floating above a cloud sea at dusk, lit from
-- behind by a sun below the horizon, every edge of her burning red-orange
-- against a cobalt sky. Same design language as the other dark themes — one
-- frame color, one readout color, everything else is state — and the second
-- dusk after harbor: RIM RED is the frame, PEACH (the horizon) is every
-- readout, the lit skin of the rim is the launcher. What separates it from
-- harbor: red and peach on COBALT, not amber on teal — nothing here is amber,
-- nothing is teal, and the bar sits on a clean cobalt sky.
-- The border runs rim -> peach at 0°, horizontal: red on the left fading to
-- peach on the right, light coming from the right the way the rim does. No
-- border_motion — she hangs still.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(f25a3cff)", "rgba(eebfa6ff)" }, angle = 0 }, -- frame -> readout
    inactive_border = "rgba(1d3d66ff)",              -- hairline (twilight)
    rounding = 10, rounding_power = 2,   -- the islands' radius: one corner for the whole desktop
    active_opacity = 1.0, inactive_opacity = 0.94,
    -- Moderate blur: the islands should show the cobalt sky through them as
    -- dusk, not as frost — harbor's numbers, under glacier's 10/0.25.
    blur   = { enabled = true, size = 8, passes = 3, vibrancy = 0.15 },
    -- A warm halo: the frame color at a low alpha, the rim's glow pooling
    -- under each window — like cyberpunk's bloom but red, and lower, because
    -- this is a sun below the horizon, not neon.
    shadow = { enabled = true, range = 16, render_power = 3, color = 0x48f25a3c },
    -- The wallpaper sweep on switch (swww): a wipe from the left, the way the
    -- light crosses her. Flags after the type pass through.
    transition = "wipe --transition-angle 0 --transition-duration 1.4",
    -- Tab-group titles (SUPER+G): `text` on the active tab, `dormant` on the rest;
    -- the strip itself wears active_border / inactive_border (hyprland.lua).
    tab_text = "rgba(f3e6ddff)",
    tab_text_inactive = "rgba(839aabff)",
    cursor = "Bibata-Modern-Ice",                    -- cold pointer on cobalt (glacier's)
    polarity = "dark",
    dim_strength = 0.12,                             -- unfocused windows step back
    -- No border_motion, deliberately: she hangs still, and the light comes
    -- from one side. Motion would carry the rim round to the left.
}
