import Quickshell
import "../config"
import "../components"

// Open todos due soon — "󰄲 3".
//
// scripts/waybar-todos.sh counts todoman VTODOs in the same vdir khal uses, and
// emits class `overdue` the moment anything is past due (which Palette maps to
// the urgent role) or `zero` when there is nothing, which hides the chip.
ScriptChip {
    script: "waybar-todos.sh"
    intervalSec: Config.get("todos", "intervalSec", 60)

    onActivated: Quickshell.execDetached([Paths.script("todo-menu.sh")])
}
