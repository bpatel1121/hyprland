-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- HYPRLAND CONFIG  ·  Hyprland 0.55+ (Lua)              --
-- Theme-switching setup. Visual identity lives in       --
-- ~/.config/hypr/themes/<name>/theme.lua                --
-- Switch with SUPER + T, or: scripts/theme-switch.sh    --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

local home = os.getenv("HOME")
local scripts = home .. "/.config/hypr/scripts/"

-- Every optional dependency gets asked the same question: run it if it is on
-- PATH, else fall through to the next candidate. `command -v` inside `sh -c`
-- is how you ask that without assuming which shell answers.
--
-- The command lands inside SINGLE quotes, so a ' in one would end the string
-- early. No call site has one today; the escape is here so the next one does
-- not have to remember. The fallback is exec'd like the candidates, which
-- saves a lingering `sh` when it is the branch that runs.
local function shq(s)
    return (s:gsub("'", "'\\''"))
end

-- first_of({ "cmd --with args", ... }, fallback) -> a shell command string.
-- The first installed candidate wins; `fallback` runs when none are. Omit it
-- and nothing runs at all when none are installed.
local function first_of(candidates, fallback)
    local parts = {}
    for _, cmd in ipairs(candidates) do
        parts[#parts + 1] = "command -v " .. cmd:match("^%S+") .. " >/dev/null && exec " .. shq(cmd)
    end
    if fallback then
        parts[#parts + 1] = "exec " .. shq(fallback)
    end
    return "sh -c '" .. table.concat(parts, "; ") .. "'"
end

------------------
---- MONITORS ----
------------------
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1.5,
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "wezterm start" -- main terminal (SUPER+Q)
local fileManager = "wezterm start -- yazi"

-- The shell: one Quickshell process (quickshell/) owns the bar, the launcher,
-- the volume/brightness OSD and the power menu. Each is driven over its IPC
-- target, so a bind is "ask the shell", never "start a program".
local shell = home .. "/.config/hypr/quickshell"
local function qs(target, fn)
    return "qs ipc -p " .. shell .. " call " .. target .. " " .. fn
end
-- Volume/brightness go through the OSD so a pill answers every press; if the
-- shell is down the bare wpctl/brightnessctl still runs — same action, silent.
local function osd(fn, fallback)
    return "sh -c '" .. shq(qs("osd", fn)) .. " 2>/dev/null || " .. shq(fallback) .. "'"
end

-------------------
---- AUTOSTART ----
-------------------
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    -- Wallpaper daemon. swww/awww cross-fades on theme switch; hyprpaper is the
    -- fallback when it isn't installed. Only ONE may run — they fight over the
    -- background — so theme-apply.sh picks whichever it finds and this starts
    -- the same one. (Upstream renamed swww -> awww; both names are handled.)
    hl.exec_cmd(first_of({ "swww-daemon", "awww-daemon" }, "hyprpaper"))
    -- Notification daemon: swaync (notification center + toggles panel).
    hl.exec_cmd("swaync")
    -- The shell. -d detaches, -n refuses to start a second copy on reload.
    -- It reads themes/current/palette.json itself; theme-apply.sh only pokes it.
    hl.exec_cmd("qs -p " .. shell .. " -d -n")
    hl.exec_cmd("hypridle") -- dim -> lock -> dpms off
    -- Night light on a schedule (hyprsunset.conf next to this file): warm
    -- after 21:00, neutral again at 07:30. Silent when it isn't installed.
    hl.exec_cmd(first_of({ "hyprsunset" }))
    -- Battery/charger events through the themed notifications (laptops; a
    -- desktop simply never triggers them). -s skips the startup replay.
    hl.exec_cmd(first_of({ "poweralertd -s" }))
    -- Calendar alert daemon: themed "in N minutes" / "now" notifications from
    -- the plain-text events file (see scripts/calendar-lib.sh).
    hl.exec_cmd(scripts .. "calendar-notify.sh")
    -- Polkit agent. Without one running, anything that asks for privilege
    -- escalation through polkit (GUI installers, disk mounts, some settings
    -- panels) fails silently with no prompt at all. The package was installed
    -- but never started, so this had been quietly broken.
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    -- Through bash, not by path: a copy of the script that lost its executable
    -- bit (every file sync does this) then still applies, instead of leaving
    -- the desktop on the old wallpaper with no error anyone sees.
    hl.exec_cmd("bash " .. scripts .. "theme-apply.sh") -- wallpaper, cursor, GTK, symlinks
    hl.exec_cmd("firefox")
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
-- nvidia-utils. No NVIDIA env block is set all the same: nothing currently
-- misbehaves, and the modern driver needs far less coaxing than it used to.
-- If you hit flickering, black textures in XWayland, or cursor glitches, this
-- is the first thing to revisit: https://wiki.hypr.land/Configuring/Nvidia/

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- The active theme is loaded here. `dofile` (not `require`) is deliberate: it
-- re-reads the file on every `hyprctl reload`, so flipping the `current`
-- symlink + reloading applies the new theme. pcall guards against a missing or
-- broken theme file so you never get locked out at a black screen.
local ok, theme = pcall(dofile, home .. "/.config/hypr/themes/current/theme.lua")
if not ok or type(theme) ~= "table" then
    theme = { -- safe fallback (Nord-ish) if no theme is selected yet
        gaps_in = 5,
        gaps_out = 16,
        border_size = 2,
        active_border = { colors = { "rgba(88c0d0ff)", "rgba(5e81acff)" }, angle = 45 },
        inactive_border = "rgba(434c5eff)",
        rounding = 8,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = { enabled = true, size = 4, passes = 2, vibrancy = 0.15 },
        shadow = { enabled = true, range = 6, render_power = 3, color = 0x66000000 },
    }
end

-- Cursor theme comes from the ACTIVE theme (cursor = "..." in theme.lua),
-- falling back to capitaine. Env covers newly launched apps; theme-apply's
-- `hyprctl setcursor` + gsettings handle the live switch.
hl.env("XCURSOR_THEME", (type(theme.cursor) == "string" and theme.cursor) or "capitaine-cursors")

-- App popups (right-click menus, dropdowns, tooltips) take the same frost as
-- the shell's surfaces. Without this they are the one flat, opaque thing on a
-- frosted desktop. Set on the theme's own blur table so the size, passes and
-- vibrancy the theme chose carry over; 0.6 skips the fully transparent
-- shadow margins GTK draws around a menu.
theme.blur = theme.blur or { enabled = true }
theme.blur.popups = true
theme.blur.popups_ignorealpha = 0.6

hl.config({
    general = {
        gaps_in = theme.gaps_in,
        gaps_out = theme.gaps_out,
        border_size = theme.border_size,
        col = {
            active_border = theme.active_border,
            inactive_border = theme.inactive_border,
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = theme.rounding,
        rounding_power = theme.rounding_power or 2,
        active_opacity = theme.active_opacity or 1.0,
        inactive_opacity = theme.inactive_opacity or 1.0,
        -- Focus reads instantly when everything else steps back half a stop.
        -- Themes tune it with dim_strength; omit to disable.
        dim_inactive = type(theme.dim_strength) == "number",
        dim_strength = theme.dim_strength or 0.0,
        shadow = theme.shadow,
        blur = theme.blur,
    },

    animations = {
        enabled = true,
    },

    -- Tab groups (SUPER+G): the one window decoration Hyprland draws itself.
    -- Left alone it is a yellow bar in a default font. Here the group's border
    -- IS the theme's window border, the tab strip wears the frame on the
    -- active tab and the hairline on the rest, and the titles use the theme's
    -- text colors (theme.lua `tab_text` / `tab_text_inactive`). No gradient
    -- blocks behind the titles — a thin indicator under each, like the bar's
    -- own understatement.
    group = {
        col = {
            border_active = theme.active_border,
            border_inactive = theme.inactive_border,
            border_locked_active = theme.active_border,
            border_locked_inactive = theme.inactive_border,
        },
        groupbar = {
            enabled = true,
            gradients = false,
            render_titles = true,
            font_family = "JetBrainsMono Nerd Font",
            font_size = 11,
            height = 20,
            indicator_height = 2,
            indicator_gap = 2,
            text_padding = 8,
            rounding = math.min(theme.rounding or 8, 20),
            blur = true,
            col = {
                active = theme.active_border,
                inactive = theme.inactive_border,
                locked_active = theme.active_border,
                locked_inactive = theme.inactive_border,
            },
            text_color = theme.tab_text or "rgba(ffffffff)",
            text_color_inactive = theme.tab_text_inactive or theme.tab_text or "rgba(ffffffff)",
        },
    },
})

-- Animation curves + timings (shared across themes).
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" }) -- the launcher drops in, toasts glide in
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- Workspaces SLIDE. Only visible when windows exist to move — an empty->empty
-- switch shows nothing, which is not a bug. If slides ever look clipped,
-- suspect anything that writes config at high frequency (see border-motion.sh,
-- deliberately throttled to one step per 2s for exactly this reason).
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.8, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2.8, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.8, bezier = "easeOutQuint", style = "slide" })
-- The scratchpad crossfades instead: it's an overlay appearing above your
-- space, not a place you travel to — different physics, different verb.
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1.8, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Border motion is NOT set here: the Lua animation binding doesn't expose
-- borderangle, and upstream's own borderangle loop is broken (registers, never
-- ticks). scripts/border-motion.sh drives the gradient angle itself instead,
-- spawned by theme-apply.sh when the theme declares `border_motion`.
--
-- The ordering that makes it work: border-motion.sh applies the angle through
-- `hyprctl eval`, and `hyprctl reload` wipes that as surely as it wipes
-- keywords — which is exactly why theme-switch.sh reloads BEFORE calling
-- theme-apply, never after.

-- Layouts
hl.config({ dwindle = { preserve_split = true } })
hl.config({ master = { new_status = "master" } })
hl.config({ scrolling = { fullscreen_on_one_column = true } })

----------------
----  MISC  ----
----------------
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Apps / session
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(qs("launcher", "toggle")))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + X", hl.dsp.window.kill())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + N", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "1" }))

-- Theme switcher: the launcher in themes mode (wallpaper + palette per row).
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(qs("launcher", "themes")))

-- Calendar: ikhal's month grid in a floating themed terminal (float rule below).
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(scripts .. "calendar-menu.sh"))

-- Todos: todoman's list in the same floating-terminal shape (todo new / todo
-- done from the shell it leaves open). Same vdir as the calendar.
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(scripts .. "todo-menu.sh"))

-- Session. Lock is on SUPER+CTRL+L, not SUPER+L — that one is already `focus
-- right` in the vim-direction block below. Both surfaces are themed and follow
-- themes/current/.
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(qs("session", "toggle")))

-- Screenshots (grim + slurp + wl-clipboard + satty)
-- Screenshots confirm themselves: clipboard captures are invisible actions,
-- and invisible actions breed double-takes. The shell flashes the screen the
-- instant the capture lands (after grim has read the pixels, so the flash is
-- never in the picture) and the toast is the receipt. If the shell is down
-- the flash is skipped and the toast still fires.
local flash = qs("fx", "flash") .. " 2>/dev/null; "
hl.bind(
    "Print",
    hl.dsp.exec_cmd(
        "grim - | wl-copy && " .. flash .. "notify-send -t 2500 'Screenshot' 'full screen copied to clipboard'"
    )
)
hl.bind(
    mainMod .. " + Print",
    hl.dsp.exec_cmd(
        'grim -g "$(slurp)" - | wl-copy && ' .. flash .. 'notify-send -t 2500 "Screenshot" "region copied to clipboard"'
    )
)
-- SUPER+SHIFT+Print: pick a region, then annotate it in satty (arrows, boxes,
-- blur, text). satty copies the result to the clipboard on Enter and saves a
-- dated copy under ~/Pictures/Screenshots; it floats centered (rule below).
hl.bind(
    mainMod .. " + SHIFT + Print",
    hl.dsp.exec_cmd(
        'mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | '
            .. "satty --filename - --copy-command wl-copy --early-exit "
            .. '--output-filename ~/Pictures/Screenshots/$(date "+%Y-%m-%d_%H-%M-%S").png'
    )
)

-- Focus (arrows + vim HJKL)
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Swap windows (SHIFT + HJKL)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

-- Tab groups: SUPER+G folds the focused window into a tabbed group (press it
-- again on a group to dissolve it), SUPER+TAB / SUPER+SHIFT+TAB walk the tabs,
-- SUPER+SHIFT+G pulls the active tab back out as its own window.
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + TAB", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev())
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ out_of_group = true }))

-- Workspaces: SUPER + [0-9] to focus, SUPER + SHIFT + [0-9] to move window
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad (special workspace "magic")
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness on SUPER + F-keys, through the shell's OSD (see osd()
-- above). The OSD acts on Pipewire directly, clamped at 100% like the old
-- `wpctl -l 1`; the fallbacks are what runs when the shell isn't up.
hl.bind(
    mainMod .. " + F1",
    hl.dsp.exec_cmd(osd("volumeMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),
    { repeating = true }
)
hl.bind(
    mainMod .. " + F2",
    hl.dsp.exec_cmd(osd("volumeLower", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")),
    { repeating = true }
)
hl.bind(
    mainMod .. " + F3",
    hl.dsp.exec_cmd(osd("volumeRaise", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")),
    { repeating = true }
)

hl.bind(
    mainMod .. " + F4",
    hl.dsp.exec_cmd(
        [[bash -c 'd=asus::kbd_backlight; m=$(brightnessctl -d $d m); c=$(brightnessctl -d $d g); brightnessctl -d $d s $(( (c + 1) % (m + 1) ))']]
    )
)

hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd(osd("brightnessLower", "brightnessctl set 5%-")), { repeating = true })
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd(osd("brightnessRaise", "brightnessctl set 5%+")), { repeating = true })

-- Notification center (swaync): history, DND toggle, sliders.
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t"))

-- Media keys (playerctl — in linux-setup's packages/pacman.txt)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Frost the bar's islands. The bar surface itself is fully transparent and the
-- islands are ~0.72 alpha, so `ignore_alpha` keeps the gaps between islands
-- perfectly clear and blurs only the islands themselves. Without this the
-- translucent islands show raw wallpaper and read as flat dark boxes.
-- The namespace is set in quickshell/bar/Bar.qml.
hl.layer_rule({
    name = "qs-bar-blur",
    match = { namespace = "^qs-hypr-bar$" },
    blur = true,
    ignore_alpha = 0.35,
})

-- The shell's other three surfaces, and swaync, get the same treatment, or
-- they sit flat and opaque next to a frosted bar. Lower ignore_alpha than the
-- bar's because these are solid panels rather than islands floating on a
-- transparent sheet. Each QML surface draws its panel on a fully transparent
-- window, which is what gives ignore_alpha an edge to find.
hl.layer_rule({
    name = "qs-surfaces-blur",
    match = { namespace = "^qs-hypr-(launcher|osd|session)$" },
    blur = true,
    ignore_alpha = 0.2,
})
-- The launcher and the power menu animate themselves (a fade and an 8px rise,
-- a backdrop fade); the compositor's layersIn slide on top of that read as two
-- motions fighting. The OSD keeps the slide — a pill rising from the bottom
-- edge is the right motion for it, and it has none of its own. The screenshot
-- flash is a snap by definition: a compositor fade-in would turn it to mush.
hl.layer_rule({
    name = "qs-surfaces-self-animated",
    match = { namespace = "^qs-hypr-(launcher|session|fx)$" },
    no_anim = true,
})
hl.layer_rule({
    name = "swaync-blur",
    match = { namespace = "^swaync-(notification-window|control-center)$" },
    blur = true,
    ignore_alpha = 0.2,
})

-- The calendar floats: ikhal is a peek-at-your-week surface, not a tiling
-- citizen. Centered, laptop-friendly size.
hl.window_rule({
    name = "ikhal-float",
    match = { class = "^ikhal$" },
    float = true,
    size = { 1000, 640 }, -- vec2: positional, not named
    center = true,
})

-- The todo list floats too — smaller than the calendar; it's a glance-and-go
-- surface (SUPER+SHIFT+A).
hl.window_rule({
    name = "todos-float",
    match = { class = "^todos$" },
    float = true,
    size = { 900, 520 },
    center = true,
})

-- satty (annotate a screenshot) floats centered: it is a one-shot editor
-- over whatever you just captured, not a tiling citizen.
hl.window_rule({
    name = "satty-float",
    match = { class = "^com\\.gabm\\.satty$" },
    float = true,
    size = { 1400, 900 },
    center = true,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})
