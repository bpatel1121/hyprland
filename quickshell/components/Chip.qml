// The tooltip below is an inline component that references `root`; Bound makes
// that resolve lexically rather than via the runtime scope chain.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../config"

// The bar's one repeated shape — the QML form of one waybar module box.
//
// Every per-module rule in waybar/style.css was some combination of the same
// nine things: a text color, a faint tinted backplate, a glow, padding, margin,
// radius, weight, a hover state and a tooltip. This component exposes exactly
// those, with the CSS's resting defaults:
//
//     padding: 0 10px; margin: 3px 2px; border-radius: <chip radius>;
//     background-color: rgba(<accent>, <chip opacity>);      the ~7% tint
//     text-shadow: 0 0 8px rgba(<accent>, 0.45);             cyberpunk only
//
// so a module that matches the shared `#custom-updates, #custom-aur, ...` rule
// sets nothing but its text and color. Alpha 0 is how a chip opts out of its
// tint or glow (the clock, the power chip); the hover properties default to the
// resting values, so a chip has a hover state only where the CSS had one.
//
// A chip with nothing to say has zero width and is invisible. That is the
// resting-bar rule the whole design depends on: temperature, network and DND
// render NOTHING until they have something to report, so color on this bar
// always means "act on me" (see docs/bar.md).
Item {
    id: root

    // --- content -------------------------------------------------------------
    property string glyph: ""
    property string label: ""
    // What sits between glyph and label. waybar formats were literal strings
    // ("{icon} {volume}%", "  {:%H:%M} "), so the gap is real spaces in the
    // same font rather than a pixel value — that is what makes the text land
    // where it did.
    property string separator: " "
    readonly property string text: root.glyph
        + (root.glyph !== "" && root.label !== "" ? root.separator : "")
        + root.label

    // Shown in a popup under the chip after a short hover, like a GTK tooltip.
    // Plain text by default; the clock sets StyledText for its calendar.
    property string tooltip: ""
    property int tooltipFormat: Text.PlainText

    // --- type ----------------------------------------------------------------
    property color accent: Theme.readout
    property int fontSize: Theme.fontSize
    property bool bold: false

    // --- backplate -----------------------------------------------------------
    // `background-color: rgba(<tintColor>, <tintOpacity>)`. The tint follows
    // the accent unless a rule says otherwise (the right-island instruments keep
    // their readout tint while their text goes red or gray).
    property color tintColor: root.accent
    property real tintOpacity: Theme.chipOpacity
    // A full gradient fill and an inset rim, for the one chip the CSS lights up
    // emissively: the active workspace (`linear-gradient` + `box-shadow: inset
    // 0 0 0 1px`). A Rectangle border is drawn inside its bounds, which is
    // exactly what an inset box-shadow with no blur was.
    property Gradient plateGradient: null
    property color rimColor: Qt.rgba(0, 0, 0, 0)
    property real rimWidth: 0

    // --- glow ----------------------------------------------------------------
    // `text-shadow: 0 0 <glowRadius>px rgba(<accent>, <glowOpacity>)`. GlowText
    // already renders nothing for this when the theme declares no glow.
    property real glowOpacity: 0.45
    property real glowRadius: Theme.glowRadius
    // `animation: pulse-red 1s ease-in-out infinite alternate` — the alert
    // pulse, and the one glow both themes draw.
    property bool pulse: false

    // --- box -----------------------------------------------------------------
    property real leftPadding: 10
    property real rightPadding: 10
    property real marginLeft: 2
    property real marginRight: 2
    property real marginVertical: 3
    // `border-top/bottom-<side>-radius: 0` — the side a chip is fused to its
    // neighbour on (the media chip and its soundwave make one pill).
    property bool squareLeft: false
    property bool squareRight: false

    // --- hover ---------------------------------------------------------------
    // Each defaults to its resting counterpart, so "no :hover rule" needs no
    // declaration at all.
    property color hoverAccent: root.accent
    property color hoverTintColor: root.tintColor
    property real hoverTintOpacity: root.tintOpacity
    property real hoverGlowOpacity: root.glowOpacity

    // --- interaction ---------------------------------------------------------
    readonly property alias hovered: mouse.containsMouse
    readonly property bool tooltipShown: tip.active
    signal activated
    signal secondaryActivated
    signal scrolled(int delta)

    // --- resolved state ------------------------------------------------------
    readonly property bool hasContent: root.text !== ""
    readonly property color currentAccent: root.hovered ? root.hoverAccent : root.accent
    readonly property color currentTint: Theme.withAlpha(
        root.hovered ? root.hoverTintColor : root.tintColor,
        root.hovered ? root.hoverTintOpacity : root.tintOpacity)
    readonly property real currentGlow: root.hovered ? root.hoverGlowOpacity : root.glowOpacity

    // 0 → 1 → 0 over two seconds while pulsing: the `from`/`to` keyframes with
    // `alternate`. Only the opacity leg of the keyframe is animated — GlowText
    // sizes its blur from glowRadius, and MultiEffect rebuilds its shader every
    // time that changes, so the radius is held at the keyframe's 10px peak and
    // the 0.4 → 0.9 swing carries the pulse.
    property real pulsePhase: 0
    SequentialAnimation on pulsePhase {
        running: root.pulse
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: 1; duration: 1000; easing.type: Easing.InOutQuad }
        NumberAnimation { from: 1; to: 0; duration: 1000; easing.type: Easing.InOutQuad }
    }

    visible: root.hasContent
    implicitWidth: root.hasContent
        ? body.implicitWidth + root.leftPadding + root.rightPadding + root.marginLeft + root.marginRight
        : 0
    implicitHeight: parent ? parent.height : 24
    width: implicitWidth
    height: implicitHeight

    // The margin is outside this box, exactly as CSS margin is outside the
    // border box: the backplate, the hover region and the padding all live in
    // `plate`, and the margin is the gap around it.
    Rectangle {
        id: plate
        anchors.fill: parent
        anchors.leftMargin: root.marginLeft
        anchors.rightMargin: root.marginRight
        anchors.topMargin: root.marginVertical
        anchors.bottomMargin: root.marginVertical

        radius: Theme.chipRadius
        topLeftRadius: root.squareLeft ? 0 : Theme.chipRadius
        bottomLeftRadius: root.squareLeft ? 0 : Theme.chipRadius
        topRightRadius: root.squareRight ? 0 : Theme.chipRadius
        bottomRightRadius: root.squareRight ? 0 : Theme.chipRadius

        // NEVER the `transparent` keyword — the themes' CSS bans it for the same
        // reason (it composites as a black halo on some layer-shell surfaces).
        // An alpha of 0 through withAlpha() is an explicit zero-alpha color.
        color: root.currentTint
        gradient: root.plateGradient
        border.width: root.rimWidth
        border.color: root.rimColor
    }

    // Glyph and label are ONE text run so the separator is measured by the font,
    // not approximated. GTK centred its label in the box the same way; exact
    // GTK/Pango line metrics are not reproducible here, so vertical placement is
    // the closest QML offers — centred on the box.
    GlowText {
        id: body
        x: root.marginLeft + root.leftPadding
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        color: root.currentAccent
        font.family: Theme.fontFamily
        font.pixelSize: root.fontSize
        font.bold: root.bold

        glowOpacity: root.pulse ? 0.4 + 0.5 * root.pulsePhase : root.currentGlow
        glowRadius: root.pulse ? 10 : root.glowRadius
        // The pulse is red whatever the text color (urgent workspaces pulse red
        // around ground-colored digits); every other glow is the text's own hue.
        glowColor: root.pulse ? Theme.urgent : root.currentAccent
        forceGlow: root.pulse
    }

    MouseArea {
        id: mouse
        anchors.fill: plate
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: function (event) {
            tip.active = false;
            if (event.button === Qt.RightButton)
                root.secondaryActivated();
            else
                root.activated();
        }

        onWheel: function (event) {
            root.scrolled(event.angleDelta.y > 0 ? 1 : -1);
        }

        onExited: tip.active = false
    }

    // --- tooltip -------------------------------------------------------------
    // GTK shows a tooltip after a short hover; 600ms is close to its default.
    Timer {
        interval: 600
        running: mouse.containsMouse && root.tooltip !== ""
        onTriggered: tip.active = true
    }

    // One popup per chip would be a window each; LazyLoader (Quickshell's
    // loader for windows and other non-Item objects) creates the window only
    // for the chip actually being hovered and tears it down after.
    LazyLoader {
        id: tip
        active: false

        PopupWindow {
            id: popup

            // The gap between the bar's edge and the tooltip box.
            readonly property int gap: 4

            // Static analysis cannot see PopupWindow's `anchor` group or the
            // Edges enum (both C++-side, Quickshell); suppressed narrowly, as
            // Bar.qml does for `margins`.
            // qmllint disable unqualified unresolved-type
            anchor.item: root
            // Below the chip for a top bar, above it for a bottom bar; centred
            // on it either way (a lone Bottom/Top edge anchors at that edge's
            // midpoint).
            anchor.edges: Config.atTop ? Edges.Bottom : Edges.Top
            anchor.gravity: Config.atTop ? Edges.Bottom : Edges.Top
            // qmllint enable unqualified unresolved-type
            visible: root.tooltip !== ""
            color: "#00000000"

            // `tooltip { }` box: 1px border, 6px 10px padding around the label.
            implicitWidth: tipText.implicitWidth + 2 * 10 + 2
            implicitHeight: tipText.implicitHeight + 2 * 6 + 2 + popup.gap

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: Config.atTop ? popup.gap : 0
                anchors.bottomMargin: Config.atTop ? 0 : popup.gap
                // tooltip { background-color: rgba(<ground>, 0.95);
                //           border: 1px solid rgba(<frame>, 0.30); }
                // Radius was 10 in cyberpunk and 4 in gruvbox — the chip radius
                // plus one and the chip radius exactly; the palette has no
                // tooltip block, and that 1px is not worth adding one for.
                color: Theme.withAlpha(Theme.ground, 0.95)
                border.width: 1
                border.color: Theme.withAlpha(Theme.frame, 0.30)
                radius: Theme.chipRadius

                Text {
                    id: tipText
                    anchors.centerIn: parent
                    text: root.tooltip
                    textFormat: root.tooltipFormat
                    // tooltip label { color: @fg } at the bar's 13px.
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }
        }
    }
}
