// Delegates below reference `root` and their own `modelData`. Bound
// component behavior makes those resolve lexically instead of walking the
// scope chain at runtime, which is both faster and what stops a rename
// elsewhere from silently rebinding them.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import "../config"
import "../components"

// Workspace stations, in one of two styles (`modules.workspaces.style`).
//
// "pills" (the default) — one 8px pill per workspace, 6px apart, centred in
// the bar. State is carried by width and tone rather than a digit:
//
//     active     26 × 8   the lit fill (see `emissive` below)
//     occupied    8 × 8   rgba(<dormant>, 0.85)       has windows
//     empty       8 × 8   rgba(<dormant>, 0.35)       nothing there
//     urgent      8 × 8   <urgent>, breathing 1 → 0.5 → 1 (keeps its look under the pointer)
//     :hover     26 × 16  rgba(<readout>, 0.6), its number on it
//
// Focus SLIDES: width and color animate over 140ms, so moving to the next
// workspace reads as the lozenge gliding one slot over rather than one dot
// going dark and another lighting. The number exists only under the pointer:
// the pill opens into a lozenge tall enough to hold it (`ground` on the
// active and urgent pills, `readout` on the rest) and closes again on leave.
//
// "numbers" — the digit stations the bar launched with, `#workspaces button`
// as one Chip per workspace:
//
//     padding: 0 9px; margin: 3px 1px; border-radius: <chip radius>;
//     transition: color 0.2s ease-in-out;
//     .empty    color: rgba(<dormant>, 0.35)      nothing there
//     (default) color: rgba(<dormant>, 0.85)      has windows
//     .active   color: <ground>; bold; lit fill (see `emissive` below)
//     :hover    color: <readout>; background: <surface>; no gradient, no rim
//     .special  color: <frame>; background: rgba(<frame>, ~0.10); glow 0.55
//     .urgent   color: <ground>; background: <urgent>; pulse-red
//
// The color rules are the SAME in both styles — the pills carry them on a
// fill instead of a glyph. Cascade order matters and is reproduced in both:
// `:hover` is declared after `.active` (so hovering the active station
// flattens it) but before `.special` and `.urgent` (which keep their look
// under the pointer).
//
// 1..`persistent` ALWAYS render (waybar's persistent-workspaces 1-5); an empty
// one draws dormant rather than disappearing, so the bar reads as a row of
// stations instead of one lonely number. Workspaces past that appear only
// while they exist. The scratchpad gets a ghost glyph that exists only while
// it is on screen — it IS the "you are in the scratchpad" indicator (waybar's
// show-special + special-visible-only). Hyprland reports it with a negative
// id, which is how it is told apart from a numbered workspace here. It is a
// glyph, not a station, so it looks the same in either style.
Row {
    id: root

    readonly property int persistent: Config.get("workspaces", "persistent", 5)
    readonly property bool showSpecial: Config.get("workspaces", "showSpecial", true)
    readonly property string specialGlyph: Config.get("workspaces", "specialGlyph", "󰊠")
    // Anything but the opt-in "numbers" draws pills, so a stale or misspelt
    // value degrades to the default rather than to no workspaces at all.
    readonly property bool pills: Config.get("workspaces", "style", "pills") !== "numbers"

    // Which "lit" the active station gets. Cyberpunk's CSS was an emissive
    // lozenge — `linear-gradient(180deg, <readoutBright>, <readout>)` with a
    // 1px inset rim — and gruvbox's a block cursor, solid `frame`. The palette
    // tells them apart by whether it declares the optional `readoutBright`
    // role: a theme with a brighter readout can be lit from it, one without
    // (readoutBright then falls back to readout) uses its frame color solid.
    readonly property bool emissive: !Qt.colorEqual(Theme.readoutBright, Theme.readout)

    height: parent ? parent.height : 0
    // Pills: a 6px gap between stations. Numbers: `#workspaces { padding: 0;
    // margin: 0 }` — the buttons' own 1px margins are the only gaps.
    spacing: root.pills ? 6 : 0

    // Per workspace id: does it hold windows, is it urgent. Rebuilt from
    // Hyprland's live model whenever any of those change.
    readonly property var info: {
        const out = {};
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            const ws = list[i];
            if (ws.id > 0) {
                out[ws.id] = {
                    occupied: (ws.toplevels?.values?.length ?? 0) > 0,
                    urgent: ws.urgent === true
                };
            }
        }
        return out;
    }

    readonly property int focusedId: Hyprland.focusedWorkspace?.id ?? -1

    // The union of "always shown" and "currently exists", ascending.
    readonly property var shownIds: {
        const ids = {};
        for (let i = 1; i <= root.persistent; i++)
            ids[i] = true;
        for (const key in root.info)
            ids[key] = true;
        return Object.keys(ids).map(k => parseInt(k)).sort((a, b) => a - b);
    }

    // The active station's lit fill, top to bottom.
    readonly property Gradient lit: Gradient {
        GradientStop { position: 0.0; color: Theme.readoutBright }
        GradientStop { position: 1.0; color: Theme.readout }
    }

    // --- pills ---------------------------------------------------------------
    // One Repeater per style; the one not in use gets an empty model, so the
    // Row only ever holds stations of one kind.
    Repeater {
        model: root.pills ? root.shownIds : []

        // The hit box: the full bar height, reaching 3px into the gap on either
        // side so the row has no dead zones between dots. The pill proper is
        // `body`, centred inside it.
        Item {
            id: pill

            required property int modelData

            readonly property bool isActive: pill.modelData === root.focusedId
            readonly property bool isOccupied: root.info[pill.modelData]?.occupied === true
            readonly property bool isUrgent: root.info[pill.modelData]?.urgent === true
            readonly property bool hovered: hit.containsMouse
            // `.active`'s lit look survives neither `.urgent` nor `:hover`.
            readonly property bool lit: pill.isActive && !pill.isUrgent && !pill.hovered

            // 0 → 1 → 0 over two seconds while urgent — the same clock as
            // Chip's pulse, so a red pill and a red chip elsewhere on the bar
            // beat together. A pill has no text to glow, so the pulse is the
            // pill itself breathing between full and half opacity.
            property real pulsePhase: 0
            SequentialAnimation on pulsePhase {
                running: pill.isUrgent
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: 1; duration: 1000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1; to: 0; duration: 1000; easing.type: Easing.InOutQuad }
            }

            // The lozenge is 26 wide: for the active station, and for any
            // station under the pointer so its number fits.
            width: (pill.isActive || pill.hovered) ? 26 : 8
            height: root.height
            Behavior on width {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }

            Rectangle {
                id: body
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                // 8 at rest; under the pointer it opens to 16, which clears a
                // 13px bold digit's cap height with a little air. Radius tracks
                // the height so it stays a pill at either size.
                height: pill.hovered ? 16 : 8
                radius: body.height / 2
                Behavior on height {
                    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }

                // The same cascade as the digit stations, on the fill. Under
                // the gradient (emissive + lit) this is the gradient's bottom
                // stop, so the ColorAnimation starts from the right place when
                // the gradient drops.
                color: pill.isUrgent ? Theme.urgent
                     : pill.hovered ? Theme.withAlpha(Theme.readout, 0.6)
                     : pill.isActive ? (root.emissive ? Theme.readout : Theme.frame)
                     : Theme.withAlpha(Theme.dormant, pill.isOccupied ? 0.85 : 0.35)
                Behavior on color {
                    ColorAnimation { duration: 140 }
                }

                gradient: pill.lit && root.emissive ? root.lit : null
                // The rim: rgba(214, 248, 252, 0.9) in the CSS — near-white,
                // which the palette has no role for; `text` at the same alpha
                // is the closest honest reading of it.
                border.width: pill.lit && root.emissive ? 1 : 0
                border.color: Theme.withAlpha(Theme.text, 0.9)

                opacity: pill.isUrgent ? 1 - 0.5 * pill.pulsePhase : 1

                // The number, only under the pointer. format-icons: "1".."10"
                // are themselves, anything else is "•". No glow — `:hover`
                // dropped the text-shadow on the digit stations too.
                GlowText {
                    anchors.centerIn: parent
                    text: pill.modelData <= 10 ? String(pill.modelData) : "•"
                    color: (pill.isUrgent || pill.isActive) ? Theme.ground : Theme.readout
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                    glowOpacity: 0

                    opacity: pill.hovered ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: 140 }
                    }
                }
            }

            MouseArea {
                id: hit
                anchors.fill: parent
                anchors.leftMargin: -3
                anchors.rightMargin: -3
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + pill.modelData)
            }
        }
    }

    // --- numbers -------------------------------------------------------------
    Repeater {
        model: root.pills ? [] : root.shownIds

        Chip {
            id: station

            required property int modelData

            readonly property bool isActive: station.modelData === root.focusedId
            readonly property bool isOccupied: root.info[station.modelData]?.occupied === true
            readonly property bool isUrgent: root.info[station.modelData]?.urgent === true
            // `.active`'s lit look survives neither `.urgent` nor `:hover`.
            readonly property bool lit: station.isActive && !station.isUrgent && !station.hovered

            // format-icons: "1".."10" are themselves, anything else is "•".
            label: station.modelData <= 10 ? String(station.modelData) : "•"

            leftPadding: 9
            rightPadding: 9
            marginLeft: 1
            marginRight: 1
            bold: station.isActive

            accent: (station.isUrgent || station.isActive)
                ? Theme.ground
                : Theme.withAlpha(Theme.dormant, station.isOccupied ? 0.85 : 0.35)
            // `transition: color 0.2s ease-in-out`.
            Behavior on accent {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            tintColor: station.isUrgent ? Theme.urgent
                     : root.emissive ? Theme.readout : Theme.frame
            tintOpacity: (station.isUrgent || station.isActive) ? 1 : 0
            plateGradient: station.lit && root.emissive ? root.lit : null
            // The rim: rgba(214, 248, 252, 0.9) in the CSS — near-white, which
            // the palette has no role for; `text` at the same alpha is the
            // closest honest reading of it.
            rimWidth: station.lit && root.emissive ? 1 : 0
            rimColor: Theme.withAlpha(Theme.text, 0.9)

            // `.active { text-shadow: 0 0 4px rgba(<ground>, 0.45) }` — a dark
            // shadow on the lit lozenge; the text is ground-colored, so
            // GlowText's default (glow in the text's own color) is exactly it.
            glowOpacity: station.isActive && !station.isUrgent ? 0.45 : 0
            glowRadius: 4
            pulse: station.isUrgent

            hoverAccent: station.isUrgent ? station.accent : Theme.readout
            hoverTintColor: station.isUrgent ? station.tintColor : Theme.surface
            hoverTintOpacity: station.isUrgent ? station.tintOpacity : 1
            hoverGlowOpacity: 0

            onActivated: Hyprland.dispatch("workspace " + station.modelData)
        }
    }

    // Whether a special workspace is on screen. Quickshell never flags one as
    // `active` — a monitor's active workspace stays the ordinary one underneath
    // the scratchpad — so this listens to Hyprland's own `activespecial` event
    // instead: `activespecial>>special:magic,eDP-1` when it opens, an empty
    // name when it closes. One event per toggle, nothing polled.
    property bool specialShown: false

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name !== "activespecial")
                return;
            root.specialShown = event.parse(2)[0] !== "";
        }
    }

    // The scratchpad ghost — `#workspaces button.special`, present only while
    // the special workspace is up. Frame-colored: an overlay of the frame, not
    // one of the readout stations. No hover rule applies (`.special` is
    // declared after `:hover`), so the hover defaults stay at rest.
    Chip {
        id: ghost

        readonly property bool visibleNow: root.showSpecial && root.specialShown

        label: ghost.visibleNow ? root.specialGlyph : ""

        leftPadding: 9
        rightPadding: 9
        marginLeft: 1
        marginRight: 1

        accent: Theme.frame
        // rgba(<frame>, 0.10) cyberpunk / 0.14 gruvbox: a touch more than the
        // chip tint. chipOpacity + 0.04 lands at 0.11 / 0.12 — close, and it
        // keeps the ghost a step above the ordinary chips in both themes.
        tintColor: Theme.frame
        tintOpacity: Theme.chipOpacity + 0.04
        // text-shadow: 0 0 8px rgba(<frame>, 0.55) — cyberpunk only, by way of
        // GlowText honoring Theme.glow.
        glowOpacity: 0.55

        onActivated: Hyprland.dispatch("togglespecialworkspace magic")
    }
}
