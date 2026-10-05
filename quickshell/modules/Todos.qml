import Quickshell
import "../config"
import "../components"

// Open todos due soon — "󰄲 3". `#custom-todos`:
//
//     color: <readout>; background rgba(<readout>, <chip opacity>);
//     text-shadow: 0 0 8px rgba(<readout>, 0.45);
//     padding: 0 10px; margin: 3px 2px;
//     .overdue  color: <urgent>; background rgba(<urgent>, 0.09 / 0.10);
//               text-shadow: 0 0 8px rgba(<urgent>, 0.5)
//     .zero     nothing
//
// scripts/waybar-todos.sh counts todoman VTODOs in the same vdir khal uses, and
// emits class `overdue` the moment anything is past due, or `zero` with empty
// text when there is nothing, which hides the chip.
ScriptChip {
    id: root

    script: "waybar-todos.sh"
    intervalSec: Config.get("todos", "intervalSec", 60)

    readonly property bool overdue: root.stateClass === "overdue"

    accent: root.overdue ? Theme.urgent : Theme.readout
    // 0.09 / 0.10: the chip tint plus 0.02, exact in both themes.
    tintOpacity: root.overdue ? Theme.chipOpacity + 0.02 : Theme.chipOpacity
    glowOpacity: root.overdue ? 0.5 : 0.45

    onActivated: Quickshell.execDetached([Paths.script("todo-menu.sh")])
}
