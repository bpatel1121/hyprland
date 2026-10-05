// Streetwear · light — SDDM greeter
//
// The login half of the theme system: same wallpaper, same palette discipline
// as hyprlock (themes/streetwear/hyprlock.conf) — the yellow TAG is the frame,
// NAVY is the content, pink appears only on failure. Colors are copied
// verbatim from the hyprlock input-field so boot -> login -> lock reads as one
// design.
//
// The first LIGHT greeter, which changes two things the dark ones never had
// to think about. The scrim is still (1 - brightness) like the others, but at
// brightness 0.9 that is a 10% navy wash — enough to settle the sky, not
// enough to turn it to mud. And the login fields sit on a PAPER CARD: dark
// type straight on a periwinkle field reads, but a dark input box on it does
// not — so the card is the one raised surface, and the inputs are whiter
// paper on it, exactly the launcher's window/input split.
//
// Same left-third layout as hyprlock, for the same reason: the figure stands
// dead center, and a centered card would cover her face. The offset is a
// fraction of the width, not a pixel count, so it holds at any resolution
// or Qt scale SDDM happens to run the greeter at.
//
// Deliberately plain Qt Quick: no Qt5Compat.GraphicalEffects (blur/glow),
// which would add a package dependency and a Qt-version headache for one
// visual flourish. Nothing here needs it: streetwear is flat print by design.
//
// Installed system-wide by scripts/sddm-apply.sh (SDDM runs as its own user
// and cannot read ~/.config). Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-streetwear

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080          // greeter resizes the root item to the real screen
    color: "#f4efe8"      // paper — ground, in case the wallpaper fails to load

    // Streetwear roles, same names as palette.json
    readonly property color cTag:     "#e9b92a"  // frame — the yellow OFF-WHITE tag
    readonly property color cNavy:    "#13202a"  // readout — the bob, the tag's print
    readonly property color cInk:     "#1b2630"  // text
    readonly property color cPink:    "#d66676"  // launcher — the holographic sticker
    readonly property color cRed:     "#d6476a"  // urgent — failure only
    readonly property color cDim:     "#7d8aa0"  // dim — quiet type on paper (never on sky)
    readonly property color cPaper:   "#f4efe8"  // ground — the card
    readonly property color cSheet:   "#fbf8f2"  // surface — the inputs, whiter paper
    readonly property color cSeam:    "#e3dcd0"  // hairline — resting input edges
    readonly property string mono:   "JetBrainsMono Nerd Font"

    // One flag drives the failure state (border + message) so the card never
    // has to re-layout: the message keeps its row and only changes opacity.
    property bool failed: false

    // Horizontal center of the whole stack: the left third. -480/1920 is the
    // hyprlock offset as a fraction, so the two screens line up.
    readonly property real stackX: -root.width * 0.25

    // --- wallpaper, settled like hyprlock (brightness 0.9) -------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }
    // (1 - 0.9) = 0.10: a navy wash, which is what brightness 0.9 does to the
    // sky in hyprlock. Navy rather than black so the tint stays in the
    // picture's own family instead of graying it.
    Rectangle { anchors.fill: parent; color: "#13202a"; opacity: 0.10 }

    // --- clock — navy glyphs on sky, no glow, same as the lock screen --------
    // Everything on the bare wallpaper is navy: dim and dormant are sky-colored
    // and disappear out here. They are for the card only.
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -140
        spacing: 8

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cNavy        // navy, like the streetwear hyprlock clock
            font.family: root.mono
            font.pixelSize: 96
            font.bold: true
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cInk
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
    // 14px corners, 1px tag edge at 60%, paper at 96%: session.radius /
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
        radius: 14
        color: Qt.rgba(root.cPaper.r, root.cPaper.g, root.cPaper.b, 0.96)
        border.width: 1
        border.color: Qt.rgba(root.cTag.r, root.cTag.g, root.cTag.b, 0.6)

        // mirrors hyprlock's input-field
        Column {
            id: panel
            anchors.centerIn: parent
            spacing: 10

            // username — prefilled with the last user; small and quiet
            Rectangle {
                width: 320; height: 34; radius: 8
                color: root.cSheet
                border.width: 1
                border.color: userInput.activeFocus ? root.cTag : root.cSeam
                anchors.horizontalCenter: parent.horizontalCenter
                TextInput {
                    id: userInput
                    anchors.fill: parent
                    anchors.leftMargin: 14; anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cDim
                    font.family: root.mono
                    font.pixelSize: 13
                    text: userModel.lastUser
                    selectByMouse: true
                    onAccepted: passInput.forceActiveFocus()
                }
            }

            // password — 320x52, radius 10, 2px tag border: hyprlock's numbers
            Rectangle {
                id: passBox
                width: 320; height: 52; radius: 10
                color: root.cSheet
                border.width: 2
                border.color: root.failed ? root.cRed : root.cTag
                anchors.horizontalCenter: parent.horizontalCenter
                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.leftMargin: 16; anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cNavy
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
                    color: root.cDim
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
            color: root.cSheet; radius: 8
            border.width: 1; border.color: root.cSeam
        }
        contentItem: Text {
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
            text: sessionBox.displayText
            color: root.cDim
            font: sessionBox.font
        }
    }

    // --- power row, bottom-right (glyphs need the Nerd Font) ----------------
    // Navy at rest, not dormant: these sit on the sky. Pink when touched —
    // the same lift the launcher gets — and red only for power off.
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 22

        Text {
            visible: sddm.canSuspend
            text: "⏾"          // fallback-safe glyph; nerd font shows it fine
            color: powerSuspend.containsMouse ? root.cPink : root.cNavy
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerSuspend; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.suspend() }
        }
        Text {
            visible: sddm.canReboot
            text: "↻"
            color: powerReboot.containsMouse ? root.cPink : root.cNavy
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerReboot; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.reboot() }
        }
        Text {
            visible: sddm.canPowerOff
            text: "⏻"
            color: powerOff.containsMouse ? root.cRed : root.cNavy
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
