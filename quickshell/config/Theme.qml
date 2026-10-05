pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The active theme's colors, read from themes/current/palette.json.
//
// NAMED `Theme`, NOT `Palette`, on purpose: QtQuick exports its own `Palette`
// type (QQuickPalette) from 6.0 onward, and any file that imports QtQuick
// resolves the bare name to THAT instead of to this singleton. The symptom is
// not an import error — it is every color silently reading as undefined, with
// "Property 'withAlpha' of object QtQuick/Palette is not a function" as the only
// clue. Do not rename this back.
//
// That file is the CANONICAL color source for every shell surface. It is
// hand-written per theme and validated in CI; nothing generates it. The twelve
// role names were the @define-color block at the top of the old waybar
// stylesheets (git history), so this is the vocabulary the CSS always used.
//
// Every role has a fallback below. hyprland.lua guards its own theme load with
// pcall for the same reason: a missing or malformed theme must degrade to
// something readable, never to an unusable surface.
Singleton {
    id: root

    // Parsed palette.json, or {} before the first successful load.
    //
    // Every derived property below goes through a helper that tolerates this
    // being empty. Bindings are evaluated once at construction, BEFORE FileView
    // has read anything, and a helper that indexes into an undefined sub-object
    // throws there — which QML reports as "Unable to assign [undefined]" and
    // leaves the island with no color at all.
    property var data: ({})

    readonly property string themeName: root.num_or(root.data, "name", "unknown")
    readonly property bool isDark: root.num_or(root.data, "polarity", "dark") !== "light"

    // --- roles ---------------------------------------------------------------
    // Fallbacks are the Nord-ish set hyprland.lua falls back to, so a broken
    // palette looks deliberate rather than broken.
    readonly property var roles: root.obj(root.data, "roles")

    property color ground:   root.role("ground",   "#2e3440")
    property color surface:  root.role("surface",  "#3b4252")
    property color hairline: root.role("hairline", "#434c5e")
    property color dim:      root.role("dim",      "#4c566a")
    property color frame:    root.role("frame",    "#88c0d0")
    property color readout:  root.role("readout",  "#88c0d0")
    property color warn:     root.role("warn",     "#ebcb8b")
    property color ok:       root.role("ok",       "#a3be8c")
    property color urgent:   root.role("urgent",   "#bf616a")
    property color dormant:  root.role("dormant",  "#616e88")
    property color text:     root.role("text",     "#eceff4")
    property color launcher: root.role("launcher", "#b48ead")

    // Optional roles fall back to their required neighbour rather than to a
    // literal, so a theme that omits them stays internally consistent.
    property color readoutBright: root.role("readoutBright", root.readout)
    property color surfaceAlt:    root.role("surfaceAlt",    root.surface)

    // --- font ----------------------------------------------------------------
    readonly property var fontData: root.obj(root.data, "font")
    readonly property string fontFamily: root.num_or(root.fontData, "mono", "monospace")
    readonly property int fontSize: root.num_or(root.fontData, "size", 13)
    readonly property int fontSizeAccent: root.num_or(root.fontData, "sizeAccent", 16)

    // --- bar identity --------------------------------------------------------
    // Geometry that differs BY THEME (cyberpunk's rounded glass vs. gruvbox's
    // sharp CRT). Geometry that is the same for every theme lives in
    // quickshell/settings.json instead.
    readonly property var barData: root.obj(root.data, "bar")
    readonly property var islandData: root.obj(root.barData, "island")
    readonly property var chipData: root.obj(root.barData, "chip")

    property color islandColor: root.num_or(root.islandData, "color", root.ground)
    property real islandOpacity: root.num_or(root.islandData, "opacity", 0.75)
    property real islandRadius: root.num_or(root.islandData, "radius", 12)
    property real islandBorderWidth: root.num_or(root.islandData, "borderWidth", 1)
    property real islandBorderOpacity: root.num_or(root.islandData, "borderOpacity", 0.2)

    // The 2px `frame` hairline along the inside top edge of each island — the
    // old `box-shadow: inset 0 2px 0`. 0 draws none (gruvbox).
    readonly property real islandAccentLine: root.num_or(root.islandData, "accentLine", 0)
    // Outer bloom in `frame`: alpha and blur radius. 0 alpha draws nothing.
    property real islandGlow: root.num_or(root.islandData, "glow", 0)
    property real islandGlowRange: root.num_or(root.islandData, "glowRange", 18)

    property real chipRadius: root.num_or(root.chipData, "radius", 8)
    property real chipOpacity: root.num_or(root.chipData, "opacity", 0.08)

    // The island fill, alpha already applied.
    readonly property color islandFill: root.withAlpha(root.islandColor, root.islandOpacity)
    // The island hairline: `frame` at the theme's declared edge alpha.
    readonly property color islandBorder: root.withAlpha(root.frame, root.islandBorderOpacity)

    // --- effects -------------------------------------------------------------
    // The structural tricks a theme uses. Glow is cyberpunk's signature (the
    // old `text-shadow: 0 0 Npx`); the panel texture is every other theme's —
    // gruvbox's scanlines, graphite's hatching, inkwash's grain, glacier's
    // sheen, harbor's horizon. Every surface asks these rather than guessing
    // from the colors — see components/GlowText.qml and components/Texture.qml.
    readonly property var effectsData: root.obj(root.data, "effects")
    readonly property bool glow: root.num_or(root.effectsData, "glow", false) === true
    readonly property real glowRadius: root.num_or(root.effectsData, "glowRadius", 8)
    readonly property string texture: root.num_or(root.effectsData, "texture", "none")
    // -1: use the kind's resting strength (Texture.qml knows it).
    readonly property real textureAlpha: root.num_or(root.effectsData, "textureAlpha", -1)

    // --- launcher identity ---------------------------------------------------
    // What used to be wofi/style.css. Colors are roles; only geometry varies.
    readonly property var launcherData: root.obj(root.data, "launcher")
    readonly property real launcherOpacity: root.num_or(root.launcherData, "opacity", 0.8)
    readonly property real launcherRadius: root.num_or(root.launcherData, "radius", 12)
    readonly property real launcherBorderWidth: root.num_or(root.launcherData, "borderWidth", 2)
    readonly property real launcherInputRadius: root.num_or(root.launcherData, "inputRadius", 8)
    readonly property real launcherEntryRadius: root.num_or(root.launcherData, "entryRadius", 8)
    readonly property int launcherFontSize: root.num_or(root.launcherData, "fontSize", 15)

    // --- osd identity --------------------------------------------------------
    // What used to be swayosd/style.css.
    readonly property var osdData: root.obj(root.data, "osd")
    readonly property real osdOpacity: root.num_or(root.osdData, "opacity", 0.85)
    readonly property real osdRadius: root.num_or(root.osdData, "radius", 999)
    readonly property real osdBorderWidth: root.num_or(root.osdData, "borderWidth", 2)
    readonly property real osdTrackRadius: root.num_or(root.osdData, "trackRadius", 4)

    // --- session-menu identity -----------------------------------------------
    // What used to be wlogout/style.css.
    readonly property var sessionData: root.obj(root.data, "session")
    readonly property real sessionWindowOpacity: root.num_or(root.sessionData, "windowOpacity", 0.85)
    readonly property real sessionTileOpacity: root.num_or(root.sessionData, "tileOpacity", 0.92)
    readonly property real sessionRadius: root.num_or(root.sessionData, "radius", 16)
    readonly property real sessionBorderWidth: root.num_or(root.sessionData, "borderWidth", 1)
    readonly property real sessionBorderOpacity: root.num_or(root.sessionData, "borderOpacity", 0.35)
    readonly property int sessionFontSize: root.num_or(root.sessionData, "fontSize", 18)

    // Re-read palette.json on demand. theme-switch.sh calls this over IPC
    // after repointing themes/current: the file watcher follows the resolved
    // inode, so a symlink that now points somewhere else is not a change it
    // can see — the file it was watching is byte-for-byte what it was.
    function reload() {
        paletteFile.reload();
    }

    // --- the crossfade -------------------------------------------------------
    // SUPER+T repoints themes/current and theme-apply.sh pokes reload() first,
    // before the wallpaper starts its sweep. Without these every surface
    // snapped to the new palette in one frame while the picture behind it took
    // two seconds to arrive. With them the bar, launcher, OSD and tiles fade
    // between palettes and the islands morph between the two themes' corners
    // and weights, in step with the wallpaper. The roles and the island
    // identity above are plain (not readonly) properties for exactly this:
    // a Behavior cannot ride a readonly property, and it leaves the binding
    // intact, so the next reload still re-reads palette.json. 600ms, a literal
    // in each line: qmllint cannot see this file's id through Quickshell's
    // Singleton type, and the wallpaper sweep this keeps step with is 1.8s.

    Behavior on ground   { ColorAnimation { duration: 600 } }
    Behavior on surface  { ColorAnimation { duration: 600 } }
    Behavior on hairline { ColorAnimation { duration: 600 } }
    Behavior on dim      { ColorAnimation { duration: 600 } }
    Behavior on frame    { ColorAnimation { duration: 600 } }
    Behavior on readout  { ColorAnimation { duration: 600 } }
    Behavior on warn     { ColorAnimation { duration: 600 } }
    Behavior on ok       { ColorAnimation { duration: 600 } }
    Behavior on urgent   { ColorAnimation { duration: 600 } }
    Behavior on dormant  { ColorAnimation { duration: 600 } }
    Behavior on text     { ColorAnimation { duration: 600 } }
    Behavior on launcher { ColorAnimation { duration: 600 } }
    Behavior on readoutBright { ColorAnimation { duration: 600 } }
    Behavior on surfaceAlt    { ColorAnimation { duration: 600 } }

    Behavior on islandColor         { ColorAnimation  { duration: 600 } }
    Behavior on islandOpacity       { NumberAnimation { duration: 600 } }
    Behavior on islandRadius        { NumberAnimation { duration: 600 } }
    Behavior on islandBorderWidth   { NumberAnimation { duration: 600 } }
    Behavior on islandBorderOpacity { NumberAnimation { duration: 600 } }
    Behavior on islandGlow          { NumberAnimation { duration: 600 } }
    Behavior on islandGlowRange     { NumberAnimation { duration: 600 } }
    Behavior on chipRadius          { NumberAnimation { duration: 600 } }
    Behavior on chipOpacity         { NumberAnimation { duration: 600 } }

    // --- helpers -------------------------------------------------------------

    // A nested object, or {} when any link in the chain is missing. Never throws.
    function obj(parent, key) {
        if (parent === undefined || parent === null)
            return {};
        const v = parent[key];
        return (v !== undefined && v !== null && typeof v === "object") ? v : {};
    }

    // One value out of an object, or `fallback`. Never throws.
    function num_or(parent, key, fallback) {
        if (parent === undefined || parent === null)
            return fallback;
        const v = parent[key];
        return v === undefined || v === null ? fallback : v;
    }

    // One role, or `fallback` when the palette omits it.
    function role(name, fallback) {
        const v = root.num_or(root.roles, name, "");
        return (typeof v === "string" && v.length > 0) ? v : fallback;
    }

    // Qt.alpha() is not available across every Qt 6 minor, so rebuild the color
    // explicitly. Colors in palette.json are deliberately opaque — alpha is the
    // consumer's decision, not the palette's.
    //
    // There is no Qt.color(): every caller passes one of the `color` properties
    // above, which already exposes r/g/b as reals in 0..1.
    function withAlpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // Map a waybar-style state class onto a role. The backing scripts in
    // scripts/waybar-*.sh already emit these names in their `class` field, so
    // this is the whole translation layer between them and this shell.
    function classColor(cls) {
        switch (cls) {
        // Classes below are the exact set the scripts emit today:
        //   waybar-agenda.sh   idle | upcoming
        //   waybar-todos.sh    zero | pending | overdue
        //   waybar-updates.sh  zero | pending
        //   waybar-cava.sh     quiet | live
        case "pending":  return root.warn;
        case "overdue":
        case "critical":
        case "urgent":   return root.urgent;
        case "ok":
        case "charging": return root.ok;
        case "zero":
        case "idle":
        case "empty":    return root.dormant;
        case "quiet":    return root.dim;
        case "upcoming":
        case "live":     return root.readout;
        default:         return root.readout;
        }
    }

    FileView {
        id: paletteFile
        path: Paths.currentTheme + "/palette.json"
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: {
            try {
                root.data = JSON.parse(this.text());
            } catch (e) {
                console.warn("Palette: themes/current/palette.json is not valid JSON:", e);
            }
        }
        onLoadFailed: function (error) {
            console.warn("Palette: could not read themes/current/palette.json:", error,
                         "— falling back to built-in defaults.");
        }
    }
}
