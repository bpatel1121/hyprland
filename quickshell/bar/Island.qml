import QtQuick
import "../config"
import "../components"

// One of the bar's three detached islands — a `.modules-left/center/right` box:
//
//     background-color: rgba(<island color>, <opacity>);
//     border: <width>px solid rgba(<frame>, <edge alpha>);
//     border-radius: <radius>;
//     padding: 2px 8px;
//     box-shadow: inset 0 2px 0 rgba(<frame>, 0.85);    cyberpunk: the accent hairline
//     background-image: repeating-linear-gradient(...)   gruvbox: the scanlines
//                                                         (now the theme's texture)
//
// Geometry and color come from the ACTIVE theme's palette.json `bar.island`
// block, which is why cyberpunk reads as rounded neon glass (radius 14, a 1px
// lit pink edge, the pink hairline) and gruvbox as a CRT panel (radius 4, a
// chunky 2px orange frame, scanlines) from the same component. The island is
// the full bar height, border included, exactly as the GTK box filled the
// 36px window; chips add their own 3px vertical margin inside the padding.
//
// An island holding nothing visible collapses to zero width and hides itself,
// so a bar whose watchdogs are all quiet does not show an empty box.
Rectangle {
    id: root

    default property alias content: row.data

    // `padding: 2px 8px`, inside the border.
    property real horizontalPadding: 8
    property real verticalPadding: 2

    readonly property bool hasContent: row.implicitWidth > 0

    // Everything painted inside the border lives in the padding box, whose
    // corners are the outer radius minus the border.
    readonly property real innerRadius: Math.max(0, root.radius - root.border.width)

    visible: root.hasContent
    implicitWidth: root.hasContent
        ? row.implicitWidth + 2 * (root.horizontalPadding + root.border.width)
        : 0
    width: implicitWidth
    height: Config.height

    radius: Theme.islandRadius
    color: Theme.islandFill
    border.width: Theme.islandBorderWidth
    border.color: Theme.islandBorder

    Behavior on color {
        ColorAnimation { duration: 160 }
    }

    // The outer bloom (components/IslandGlow.qml), only when the theme asks
    // for one. A Loader so the Qt 6.9 type it needs can be missing without
    // taking the island down with it.
    Loader {
        anchors.fill: parent
        z: -1
        active: Theme.islandGlow > 0
        source: Qt.resolvedUrl("../components/IslandGlow.qml")
        onLoaded: item.cornerRadius = Qt.binding(() => root.radius)
        onStatusChanged: {
            if (status === Loader.Error)
                console.warn("Island: glow unavailable (RectangularShadow needs Qt 6.9+)");
        }
    }

    // The theme's panel texture (gruvbox's stripes, graphite's hatching, ...),
    // inside the frame. A no-op when the theme declares none.
    Texture {
        anchors.margins: root.border.width
        radius: root.innerRadius
    }

    // cyberpunk's `box-shadow: inset 0 2px 0`: a 2px line of `frame` along the
    // inside top edge, following the inner rounded corners. A Rectangle cannot
    // clip to a rounded rect, so this is a Canvas with a rounded clip — the same
    // trick Texture uses. Alpha 0 (gruvbox) paints nothing.
    Canvas {
        id: accentLine

        readonly property color lineColor: Theme.withAlpha(Theme.frame, Theme.islandAccentLine)
        readonly property real innerRadius: root.innerRadius

        anchors.fill: parent
        anchors.margins: root.border.width
        visible: Theme.islandAccentLine > 0

        onWidthChanged: accentLine.requestPaint()
        onHeightChanged: accentLine.requestPaint()
        onLineColorChanged: accentLine.requestPaint()
        onInnerRadiusChanged: accentLine.requestPaint()
        onVisibleChanged: if (accentLine.visible) accentLine.requestPaint()

        onPaint: {
            const ctx = accentLine.getContext("2d");
            ctx.clearRect(0, 0, accentLine.width, accentLine.height);
            if (!accentLine.visible || accentLine.width <= 0 || accentLine.height <= 0)
                return;
            ctx.save();
            ctx.beginPath();
            ctx.roundedRect(0, 0, accentLine.width, accentLine.height,
                            accentLine.innerRadius, accentLine.innerRadius);
            ctx.clip();
            ctx.fillStyle = accentLine.lineColor;
            ctx.fillRect(0, 0, accentLine.width, 2);
            ctx.restore();
        }
    }

    // The content strip: inside the border and the padding. Modules fill its
    // height and lay their own margins inside it.
    Row {
        id: row
        anchors.fill: parent
        anchors.leftMargin: root.border.width + root.horizontalPadding
        anchors.rightMargin: root.border.width + root.horizontalPadding
        anchors.topMargin: root.border.width + root.verticalPadding
        anchors.bottomMargin: root.border.width + root.verticalPadding
        spacing: Config.spacing
    }
}
