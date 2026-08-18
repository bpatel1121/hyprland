// Generated · Material You (matugen) — SDDM greeter
//
// The login half of the theme system: same wallpaper, same palette discipline
// as hyprlock (themes/cyberpunk/hyprlock.conf) — PINK is the frame, CYAN is
// the content, red appears only on failure. Colors are copied verbatim from
// the hyprlock input-field so boot -> login -> lock reads as one design.
//
// Deliberately plain Qt Quick: no Qt5Compat.GraphicalEffects (blur/glow),
// which would add a package dependency and a Qt-version headache for one
// visual flourish. The "glow" here is a raised pink text style — cheap, safe.
//
// Installed system-wide by scripts/sddm-apply.sh (SDDM runs as its own user
// and cannot read ~/.config). Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-cyberpunk

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080          // greeter resizes the root item to the real screen
    color: "#1a110e"      // no0 — ground, in case the wallpaper fails to load

    // Cybrcolors, same names as waybar/style.css
    readonly property color cPink:  "#ffb596"   // pi0 — frame
    readonly property color cCyan:  "#e6beae"   // cy0 — content
    readonly property color cRed:   "#ffb4ab"   // re0 — failure only
    readonly property color cGray:  "#d8c2ba"   // wh0 — dormant
    readonly property color cFg:    "#f1dfd9"   // text
    readonly property color cInner: "#271e1a"   // no2 — raised surfaces
    readonly property string mono:  "JetBrainsMono Nerd Font"

    // --- wallpaper, dimmed like hyprlock (brightness 0.55) ------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }
    Rectangle { anchors.fill: parent; color: "#1a110e"; opacity: 0.45 }

    // --- clock — cyan glyphs, pink undertone, same as the lock screen -------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -140
        spacing: 8

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cCyan
            font.family: root.mono
            font.pixelSize: 96
            font.bold: true
            style: Text.Raised
            styleColor: "#80F230B2"   // pi0 at ~50% — the budget glow
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
        anchors.verticalCenterOffset: 60
        spacing: 10

        // username — prefilled with the last user; small and quiet
        Rectangle {
            width: 320; height: 34; radius: 10
            color: root.cInner
            border.width: 1
            border.color: userInput.activeFocus ? root.cPink : "#53443e"
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

        // password — 320x52, radius 12, 2px pink border: hyprlock's numbers
        Rectangle {
            id: passBox
            width: 320; height: 52; radius: 12
            color: root.cInner
            border.width: 2
            border.color: failText.visible ? root.cRed : root.cPink
            anchors.horizontalCenter: parent.horizontalCenter
            TextInput {
                id: passInput
                anchors.fill: parent
                anchors.leftMargin: 16; anchors.rightMargin: 16
                verticalAlignment: TextInput.AlignVCenter
                color: root.cFg
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
            color: root.cInner; radius: 10
            border.width: 1; border.color: "#53443e"
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
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 22

        Text {
            visible: sddm.canSuspend
            text: "⏾"          // fallback-safe glyph; nerd font shows it fine
            color: powerSuspend.containsMouse ? root.cCyan : root.cGray
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerSuspend; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.suspend() }
        }
        Text {
            visible: sddm.canReboot
            text: "↻"
            color: powerReboot.containsMouse ? root.cCyan : root.cGray
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
        function onLoginFailed() {
            failText.visible = true
            passInput.text = ""
            passInput.forceActiveFocus()
        }
        function onLoginSucceeded() { }
    }

    Component.onCompleted: passInput.forceActiveFocus()
}
