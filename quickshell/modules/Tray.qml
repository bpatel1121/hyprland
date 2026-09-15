// Delegates below reference `root` and their own `modelData`. Bound
// component behavior makes those resolve lexically instead of walking the
// scope chain at runtime, which is both faster and what stops a rename
// elsewhere from silently rebinding them.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray
import "../config"

// System tray.
//
// Icons only — a tray entry's own artwork is its identity, so unlike every other
// module here it is not recolored to a role. Left click activates, right click
// opens the item's menu where it has one.
Row {
    id: root

    readonly property int iconSpacing: Config.get("tray", "spacing", 8)

    height: parent ? parent.height : 0
    spacing: root.iconSpacing
    // An empty tray must not add padding to the island.
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Item {
            id: entry

            required property var modelData

            width: 18
            height: root.height

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: entry.modelData.icon
                fillMode: Image.PreserveAspectFit
                // Tray icons arrive at whatever size the app chose; ask for a
                // crisp raster at the size actually drawn.
                sourceSize.width: 18
                sourceSize.height: 18
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: function (event) {
                    // onlyMenu items have no activate action at all — clicking
                    // one should open its menu rather than do nothing.
                    if (event.button === Qt.RightButton || entry.modelData.onlyMenu)
                        console.log("Tray: menu for", entry.modelData.title,
                                    "— popup not wired yet, see quickshell/README.md");
                    else
                        entry.modelData.activate();
                }
            }
        }
    }
}
