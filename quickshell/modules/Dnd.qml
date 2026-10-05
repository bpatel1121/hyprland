import Quickshell
import "../config"
import "../components"

// Do-not-disturb indicator — `#custom-dnd.dnd-*`:
//
//     color: <warn>; background rgba(<warn>, 0.10 / 0.12);
//     text-shadow: 0 0 8px rgba(<warn>, 0.5);
//     padding: 0 10px; margin: 3px 2px;
//     (any non-dnd class)  nothing — zeroed so the bar reserves no space
//
// Amber is the warning vocabulary: you are choosing to miss things. The chip
// renders ONLY while DND is on; the muted bell appearing IS the signal.
//
// Not a repo script but the same one-line-JSON shape: `swaync-client -swb`
// STREAMS state changes, so this updates instantly with no polling — which is
// why ScriptChip's `command` escape hatch exists. swaync emits a status word
// rather than a glyph, so unlike the waybar-*.sh chips this one maps the
// state to an icon itself (format-icons: every dnd-* state → 󰂛, the rest → "").
ScriptChip {
    id: root

    command: ["swaync-client", "-swb"]
    intervalSec: 0

    // swaync's `class` field carries the state; its `text` is not a glyph.
    readonly property bool dndOn: root.stateClass.indexOf("dnd") !== -1

    label: root.dndOn ? "󰂛" : ""
    accent: Theme.warn
    // 0.10 / 0.12 in the CSS: chip tint + the "state" step (0.10 / 0.11).
    tintOpacity: Theme.chipOpacity + 0.03
    glowOpacity: 0.5

    onActivated: Quickshell.execDetached(["swaync-client", "-t", "-sw"])
    onSecondaryActivated: Quickshell.execDetached(["swaync-client", "-d", "-sw"])
}
