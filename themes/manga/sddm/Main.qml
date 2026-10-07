// Manga · light — SDDM greeter
//
// The login half of the theme system: same wallpaper, same palette discipline
// as hyprlock (themes/manga/hyprlock.conf) — INK is the frame and the type,
// the MID INK appears only on the thing being acted on (a focused input, a
// hovered button), and failure is pure ink, told by weight: the password box
// goes to a 2px line of it. No hue anywhere. Colors are copied verbatim from
// the hyprlock input-field so boot -> login -> lock reads as one design.
//
// A light greeter, which changes two things the dark ones never had to think
// about. The scrim is still (1 - brightness) like the others, but at
// brightness 0.95 that is a 5% ink wash — enough to settle the page, not
// enough to grey it. And the login fields sit on a CARDSTOCK CARD: the
// inputs are the clean page on it, exactly the launcher's window/input split
// and the power menu's tile — so the card is the one raised surface on a
// page that is otherwise flat. The power row sits straight on the page: this
// corner is blank paper (measured), and the mid ink reads at 7.4:1 there.
//
// Same left-of-centre layout as hyprlock, for the same reason: the figure
// stands right of centre (x 70..94 % of the crop, y 19..97 %), so the dark
// greeters' centred stack would cross her blades and graphite's lower-right
// one her skirt — see the LAYOUT NOTE in hyprlock.conf for the measurements.
// The offset is a fraction of the screen, not a pixel count, so the stack
// lands on the same patch of page at any resolution or Qt scale SDDM happens
// to run the greeter at.
//
// Deliberately plain Qt Quick: no Qt5Compat.GraphicalEffects (blur/glow),
// which would add a package dependency and a Qt-version headache for one
// visual flourish. Nothing here needs it: manga is a printed page by design.
//
// Installed system-wide by scripts/sddm-apply.sh (SDDM runs as its own user
// and cannot read ~/.config). Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypr-manga

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080          // greeter resizes the root item to the real screen
    color: "#e8e8e8"      // cardstock — ground, in case the wallpaper fails to load

    // Manga roles, same names as palette.json
    readonly property color cInk:     "#111111"  // frame — the heaviest line
    readonly property color cMidInk:  "#4a4a4a"  // launcher — the touch weight
    readonly property color cPureInk: "#000000"  // urgent — failure only (hyprlock's checking grey never shows here: a greeter has no checking state)
    readonly property color cType:    "#161616"  // text
    readonly property color cPencil:  "#858585"  // dim — quiet type on the card (never on the page)
    readonly property color cCard:    "#e8e8e8"  // ground — the card
    readonly property color cPage:    "#f5f5f5"  // surface — the inputs, the clean page
    readonly property color cRule:    "#cfcfcf"  // hairline — resting input edges
    readonly property string mono:   "JetBrainsMono Nerd Font"

    // One flag drives the failure state (border + message) so the card never
    // has to re-layout: the message keeps its row and only changes opacity.
    property bool failed: false

    // Centre of the whole stack: left of centre, vertically centred. -480/1920
    // is the hyprlock x offset as a fraction; hyprlock keeps the dark themes'
    // vertical layout, so there is no y offset.
    readonly property real stackX: -root.width * 0.25

    // --- wallpaper, settled like hyprlock (brightness 0.95) ------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }
    // (1 - 0.95) = 0.05: an ink wash, which is what brightness 0.95 does to
    // the page in hyprlock. Ink rather than black so it is the page's own
    // grey, not a cast.
    Rectangle { anchors.fill: parent; color: "#111111"; opacity: 0.05 }

    // --- clock — ink glyphs on the page, no glow, same as the lock screen ----
    // Everything on the bare wallpaper is ink: dim and dormant are the page's
    // own greys and thin out against it. They are for the card only.
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.stackX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -140
        spacing: 8

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cInk         // ink, like the manga hyprlock clock
            font.family: root.mono
            font.pixelSize: 96
            font.bold: true
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cType
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

    // --- login card — a cardstock tile, the power menu's numbers ------------
    // 4px corners, 1px ink edge at 90%, cardstock at 97%: session.radius /
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
        radius: 4
        color: Qt.rgba(root.cCard.r, root.cCard.g, root.cCard.b, 0.97)
        border.width: 1
        border.color: Qt.rgba(root.cInk.r, root.cInk.g, root.cInk.b, 0.9)

        // mirrors hyprlock's input-field
        Column {
            id: panel
            anchors.centerIn: parent
            spacing: 10

            // username — prefilled with the last user; small and quiet. The
            // focused edge is the mid ink: the touch weight, on the thing you
            // are acting on (launcher.inputRadius 3).
            Rectangle {
                width: 320; height: 34; radius: 3
                color: root.cPage
                border.width: 1
                border.color: userInput.activeFocus ? root.cMidInk : root.cRule
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

            // password — 320x52, radius 4, 1px ink border: hyprlock's numbers.
            // Failure is weight, not hue: pure ink, and the line doubles.
            Rectangle {
                id: passBox
                width: 320; height: 52; radius: 4
                color: root.cPage
                border.width: root.failed ? 2 : 1
                border.color: root.failed ? root.cPureInk : root.cInk
                anchors.horizontalCenter: parent.horizontalCenter
                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.leftMargin: 16; anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.cType
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
                color: root.cPureInk
                font.family: root.mono
                font.pixelSize: 13
                font.bold: true
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
            color: root.cPage; radius: 3
            border.width: 1; border.color: root.cRule
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
    // The mid ink at rest, ink when touched — heavier is the lift on a page,
    // the same step the launcher's selected row takes — and pure ink for
    // power off. Straight on the page, not on a tile like graphite's: this
    // corner is blank paper (every pixel under it is #f6f6f6), and under the
    // 5% wash the row reads at 7.4:1 resting, 15.8:1 touched.
    Row {
        id: powerRow
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 22

        Text {
            visible: sddm.canSuspend
            text: "⏾"          // fallback-safe glyph; nerd font shows it fine
            color: powerSuspend.containsMouse ? root.cInk : root.cMidInk
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerSuspend; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.suspend() }
        }
        Text {
            visible: sddm.canReboot
            text: "↻"
            color: powerReboot.containsMouse ? root.cInk : root.cMidInk
            font.family: root.mono; font.pixelSize: 20
            MouseArea { id: powerReboot; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.reboot() }
        }
        Text {
            visible: sddm.canPowerOff
            text: "⏻"
            color: powerOff.containsMouse ? root.cPureInk : root.cMidInk
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
