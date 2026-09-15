import QtQuick
import Quickshell
import "../config"
import "../components"

// The clock, and the only thing in the center island.
//
// SystemClock ticks this — no Timer, and it wakes only at the precision asked
// for, so a minute-resolution clock is not spinning once a second.
//
// Click swaps to the date, matching waybar's format-alt.
Chip {
    id: root

    property bool showingAlt: false

    readonly property string fmt: root.showingAlt
        ? Config.get("clock", "altFormat", "ddd dd MMM")
        : Config.get("clock", "format", "HH:mm")

    glyph: root.showingAlt ? "󰃭" : "󰥔"
    label: Qt.formatDateTime(clock.date, root.fmt)
    accent: Theme.readout
    fontSize: Theme.fontSizeAccent

    onActivated: root.showingAlt = !root.showingAlt

    SystemClock {
        id: clock
        // Minutes is all either format shows; seconds would wake the shell 60x
        // more often for pixels that never change.
        precision: SystemClock.Minutes
    }
}
