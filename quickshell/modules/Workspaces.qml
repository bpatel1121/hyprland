// Delegates below reference `root` and their own `modelData`. Bound
// component behavior makes those resolve lexically instead of walking the
// scope chain at runtime, which is both faster and what stops a rename
// elsewhere from silently rebinding them.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import "../config"
import "../components"

// Workspace stations — `#workspaces button`, one Chip per workspace:
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
// Cascade order matters and is reproduced: `:hover` is declared after
// `.active` (so hovering the active station flattens it to the surface fill)
// but before `.special` and `.urgent` (which keep their look under the
// pointer).
//
// 1..`persistent` ALWAYS render (waybar's persistent-workspaces 1-5); an empty
// one draws dormant rather than disappearing, so the bar reads as a row of
// stations instead of one lonely number. Workspaces past that appear only
// while they exist. The scratchpad gets a ghost glyph that exists only while
// it is on screen — it IS the "you are in the scratchpad" indicator (waybar's
// show-special + special-visible-only). Hyprland reports it with a negative
// id, which is how it is told apart from a numbered workspace here.
Row {
    id: root

    readonly property int persistent: Config.get("workspaces", "persistent", 5)
    readonly property bool showSpecial: Config.get("workspaces", "showSpecial", true)
    readonly property string specialGlyph: Config.get("workspaces", "specialGlyph", "󰊠")

    // Which "lit" the active station gets. Cyberpunk's CSS was an emissive
    // lozenge — `linear-gradient(180deg, <readoutBright>, <readout>)` with a
    // 1px inset rim — and gruvbox's a block cursor, solid `frame`. The palette
    // tells them apart by whether it declares the optional `readoutBright`
    // role: a theme with a brighter readout can be lit from it, one without
    // (readoutBright then falls back to readout) uses its frame color solid.
    readonly property bool emissive: !Qt.colorEqual(Theme.readoutBright, Theme.readout)

    height: parent ? parent.height : 0
    // `#workspaces { padding: 0; margin: 0 }` — the buttons' own 1px margins
    // are the only gaps.
    spacing: 0

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

    Repeater {
        model: root.shownIds

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

    // The scratchpad ghost — `#workspaces button.special`, present only while
    // the special workspace is up. Frame-colored: an overlay of the frame, not
    // one of the readout stations. No hover rule applies (`.special` is
    // declared after `:hover`), so the hover defaults stay at rest.
    Chip {
        id: ghost

        readonly property bool visibleNow: {
            if (!root.showSpecial)
                return false;
            const list = Hyprland.workspaces.values;
            for (let i = 0; i < list.length; i++) {
                if (list[i].id < 0 && list[i].active)
                    return true;
            }
            return false;
        }

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
