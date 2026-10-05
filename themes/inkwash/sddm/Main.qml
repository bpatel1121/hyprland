// Inkwash · light — SDDM greeter
//
// The login half of the theme system: same wallpaper, same palette discipline
// as hyprlock (themes/inkwash/hyprlock.conf) — the GOLD FILIGREE is the frame,
// the OLIVE INK is the content, the cyan burst is the live color, red appears
// only on failure. Colors are copied verbatim from the hyprlock input-field so
// boot -> login -> lock reads as one design.
//
// A light greeter, which changes two things the dark ones never had to think
// about. The scrim is still (1 - brightness) like the others, but at
// brightness 0.92 that is an 8% ink wash — enough to settle the paper, not
// enough to grey it. And the login fields sit on a PAPER CARD: ink type
// straight on the smoke wash reads, but a bare input box on it does not — so
// the card is the one raised surface, and the inputs are whiter paper on it,
// exactly the launcher's window/input split.
//
// Same upper-left layout as hyprlock, for the same reason: the figure fills
// the center, his shoulder plate reaches a quarter of the way across below
// the midline, and the smoke wash is only clear above it — see the LAYOUT
// NOTE in hyprlock.conf for the measurements. Both offsets are fractions of
// the screen, not pixel counts, so the stack lands on the same patch of
// smoke at any resolution or Qt scale SDDM happens to run the greeter at.
//
// Deliberately plain Qt Quick: no Qt5Compat.GraphicalEffects (blur/glow),
// which would add a package dependency and a Qt-version headache for one
// visual flourish. Nothing here needs it: inkwash is flat ink by design.
//
// Installed system-wide by scripts/sddm-apply.sh (SDDM runs as its own user
// and cannot read ~/.config). Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-inkwash

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080          // greeter resizes the root item to the real screen
    color: "#ebe9e5"      // paper — ground, in case the wallpaper fails to load

    // Inkwash roles, same names as palette.json
    readonly property color cGold:    "#c89a3e"  // frame — the filigree on the armor
    readonly property color cOlive:   "#3f4d2a"  // readout — the armor's olive ink
    readonly property color cInk:     "#1c1b14"  // text
    readonly property color cBurst:   "#286884"  // launcher — the cyan burst, printed to its deep water
    readonly property color cRed:     "#c0392b"  // urgent — failure only
    readonly property color cSmoke:   "#8a8a7a"  // dim — quiet type on paper (never on the wash)
    readonly property color cPaper:   "#ebe9e5"  // ground — the card
    readonly property color cSheet:   "#f6f5f2"  // surface — the inputs, whiter paper
    readonly property color cEdge:    "#d6d3cb"  // hairline — resting input edges
    readonly property string mono:   "JetBrainsMono Nerd Font"

    // One flag drives the failure state (border + message) so the card never
    // has to re-layout: the message keeps its row and only changes opacity.
    property bool failed: false

    // Center of the whole stack, upper left. -700/1920 and the clock's
    // 440/1200 lift are the hyprlock offsets as fractions, so the two screens
    // line up: the clock column is centered 0.36 of the height above center,
    // the card 0.20 — which puts its password box where hyprlock's input is.
    readonly property real stackX: -root.width * 0.365
    readonly property real clockY: -root.height * 0.36
    readonly property real cardY:  -root.height * 0.20

    // --- wallpaper, settled like hyprlock (brightness 0.92) ------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }
    // (1 - 0.92) = 0.08: an ink wash, which is what brightness 0.92 does to
    // the paper in hyprlock. Ink rather than black so the tint stays in the
    // painting's own family instead of greying it.
    Rectangle { anchors.fill: parent; color: "#1c1b14"; opacity: 0.08 }

    // --- clock — olive-ink glyphs on the wash, no glow, same as the lock ----
    // Everything on the bare wallpaper is an ink: dim and dormant are
    // smoke-colored and disappear out here. They are for the card only.
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.clockY
        spacing: 8

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cOlive       // olive ink, like the inkwash hyprlock clock
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
    // 8px corners, 1px gold edge at 80%, paper at 95%: session.radius /
    // borderWidth / borderOpacity / tileOpacity from palette.json, so the card
    // is the same object as a session tile.
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.cardY
        width: panel.width + 48
        height: panel.height + 40
        radius: 8
        color: Qt.rgba(root.cPaper.r, root.cPaper.g, root.cPaper.b, 0.95)
        border.width: 1
        border.color: Qt.rgba(root.cGold.r, root.cGold.g, root.cGold.b, 0.8)

        // mirrors hyprlock's input-field
        Column {
            id: panel
            anchors.centerIn: parent
            spacing: 10

            // username — prefilled with the last user; small and quiet.
            // 5px corners: the launcher's inputRadius.
            Rectangle {
                width: 320; height: 34; radius: 5
                color: root.cSheet
                border.width: 1
                border.color: userInput.activeFocus ? root.cGold : root.cEdge
                anchors.horizontalCenter: parent.horizontalCenter
                TextInput {
                    id: userInput
                    anchors.fill: parent
                    anchors.leftMargin: 14; anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cSmoke
                    font.family: root.mono
                    font.pixelSize: 13
                    text: userModel.lastUser
                    selectByMouse: true
                    onAccepted: passInput.forceActiveFocus()
                }
            }

            // password — 320x52, radius 6, 1px gold rim: hyprlock's numbers
            Rectangle {
                id: passBox
                width: 320; height: 52; radius: 6
                color: root.cSheet
                border.width: 1
                border.color: root.failed ? root.cRed : root.cGold
                anchors.horizontalCenter: parent.horizontalCenter
                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.leftMargin: 16; anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cOlive
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
                    color: root.cSmoke
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
            color: root.cSheet; radius: 5
            border.width: 1; border.color: root.cEdge
        }
        contentItem: Text {
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
            text: sessionBox.displayText
            color: root.cSmoke
            font: sessionBox.font
        }
    }

    // --- power row, bottom-right (glyphs need the Nerd Font) ----------------
    // Olive ink at rest, not dormant: these sit on the wash. The burst when
    // touched — the same lift the launcher gets — and red only for power off.
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 22

        Text {
            visible: sddm.canSuspend
            text: "⏾"          // fallback-safe glyph; nerd font shows it fine
            color: powerSuspend.containsMouse ? root.cBurst : root.cOlive
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerSuspend; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.suspend() }
        }
        Text {
            visible: sddm.canReboot
            text: "↻"
            color: powerReboot.containsMouse ? root.cBurst : root.cOlive
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerReboot; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.reboot() }
        }
        Text {
            visible: sddm.canPowerOff
            text: "⏻"
            color: powerOff.containsMouse ? root.cRed : root.cOlive
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
