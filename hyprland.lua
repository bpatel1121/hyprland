-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- HYPRLAND CONFIG  ·  Hyprland 0.55+ (Lua)              --
-- Theme-switching setup. Visual identity lives in       --
-- ~/.config/hypr/themes/<name>/theme.lua                --
-- Switch with SUPER + T, or: scripts/theme-switch.sh    --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

local home = os.getenv("HOME")

------------------
---- MONITORS ----
------------------
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "wezterm start"                       -- main terminal (SUPER+Q)
local fileManager = "wezterm start -- yazi"
local menu        = "wofi --show drun --style " .. os.getenv("HOME") .. "/.config/hypr/themes/current/wofi/style.css"


-------------------
---- AUTOSTART ----
-------------------
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")                                   -- wallpaper daemon
    hl.exec_cmd("mako")                                        -- notifications
    hl.exec_cmd(home .. "/.config/hypr/scripts/theme-apply.sh")-- themed waybar + wallpaper
    hl.exec_cmd("firefox")
    -- hl.exec_cmd(terminal)  -- you had this: opens a terminal on every login. Uncomment if wanted.
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- You're on Intel graphics, so no NVIDIA env block is needed. If you ever move
-- rendering to the NVIDIA card, see https://wiki.hypr.land/Configuring/Nvidia/


-----------------------
---- LOOK AND FEEL ----
-----------------------
-- The active theme is loaded here. `dofile` (not `require`) is deliberate: it
-- re-reads the file on every `hyprctl reload`, so flipping the `current`
-- symlink + reloading applies the new theme. pcall guards against a missing or
-- broken theme file so you never get locked out at a black screen.
local ok, theme = pcall(dofile, home .. "/.config/hypr/themes/current/theme.lua")
if not ok or type(theme) ~= "table" then
    theme = {  -- safe fallback (Nord-ish) if no theme is selected yet
        gaps_in = 5, gaps_out = 16, border_size = 2,
        active_border   = { colors = { "rgba(88c0d0ff)", "rgba(5e81acff)" }, angle = 45 },
        inactive_border = "rgba(434c5eff)",
        rounding = 8, rounding_power = 2,
        active_opacity = 1.0, inactive_opacity = 1.0,
        blur   = { enabled = true, size = 4, passes = 2, vibrancy = 0.15 },
        shadow = { enabled = true, range = 6, render_power = 3, color = 0x66000000 },
    }
end

hl.config({
    general = {
        gaps_in  = theme.gaps_in,
        gaps_out = theme.gaps_out,
        border_size = theme.border_size,
        col = {
            active_border   = theme.active_border,
            inactive_border = theme.inactive_border,
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = theme.rounding,
        rounding_power = theme.rounding_power or 2,
        active_opacity   = theme.active_opacity   or 1.0,
        inactive_opacity = theme.inactive_opacity or 1.0,
        shadow = theme.shadow,
        blur   = theme.blur,
    },

    animations = {
        enabled = true,
    },
})

-- Animation curves + timings (shared across themes).
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Layouts
hl.config({ dwindle   = { preserve_split = true } })
hl.config({ master    = { new_status = "master" } })
hl.config({ scrolling = { fullscreen_on_one_column = true } })

----------------
----  MISC  ----
----------------
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})


---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Example per-device config (commented; matches nothing on your system):
-- hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })


---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Apps / session
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + X", hl.dsp.window.kill())
hl.bind(mainMod .. " + 0", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + N", hl.dsp.layout("togglesplit"))   -- dwindle only
-- Move focused window out of the scratchpad into the current workspace
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "e+0" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "1" }))

-- Theme switcher
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/theme-menu.sh"))

-- Screenshots (grim + slurp + wl-clipboard — all installed)
hl.bind("Print",         hl.dsp.exec_cmd("grim - | wl-copy"))               -- whole screen -> clipboard
hl.bind("SUPER + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy')) -- region select -> clipboard

-- Focus (arrows + vim HJKL)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }))

-- Swap windows (SHIFT + HJKL)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

-- Workspaces: SUPER + [0-9] to focus, SUPER + SHIFT + [0-9] to move window
for i = 1, 10 do
    local key = i % 10  -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad (special workspace "magic")
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume (wpctl / wireplumber — installed)
-- Volume / brightness on SUPER + F-keys (media keys aren't reaching Hyprland)
hl.bind("SUPER + F1", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { repeating = true })
hl.bind("SUPER + F2", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { repeating = true })
hl.bind("SUPER + F3", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),{ repeating = true })
hl.bind("SUPER + F5", hl.dsp.exec_cmd("brightnessctl set 5%-"),                         { repeating = true })
hl.bind("SUPER + F6", hl.dsp.exec_cmd("brightnessctl set 5%+"),                         { repeating = true })

-- Media keys (needs: sudo pacman -S playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class = "^$", title = "^$",
        xwayland = true, float = true, fullscreen = false, pin = false,
    },
    no_focus = true,
})
