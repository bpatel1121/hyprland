import Quickshell
import "../config"
import "../components"

// Next calendar event — "󰃭 Advisor meeting in 45m".
//
// Backed unchanged by scripts/waybar-agenda.sh, which reads khal through
// calendar-lib.sh, truncates the title, and emits the glyph inside its own text
// (so this chip adds none). It emits class `idle` with empty text when nothing
// is inside the horizon, which renders as nothing at all.
//
// horizonHours is read here for documentation and for the tooltip, but the
// script owns the real cutoff — CI asserts the two agree.
ScriptChip {
    script: "waybar-agenda.sh"
    intervalSec: Config.get("agenda", "intervalSec", 60)

    onActivated: Quickshell.execDetached([Paths.script("calendar-menu.sh")])
}
