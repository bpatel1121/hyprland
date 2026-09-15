// Delegates below reference `root` and their own `modelData`. Bound
// component behavior makes those resolve lexically instead of walking the
// scope chain at runtime, which is both faster and what stops a rename
// elsewhere from silently rebinding them.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import "../config"

// Workspace stations.
//
// 1..`persistent` ALWAYS render; an empty one draws in the `dormant` role
// rather than disappearing, so the bar reads as a row of stations instead of one
// lonely number. Workspaces past that appear only when they hold something.
//
// The scratchpad gets a ghost glyph that exists only while it is on screen — it
// IS the "you are in the scratchpad" indicator. Hyprland reports it with a
// negative id, which is how it is told apart from a numbered workspace here.
Row {
    id: root

    readonly property int persistent: Config.get("workspaces", "persistent", 5)
    readonly property bool showSpecial: Config.get("workspaces", "showSpecial", true)
    readonly property string specialGlyph: Config.get("workspaces", "specialGlyph", "󰊠")

    height: parent ? parent.height : 0
    spacing: 2

    // Occupied workspace ids, from Hyprland's live model.
    readonly property var occupied: {
        const out = {};
        for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
            const ws = Hyprland.workspaces.values[i];
            if (ws.id > 0)
                out[ws.id] = (ws.toplevels?.values?.length ?? 0) > 0;
        }
        return out;
    }

    readonly property int focusedId: Hyprland.focusedWorkspace?.id ?? -1

    // The union of "always shown" and "currently exists", ascending.
    readonly property var shownIds: {
        const ids = {};
        for (let i = 1; i <= root.persistent; i++)
            ids[i] = true;
        for (const key in root.occupied)
            ids[key] = true;
        return Object.keys(ids).map(k => parseInt(k)).sort((a, b) => a - b);
    }

    Repeater {
        model: root.shownIds

        Item {
            id: station

            required property int modelData

            readonly property bool isFocused: station.modelData === root.focusedId
            readonly property bool isOccupied: root.occupied[station.modelData] === true

            width: 22
            height: root.height

            Rectangle {
                anchors.centerIn: parent
                width: 20
                height: 20
                radius: Theme.chipRadius
                color: station.isFocused
                    ? Theme.withAlpha(Theme.frame, 0.18)
                    : Qt.rgba(0, 0, 0, 0)

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }
            }

            Text {
                anchors.centerIn: parent
                text: station.modelData
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: station.isFocused
                // Three states, three roles: focused reads in the identity
                // color, occupied-but-elsewhere in the readout color, empty in
                // dormant. Nothing vanishes.
                color: station.isFocused ? Theme.frame
                     : station.isOccupied ? Theme.readout
                     : Theme.dormant

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + station.modelData)
            }
        }
    }

    // The scratchpad ghost — present only while the special workspace is up.
    Item {
        id: ghost

        readonly property bool visibleNow: {
            if (!root.showSpecial)
                return false;
            for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                const ws = Hyprland.workspaces.values[i];
                if (ws.id < 0 && ws.active)
                    return true;
            }
            return false;
        }

        visible: ghost.visibleNow
        width: ghost.visibleNow ? 22 : 0
        height: root.height

        Text {
            anchors.centerIn: parent
            text: root.specialGlyph
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: Theme.frame
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch("togglespecialworkspace magic")
        }
    }
}
