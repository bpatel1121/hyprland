import Quickshell
import Quickshell.Bluetooth
import "../config"
import "../components"

// Bluetooth — icon only, and only while the adapter is on.
//
// Connected lights the icon in the readout role and names the device in the
// tooltip; powered-but-idle sits dormant; adapter off renders nothing.
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
    accent: root.connectedDevice ? Theme.readout : Theme.dormant

    onActivated: Quickshell.execDetached(["wezterm", "start", "--", "bluetoothctl"])
}
