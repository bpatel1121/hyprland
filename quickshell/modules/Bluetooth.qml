import Quickshell
import Quickshell.Bluetooth
import "../config"
import "../components"

// Bluetooth — icon only, and only while the adapter is on. `#bluetooth`:
//
//     color: <readout>; background rgba(<readout>, <chip opacity>);
//     padding: 0 10px; margin: 3px 2px;  no glow
//     .disabled  color: rgba(<dormant>, 0.5)
//
// waybar's format-off/-disabled were empty (hidden), format-connected the lit
// icon with "{device_alias}" as the tooltip. Connected lights the icon in the
// readout role; powered-but-idle keeps the icon and takes the CSS's one dim
// bluetooth color; adapter off renders nothing.
Chip {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: root.adapter?.enabled ?? false

    readonly property var connectedDevice: {
        const devices = Bluetooth.devices?.values ?? [];
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return devices[i];
        }
        return null;
    }

    glyph: {
        if (!root.powered)
            return "";
        return root.connectedDevice ? "󰂱" : "󰂯";
    }

    tooltip: root.connectedDevice?.name ?? ""
    accent: root.connectedDevice ? Theme.readout : Theme.withAlpha(Theme.dormant, 0.5)
    tintColor: Theme.readout
    glowOpacity: 0

    onActivated: Quickshell.execDetached(["wezterm", "start", "--", "bluetoothctl"])
}
