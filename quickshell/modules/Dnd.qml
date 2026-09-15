import Quickshell
import "../config"
import "../components"

// Do-not-disturb indicator.
//
// Not a repo script but the same one-line-JSON shape: `swaync-client -swb`
// STREAMS state changes, so this updates instantly with no polling — which is
// why ScriptChip's `command` escape hatch exists.
//
// swaync emits a status word rather than a glyph, so unlike the waybar-*.sh
// chips this one maps the state to an icon itself. It renders only while DND is
// actually on: the muted bell appearing IS the signal.
ScriptChip {
    id: root

    command: ["swaync-client", "-swb"]
    intervalSec: 0

    // swaync's `class` field carries the state; its `text` is not a glyph.
    readonly property bool dndOn: root.stateClass.indexOf("dnd") !== -1

    label: root.dndOn ? "󰂛" : ""
    accent: Theme.dormant

    onActivated: Quickshell.execDetached(["swaync-client", "-t", "-sw"])
    onSecondaryActivated: Quickshell.execDetached(["swaync-client", "-d", "-sw"])
}
