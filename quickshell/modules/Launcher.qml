import Quickshell
import "../config"
import "../components"

// The Arch chip that opens the launcher — the bar's left bookend.
//
// Runs the SAME wofi invocation hyprland.lua binds to SUPER+R, including the
// per-theme stylesheet, so the launcher looks and behaves identically however it
// was opened. --allow-images with columns is what turns wofi from a dmenu strip
// into an icon grid; the geometry is passed as config because wofi treats size
// as config rather than style.
Chip {
    id: root

    glyph: Config.get("launcher", "glyph", "󰃃")
    accent: Theme.frame
    fontSize: Theme.fontSizeAccent
    tinted: true

    onActivated: Quickshell.execDetached([
        "wofi", "--show", "drun", "--allow-images", "--columns", "2",
        "--width", "640", "--height", "480",
        "--style", Paths.currentTheme + "/wofi/style.css"
    ])
}
