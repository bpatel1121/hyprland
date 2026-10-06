// The grid delegate below references `root`, `grid` and its own `modelData`.
// Bound component behavior makes those resolve lexically instead of walking
// the scope chain at runtime — see modules/Workspaces.qml.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import "../config"
import "../components"

// The application launcher — what used to be
//
//     wofi --show drun --allow-images --columns 2 --width 640 --height 480
//
// styled by themes/<name>/wofi/style.css. The input geometry and the window's
// radius, frame and opacity are still that stylesheet's (through Theme); the
// rows are not. wofi's grid dumped every desktop entry into two columns the
// moment it opened — a wall of violet on black with a hole wherever an entry
// had no icon. This one opens short:
//
//   empty   ONE column of the apps you actually launch, ranked by frecency
//           (launch count, decayed by how long ago the last launch was),
//           at most `recentCount` of them. Nothing launched yet? The first
//           `recentCount` apps alphabetically, so the first open is a short
//           card too. The window is only as tall as those rows.
//   typed   the ranked full list in the configured `columns` grid at the
//           configured `height` — wofi's layout, softer surfaces.
//
// Launches are counted into launcher-history.json in Quickshell's per-shell
// state dir; nothing else reads it and deleting it just resets the ranking.
//
// Opened by IPC (`qs ipc call launcher toggle|open|close`) — the bar chip and
// the SUPER+R bind both go through that, so the launcher behaves identically
// however it was summoned. While closed the window does not exist and holds
// no keyboard focus. (The theme picker, once a second mode of this window, is
// themes/ThemePicker.qml now.)
Scope {
    id: root

    // --- state ---------------------------------------------------------------
    property bool shown: false

    // The screen the launcher was opened on. Frozen at open rather than bound
    // to Hyprland.focusedMonitor: with exclusive keyboard focus the pointer is
    // the only thing that can change the focused monitor, and a launcher that
    // jumps monitors when the mouse drifts is a launcher you lose.
    property var targetScreen: null

    // Last pointer position over the grid, in grid coordinates — the guard the
    // delegate's hover handler uses to tell motion from re-delivered hover.
    property real pointerX: -1
    property real pointerY: -1

    // --- geometry (settings.json `surfaces.launcher`) ------------------------
    readonly property int windowWidth: Config.surface("launcher", "width", 640)
    readonly property int windowHeight: Config.surface("launcher", "height", 480)
    readonly property int columns: Config.surface("launcher", "columns", 2)
    readonly property int recentCount: Config.surface("launcher", "recentCount", 8)
    readonly property string placeholder: Config.surface("launcher", "placeholder", "Search")

    // wofi/style.css, verbatim, for the parts that survived. Both themes use
    // the same numbers; only the radii, border width and window alpha differ
    // and those live in palette.json.
    //   #input      { margin: 10px; padding: 8px 12px; border: 2px }
    //   #inner-box  { margin: 4px 10px 10px 10px }
    //   #entry img  { margin-right: 10px }
    //   #text       { margin: 0 6px }
    readonly property int inputMargin: 10
    readonly property int inputPaddingY: 8
    readonly property int inputPaddingX: 12
    readonly property int inputBorder: 2
    readonly property int gridMarginTop: 4
    readonly property int gridMargin: 10
    readonly property int iconGap: 10
    readonly property int textMargin: 6

    // The row is the redesigned part: 44px tall, 6px of air between rows,
    // 10px of padding either side, a 28px icon. A 28px icon in a 44px row
    // reads as a list; wofi's 32px-in-52px read as a grid of tiles.
    readonly property int rowHeight: 44
    readonly property int rowSpacing: 6
    readonly property int entryPadding: 10
    // From settings (`surfaces.launcher.iconSize`); the row fits anything up to 32.
    readonly property int iconSize: Math.min(32, Config.surface("launcher", "iconSize", 28))
    readonly property int genericFontSize: 12

    // A GridView has no spacing of its own, so the cell carries the row plus
    // its gap, and the delegate paints only the top `rowHeight` of it.
    readonly property int cellHeight: root.rowHeight + root.rowSpacing

    // The open slide: content rises this far while it fades in.
    readonly property int slideDistance: 8

    // --- data ----------------------------------------------------------------
    property string query: ""

    // Nothing typed.
    readonly property bool recentMode: root.query.trim() === ""

    // The frecent list, computed once per open (see show()) rather than bound:
    // the decay depends on the clock, and a binding would only re-rank when
    // something it reads changed, not when the launcher is next summoned.
    property var recentList: []

    // What the grid shows. Recomputed whenever the query, the desktop-entry
    // model or the recent list changes.
    readonly property var results: root.recentMode
        ? root.recentList
        : root.filter(DesktopEntries.applications.values, root.query)

    // Ranked substring match, case-insensitive. wofi's own matching is a plain
    // `contains`; the tiering is what makes "fire" put Firefox above an entry
    // that merely mentions it in its comment.
    //   0  name starts with the query
    //   1  name contains it
    //   2  genericName, a keyword or the comment contains it
    // Alphabetical within a tier (JS sort is stable, but say so explicitly).
    // An empty query lists everything by name — the first-run fallback below
    // takes the head of that.
    function filter(items, rawQuery) {
        const q = rawQuery.trim().toLowerCase();
        const ranked = [];
        for (let i = 0; i < items.length; i++) {
            const tier = q === "" ? 0 : root.rank(items[i], q);
            if (tier >= 0)
                ranked.push({ tier: tier, item: items[i] });
        }
        ranked.sort((a, b) => (a.tier - b.tier)
            || a.item.name.localeCompare(b.item.name, undefined, { sensitivity: "base" }));
        return ranked.map(r => r.item);
    }

    function rank(e, q) {
        const name = (e.name ?? "").toLowerCase();
        if (name.startsWith(q))
            return 0;
        if (name.includes(q))
            return 1;
        if ((e.genericName ?? "").toLowerCase().includes(q))
            return 2;
        const keywords = e.keywords ?? [];
        for (let i = 0; i < keywords.length; i++)
            if (keywords[i].toLowerCase().includes(q))
                return 2;
        if ((e.comment ?? "").toLowerCase().includes(q))
            return 2;
        return -1;
    }

    // --- launch history ------------------------------------------------------
    // { "<desktop entry id>": { "count": n, "last": <ms epoch> } }. Keyed by
    // the entry id, not the name, so a renamed app keeps its rank and two apps
    // that share a name stay apart.
    property var history: ({})

    readonly property real dayMs: 24 * 60 * 60 * 1000

    // Bump the entry and write the whole file back. The in-memory object is
    // the source of truth; the file is a mirror for the next shell start.
    function remember(entry) {
        if (entry.id === "")
            return;
        const prev = root.history[entry.id] ?? {};
        root.history[entry.id] = { count: (prev.count ?? 0) + 1, last: Date.now() };
        historyFile.setText(JSON.stringify(root.history));
    }

    // The most-launched apps, most relevant first: count weighted by how
    // recently the app was last launched (today 1, this week 0.7, this month
    // 0.4, older 0.1), so something used daily outranks a one-week binge from
    // last year. Ids that no longer resolve to an installed, listed entry are
    // dropped silently — the file is a cache, not a record. With no history
    // at all, the alphabetical head of the full list, so the first open looks
    // like every other open.
    function frecent() {
        const now = Date.now();
        const scored = [];
        for (const id in root.history) {
            const h = root.history[id];
            if (h === null || typeof h !== "object")
                continue;
            const e = DesktopEntries.byId(id);
            if (e === null || e === undefined || e.noDisplay)
                continue;
            const age = now - (h.last ?? 0);
            const decay = age < root.dayMs ? 1
                : age < 7 * root.dayMs ? 0.7
                : age < 30 * root.dayMs ? 0.4
                : 0.1;
            scored.push({ score: (h.count ?? 0) * decay, item: e });
        }
        scored.sort((a, b) => (b.score - a.score)
            || a.item.name.localeCompare(b.item.name, undefined, { sensitivity: "base" }));
        const top = scored.slice(0, root.recentCount).map(s => s.item);
        if (top.length > 0)
            return top;
        return root.filter(DesktopEntries.applications.values, "").slice(0, root.recentCount);
    }

    // Quickshell.statePath() is `${Quickshell.stateDir}/<path>`, the per-shell
    // state dir (~/.local/state/quickshell/by-shell/<id>/). setText() writes
    // atomically off the UI thread and creates the file — and the directory —
    // when they do not exist yet.
    FileView {
        id: historyFile

        path: Quickshell.statePath("launcher-history.json")
        // A missing file is the first run, not an error, so the default
        // logging is off and the two real failures are reported by hand.
        printErrors: false

        onLoaded: {
            try {
                const parsed = JSON.parse(this.text());
                root.history = (parsed !== null && typeof parsed === "object") ? parsed : {};
            } catch (e) {
                console.warn("Launcher: launcher-history.json is not valid JSON — starting over:", e);
            }
        }
        onLoadFailed: function (error) {
            if (error !== FileViewError.FileNotFound)
                console.warn("Launcher: could not read launcher-history.json:", error);
        }
        onSaveFailed: function (error) {
            console.warn("Launcher: could not write launcher-history.json:", error);
        }
    }

    // --- open / close --------------------------------------------------------
    function show() {
        root.query = "";
        input.text = "";
        root.targetScreen = root.focusedScreen();
        root.recentList = root.frecent();
        root.shown = true;
        input.forceActiveFocus();
    }

    function hide() {
        root.shown = false;
    }

    // Hyprland's focused monitor as a ShellScreen. HyprlandMonitor carries no
    // screen reference of its own, so the join is by output name (both sides
    // report the connector, e.g. "DP-1"). First screen when nothing matches.
    function focusedScreen() {
        const name = Hyprland.focusedMonitor?.name ?? "";
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++)
            if (screens[i].name === name)
                return screens[i];
        return screens.length > 0 ? screens[0] : null;
    }

    // Enter / click. Launches the selection and closes.
    function activate(index) {
        const item = root.results[index];
        if (item === undefined)
            return;
        root.launch(item);
        root.remember(item);
        root.hide();
    }

    // DesktopEntry.execute() ignores Terminal=true, so a terminal entry is
    // wrapped in wezterm by hand — the same terminal hyprland.lua binds to
    // SUPER+Q. `command` is the Exec line already parsed and stripped of its
    // %f/%u field codes, which is what execute() itself runs.
    function launch(entry) {
        if (!entry.runInTerminal) {
            entry.execute();
            return;
        }
        const cmd = ["wezterm", "start", "--"];
        for (let i = 0; i < entry.command.length; i++)
            cmd.push(entry.command[i]);
        const ctx = { command: cmd };
        if (entry.workingDirectory !== "")
            ctx.workingDirectory = entry.workingDirectory;
        Quickshell.execDetached(ctx);
    }

    // --- IPC -----------------------------------------------------------------
    // `qs ipc -p ~/.config/hypr/quickshell call launcher <fn>`
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            if (root.shown)
                root.hide();
            else
                root.show();
        }
        function open(): void { root.show(); }
        function close(): void { root.hide(); }
    }

    // Click anywhere outside the window and the compositor clears the grab.
    HyprlandFocusGrab {
        windows: [win]
        active: root.shown
        onCleared: root.hide()
    }

    // The name's baseline, so the generic name can sit on it. GlowText is an
    // Item around a Text and does not forward the Text's own baselineOffset;
    // for a single top-aligned line that offset is the font's ascent, which
    // FontMetrics knows without laying anything out.
    FontMetrics {
        id: nameMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.launcherFontSize
    }

    // --- window --------------------------------------------------------------
    // No anchors: a layer surface with none is centered by the compositor,
    // which is exactly where wofi put itself. Overlay layer so it sits above
    // the bar (the one surface that covers it — see the gruvbox stylesheet's
    // note on why the launcher gets the purple nothing else uses).
    PanelWindow {
        id: win

        screen: root.targetScreen
        visible: root.shown

        WlrLayershell.namespace: "qs-hypr-launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        // Exclusive only while shown. A hidden layer surface that still asks
        // for exclusive keyboard focus is a hidden surface that eats keystrokes.
        WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive
                                                : WlrKeyboardFocus.None

        exclusionMode: ExclusionMode.Ignore

        implicitWidth: root.windowWidth

        // The empty state is exactly as tall as what it shows: the frame, the
        // input inside its 10px margin, the 14px gap below it (the input's
        // margin plus the grid's 4px top margin — GTK margins never collapsed),
        // one cell per row, and the 10px bottom margin, 6px of which is the
        // last cell's own trailing gap. Typing restores wofi's height; the
        // compositor keeps the window centered through the change.
        readonly property int emptyHeight: 2 * Theme.launcherBorderWidth
            + root.inputMargin + inputBox.height
            + root.inputMargin + root.gridMarginTop
            + root.results.length * root.cellHeight
            + root.gridMargin - root.rowSpacing

        implicitHeight: root.recentMode ? win.emptyHeight : root.windowHeight

        // Never the `transparent` keyword — see bar/Bar.qml. The body below
        // draws the rounded frame; the corners outside it stay clear.
        color: "#00000000"

        // window { background-color: rgba(ground, opacity); border: Npx solid
        // rgba(launcher, 0.5); border-radius }. The frame used to be full-
        // strength violet; at half alpha it reads as an edge, not a bar.
        //
        // Sized rather than anchored because `y` is the open slide: the body
        // rises `slideDistance` while it fades in, instead of snapping into
        // existence the way a layer surface otherwise does. The window itself
        // is simply visible or not; only its content moves.
        Rectangle {
            id: body

            width: parent.width
            height: parent.height
            y: root.shown ? 0 : root.slideDistance
            opacity: root.shown ? 1 : 0

            Behavior on y {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 120 }
            }

            radius: Theme.launcherRadius
            color: Theme.withAlpha(Theme.ground, Theme.launcherOpacity)
            border.width: Theme.launcherBorderWidth
            border.color: Theme.withAlpha(Theme.launcher, 0.5)

            // Everything painted inside the frame follows its inner corners.
            readonly property real innerRadius: Math.max(0, body.radius - body.border.width)

            // Inset by the frame so the stripes ride the fill, not the border —
            // GTK painted background-image under the border, never over it.
            Texture {
                anchors.margins: body.border.width
                radius: body.innerRadius
            }

            // A 1px hairline of `launcher` at 12% just inside the frame — the
            // same soft double edge the bar islands draw, so the launcher
            // looks like it belongs to the bar rather than to wofi.
            Rectangle {
                anchors.fill: parent
                anchors.margins: body.border.width
                radius: body.innerRadius
                color: Qt.rgba(0, 0, 0, 0)
                border.width: 1
                border.color: Theme.withAlpha(Theme.launcher, 0.12)
            }

            // --- #input --------------------------------------------------
            // GtkEntry: margin 10, padding 8/12, 2px frame of `launcher`,
            // `surface` fill. The frame rests at 35% and brightens to 70% while
            // there is a query, so the eye is told where the typing went. The
            // magnifier is the entry's primary icon (`#input image { color:
            // launcher }`).
            Rectangle {
                id: inputBox

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: body.border.width + root.inputMargin
                anchors.leftMargin: body.border.width + root.inputMargin
                anchors.rightMargin: body.border.width + root.inputMargin

                height: input.implicitHeight + 2 * (root.inputPaddingY + root.inputBorder)
                radius: Theme.launcherInputRadius
                color: Theme.surface
                border.width: root.inputBorder
                border.color: input.text !== "" ? Theme.withAlpha(Theme.launcher, 0.7)
                                                : Theme.withAlpha(Theme.launcher, 0.35)

                Behavior on border.color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    id: searchGlyph
                    anchors.left: parent.left
                    anchors.leftMargin: root.inputBorder + root.inputPaddingX
                    anchors.verticalCenter: parent.verticalCenter
                    // U+F002 nf-fa-search, as an escape: BMP private-use glyphs
                    // do not survive every editor (see modules/Clock.qml).
                    text: "\uf002"
                    color: Theme.launcher
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.launcherFontSize
                }

                TextInput {
                    id: input

                    anchors.left: searchGlyph.right
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    // GTK spaces an entry's icon from its text by about a
                    // glyph's worth; 6 lands on what wofi drew.
                    anchors.leftMargin: 6
                    anchors.rightMargin: root.inputBorder + root.inputPaddingX

                    color: Theme.text
                    selectionColor: Theme.launcher
                    selectedTextColor: Theme.ground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.launcherFontSize
                    clip: true
                    selectByMouse: true
                    focus: true

                    onTextChanged: root.query = input.text

                    // wofi's bindings: Up/Down walk the list, Tab/Shift+Tab
                    // cycle through it end to end, Enter runs, Escape leaves.
                    // Left/Right walk the grid only when there IS a grid — in
                    // a single column they fall through to the entry and move
                    // the cursor, which is the one thing wofi's did not do.
                    // Everything else is typing.
                    Keys.onPressed: function (event) {
                        switch (event.key) {
                        case Qt.Key_Escape:
                            root.hide();
                            break;
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            root.activate(grid.currentIndex);
                            break;
                        case Qt.Key_Up:
                            grid.moveCurrentIndexUp();
                            break;
                        case Qt.Key_Down:
                            grid.moveCurrentIndexDown();
                            break;
                        case Qt.Key_Left:
                            if (grid.columns <= 1)
                                return;
                            grid.moveCurrentIndexLeft();
                            break;
                        case Qt.Key_Right:
                            if (grid.columns <= 1)
                                return;
                            grid.moveCurrentIndexRight();
                            break;
                        case Qt.Key_Backtab:
                            grid.step(-1);
                            break;
                        case Qt.Key_Tab:
                            grid.step(1);
                            break;
                        default:
                            return;
                        }
                        event.accepted = true;
                    }

                    // Placeholder in `dormant`, where the typed text will go.
                    Text {
                        anchors.fill: parent
                        text: root.placeholder
                        visible: input.text === ""
                        color: Theme.dormant
                        font: input.font
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // --- #scroll > #inner-box ------------------------------------
            // margin: 4px 10px 10px 10px, below the input's own 10px margin.
            // GTK margins do not collapse, so input-to-grid is 14. The bottom
            // margin is 10 less the row spacing: the last cell's trailing gap
            // supplies the rest, and the view's content then fits its height
            // exactly — otherwise selecting the last row would scroll the
            // whole list up by those 6px to bring its gap into view.
            GridView {
                id: grid

                anchors.top: inputBox.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: root.inputMargin + root.gridMarginTop
                anchors.leftMargin: body.border.width + root.gridMargin
                anchors.rightMargin: body.border.width + root.gridMargin
                anchors.bottomMargin: body.border.width + root.gridMargin - root.rowSpacing

                clip: true
                model: root.results

                // One column for the frecent card; a typed query gets wofi's
                // --columns 2.
                readonly property int columns: root.recentMode ? 1 : root.columns
                cellWidth: Math.floor(grid.width / grid.columns)
                cellHeight: root.cellHeight

                // No overshoot: GTK's scrolled window stopped dead at the ends.
                boundsBehavior: Flickable.StopAtBounds

                // Tab order: every cell in reading order, wrapping at either
                // end, whatever the column count.
                function step(delta) {
                    if (grid.count > 0)
                        grid.currentIndex = (grid.currentIndex + delta + grid.count) % grid.count;
                }

                // A fresh result set starts at the top with the first entry
                // selected, which is what wofi does on every keystroke.
                onModelChanged: {
                    grid.currentIndex = grid.count > 0 ? 0 : -1;
                    grid.positionViewAtBeginning();
                }
                onCountChanged: {
                    if (grid.currentIndex < 0 && grid.count > 0)
                        grid.currentIndex = 0;
                }

                // --- #entry ----------------------------------------------
                delegate: Item {
                    id: entry

                    required property var modelData
                    required property int index

                    readonly property bool selected: entry.GridView.isCurrentItem

                    width: grid.cellWidth
                    height: grid.cellHeight

                    // The app icon as an Image source, or "" when the entry
                    // names none or the icon theme has none by that name —
                    // iconPath's check form returns empty rather than the
                    // broken-image placeholder, and the monogram takes over.
                    readonly property string iconSource:
                        (entry.modelData.icon ?? "") !== ""
                            ? Quickshell.iconPath(entry.modelData.icon, true) : ""

                    // The generic name, or "" when there is none or it only
                    // repeats the name ("Firefox  Firefox" helps nobody).
                    readonly property string genericName: {
                        const g = entry.modelData.genericName ?? "";
                        const n = entry.modelData.name ?? "";
                        return g.toLowerCase() === n.toLowerCase() ? "" : g;
                    }

                    // The selected row is a tint and an edge of `launcher`,
                    // not a solid violet block with ground-colored text: the
                    // highlight should pick a row out, not shout. Both carry
                    // a 100ms transition so the selection glides down the
                    // list under the arrow keys. At rest the same color at
                    // alpha 0, so only the alpha animates and nothing passes
                    // through a muddy midpoint.
                    property color fill: entry.selected ? Theme.withAlpha(Theme.launcher, 0.18)
                                                        : Theme.withAlpha(Theme.launcher, 0)
                    property color edge: entry.selected ? Theme.withAlpha(Theme.launcher, 0.55)
                                                        : Theme.withAlpha(Theme.launcher, 0)

                    Behavior on fill {
                        ColorAnimation { duration: 100 }
                    }
                    Behavior on edge {
                        ColorAnimation { duration: 100 }
                    }

                    // The row proper: the cell minus its trailing gap.
                    Rectangle {
                        id: row

                        anchors.fill: parent
                        anchors.bottomMargin: root.rowSpacing
                        radius: Theme.launcherEntryRadius
                        color: entry.fill
                        border.width: 1
                        border.color: entry.edge

                        // The icon slot: the app icon, or its monogram. Fixed
                        // width, so the text column starts at the same x on
                        // every row whether or not an icon was found.
                        Item {
                            id: iconSlot

                            anchors.left: parent.left
                            anchors.leftMargin: root.entryPadding
                            anchors.verticalCenter: parent.verticalCenter
                            width: root.iconSize
                            height: root.iconSize

                            IconImage {
                                anchors.centerIn: parent
                                visible: entry.iconSource !== ""
                                implicitSize: root.iconSize
                                asynchronous: true
                                source: entry.iconSource
                            }

                            // No icon: a tinted disc with the app's initial.
                            // wofi showed the generic executable icon here;
                            // a letter in the launcher color keeps the row
                            // in the family instead of flagging it as broken.
                            Rectangle {
                                anchors.centerIn: parent
                                visible: entry.iconSource === ""
                                width: root.iconSize
                                height: root.iconSize
                                radius: root.iconSize / 2
                                color: Theme.withAlpha(Theme.launcher, 0.15)

                                Text {
                                    anchors.centerIn: parent
                                    text: (entry.modelData.name ?? "").trim().charAt(0).toUpperCase()
                                    color: Theme.launcher
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                        }

                        // The name: `text` at rest, `launcher` when selected,
                        // and on cyberpunk the selected one glows (a no-op on
                        // gruvbox, which declares no glow). `#text { margin:
                        // 0 6px }` still sets the gap after the icon, and the
                        // same 6px plus the row padding ends the text column
                        // at the right.
                        //
                        // Never elided while the generic name has room to give:
                        // it takes its natural width up to the whole column and
                        // the generic name gets what is left.
                        GlowText {
                            id: name

                            anchors.left: iconSlot.right
                            anchors.leftMargin: root.iconGap + root.textMargin
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.min(name.implicitWidth,
                                            Math.max(0, row.width - root.entryPadding - root.textMargin - name.x))
                            baselineOffset: nameMetrics.ascent

                            text: entry.modelData.name ?? ""
                            color: entry.selected ? Theme.launcher : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.launcherFontSize
                            elide: Text.ElideRight
                            glowRadius: 8
                            glowOpacity: entry.selected ? 0.45 : 0
                        }

                        // The generic name — "Web Browser" — two spaces on,
                        // smaller and `dormant`, on the name's baseline. First
                        // to give way when the row is tight.
                        Text {
                            anchors.left: name.right
                            anchors.right: parent.right
                            anchors.rightMargin: root.entryPadding + root.textMargin
                            anchors.baseline: name.baseline
                            visible: entry.genericName !== ""

                            text: "  " + entry.genericName
                            color: Theme.dormant
                            font.family: Theme.fontFamily
                            font.pixelSize: root.genericFontSize
                            elide: Text.ElideRight
                        }
                    }

                    // Hover selects, click runs — the pointer half of the
                    // keyboard rules above. Covers the whole cell, gap
                    // included, so there is no dead strip between rows.
                    //
                    // Selection follows REAL pointer motion only. Qt re-delivers
                    // hover every frame to whatever sits under a resting cursor,
                    // so without the position check each keystroke would snap
                    // the selection from the first result back to the cell the
                    // mouse happens to be parked over.
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: function (mouse) {
                            const p = entry.mapToItem(grid, mouse.x, mouse.y);
                            if (p.x === root.pointerX && p.y === root.pointerY)
                                return;
                            root.pointerX = p.x;
                            root.pointerY = p.y;
                            grid.currentIndex = entry.index;
                        }
                        onClicked: root.activate(entry.index)
                    }
                }
            }
        }
    }
}
