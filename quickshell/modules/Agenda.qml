import Quickshell
import "../config"
import "../components"

// Next calendar event — "󰃭 Advisor meeting in 45m". `#custom-agenda`:
//
//     color: <readout>; background rgba(<readout>, <chip opacity>);
//     text-shadow: 0 0 8px rgba(<readout>, 0.45);
//     padding: 0 10px; margin: 3px 2px;
//     .idle   nothing — padding and margin zeroed, no fill
//
// All of that is Chip's resting default, so this file only names its script.
//
// Backed unchanged by scripts/waybar-agenda.sh, which reads khal through
// calendar-lib.sh, truncates the title, and emits the glyph inside its own text
// (so this chip adds none). It emits class `idle` with empty text when nothing
// is inside the horizon, which renders as nothing at all — the `.idle` rule.
//
// horizonHours is read here for documentation and for the tooltip, but the
// script owns the real cutoff — CI asserts the two agree.
ScriptChip {
    script: "waybar-agenda.sh"
    intervalSec: Config.get("agenda", "intervalSec", 60)

    accent: Theme.readout

    onActivated: Quickshell.execDetached([Paths.script("calendar-menu.sh")])
}
