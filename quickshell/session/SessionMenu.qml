// The window delegate below references `menu`, and the tile delegates
// reference `menu`, `root`, `grid` and their own `modelData`/`index`. Bound
// makes those resolve lexically instead of via the runtime scope chain.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../config"
import "../components"

// The power menu — what used to be `wlogout -p layer-shell` (SUPER+ESCAPE and
// the bar's power chip).
//
// wlogout's geometry, reproduced from its source rather than guessed:
//
//   window    one full-screen OVERLAY layer surface PER MONITOR — wlogout dims
//             every output and puts the button grid on just one of them. It
//             used its "primary" monitor; this uses whichever monitor Hyprland
//             had focused when the menu opened.
//   grid      `--buttons-per-row 3` (default), `--margin 230` on all four
//             sides (default), `--column-spacing 0 --row-spacing 0` (default),
//             every button hexpand+vexpand — so the inset area is split into
//             equal cells.
//   tile      sits 12px inside its cell: `button { margin: 12px }`.
//   focus     GTK hands a freshly mapped window's focus to its first focusable
//             child, so wlogout always came up with "lock" already lit, and
//             hovering another tile lit a second one without moving focus.
//             Reproduced, because that is how it looked.
//   activate  wlogout destroyed its window BEFORE `system(action)`; same here,
//             so hyprlock never comes up underneath this surface.
//
// Everything else — fill, frame, radius, font, glow — comes from
// wlogout/style.css by way of palette.json `session` (see Theme.qml). The
// buttons themselves are BEHAVIOR and come from settings.json `surfaces.session`.
//
// Owned by shell.qml as `SessionMenu {}`. Driven over IPC:
//   qs ipc -p ~/.config/hypr/quickshell call session toggle   (open / close)
Scope {
    id: menu

    property bool open: false

    // Which screen carries the tiles. Latched when the menu opens — Hyprland's
    // focused monitor follows the pointer, so binding to it live would make
    // the grid hop outputs as the mouse crossed between them.
    property string screenName: ""

    // Index of the tile holding keyboard focus; 0 ("lock") on every open, as
    // GTK did. Arrows move it, Enter activates it.
    property int focusIndex: 0

    // The old wlogout/layout, transcribed into settings.json in the same order.
    readonly property var buttons: {
        const b = Config.surface("session", "buttons", []);
        return Array.isArray(b) ? b : [];
    }

    // wlogout --buttons-per-row default. Rows follow from the button count.
    readonly property int columns: 3
    readonly property int rows: Math.max(1, Math.ceil(menu.buttons.length / menu.columns))

    function show() {
        // Hyprland's focused monitor, resolved to a Quickshell screen by name
        // (HyprlandMonitor carries no ShellScreen of its own). Falls back to
        // the first screen when the name matches nothing, which is also what
        // wlogout did when asked for a monitor it did not have.
        const focused = Hyprland.focusedMonitor?.name ?? "";
        const screens = Quickshell.screens;
        let name = screens.length > 0 ? screens[0].name : "";
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === focused) {
                name = focused;
                break;
            }
        }
        menu.screenName = name;
        menu.focusIndex = 0;
        menu.open = true;
    }

    function hide() {
        menu.open = false;
    }

    // Run one tile's action. Closes FIRST — see the header: a lock screen
    // launched while this surface is still mapped ends up underneath it.
    function activate(index) {
        const b = menu.buttons[index];
        if (!b || !b.action)
            return;
        menu.hide();
        Quickshell.execDetached(["sh", "-c", String(b.action)]);
    }

    // Arrow keys walk the grid the way GTK's directional keynav did: clamped
    // at the edges, never wrapping, and never onto a cell that has no button.
    function moveFocus(dx, dy) {
        const n = menu.buttons.length;
        const col = menu.focusIndex % menu.columns + dx;
        const row = Math.floor(menu.focusIndex / menu.columns) + dy;
        const next = row * menu.columns + col;
        if (col < 0 || col >= menu.columns || row < 0 || next < 0 || next >= n)
            return;
        menu.focusIndex = next;
    }

    // Tab / Shift+Tab: GTK's tab chain, which DOES wrap.
    function cycleFocus(step) {
        const n = menu.buttons.length;
        if (n > 0)
            menu.focusIndex = (menu.focusIndex + step + n) % n;
    }

    IpcHandler {
        target: "session"

        function toggle(): void {
            if (menu.open)
                menu.hide();
            else
                menu.show();
        }

        function open(): void {
            menu.show();
        }

        function close(): void {
            menu.hide();
        }
    }

    // One surface per monitor, like wlogout. Variants tracks hotplug, so a
    // display connected later is dimmed too without a restart.
    //
    // Variants fills `modelData` on each instance at runtime; the linter
    // cannot see that through the unresolved type and reports the required
    // property as unset. Suppressed for this block only, like Bar.qml's
    // `margins`.
    // qmllint disable required
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: root.modelData

            // The one output that gets the tiles and the keyboard. The others
            // are just the dimming sheet.
            readonly property bool primary: root.modelData.name === menu.screenName

            // wlogout's `--margin 230`, flat, on every side. The clamp only
            // bites on screens under 1150 logical px on their short side,
            // where a flat 230 would squash the tiles to a sliver; on this
            // box's 1920x1200 (2880x1800 @ 1.5) it is exactly 230.
            readonly property int inset: Math.min(230,
                Math.round(Math.min(content.width, content.height) * 0.2))

            visible: menu.open

            WlrLayershell.namespace: "qs-hypr-session"
            // Over fullscreen windows, as wlogout was (GTK_LAYER_SHELL_LAYER_OVERLAY).
            WlrLayershell.layer: WlrLayer.Overlay
            // wlogout: keyboard_interactivity TRUE on the primary window only.
            WlrLayershell.keyboardFocus: (menu.open && root.primary)
                ? WlrKeyboardFocus.Exclusive
                : WlrKeyboardFocus.None

            // A menu reserves no space, and never shifts a window behind it.
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0

            // The surface itself is fully transparent and the dimming sheet is
            // a child Rectangle, so the layer rule's blur + ignore_alpha treat
            // it the way they treated wlogout's. Never the `transparent`
            // keyword — see Bar.qml.
            color: "#00000000"

            // Opposing anchors on both axes stretch to the full screen.
            //
            // Same narrow suppression as Bar.qml's `margins`: the grouped
            // scope is declared on the C++ side, so static analysis reports
            // it as unqualified even though it binds at runtime.
            // qmllint disable unqualified unresolved-type
            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }
            // qmllint enable unqualified unresolved-type

            // Keyboard lands on `content`, which owns every key wlogout
            // handled. forceActiveFocus on map is belt-and-braces: Escape is
            // the one way out that does not need the mouse.
            onVisibleChanged: {
                if (root.visible && root.primary)
                    content.forceActiveFocus();
            }

            Item {
                id: content
                anchors.fill: parent
                focus: true

                Keys.onPressed: function (event) {
                    event.accepted = true;
                    switch (event.key) {
                    case Qt.Key_Escape:
                        menu.hide();
                        return;
                    case Qt.Key_Left:
                        menu.moveFocus(-1, 0);
                        return;
                    case Qt.Key_Right:
                        menu.moveFocus(1, 0);
                        return;
                    case Qt.Key_Up:
                        menu.moveFocus(0, -1);
                        return;
                    case Qt.Key_Down:
                        menu.moveFocus(0, 1);
                        return;
                    case Qt.Key_Tab:
                        menu.cycleFocus(1);
                        return;
                    case Qt.Key_Backtab:
                        menu.cycleFocus(-1);
                        return;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                    case Qt.Key_Space:
                        menu.activate(menu.focusIndex);
                        return;
                    }
                    // wlogout matched the keyval against each button's
                    // `keybind` — the l/e/u/h/r/s letters in settings.json.
                    const typed = event.text.toLowerCase();
                    if (typed === "") {
                        event.accepted = false;
                        return;
                    }
                    for (let i = 0; i < menu.buttons.length; i++) {
                        if (String(menu.buttons[i].key ?? "").toLowerCase() === typed) {
                            menu.activate(i);
                            return;
                        }
                    }
                    event.accepted = false;
                }

                // window { background-color: rgba(ground, 0.85) } — the sheet
                // that dims the desktop. Clicking it, outside any tile, closes.
                Rectangle {
                    anchors.fill: parent
                    color: Theme.withAlpha(Theme.ground, Theme.sessionWindowOpacity)

                    MouseArea {
                        anchors.fill: parent
                        onClicked: menu.hide()
                    }
                }

                // The button grid: the inset area split into equal cells.
                // Integer cells, so tile edges land on whole pixels; the one
                // or two leftover px split evenly around the grid.
                Grid {
                    id: grid

                    readonly property int cellWidth:
                        Math.max(0, Math.floor((content.width - 2 * root.inset) / menu.columns))
                    readonly property int cellHeight:
                        Math.max(0, Math.floor((content.height - 2 * root.inset) / menu.rows))

                    anchors.centerIn: parent
                    columns: menu.columns
                    spacing: 0   // --column-spacing 0 --row-spacing 0
                    visible: root.primary

                    Repeater {
                        model: menu.buttons

                        // One cell. The tile is the Rectangle 12px inside it.
                        Item {
                            id: cell

                            required property var modelData
                            required property int index

                            // `destructive: true` in settings.json — the two
                            // that cannot be undone (reboot, shutdown), which
                            // the CSS singled out by #id to go red.
                            readonly property bool destructive: cell.modelData.destructive === true

                            // button:hover, button:focus — same rule for both,
                            // so a hovered tile and the focused tile are both
                            // lit, exactly as GTK drew them.
                            readonly property bool lit: tileMouse.containsMouse
                                || menu.focusIndex === cell.index

                            // "cyan = live" (readout) for most; red (urgent)
                            // for the destructive pair.
                            readonly property color accent: cell.destructive ? Theme.urgent : Theme.readout

                            // Text and border carry the 150ms transition from
                            // `transition: color 0.15s, border-color 0.15s`.
                            // The fill is NOT in that list and snaps, as it did.
                            property color ink: cell.lit ? cell.accent : Theme.text
                            property color edge: cell.lit
                                ? cell.accent
                                : Theme.withAlpha(Theme.frame, Theme.sessionBorderOpacity)

                            Behavior on ink {
                                ColorAnimation { duration: 150 }
                            }
                            Behavior on edge {
                                ColorAnimation { duration: 150 }
                            }

                            width: grid.cellWidth
                            height: grid.cellHeight

                            Rectangle {
                                id: tile
                                anchors.fill: parent
                                anchors.margins: 12   // button { margin: 12px }

                                radius: Theme.sessionRadius
                                // button { background-color: rgba(surface, 0.92) };
                                // :hover/:focus { background-color: surface } opaque.
                                color: cell.lit
                                    ? Theme.surface
                                    : Theme.withAlpha(Theme.surface, Theme.sessionTileOpacity)
                                // button { border: Npx solid rgba(frame, A) };
                                // lit: Npx solid accent.
                                border.width: Theme.sessionBorderWidth
                                border.color: cell.edge

                                // Gruvbox's CRT stripes (palette.json `effects`:
                                // "scanlines ride every panel"); a no-op on
                                // cyberpunk. The old wlogout CSS left these off
                                // (`background-image: none`) — delete this line
                                // to match that stylesheet to the pixel.
                                Scanlines { radius: tile.radius }

                                // The layout's `text`: glyph, two spaces, word —
                                // one GTK label, centered in the button.
                                GlowText {
                                    anchors.centerIn: parent
                                    text: String(cell.modelData.glyph ?? "") + "  "
                                        + String(cell.modelData.label ?? "")
                                    color: cell.ink
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.sessionFontSize
                                    // :hover/:focus text-shadow: 0 0 10px rgba(accent, 0.55),
                                    // 0.6 for the destructive pair; none at rest.
                                    // Not in the transition list either — it snaps.
                                    glowRadius: 10
                                    glowOpacity: cell.lit ? (cell.destructive ? 0.6 : 0.55) : 0
                                }

                                MouseArea {
                                    id: tileMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: menu.activate(cell.index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // qmllint enable required
}
