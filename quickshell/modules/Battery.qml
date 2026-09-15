import Quickshell.Services.UPower
import "../config"
import "../components"

// Battery — hidden entirely on a machine that has none.
//
// A desktop showing nothing here is correct, not a bug: `isLaptopBattery` and
// `isPresent` are both required before the chip renders at all.
Chip {
    id: root

    readonly property int warnAt: Config.get("battery", "warnPercent", 30)
    readonly property int criticalAt: Config.get("battery", "criticalPercent", 15)

    readonly property var device: UPower.displayDevice
    readonly property bool present: (root.device?.isLaptopBattery ?? false)
                                 && (root.device?.isPresent ?? false)

    readonly property int percent: Math.round((root.device?.percentage ?? 0) * 100)
    readonly property bool charging: root.device?.state === UPowerDeviceState.Charging
                                  || root.device?.state === UPowerDeviceState.FullyCharged

    // Five levels, matching waybar's format-icons ramp.
    glyph: {
        if (!root.present)
            return "";
        if (root.charging)
            return "󰂄";
        if (root.percent <= 15)
            return "󰁺";
        if (root.percent <= 35)
            return "󰁼";
        if (root.percent <= 60)
            return "󰁾";
        if (root.percent <= 85)
            return "󰂀";
        return "󰁹";
    }

    label: root.present ? root.percent + "%" : ""

    // Charging wins over the thresholds: plugged in at 8% is not an alert.
    accent: root.charging ? Theme.ok
          : root.percent <= root.criticalAt ? Theme.urgent
          : root.percent <= root.warnAt ? Theme.warn
          : Theme.readout
}
