// Glacier · frost — SDDM greeter
//
// The login half of the theme system: same wallpaper, same palette discipline
// as hyprlock (themes/glacier/hyprlock.conf) — ICE CYAN is the frame, WHITE
// is the content, red appears only on failure. Colors are copied verbatim
// from the hyprlock input-field so boot -> login -> lock reads as one design.
//
// Same lower-third layout as hyprlock, for the same reason: the figure sits
// dead center on her throne, and the centered stack of the other dark
// greeters would put the clock across her chest and the inputs across her
// lap; this low it crosses only her legs and the ice floor. The whole stack
// moves down by a fraction of the height rather than a pixel count, so it
// holds at any resolution or Qt scale SDDM happens to run the greeter at.
//
// Deliberately plain Qt Quick: no Qt5Compat.GraphicalEffects (blur/glow),
// which would add a package dependency and a Qt-version headache for one
// visual flourish. The "glow" here is a raised ice-cyan text style under the
// white clock — cheap, safe, and quiet, which is the whole theme.
//
// Installed system-wide by scripts/sddm-apply.sh (SDDM runs as its own user
// and cannot read ~/.config). Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-glacier

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080          // greeter resizes the root item to the real screen
    color: "#0b1838"      // sky — ground, in case the wallpaper fails to load

    // Glacier roles, same names as palette.json
    readonly property color cFrame:   "#5bd7fa"  // frame — the ice swords
    readonly property color cReadout: "#e8f4ff"  // readout — the white cap
    readonly property color cRed:     "#ff6b81"  // urgent — failure only
    readonly property color cGray:    "#7f8fbf"  // dormant — quiet type
    readonly property color cFg:      "#e6eefc"  // text — snow
    readonly property color cInner:   "#15295a"  // surface — deep ice, the inputs
    readonly property color cSeam:    "#223b6e"  // hairline — resting input edges
    readonly property string mono:   "JetBrainsMono Nerd Font"

    // Vertical shift of the whole stack: the lower third. hyprlock moves its
    // stack 210px down a 1080-high layout, so 0.2 of the height keeps the two
    // screens lined up.
    readonly property real stackY: root.height * 0.2

    // --- wallpaper, dimmed like hyprlock (brightness 0.5) -------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }
    // (1 - 0.5) = 0.50: the navy scrim that brightness 0.5 is in hyprlock.
    // Sky rather than black so the dim stays in the painting's own hue.
    Rectangle { anchors.fill: parent; color: "#0b1838"; opacity: 0.50 }  // sky scrim

    // --- clock — white glyphs, ice-cyan undertone, same as the lock screen --
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -140 + root.stackY
        spacing: 8

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cReadout
            font.family: root.mono
            font.pixelSize: 96
            font.bold: true
            style: Text.Raised
            styleColor: "#805bd7fa"   // frame at ~50% — the budget glow, cold
            text: Qt.formatTime(new Date(), "HH:mm")
        }
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
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 60 + root.stackY
        spacing: 10

        // username — prefilled with the last user; small and quiet. 8px
        // corners: the launcher's inputRadius, the same object as its input.
        Rectangle {
            width: 320; height: 34; radius: 8
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

        // password — 320x52, radius 12, 2px ice border: hyprlock's numbers
        Rectangle {
            id: passBox
            width: 320; height: 52; radius: 12
            color: root.cInner
            border.width: 2
            border.color: failText.visible ? root.cRed : root.cFrame
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

        Text {
            id: failText
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            text: "authentication failed"
            color: root.cRed
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
            color: root.cInner; radius: 8
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
    // Dormant at rest, ice cyan when touched — the frame hue is the lift here,
    // as it is on the bar's chips — and red only for power off.
    Row {
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
            color: powerOff.containsMouse ? root.cRed : root.cGray
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
