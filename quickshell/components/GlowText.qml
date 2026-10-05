// The inline MultiEffect below references `root` and `label`; Bound makes
// those resolve lexically rather than via the runtime scope chain.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import "../config"

// Text with the theme's glow — the QML counterpart of `text-shadow: 0 0 Npx`.
//
// Every lit element in the old stylesheets (the clock, the launcher chip, every
// readout chip, a hovered power-menu tile, the OSD readout) carried a
// text-shadow in its own color. That was the ONE glow primitive GTK3 could draw
// without a black halo on a layer-shell surface. Here it is a MultiEffect drop
// shadow with zero offset: same look, and it spills past the item's bounds
// without a rectangle, because there is no GTK compositor in the way.
//
// Honors `Theme.glow`: gruvbox declares no glow and gets a plain Text, with no
// effect node allocated at all. `forceGlow` is for the one exception gruvbox
// makes — the red alert pulse (`@keyframes pulse-red`) is a text-shadow in BOTH
// themes.
Item {
    id: root

    property alias text: label.text
    property alias font: label.font
    property alias color: label.color
    property alias horizontalAlignment: label.horizontalAlignment
    property alias verticalAlignment: label.verticalAlignment
    property alias elide: label.elide
    property alias textFormat: label.textFormat
    property alias wrapMode: label.wrapMode

    // text-shadow: 0 0 <glowRadius>px rgba(<glowColor>, <glowOpacity>)
    property real glowOpacity: 0.45
    property real glowRadius: Theme.glowRadius
    property color glowColor: label.color
    property bool forceGlow: false

    readonly property bool glowing: (root.forceGlow || Theme.glow)
        && root.glowOpacity > 0 && root.glowRadius > 0

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.fill: parent
        // Rendered through the effect while glowing (drawing it here too would
        // double the ink), directly otherwise.
        visible: !root.glowing
    }

    Loader {
        anchors.fill: label
        active: root.glowing

        sourceComponent: MultiEffect {
            source: label
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: root.glowColor
            shadowOpacity: root.glowOpacity
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0
            shadowScale: 1
            // shadowBlur is a 0..1 fraction of blurMax, so a full-strength blur
            // sized to twice the CSS radius lands close to text-shadow's falloff.
            shadowBlur: 1
            blurMax: Math.max(2, Math.ceil(root.glowRadius * 2))
        }
    }
}
