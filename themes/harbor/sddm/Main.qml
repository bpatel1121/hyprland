// Harbor · dusk over water — SDDM greeter
//
// The login half of the theme system: same wallpaper, same palette discipline
// as hyprlock (themes/harbor/hyprlock.conf) — AMBER is the frame AND the
// content, one hue at two weights, on the sky's teal-black; red appears only
// on failure. (The smoke cyan is hyprlock's checking flash; a greeter has no
// checking state, so it never shows here.) Colors are copied verbatim from
// the hyprlock input-field so boot -> login -> lock reads as one design.
//
// Same centre-right layout as hyprlock, for the same reason: the figure
// stands left of centre (her arm and the can reach nearly to the middle),
// and the skyline fills the band where the other dark greeters put their
// clock; over the water at x ~62 % and a little low, the stack crosses only
// dark water and the railing in front of it — see the LAYOUT NOTE in
// hyprlock.conf for the measurements. Both offsets are fractions of the
// screen, not pixel counts, so the stack lands on the same patch of water at
// any resolution or Qt scale SDDM happens to run the greeter at.
//
// Deliberately plain Qt Quick: no Qt5Compat.GraphicalEffects (blur/glow),
// which would add a package dependency and a Qt-version headache for one
// visual flourish. The "glow" here is a raised mid-amber text style under the
// lit-amber clock — cheap, safe, and quiet: lamplight, not neon.
//
// Installed system-wide by scripts/sddm-apply.sh (SDDM runs as its own user
// and cannot read ~/.config). Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-harbor

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080          // greeter resizes the root item to the real screen
    color: "#0e1a20"      // dusk — ground, in case the wallpaper fails to load

    // Harbor roles, same names as palette.json
    readonly property color cFrame:   "#e0ab5a"  // frame — the hoodie's amber
    readonly property color cReadout: "#f6c870"  // readout — the hoodie, lit
    readonly property color cRed:     "#eb4030"  // urgent — failure only
    readonly property color cGray:    "#62939f"  // dormant — quiet type
    readonly property color cFg:      "#efe6d3"  // text — cream
    readonly property color cInner:   "#172730"  // surface — the skyline, the inputs
    readonly property color cSeam:    "#243a44"  // hairline — resting input edges
    readonly property string mono:   "JetBrainsMono Nerd Font"

    // Centre of the whole stack: over the water, a little low. +230/1920 is
    // the hyprlock x offset as a fraction, and hyprlock moves its stack 210px
    // down a 1080-high layout, so 0.2 of the height keeps the two screens
    // lined up.
    readonly property real stackX: root.width * 0.12
    readonly property real stackY: root.height * 0.2

    // --- wallpaper, dimmed like hyprlock (brightness 0.55) ------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }
    // (1 - 0.55) = 0.45: the scrim that brightness 0.55 is in hyprlock.
    // Teal-black rather than black so the dim stays in the picture's own hue.
    Rectangle { anchors.fill: parent; color: "#0e1a20"; opacity: 0.45 }  // dusk scrim

    // --- clock — lit-amber glyphs, mid-amber undertone, same as the lock screen
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
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
            styleColor: "#80e0ab5a"   // frame at ~50% — the budget glow, warm
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        // Outlined in the ground, which hyprlock never needs: the lock screen
        // blurs the picture and the greeter cannot, so here the railing's lit
        // edges cross the date at full sharpness — dormant straight on them
        // dips to 2.7:1 over a twentieth of the line. A 1px ground outline
        // keeps every glyph edge on teal-black (5.2:1) at no cost to the layout.
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cGray
            font.family: root.mono
            font.pixelSize: 16
            style: Text.Outline
            styleColor: root.color
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

        // password — 320x52, radius 12, 2px amber border: hyprlock's numbers
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

        // Outlined like the date, for the same reason: it sits on the railing.
        Text {
            id: failText
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            text: "authentication failed"
            color: root.cRed
            font.family: root.mono
            font.pixelSize: 13
            style: Text.Outline
            styleColor: root.color
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
    // Dormant at rest, amber when touched — the frame hue is the lift here,
    // as it is on the bar's chips — and red only for power off.
    //
    // On a pane, as glacier's is: this corner of the picture is the lamplit
    // pavement, the brightest warm thing in it, and even at brightness 0.55
    // dormant type straight on it is 2.0:1 (red 1.8:1 — red on orange). The
    // pane is the notification card — the skyline's teal-navy (surface) at
    // 0.85 with a 1px seam, 12px corners — and on it the row reads at 4.0:1
    // resting, 6.5:1 touched, 3.4:1 for red.
    Rectangle {
        anchors.fill: powerRow
        anchors.margins: -10
        radius: 12
        color: root.cInner
        opacity: 0.85
        border.width: 1
        border.color: root.cSeam
    }
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
