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
-- --allow-images + columns turns wofi from a dmenu strip into an icon-grid
-- launcher; the theme css sizes it. Width/height here rather than css because
-- wofi treats geometry as config, not style.
local menu        = "wofi --show drun --allow-images --columns 2 --width 640 --height 480 --style " .. os.getenv("HOME") .. "/.config/hypr/themes/current/wofi/style.css"


-------------------
---- AUTOSTART ----
-------------------
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    -- Wallpaper daemon. swww/awww cross-fades on theme switch; hyprpaper is the
    -- fallback when it isn't installed. Only ONE may run — they fight over the
    -- background — so theme-apply.sh picks whichever it finds and this starts
    -- the same one. (Upstream renamed swww -> awww; both names are handled.)
    hl.exec_cmd("sh -c 'command -v swww-daemon >/dev/null && exec swww-daemon; "
             .. "command -v awww-daemon >/dev/null && exec awww-daemon; "
             .. "exec hyprpaper'")
    -- Notification daemon: swaync (notification center + toggles panel),
    -- falling back to mako on a box that only has that — degrade, don't die.
    hl.exec_cmd("sh -c 'command -v swaync >/dev/null && exec swaync; exec mako'")
    -- Volume/brightness OSD server (clients fire from the binds below).
    hl.exec_cmd("sh -c 'command -v swayosd-server >/dev/null && exec swayosd-server'")
    hl.exec_cmd("hypridle")                                    -- dim -> lock -> dpms off
    -- Battery/charger events through the themed notifications (laptops; a
    -- desktop simply never triggers them). -s skips the startup replay.
    hl.exec_cmd("sh -c 'command -v poweralertd >/dev/null && exec poweralertd -s'")
    -- Calendar alert daemon: themed "in N minutes" / "now" notifications from
    -- the plain-text events file (see scripts/calendar-lib.sh).
    hl.exec_cmd(home .. "/.config/hypr/scripts/calendar-notify.sh")
    -- Polkit agent. Without one running, anything that asks for privilege
    -- escalation through polkit (GUI installers, disk mounts, some settings
    -- panels) fails silently with no prompt at all. The package was installed
    -- but never started, so this had been quietly broken.
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd(home .. "/.config/hypr/scripts/theme-apply.sh")-- themed waybar + wallpaper
    hl.exec_cmd("firefox")
    -- hl.exec_cmd(terminal)  -- you had this: opens a terminal on every login. Uncomment if wanted.
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- Qt apps have no platform theme of their own on a bare Wayland session, so
-- they'd render in default Fusion light. qt6ct (with Kvantum available as the
-- engine) is what lets them follow the dark palette like GTK apps do.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
-- GPU: this box has BOTH an Intel UHD 630 (00:02.0) and an NVIDIA RTX 2070
-- (02:00.0), with nvidia-open-dkms installed and hyprland linked against
-- nvidia-utils. An older comment here claimed "Intel graphics only, no NVIDIA
-- env block needed" — that was wrong, so don't trust it if it resurfaces.
--
-- No NVIDIA env block is set all the same, because nothing currently misbehaves
-- and the modern driver needs far less coaxing than it used to. If you hit
-- flickering, black textures in XWayland, or cursor glitches, that's the first
-- thing to revisit: https://wiki.hypr.land/Configuring/Nvidia/


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

-- Cursor theme comes from the ACTIVE theme (cursor = "..." in theme.lua),
-- falling back to capitaine. Env covers newly launched apps; theme-apply's
-- `hyprctl setcursor` + gsettings handle the live switch.
hl.env("XCURSOR_THEME", (type(theme.cursor) == "string" and theme.cursor) or "capitaine-cursors")

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
        -- Focus reads instantly when everything else steps back half a stop.
        -- Themes tune it with dim_strength; omit to disable.
        dim_inactive = type(theme.dim_strength) == "number",
        dim_strength = theme.dim_strength or 0.0,
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
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "slide" })   -- wofi drops in, mako glides in
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
-- Workspaces SLIDE. Only visible when windows exist to move — an empty->empty
-- switch shows nothing, which is not a bug. If slides ever look clipped,
-- suspect anything that writes config at high frequency (see border-motion.sh,
-- deliberately throttled to one step per 2s for exactly this reason).
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 2.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 2.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 2.8,  bezier = "easeOutQuint", style = "slide" })
-- The scratchpad crossfades instead: it's an overlay appearing above your
-- space, not a place you travel to — different physics, different verb.
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1.8, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Border motion (borderangle loop) is NOT set here: the Lua animation binding
-- doesn't expose borderangle, so theme-apply.sh applies it via
-- `hyprctl keyword` from the theme's `border_motion` key instead. Reload wipes
-- keywords, but theme-switch reloads before theme-apply, so the order holds.

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

-- Agenda: upcoming events in a themed wofi window; top row edits the file.
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/calendar-menu.sh"))

-- Todos: todoman's list in the same floating-terminal shape (todo new / todo
-- done from the shell it leaves open). Same vdir as the calendar.
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/todo-menu.sh"))

-- Session. Lock is on SUPER+CTRL+L, not SUPER+L — that one is already `focus
-- right` in the vim-direction block below. Both surfaces are themed and follow
-- themes/current/.
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + ESCAPE",   hl.dsp.exec_cmd("wlogout -p layer-shell"))

-- Screenshots (grim + slurp + wl-clipboard — all installed)
-- Screenshots confirm themselves: clipboard captures are invisible actions,
-- and invisible actions breed double-takes. The toast is the receipt.
hl.bind("Print",         hl.dsp.exec_cmd("grim - | wl-copy && notify-send -t 2500 'Screenshot' 'full screen copied to clipboard'"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy && notify-send -t 2500 "Screenshot" "region copied to clipboard"'))

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

-- Volume / brightness on SUPER + F-keys, through swayosd so an on-screen
-- pill answers every press; falls back to bare wpctl/brightnessctl when
-- swayosd isn't installed — same action, just silent.
hl.bind("SUPER + F1", hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && exec swayosd-client --output-volume mute-toggle; wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'"),   { repeating = true })
hl.bind("SUPER + F2", hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && exec swayosd-client --output-volume lower; wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'"),    { repeating = true })
hl.bind("SUPER + F3", hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && exec swayosd-client --output-volume raise; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+'"),{ repeating = true })
hl.bind("SUPER + F5", hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && exec swayosd-client --brightness lower; brightnessctl set 5%-'"),                         { repeating = true })
hl.bind("SUPER + F6", hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && exec swayosd-client --brightness raise; brightnessctl set 5%+'"),                         { repeating = true })

-- Notification center (swaync): history, DND toggle, sliders.
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t"))

-- Media keys (playerctl — in linux-setup's packages/pacman.txt)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Frost the waybar islands. The bar surface itself is fully transparent and the
-- islands are ~0.72 alpha, so `ignore_alpha` keeps the gaps between islands
-- perfectly clear and blurs only the islands themselves. Without this the
-- translucent islands show raw wallpaper and read as flat dark boxes.
hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "^waybar$" },
    blur  = true,
    ignore_alpha = 0.35,
})

-- The other three layer surfaces get the same treatment, or they sit flat and
-- opaque next to a frosted bar. Lower ignore_alpha than waybar's because these
-- are solid panels rather than islands floating on a transparent sheet.
-- Namespaces: mako calls itself "notifications" and wlogout "logout_dialog"
-- (both confirmed in their binaries); wofi's could not be confirmed the same
-- way, so verify with `hyprctl layers` while it's open if the blur looks absent.
hl.layer_rule({
    name  = "wofi-blur",
    match = { namespace = "^wofi$" },
    blur  = true,
    ignore_alpha = 0.2,
})
hl.layer_rule({
    name  = "mako-blur",
    match = { namespace = "^notifications$" },
    blur  = true,
    ignore_alpha = 0.2,
})
hl.layer_rule({
    name  = "swaync-blur",
    match = { namespace = "^swaync-(notification-window|control-center)$" },
    blur  = true,
    ignore_alpha = 0.2,
})
hl.layer_rule({
    name  = "swayosd-blur",
    match = { namespace = "^swayosd$" },
    blur  = true,
    ignore_alpha = 0.2,
})
hl.layer_rule({
    name  = "wlogout-blur",
    match = { namespace = "^(wlogout|logout_dialog)$" },
    blur  = true,
    ignore_alpha = 0.2,
})

-- The calendar floats: ikhal is a peek-at-your-week surface, not a tiling
-- citizen. Centered, laptop-friendly size.
hl.window_rule({
    name  = "ikhal-float",
    match = { class = "^ikhal$" },
    float = true,
    size  = { 1000, 640 },   -- vec2: positional, not named
    center = true,
})

-- The todo list floats too — smaller than the calendar; it's a glance-and-go
-- surface (SUPER+SHIFT+A).
hl.window_rule({
    name  = "todos-float",
    match = { class = "^todos$" },
    float = true,
    size  = { 900, 520 },
    center = true,
})

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
