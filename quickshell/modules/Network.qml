import Quickshell
import Quickshell.Networking
import "../config"
import "../components"

// Silent watchdog: renders NOTHING while the network is up. `#network`:
//
//     color: <readout>; background rgba(<readout>, <chip opacity>);
//     padding: 0 10px; margin: 3px 2px;  no glow
//     .disconnected  color: rgba(<dormant>, 0.5)      the only state that shows
//
// waybar's format-wifi/-ethernet were empty (an empty format hides the
// module) and format-disconnected "<glyph> off", with tooltip "no network".
// So the one thing this chip ever draws is the dim dormant "off" on the
// readout tint.
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
    tooltip: root.up ? "" : "no network"

    accent: Theme.withAlpha(Theme.dormant, 0.5)
    tintColor: Theme.readout
    glowOpacity: 0

    onActivated: Quickshell.execDetached(["wezterm", "start", "--", "nmtui"])
}
