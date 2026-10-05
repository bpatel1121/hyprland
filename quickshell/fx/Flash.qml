// The sheet below references `root` and `pop`; Bound makes those resolve
// lexically rather than via the runtime scope chain.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../config"

// The camera flash — the one effect in this shell that is not a surface.
//
// hyprland.lua's screenshot binds call `fx flash` the instant grim has read
// the pixels, so the capture itself is never in the picture. A full-screen
// sheet of `text` (near-white on the dark themes, near-black on the light
// ones: a flash on paper is a shutter, not a strobe) snaps to 0.55 and fades
// out over 180ms. Overlay layer, so it covers fullscreen windows too; an empty
// mask so it never takes a click; no exclusive zone.
//
// One window per screen, unmapped whenever the sheet is fully transparent —
// the same stays-mapped-until-faded rule the OSD uses, so a screen that
// never screenshots has no surface at all.
Scope {
    id: root

    // Bumped per call; every screen's sheet watches it.
    property int flashes: 0

    IpcHandler {
        target: "fx"

        function flash(): void {
            root.flashes += 1;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: win.modelData

            WlrLayershell.namespace: "qs-hypr-fx"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            mask: Region {}

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            // Never the `transparent` keyword — see bar/Bar.qml.
            color: "#00000000"
            visible: sheet.opacity > 0

            Rectangle {
                id: sheet

                readonly property int tick: root.flashes

                anchors.fill: parent
                color: Theme.text
                opacity: 0

                onTickChanged: pop.restart()

                SequentialAnimation {
                    id: pop
                    running: false
                    PropertyAction { target: sheet; property: "opacity"; value: 0.55 }
                    NumberAnimation { target: sheet; property: "opacity"; to: 0; duration: 180; easing.type: Easing.OutQuad }
                }
            }
        }
    }
}
