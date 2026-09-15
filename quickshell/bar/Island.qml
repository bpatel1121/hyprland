import QtQuick
import "../config"

// One of the bar's three detached islands.
//
// Geometry and color come from the ACTIVE theme's palette.json `bar.island`
// block, which is why cyberpunk reads as rounded neon glass (radius 14, a 1px
// lit pink edge) and gruvbox as a CRT panel (radius 4, a chunky 2px orange
// frame) from the same component.
//
// An island holding nothing visible collapses to zero width and hides itself,
// so a bar whose watchdogs are all quiet does not show an empty box.
Rectangle {
    id: root

    default property alias content: row.data

    property real horizontalPadding: 6

    readonly property bool hasContent: row.implicitWidth > 0

    visible: root.hasContent
    implicitWidth: root.hasContent ? row.implicitWidth + 2 * root.horizontalPadding : 0
    width: implicitWidth
    height: Config.height

    radius: Theme.islandRadius
    color: Theme.islandFill
    border.width: Theme.islandBorderWidth
    border.color: Theme.islandBorder

    Behavior on color {
        ColorAnimation { duration: 160 }
    }

    Row {
        id: row
        anchors.centerIn: parent
        height: parent.height
        spacing: Config.spacing
    }
}
