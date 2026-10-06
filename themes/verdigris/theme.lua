-- Verdigris · candlelit stone (no upstream palette — every color is sampled
-- from the picture). A gothic castle of black-green stone, its gates and
-- windows lit a pale witch-green. Same design language as the other dark
-- themes — one frame color, one readout color, everything else is state —
-- and the first green one: WITCHLIGHT (the gates' green) is the frame, BONE
-- (the window light, desaturated) is every readout, the SUN's pale
-- yellow-green is the launcher, and nothing is warm. The readouts are pale
-- on purpose: a green theme reads sickly the moment its type goes terminal
-- green, so the type is the window light, not the gate light.
-- The border runs witchlight -> bone at 45°, the gate's light meeting the
-- window's, and drifts at the slowest rate in the set: light moving along
-- wet stone.
return {
    gaps_in = 5, gaps_out = 14, border_size = 2,
    active_border  = { colors = { "rgba(7ea763ff)", "rgba(cfdcc3ff)" }, angle = 45 }, -- frame -> readout
    inactive_border = "rgba(2b372fff)",              -- hairline (cliff)
    rounding = 6, rounding_power = 2,    -- a gothic arch is not a round corner; 6 keeps it from gruvbox's 4
    active_opacity = 1.0, inactive_opacity = 0.94,
    -- Moderate blur, little vibrancy: the islands should show the olive sky
    -- through them as stone shows damp, not as glass — under harbor's 0.15.
    blur   = { enabled = true, size = 8, passes = 3, vibrancy = 0.10 },
    -- Pure black (the hueless exemption gruvbox and glacier use): this is the
    -- darkest theme and its windows sit in deep shadow, so the shadow is
    -- deeper and wider than the others' and carries no color at all —
    -- candlelight does not cast a green shadow.
    shadow = { enabled = true, range = 20, render_power = 3, color = 0x80000000 },
    -- The wallpaper sweep on switch (swww): the witchlight spreading out from
    -- the gate, slow. Flags after the type pass through.
    transition = "grow --transition-pos center --transition-duration 1.8",
    -- Tab-group titles (SUPER+G): `text` on the active tab, `dormant` on the rest;
    -- the strip itself wears active_border / inactive_border (hyprland.lua).
    tab_text = "rgba(d9dcc8ff)",
    tab_text_inactive = "rgba(8c9a74ff)",
    cursor = "Bibata-Modern-Classic",                -- dark pointer; installed for the light themes
    polarity = "dark",
    dim_strength = 0.12,                             -- unfocused windows step back
    -- Border motion at the slowest drift in the set — slower than glacier's
    -- 140 — light moving along wet stone.
    border_motion = 180,
}
