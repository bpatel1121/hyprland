// Graphite · light — SDDM greeter
//
// The login half of the theme system: same wallpaper, same palette discipline
// as hyprlock (themes/graphite/hyprlock.conf) — INK is the frame and the
// type, the VIOLET appears only on the thing being acted on (a focused
// input, a hovered button), red only on failure. Colors are copied verbatim
// from the hyprlock input-field so boot -> login -> lock reads as one design.
//
// A light greeter, which changes two things the dark ones never had to think
// about. The scrim is still (1 - brightness) like the others, but at
// brightness 0.92 that is an 8% ink wash — enough to settle the paper, not
// enough to turn it to slate. And the login fields sit on a PAPER CARD: dark
// type straight on the sketch reads, but a dark-rimmed input box over pencil
// hatching does not — so the card is the one raised surface, and the inputs
// are whiter paper on it, exactly the launcher's window/input split.
//
// Same right-third layout as hyprlock, for the same reason: the figure fills
// the left and center of the sketch, and a centered card would cover the
// rifle. The offset is a fraction of the width, not a pixel count, so it
// holds at any resolution or Qt scale SDDM happens to run the greeter at.
//
// Deliberately plain Qt Quick: no Qt5Compat.GraphicalEffects (blur/glow),
// which would add a package dependency and a Qt-version headache for one
// visual flourish. Nothing here needs it: graphite is a flat sketch by design.
//
// Installed system-wide by scripts/sddm-apply.sh (SDDM runs as its own user
// and cannot read ~/.config). Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-graphite

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080          // greeter resizes the root item to the real screen
    color: "#e9e4e8"      // paper — ground, in case the wallpaper fails to load

    // Graphite roles, same names as palette.json
    readonly property color cInk:     "#2b2427"  // frame — the barrel's heaviest line
    readonly property color cEye:     "#8a4f96"  // readout — the violet eye, the one hue
    readonly property color cVisor:   "#1d1719"  // text
    readonly property color cEyeLit:  "#9c63a8"  // launcher — the eye where the light catches it
    readonly property color cRed:     "#c4475c"  // urgent — failure only
    readonly property color cPencil:  "#8f8181"  // dim — quiet type on the card (never on the sketch)
    readonly property color cPaper:   "#e9e4e8"  // ground — the card
    readonly property color cSheet:   "#f6f3f5"  // surface — the inputs, whiter paper
    readonly property color cEdge:    "#cfc8cf"  // hairline — resting input edges
    readonly property string mono:   "JetBrainsMono Nerd Font"

    // One flag drives the failure state (border + message) so the card never
    // has to re-layout: the message keeps its row and only changes opacity.
    property bool failed: false

    // Horizontal center of the whole stack: the right third. +480/1920 is the
    // hyprlock offset as a fraction, so the two screens line up.
    readonly property real stackX: root.width * 0.25

    // --- wallpaper, settled like hyprlock (brightness 0.92) ------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }
    // (1 - 0.92) = 0.08: an ink wash, which is what brightness 0.92 does to
    // the paper in hyprlock. Ink rather than black so the tint stays in the
    // sketch's own warm grey instead of cooling it.
    Rectangle { anchors.fill: parent; color: "#2b2427"; opacity: 0.08 }

    // --- clock — ink glyphs on paper, no glow, same as the lock screen -------
    // Everything on the bare wallpaper is ink: dim and dormant are the paper's
    // own greys and thin out against the hatching. They are for the card only.
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -140
        spacing: 8

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cInk         // ink, like the graphite hyprlock clock
            font.family: root.mono
            font.pixelSize: 96
            font.bold: true
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cVisor
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

    // --- login card — a paper tile, the power menu's numbers -----------------
    // 10px corners, 1px ink edge at 70%, paper at 97%: session.radius /
    // borderWidth / borderOpacity / tileOpacity from palette.json, so the card
    // is the same object as a session tile.
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 60
        width: panel.width + 48
        height: panel.height + 40
        radius: 10
        color: Qt.rgba(root.cPaper.r, root.cPaper.g, root.cPaper.b, 0.97)
        border.width: 1
        border.color: Qt.rgba(root.cInk.r, root.cInk.g, root.cInk.b, 0.7)

        // mirrors hyprlock's input-field
        Column {
            id: panel
            anchors.centerIn: parent
            spacing: 10

            // username — prefilled with the last user; small and quiet. The
            // focused edge is the violet: the one hue, on the thing you are
            // acting on (launcher.inputRadius 6).
            Rectangle {
                width: 320; height: 34; radius: 6
                color: root.cSheet
                border.width: 1
                border.color: userInput.activeFocus ? root.cEye : root.cEdge
                anchors.horizontalCenter: parent.horizontalCenter
                TextInput {
                    id: userInput
                    anchors.fill: parent
                    anchors.leftMargin: 14; anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cPencil
                    font.family: root.mono
                    font.pixelSize: 13
                    text: userModel.lastUser
                    selectByMouse: true
                    onAccepted: passInput.forceActiveFocus()
                }
            }

            // password — 320x52, radius 8, 1px ink border: hyprlock's numbers
            Rectangle {
                id: passBox
                width: 320; height: 52; radius: 8
                color: root.cSheet
                border.width: 1
                border.color: root.failed ? root.cRed : root.cInk
                anchors.horizontalCenter: parent.horizontalCenter
                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.leftMargin: 16; anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cVisor
                    font.family: root.mono
                    font.pixelSize: 15
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    focus: true
                    selectByMouse: true
                    onTextChanged: root.failed = false
                    onAccepted: sddm.login(userInput.text, passInput.text, sessionBox.currentIndex)
                }
                Text {
                    anchors.centerIn: parent
                    visible: passInput.text.length === 0
                    text: "enter password"
                    color: root.cPencil
                    font.family: root.mono
                    font.pixelSize: 13
                }
            }

            // Always laid out, so the card does not jump when it appears.
            Text {
                id: failText
                opacity: root.failed ? 1 : 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: "authentication failed"
                color: root.cRed
                font.family: root.mono
                font.pixelSize: 13
            }
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
            color: root.cSheet; radius: 6
            border.width: 1; border.color: root.cEdge
        }
        contentItem: Text {
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
            text: sessionBox.displayText
            color: root.cPencil
            font: sessionBox.font
        }
    }

    // --- power row, bottom-right (glyphs need the Nerd Font) ----------------
    // Ink at rest, not dormant: these sit on the sketch. Violet when touched —
    // the same lift the launcher gets — and red only for power off.
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 22

        Text {
            visible: sddm.canSuspend
            text: "⏾"          // fallback-safe glyph; nerd font shows it fine
            color: powerSuspend.containsMouse ? root.cEyeLit : root.cInk
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerSuspend; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.suspend() }
        }
        Text {
            visible: sddm.canReboot
            text: "↻"
            color: powerReboot.containsMouse ? root.cEyeLit : root.cInk
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerReboot; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.reboot() }
        }
        Text {
            visible: sddm.canPowerOff
            text: "⏻"
            color: powerOff.containsMouse ? root.cRed : root.cInk
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerOff; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.powerOff() }
        }
    }

    // --- sddm signals --------------------------------------------------------
    Connections {
        target: sddm
        // Clear FIRST, then flag: clearing fires onTextChanged, which resets
        // the flag — in the other order the message is wiped the instant it
        // appears.
        function onLoginFailed() {
            passInput.text = ""
            root.failed = true
            passInput.forceActiveFocus()
        }
        function onLoginSucceeded() { }
    }

    Component.onCompleted: passInput.forceActiveFocus()
}
