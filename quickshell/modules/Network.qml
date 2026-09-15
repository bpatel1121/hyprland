import Quickshell
import Quickshell.Networking
import "../config"
import "../components"

// Silent watchdog: renders NOTHING while the network is up.
//
// The throughput readout that used to live in this slot was the one chip on the
// bar that changed width on its own, and a live kB/s figure is not something you
// act on — it is motion for its own sake, which the whole bar is designed
// against. Connection details stay one click away: nmtui.
Chip {
    id: root

    readonly property bool up: {
        const devices = Networking.devices?.values ?? [];
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return true;
        }
        return false;
    }

    glyph: root.up ? "" : "󰤭"
    label: root.up ? "" : "off"
    accent: Theme.urgent

    onActivated: Quickshell.execDetached(["wezterm", "start", "--", "nmtui"])
}
