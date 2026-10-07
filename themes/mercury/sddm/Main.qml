// Mercury · liquid metal on true black — SDDM greeter
//
// The login half of the theme system: same wallpaper, same palette discipline
// as hyprlock (themes/mercury/hyprlock.conf) — CHROME is the frame, SILVER is
// the content, and failure is pure white, told by weight. (The heated grey is
// hyprlock's checking state; a greeter has no checking state, so it never
// shows here.) No hue anywhere. Colors are copied verbatim from the hyprlock
// input-field so boot -> login -> lock reads as one design.
//
// Same left-of-centre layout as hyprlock, for the same reason: the figure is
// centre-right (x 40..75 % of the crop, the head at y 37..60 %), so the
// centred stack of the other dark greeters would cross the face; at x ~22 %
// and vertically centred the stack sits over pure black — see the LAYOUT NOTE
// in hyprlock.conf for the measurements. The offset is a fraction of the
// screen, not a pixel count, so the stack lands on the same patch of black at
// any resolution or Qt scale SDDM happens to run the greeter at.
//
// Deliberately plain Qt Quick: no Qt5Compat.GraphicalEffects (blur/glow),
// which would add a package dependency and a Qt-version headache for one
// visual flourish. The "glow" here is a raised chrome text style under the
// silver clock — cheap, safe, and quiet: metal catching light, not neon.
//
// Installed system-wide by scripts/sddm-apply.sh (SDDM runs as its own user
// and cannot read ~/.config). Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-mercury

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080          // greeter resizes the root item to the real screen
    color: "#000000"      // void — ground, in case the wallpaper fails to load

    // Mercury roles, same names as palette.json
    readonly property color cFrame:   "#dedede"  // frame — chrome, the specular edge
    readonly property color cReadout: "#b4b4b4"  // readout — brushed silver
    readonly property color cHot:     "#ffffff"  // urgent — failure only, white-hot
    readonly property color cGray:    "#8c8c8c"  // dormant — quiet type (pewter)
    readonly property color cFg:      "#ececec"  // text — the specks' white
    readonly property color cInner:   "#101010"  // surface — the shadow side, the inputs
    readonly property color cSeam:    "#2a2a2a"  // hairline — resting input edges
    readonly property string mono:   "JetBrainsMono Nerd Font"

    // Centre of the whole stack: left of centre, vertically centred. -538/1920
    // is the hyprlock x offset as a fraction; hyprlock keeps the dark themes'
    // vertical layout, so there is no y offset.
    readonly property real stackX: -root.width * 0.28

    // --- wallpaper, dimmed like hyprlock (brightness 0.7) -------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }
    // (1 - 0.7) = 0.3: the scrim that brightness 0.7 is in hyprlock — lighter
    // than the night themes' 0.45 because the ground is already true black
    // and only the figure's highlights need settling. Black, which is the
    // ground: the dim stays in the picture's own nothing.
    Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.3 }  // void scrim

    // --- clock — silver glyphs, chrome undertone, same as the lock screen ---
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -140
        spacing: 8

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cReadout
            font.family: root.mono
            font.pixelSize: 96
            font.bold: true
            style: Text.Raised
            styleColor: "#80dedede"   // frame at ~50% — the budget glow, chrome
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        // No outline: everything under the stack is the black (hyprlock.conf,
        // LAYOUT NOTE), so the greeter, which cannot blur, reads the same as
        // the lock — dormant 6.2:1, the clock 10.1:1. The one thing the blur
        // would have hidden is a speck, a single pixel of star under the 0.3
        // scrim; a glyph is not legible or illegible by one pixel.
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cGray
            font.family: root.mono
            font.pixelSize: 16
            text: Qt.formatDate(new Date(), "dddd, dd MMMM")
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            clockText.text = Qt.formatTime(new Date(), "HH:mm")
            dateText.text  = Qt.formatDate(new Date(), "dddd, dd MMMM")
        }
    }

    // --- login panel — mirrors hyprlock's input-field ------------------------
    Column {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 60
        spacing: 10

        // username — prefilled with the last user; small and quiet. 7px
        // corners: the launcher's inputRadius, the same object as its input.
        Rectangle {
            width: 320; height: 34; radius: 7
            color: root.cInner
            border.width: 1
            border.color: userInput.activeFocus ? root.cFrame : root.cSeam
            anchors.horizontalCenter: parent.horizontalCenter
            TextInput {
                id: userInput
                anchors.fill: parent
                anchors.leftMargin: 14; anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                color: root.cGray
                font.family: root.mono
                font.pixelSize: 13
                text: userModel.lastUser
                selectByMouse: true
                onAccepted: passInput.forceActiveFocus()
            }
        }

        // password — 320x52, radius 10, 2px chrome border: hyprlock's numbers.
        // Failure goes white-hot: the only thing brighter than the frame.
        Rectangle {
            id: passBox
            width: 320; height: 52; radius: 10
            color: root.cInner
            border.width: 2
            border.color: failText.visible ? root.cHot : root.cFrame
            anchors.horizontalCenter: parent.horizontalCenter
            TextInput {
                id: passInput
                anchors.fill: parent
                anchors.leftMargin: 16; anchors.rightMargin: 16
                verticalAlignment: TextInput.AlignVCenter
                color: root.cReadout
                font.family: root.mono
                font.pixelSize: 15
                echoMode: TextInput.Password
                passwordCharacter: "•"
                focus: true
                selectByMouse: true
                onTextChanged: failText.visible = false
                onAccepted: sddm.login(userInput.text, passInput.text, sessionBox.currentIndex)
            }
            Text {
                anchors.centerIn: parent
                visible: passInput.text.length === 0
                text: "enter password"
                color: root.cGray
                font.family: root.mono
                font.pixelSize: 13
                opacity: 0.7
            }
        }

        // No outline either: white on black is 21:1, and the stack sits on
        // the black (see the clock's note).
        Text {
            id: failText
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            text: "authentication failed"
            color: root.cHot
            font.family: root.mono
            font.pixelSize: 13
        }
    }

    // --- session picker, bottom-left ----------------------------------------
    ComboBox {
        id: sessionBox
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 28
        width: 200
        model: sessionModel
        textRole: "name"
        currentIndex: sessionModel.lastIndex
        font.family: root.mono
        font.pixelSize: 12

        background: Rectangle {
            color: root.cInner; radius: 7
            border.width: 1; border.color: root.cSeam
        }
        contentItem: Text {
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
            text: sessionBox.displayText
            color: root.cGray
            font: sessionBox.font
        }
    }

    // --- power row, bottom-right (glyphs need the Nerd Font) ----------------
    // Dormant at rest, chrome when touched — the frame is the lift here, as it
    // is on the bar's chips — and white-hot only for power off: weight, not hue.
    //
    // Straight on the picture, as vesper's is, not on a pane: this corner is
    // the black (mean #000000 measured; the shoulders stop at x ~75 %), and
    // under the 0.3 scrim the row reads at 6.2:1 resting, 15.6:1 touched,
    // 21:1 for white.
    Row {
        id: powerRow
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 22

        Text {
            visible: sddm.canSuspend
            text: "⏾"          // fallback-safe glyph; nerd font shows it fine
            color: powerSuspend.containsMouse ? root.cFrame : root.cGray
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerSuspend; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.suspend() }
        }
        Text {
            visible: sddm.canReboot
            text: "↻"
            color: powerReboot.containsMouse ? root.cFrame : root.cGray
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerReboot; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.reboot() }
        }
        Text {
            visible: sddm.canPowerOff
            text: "⏻"
            color: powerOff.containsMouse ? root.cHot : root.cGray
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerOff; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.powerOff() }
        }
    }

    // --- sddm signals --------------------------------------------------------
    Connections {
        target: sddm
        // Clear FIRST, then show: clearing fires onTextChanged, which hides
        // the message — in the other order it is wiped the instant it appears.
        function onLoginFailed() {
            passInput.text = ""
            failText.visible = true
            passInput.forceActiveFocus()
        }
        function onLoginSucceeded() { }
    }

    Component.onCompleted: passInput.forceActiveFocus()
}
