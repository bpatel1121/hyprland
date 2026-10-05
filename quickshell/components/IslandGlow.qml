import QtQuick
import QtQuick.Effects
import "../config"

// The island's outer bloom — the bar's share of the window glow.
//
// theme.lua gives cyberpunk's windows a wide pink shadow (range 22, pi0 at
// ~77%); the islands sat flat beside them. This is the same bloom at bar
// scale: a RectangularShadow in `frame` at `Theme.islandGlow` alpha, blurred
// to `Theme.islandGlowRange`, drawn beneath the island (negative z). Gruvbox
// declares 0 and gets nothing, as its windows get a neutral shadow.
//
// Loaded by Island.qml through a Loader rather than declared inline:
// RectangularShadow arrived in Qt 6.9, and a Loader turns "type not found" on
// an older Qt into one warning instead of a bar that never appears.
RectangularShadow {
    // Set by Island.qml's Loader: `parent` here is the Loader, not the island.
    property real cornerRadius: 0

    anchors.fill: parent
    radius: cornerRadius
    blur: Theme.islandGlowRange
    spread: 0
    color: Theme.withAlpha(Theme.frame, Theme.islandGlow)
}
