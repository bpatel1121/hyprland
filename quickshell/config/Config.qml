pragma Singleton

import Quickshell
import Quickshell.Io

// Behavior for this shell, read from quickshell/settings.json.
//
// The counterpart to Palette: settings.json is BEHAVIOR (which modules, where,
// how often), palette.json is IDENTITY (what it looks like). That is the same
// split the rest of the repo already uses — waybar/config.jsonc at the root is
// shared, waybar/style.css is per-theme. See docs/architecture.md.
//
// Values here are transcribed from waybar/config.jsonc so the QML bar starts
// out behaving identically to the bar it will eventually replace. Nothing here
// feeds waybar; waybar still reads its own config.
Singleton {
    id: root

    property var data: ({})

    // Same defensive accessors as Palette, for the same reason: bindings are
    // evaluated before FileView has read settings.json.
    readonly property var bar: root.obj(root.data, "bar")
    readonly property var modules: root.obj(root.data, "modules")

    // --- bar geometry --------------------------------------------------------
    readonly property string position: root.or_(root.bar, "position", "top")
    readonly property bool atTop: root.position !== "bottom"
    readonly property int height: root.or_(root.bar, "height", 36)
    readonly property int spacing: root.or_(root.bar, "spacing", 0)

    readonly property var marginData: root.obj(root.bar, "margins")
    readonly property int marginTop: root.or_(root.marginData, "top", 8)
    readonly property int marginBottom: root.or_(root.marginData, "bottom", 8)
    readonly property int marginLeft: root.or_(root.marginData, "left", 14)
    readonly property int marginRight: root.or_(root.marginData, "right", 14)

    // --- islands ------------------------------------------------------------
    readonly property var islands: root.obj(root.bar, "islands")
    readonly property var leftModules: root.island("left")
    readonly property var centerModules: root.island("center")
    readonly property var rightModules: root.island("right")

    // --- helpers ------------------------------------------------------------

    // The module list for one island, already filtered by each module's
    // `enabled` flag — so switching a module off in settings.json removes it
    // without also having to delete it from the island list.
    function island(side) {
        const names = root.islands[side];
        if (names === undefined || names === null)
            return [];
        return names.filter(n => root.enabled(n));
    }

    // A nested object, or {} when any link is missing. Never throws.
    function obj(parent, key) {
        if (parent === undefined || parent === null)
            return {};
        const v = parent[key];
        return (v !== undefined && v !== null && typeof v === "object") ? v : {};
    }

    // One value, or `fallback`. Never throws.
    function or_(parent, key, fallback) {
        if (parent === undefined || parent === null)
            return fallback;
        const v = parent[key];
        return v === undefined || v === null ? fallback : v;
    }

    // One module's settings object, or {} when it has none.
    function module(name) {
        return root.obj(root.modules, name);
    }

    // Opt-OUT rather than opt-in: a module with no `enabled` key is on. That
    // keeps settings.json terse and matches how the theme files in this repo
    // degrade — absent means default, not disabled.
    function enabled(name) {
        return root.module(name).enabled !== false;
    }

    // One setting, with a fallback. `Config.get("aur", "intervalSec", 300)`.
    function get(moduleName, key, fallback) {
        return root.or_(root.module(moduleName), key, fallback);
    }

    FileView {
        path: Paths.shell + "/settings.json"
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: {
            try {
                root.data = JSON.parse(this.text());
            } catch (e) {
                console.warn("Config: quickshell/settings.json is not valid JSON:", e);
            }
        }
        onLoadFailed: function (error) {
            console.warn("Config: could not read quickshell/settings.json:", error,
                         "— falling back to built-in defaults.");
        }
    }
}
