// Delegates below reference `root` and their own `modelData`. Bound
// component behavior makes those resolve lexically instead of walking the
// scope chain at runtime, which is both faster and what stops a rename
// elsewhere from silently rebinding them.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../config"

// System tray — `#tray`:
//
//     padding: 0 10px; margin: 3px 2px; background: none     (the shared chip
//     rule, with its tint zeroed back out); `tray { spacing: 8 }`
//
// Icons only — a tray entry's own artwork is its identity, so unlike every other
// module here it is not recolored to a role, and it is not a Chip. Left click
// activates, right click (or any click on a menu-only item) opens the item's
// native menu under the icon.
Item {
    id: root

    readonly property int iconSpacing: Config.get("tray", "spacing", 8)
    readonly property int iconSize: 18
    readonly property bool hasItems: SystemTray.items.values.length > 0

    height: parent ? parent.height : 0
    // padding 10 + margin 2 each side; an empty tray adds nothing to the island.
    implicitWidth: root.hasItems ? icons.implicitWidth + 2 * (10 + 2) : 0
    width: implicitWidth
    visible: root.hasItems

    Row {
        id: icons
        anchors.centerIn: parent
        height: parent.height
        spacing: root.iconSpacing

        Repeater {
            model: SystemTray.items

            Item {
                id: entry

                required property var modelData

                width: root.iconSize
                height: icons.height

                Image {
                    anchors.centerIn: parent
                    width: root.iconSize
                    height: root.iconSize
                    source: entry.modelData.icon
                    fillMode: Image.PreserveAspectFit
                    // Tray icons arrive at whatever size the app chose; ask for a
                    // crisp raster at the size actually drawn.
                    sourceSize.width: root.iconSize
                    sourceSize.height: root.iconSize
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
                            entry.openMenu();
                        else
                            entry.modelData.activate();
                    }
                }

                // SystemTrayItem.display() wants the menu's position relative
                // to the bar window. The window is reached through the
                // QsWindow attached property rather than passed down — a
                // Loader-loaded module has no way to be handed it. The
                // attached property is C++-side (Quickshell), invisible to
                // static analysis; suppressed narrowly, as Bar.qml does.
                // qmllint disable unqualified
                function openMenu() {
                    if (!entry.modelData.hasMenu)
                        return;
                    const win = QsWindow.window;
                    if (!win)
                        return;
                    const pos = win.itemPosition(entry);
                    entry.modelData.display(win, pos.x, pos.y + (Config.atTop ? entry.height : 0));
                }
                // qmllint enable unqualified
            }
        }
    }
}
