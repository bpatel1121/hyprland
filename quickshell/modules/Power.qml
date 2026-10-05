import Quickshell
import "../config"
import "../components"

// The bar's right bookend — opens the session menu, the same surface
// SUPER+ESCAPE does. `#custom-power`:
//
//     color: rgba(<dormant>, 0.6); font-size: 14px;
//     padding: 0 10px; margin: 3px 2px; background: none;
//     :hover  color: <urgent>; background rgba(<urgent>, 0.10 / 0.12);
//             text-shadow: 0 0 8px rgba(<urgent>, 0.6)       cyberpunk
//
// Quiet until you mean it: a power glyph that is permanently red reads as an
// alert, and this bar reserves the urgent role for things that actually need
// acting on. Same IPC route as the launcher chip — `session toggle` is what
// hyprland.lua binds too.
Chip {
    id: root

    glyph: Config.get("power", "glyph", "⏻")
    // 14px: between the bar's 13 and the launcher's 16, and the CSS's own number.
    fontSize: 14

    accent: Theme.withAlpha(Theme.dormant, 0.6)
    tintOpacity: 0
    glowOpacity: 0

    hoverAccent: Theme.urgent
    hoverTintColor: Theme.urgent
    // 0.10 / 0.12 in the CSS: the chip tint plus the step every "state" tint
    // on this bar takes over the resting one (0.10 / 0.11).
    hoverTintOpacity: Theme.chipOpacity + 0.03
    hoverGlowOpacity: 0.6

    onActivated: Quickshell.execDetached([
        "qs", "ipc", "-p", Paths.shell, "call", "session", "toggle"
    ])
}
