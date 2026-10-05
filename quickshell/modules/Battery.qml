import Quickshell.Services.UPower
import "../config"
import "../components"

// Battery — hidden entirely on a machine that has none. `#battery`, waybar's
// "{icon} {capacity}%" / format-charging "󰂄 {capacity}%":
//
//     color: <readout>; background rgba(<readout>, <chip opacity>);
//     padding: 0 10px; margin: 3px 2px;  no glow
//     .charging                 color: <ok>
//     .warning   (<= 30)        color: <urgent>, steady
//     .critical:not(.charging)  color: <urgent>; animation: pulse-red
//
// Warning and critical share red and differ by motion, not hue: amber belongs
// to Pac-Man alone. The tint stays the readout's through every state.
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
    // Charging only. A full battery on the charger is waybar's "Full" status:
    // no `charging` class, the top-of-ramp icon, readout color — so it is not
    // folded in here either.
    readonly property bool charging: root.device?.state === UPowerDeviceState.Charging

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
          : root.percent <= root.warnAt ? Theme.urgent
          : Theme.readout
    pulse: root.present && !root.charging && root.percent <= root.criticalAt
    tintColor: Theme.readout
    glowOpacity: 0
}
