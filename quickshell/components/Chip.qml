import QtQuick
import "../config"

// The bar's one repeated shape: an optional glyph, an optional label, and a
// state color. Every module is built from this, which is what keeps a
// twelve-module island visually consistent without twelve stylesheets.
//
// A chip with nothing to say has zero width and is invisible. That is the
// resting-bar rule the whole design depends on: temperature, network and DND
// render NOTHING until they have something to report, so color on this bar
// always means "act on me" (see docs/bar.md).
Item {
    id: root

    // --- content -------------------------------------------------------------
    property string glyph: ""
    property string label: ""

    // Tooltip text. Carried but not yet drawn — see quickshell/README.md.
    property string tooltip: ""

    // --- appearance ----------------------------------------------------------
    property color accent: Theme.readout
    property int fontSize: Theme.fontSize
    // Draw the tinted backplate behind this chip. Off by default: most chips sit
    // directly on the island, and only the bookends (launcher, power) are raised.
    property bool tinted: false
    property real horizontalPadding: 8
    property real glyphSpacing: 6

    // --- interaction ---------------------------------------------------------
    property bool interactive: mouse.enabled
    // Exposed so a module can react to hover without reaching into the
    // MouseArea. Power.qml uses it to go red only under the pointer.
    readonly property alias hovered: mouse.containsMouse
    signal activated
    signal secondaryActivated
    signal scrolled(int delta)

    readonly property bool hasContent: root.glyph !== "" || root.label !== ""

    visible: root.hasContent
    implicitWidth: root.hasContent ? row.implicitWidth + 2 * root.horizontalPadding : 0
    implicitHeight: parent ? parent.height : 24
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: Theme.chipRadius
        // NEVER the `transparent` keyword — the themes' CSS bans it for the same
        // reason (it composites as a black halo on some layer-shell surfaces).
        // An explicit zero-alpha color is unambiguous.
        color: {
            if (root.tinted || mouse.containsMouse)
                return Theme.withAlpha(root.accent,
                                         mouse.containsMouse ? Theme.chipOpacity * 2
                                                             : Theme.chipOpacity);
            return Qt.rgba(0, 0, 0, 0);
        }

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: (root.glyph !== "" && root.label !== "") ? root.glyphSpacing : 0

        Text {
            text: root.glyph
            visible: root.glyph !== ""
            color: root.accent
            font.family: Theme.fontFamily
            font.pixelSize: root.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.label
            visible: root.label !== ""
            color: root.accent
            font.family: Theme.fontFamily
            font.pixelSize: root.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: function (event) {
            if (event.button === Qt.RightButton)
                root.secondaryActivated();
            else
                root.activated();
        }

        onWheel: function (event) {
            root.scrolled(event.angleDelta.y > 0 ? 1 : -1);
        }
    }
}
