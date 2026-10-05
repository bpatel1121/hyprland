import QtQuick
import Quickshell.Io
import "../config"
import "../components"

// Silent watchdog, like Network: renders NOTHING below criticalC. The chip
// appearing IS the signal that the machine is hot. `#temperature`:
//
//     (rest)     padding: 0; margin: 3px 0        — nothing to see
//     .critical  padding: 0 10px; margin: 3px 1px;
//                color: <urgent>; animation: pulse-red
//                background: the shared rgba(<readout>, <chip opacity>) tint
//
// waybar's format-critical was "<glyph> {temperatureC}°". The tint is still
// the readout's: `.critical` recolors the text and nothing else.
//
// The sensor is resolved by hwmon NAME, not by hwmon index: /sys/class/hwmon
// numbering is not stable across boots, so a hardcoded hwmon6 silently reads the
// wrong chip (or nothing) after a reboot or a kernel bump. `hwmonName` in
// settings.json is what makes this portable between machines — k10temp on AMD,
// coretemp on Intel.
Chip {
    id: root

    readonly property int criticalC: Config.get("temperature", "criticalC", 80)
    readonly property string hwmonName: Config.get("temperature", "hwmonName", "k10temp")

    property int celsius: 0
    readonly property bool hot: root.celsius >= root.criticalC

    // U+F2C7 nf-fa-thermometer_full, as an escape (BMP private-use glyphs do
    // not survive every editor).
    glyph: root.hot ? "\uf2c7" : ""
    label: root.hot ? root.celsius + "°" : ""

    accent: Theme.urgent
    tintColor: Theme.readout
    glowOpacity: 0
    pulse: root.hot
    marginLeft: 1
    marginRight: 1

    Process {
        id: probe
        command: ["sh", "-c",
            'for d in /sys/class/hwmon/hwmon*; do ' +
            '[ "$(cat "$d/name" 2>/dev/null)" = "' + root.hwmonName + '" ] && ' +
            'cat "$d/temp1_input" 2>/dev/null && exit 0; done']

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function (line) {
                const milli = parseInt(line.trim());
                if (!isNaN(milli))
                    root.celsius = Math.round(milli / 1000);
            }
        }
    }

    // 10s is plenty: this only has to notice sustained heat, and a thermal spike
    // shorter than that is not something you would act on anyway.
    Timer {
        running: true
        interval: 10000
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }
}
