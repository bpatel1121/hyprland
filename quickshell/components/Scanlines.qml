import QtQuick
import "../config"

// CRT scanlines — gruvbox's signature, the way glow is cyberpunk's.
//
// The old stylesheets drew these as a repeating-linear-gradient on every panel
// fill: 1px of 14% black, 2px clear, repeat. This paints the same stripes onto
// a canvas clipped to the panel's own rounded rectangle, so it sits INSIDE the
// frame exactly as the background-image did.
//
// Honors `Theme.scanlines`: a theme without them (cyberpunk) renders nothing
// and never paints. Drop it inside any Rectangle, after the fill and before
// the content:
//
//     Rectangle { radius: 4; Scanlines { radius: parent.radius } ... }
Canvas {
    id: root

    property real radius: 0
    property real lineAlpha: 0.14
    property int period: 3

    anchors.fill: parent
    visible: Theme.scanlines

    onWidthChanged: root.requestPaint()
    onHeightChanged: root.requestPaint()
    onRadiusChanged: root.requestPaint()
    onVisibleChanged: if (root.visible) root.requestPaint()

    onPaint: {
        const ctx = root.getContext("2d");
        ctx.clearRect(0, 0, root.width, root.height);
        if (!root.visible || root.width <= 0 || root.height <= 0)
            return;
        ctx.save();
        ctx.beginPath();
        ctx.roundedRect(0, 0, root.width, root.height, root.radius, root.radius);
        ctx.clip();
        ctx.fillStyle = Qt.rgba(0, 0, 0, root.lineAlpha);
        for (let y = 0; y < root.height; y += root.period)
            ctx.fillRect(0, y, root.width, 1);
        ctx.restore();
    }
}
