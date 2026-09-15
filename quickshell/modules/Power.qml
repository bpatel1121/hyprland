import Quickshell
import "../config"
import "../components"

// The bar's right bookend — opens wlogout, the same surface SUPER+ESCAPE does.
//
// Goes red only on hover. A power glyph that is permanently red reads as an
// alert, and this bar reserves the urgent role for things that actually need
// acting on.
Chip {
    id: root

    glyph: Config.get("power", "glyph", "⏻")
    accent: root.hovered ? Theme.urgent : Theme.dormant
    fontSize: Theme.fontSizeAccent

    onActivated: Quickshell.execDetached(["wlogout", "-p", "layer-shell"])
}
