// The card delegate below references `root`, `stage` and `list`, and the
// palette readers reference `root`. Bound makes those resolve lexically
// instead of via the runtime scope chain — see modules/Workspaces.qml.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import "../config"
import "../components"

// The theme picker — SUPER+T. What used to be a row per theme inside the
// launcher is now a surface of its own: the whole screen, frosted, with the
// themes' wallpapers in a carousel across the middle (Omarchy's theme
// switcher is the reference feel), the current one's name, polarity and
// twelve palette roles under it, and a search field along the bottom.
//
//   carousel  one card per directory in themes/, alphabetical, the ACTIVE
//             theme centred on open. The centre card is full size; its
//             neighbours peek from both sides, smaller and dimmer, scaled
//             by how far they sit from the centre.
//   caption   name, "dark"/"light", and the roles as a row of discs — the
//             same strip the launcher row used to carry, at a size you can
//             actually judge a palette by. Crossfades as the carousel moves.
//   search    typing filters the carousel to names CONTAINING the text; the
//             filtered list keeps its order and starts over at its first card.
//
// Keys, all handled on the search field so it keeps focus throughout:
//
//   Left / Right     previous / next, wrapping at the ends
//   h / l            the same — but ONLY while the field is empty. With text
//                    in it they are letters again. This is the one compromise
//                    between "type the theme" and vim keys: the field cannot
//                    tell "h for harbor" from "h for left", so the first
//                    letter of a theme that starts with h or l has to be
//                    skipped ("arbor" still finds harbor — the filter is a
//                    substring match, not a prefix one).
//   Tab / Shift+Tab  next / previous as well
//   Enter            apply the centre card: theme-switch.sh <name>, then close.
//                    Already the active theme? Just close.
//   Escape           close, change nothing
//   click            a side card: make it the centre; the centre card: apply
//   wheel            one card per notch, over the carousel
//
// Nothing applies until Enter or a click. There is deliberately no live
// preview: a switch costs about a second and repaints every surface and the
// wallpaper, so scrubbing through the list would be a slideshow of reloads.
//
// Motion: hyprland.lua gives this namespace `no_anim` (the
// qs-surfaces-self-animated layer rule) and the compositor neither slides nor
// fades it. The surface animates itself the way the launcher body does — the
// backdrop fades, the rest fades with it and rises 12px — 150ms in, 120ms out.
// The window stays mapped until the fade-out has run, like the session menu.
//
// Owned by shell.qml as `ThemePicker {}`. Driven over IPC:
//   qs ipc -p ~/.config/hypr/quickshell call themes toggle|open|close
Scope {
    id: root

    // --- state ---------------------------------------------------------------
    property bool shown: false

    // The screen the picker opened on. Frozen at open, as the launcher does:
    // with exclusive keyboard focus only the pointer can move Hyprland's
    // focused monitor, and a full-screen surface that hops outputs when the
    // mouse drifts is a surface you lose.
    property var targetScreen: null

    // Length of the fade the window is about to run: 150ms in, 120ms out. Set
    // BEFORE `shown` flips so every Behavior below has read the new figure by
    // the time the flip starts it (see session/SessionMenu.qml).
    property int fadeMs: 150

    // --- geometry ------------------------------------------------------------
    // The backdrop: `ground` at 0.82 — the session menu's sheet, a shade
    // lighter, because the wallpapers behind it are the point here.
    // 0.9, not the launcher's 0.8: this surface is no longer blurred by the
    // compositor (hyprland.lua) — a full-screen blur recomputed on every frame
    // of the fade was the other half of the stutter — so the backdrop covers
    // the desktop by opacity alone.
    readonly property real backdropOpacity: 0.9

    // The open slide: everything but the backdrop rises this far while it
    // fades in (the launcher body's 8px, a little further on a full screen).
    readonly property int slideDistance: 12

    // Cards are 52% of the screen width, at the panel's 16:10, so a neighbour
    // peeks from either side. Capped so a card is never taller than 52% of
    // the screen: on a 16:10 output both limits agree; on a wider one the
    // width cap would push the caption into the search field.
    readonly property real cardFraction: 0.52
    readonly property int cardGap: 24
    // One card away from the centre: this much smaller (scale only; no dimming).
    readonly property real sideScale: 0.82

    // The caption under the carousel: 24px below the card, 10px between its
    // three lines, 22px discs with 8px between them.
    readonly property int captionGap: 24
    readonly property int captionSpacing: 10
    readonly property int swatchSize: 22
    readonly property int swatchGap: 8

    // The search field: the launcher's input, free-standing. 460x44, its
    // bottom 7% of the screen up, the glyph 14px in and 10px from the text.
    readonly property int inputWidth: 460
    readonly property int inputHeight: 44
    readonly property real inputBottomFraction: 0.07
    readonly property int inputPaddingX: 14
    readonly property int glyphGap: 10

    // The "current" tag on the active theme's card: 12px text with 8px of
    // padding, 12px inside the card's rim.
    readonly property int tagFontSize: 12
    readonly property int tagPadding: 8
    readonly property int tagInset: 12

    // The twelve roles, in the order palette.json declares them, so the row
    // of discs reads the same way the @define-color block did.
    readonly property var roleOrder: [
        "ground", "surface", "hairline", "dim", "frame", "readout",
        "warn", "ok", "urgent", "dormant", "text", "launcher"
    ]

    // --- data ----------------------------------------------------------------
    property string query: ""

    // Every theme directory: [{ name, dir, wallpaper }], from the lister below
    // — run at startup and again on each open, applied when it differs.
    property var themes: []

    // What the carousel shows: the themes whose name contains the query,
    // case-insensitively, in directory order. The whole list when it is empty.
    readonly property var visibleThemes: {
        const q = root.query.trim().toLowerCase();
        return q === "" ? root.themes
                        : root.themes.filter(t => t.name.toLowerCase().includes(q));
    }

    // The centre card's theme, or null when nothing matches.
    readonly property var currentTheme: root.visibleThemes[list.currentIndex] ?? null

    // What the caption describes. Lags `currentTheme` by half a crossfade:
    // the old text fades out, the swap happens at zero, the new text fades
    // in. Swapped at once while the picker is hidden (nothing to see).
    property var captionTheme: null

    // { "<name>": { polarity, roles: [12 colors in roleOrder] } }, one entry
    // per theme as its palette.json comes in. Reassigned rather than mutated
    // so the caption's bindings see each arrival.
    property var palettes: ({})
    readonly property var captionPalette: root.palettes[root.captionTheme?.name ?? ""] ?? null

    // The index the carousel opens on: the active theme, or the first card
    // when it is filtered out (or themes/current points at nothing listed).
    function activeIndex() {
        return Math.max(0, root.visibleThemes.findIndex(t => t.name === Theme.themeName));
    }

    // Only a change of THEME moves the caption. The list is rebuilt on every
    // keystroke, and a `var` property reports a change on every write, so
    // without the name check each letter typed would blink the caption even
    // when the same card stayed centred.
    onCurrentThemeChanged: {
        if ((root.currentTheme?.name ?? "") === (root.captionTheme?.name ?? ""))
            return;
        if (root.shown)
            captionFade.restart();
        else
            root.captionTheme = root.currentTheme;
    }

    // The 160ms crossfade: 80 out, swap, 80 in.
    SequentialAnimation {
        id: captionFade
        NumberAnimation { target: caption; property: "opacity"; to: 0; duration: 80 }
        ScriptAction { script: root.captionTheme = root.currentTheme }
        NumberAnimation { target: caption; property: "opacity"; to: 1; duration: 80 }
    }

    // --- open / close --------------------------------------------------------
    function show() {
        root.targetScreen = root.focusedScreen();
        input.text = "";
        // Set while still hidden, so the move is instant (see the view's
        // highlightMoveDuration) and the caption swaps without a fade.
        list.currentIndex = root.activeIndex();
        root.captionTheme = root.currentTheme;
        // A fresh listing every open, so a theme copied in since the shell
        // started shows up without a restart.
        themeLister.running = true;
        root.fadeMs = 150;
        root.shown = true;
        input.forceActiveFocus();
    }

    // `shown` goes false at once: the keyboard is released now, the window
    // unmaps on its own once the fade-out has run.
    function hide() {
        root.fadeMs = 120;
        root.shown = false;
    }

    // Hyprland's focused monitor as a ShellScreen, joined by output name —
    // HyprlandMonitor carries no screen reference of its own. First screen
    // when nothing matches (startup race, or Hyprland's socket not up yet).
    function focusedScreen() {
        const name = Hyprland.focusedMonitor?.name ?? "";
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++)
            if (screens[i].name === name)
                return screens[i];
        return screens.length > 0 ? screens[0] : null;
    }

    // Previous / next, wrapping at either end.
    function step(delta) {
        if (list.count > 0)
            list.currentIndex = (list.currentIndex + delta + list.count) % list.count;
    }

    // Enter / click on the centre card. Switches and closes; the active
    // theme just closes — a switch to itself still costs the full reload.
    function apply(theme) {
        if (theme === null || theme === undefined)
            return;
        // Through bash so a synced copy without its executable bit still runs.
        if (theme.name !== Theme.themeName)
            Quickshell.execDetached(["bash", Paths.script("theme-switch.sh"), theme.name]);
        root.hide();
    }

    // --- IPC -----------------------------------------------------------------
    // `qs ipc -p ~/.config/hypr/quickshell call themes <fn>`
    IpcHandler {
        target: "themes"

        function toggle(): void {
            if (root.shown)
                root.hide();
            else
                root.show();
        }
        function open(): void { root.show(); }
        function close(): void { root.hide(); }
    }

    // --- themes/ listing -----------------------------------------------------
    // One line per theme directory, `name<TAB>picture`, skipping the
    // `current` symlink. The picture is the theme's thumb.webp — a 1280px
    // copy of its wallpaper, shipped in the repo precisely so this surface
    // never decodes a 4K webp on open (eight of those, in list order, was a
    // visible stutter with the current theme arriving last). A theme without
    // one falls back to its full wallpaper, same glob as theme_wallpaper() in
    // scripts/theme-lib.sh.
    Process {
        id: themeLister
        command: ["sh", "-c",
            "for d in \"$1\"/*/; do n=${d%/}; n=${n##*/}; [ \"$n\" = current ] && continue; "
            + "w=; for f in \"$d\"thumb.webp \"$d\"wallpaper.*; do [ -e \"$f\" ] && { w=$f; break; }; done; "
            + "printf '%s\\t%s\\n' \"$n\" \"$w\"; done",
            "_", Paths.themes]
        stdout: themeListing
    }

    // The lister's output. A sibling of the Process rather than inline in its
    // `stdout`, so the handler's scope is the Scope's own and `root`/`list`
    // resolve for the linter as they do everywhere else in this file.
    StdioCollector {
        id: themeListing

        onStreamFinished: {
            const out = [];
            const lines = themeListing.text.split("\n");
            for (let i = 0; i < lines.length; i++) {
                const parts = lines[i].split("\t");
                if (parts[0] === "")
                    continue;
                out.push({
                    name: parts[0],
                    dir: Paths.themes + "/" + parts[0],
                    wallpaper: parts[1] ?? ""
                });
            }
            // Only a DIFFERENT listing is a new model. The view starts over at
            // 0 on every model it is handed, so handing it an equal array on
            // each open would slide the carousel from the first card back to
            // the active one in front of the user. (Also why the first listing
            // runs at startup, below: the first open finds it settled too.)
            if (JSON.stringify(out) === JSON.stringify(root.themes))
                return;
            root.themes = out;
            list.currentIndex = root.activeIndex();
        }
    }

    Component.onCompleted: themeLister.running = true

    // One FileView per theme, reading ITS palette.json for the caption — the
    // launcher row used to do this per entry. Variants keys instances by
    // value, so a re-listing that returns the same themes re-reads nothing.
    //
    // Variants fills `modelData` on each instance at runtime; the linter
    // cannot see that through the unresolved type and reports the required
    // property as unset. Suppressed for this block only, like SessionMenu.
    // qmllint disable required
    Variants {
        model: root.themes

        FileView {
            id: paletteReader

            required property var modelData

            path: paletteReader.modelData.dir + "/palette.json"

            onLoaded: {
                try {
                    const parsed = JSON.parse(this.text());
                    const roles = parsed.roles ?? {};
                    const next = Object.assign({}, root.palettes);
                    next[paletteReader.modelData.name] = {
                        polarity: parsed.polarity ?? "dark",
                        roles: root.roleOrder.map(r => roles[r] ?? "#00000000")
                    };
                    root.palettes = next;
                } catch (e) {
                    console.warn("ThemePicker: " + paletteReader.modelData.name
                                 + "/palette.json is not valid JSON:", e);
                }
            }
            onLoadFailed: function (error) {
                console.warn("ThemePicker: could not read " + paletteReader.modelData.name
                             + "/palette.json:", error);
            }
        }
    }
    // qmllint enable required

    // Click on another monitor and the compositor clears the grab.
    HyprlandFocusGrab {
        windows: [win]
        active: root.shown
        onCleared: root.hide()
    }

    // --- window --------------------------------------------------------------
    // Overlay layer, like the launcher, so it sits above the bar.
    PanelWindow {
        id: win

        screen: root.targetScreen

        // Stays mapped until the backdrop has faded out, so the picker
        // dissolves instead of blinking off (osd/Osd.qml does the same).
        visible: root.shown || sheet.opacity > 0

        WlrLayershell.namespace: "qs-hypr-themes"
        WlrLayershell.layer: WlrLayer.Overlay
        // Exclusive only while shown. A window that is only still mapped for
        // its fade-out must not be swallowing keys meanwhile.
        WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive
                                                : WlrKeyboardFocus.None

        // Reserves nothing, shifts nothing behind it.
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        // The surface itself is fully transparent and the backdrop is a child
        // Rectangle, so the layer rule's blur + ignore_alpha find its edge.
        // Never the `transparent` keyword — see bar/Bar.qml.
        color: "#00000000"

        // Opposing anchors on both axes stretch to the full screen.
        //
        // Same narrow suppression as Bar.qml's `margins`: the grouped scope is
        // declared on the C++ side, so static analysis reports it as
        // unqualified even though it binds at runtime.
        // qmllint disable unqualified unresolved-type
        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }
        // qmllint enable unqualified unresolved-type

        // The backdrop. Fades only — a rising full-screen sheet would show a
        // strip of bare desktop along the top. A click on it, outside every
        // card, closes (the session menu's sheet does the same).
        Rectangle {
            id: sheet

            anchors.fill: parent
            color: Theme.withAlpha(Theme.ground, root.backdropOpacity)

            opacity: root.shown ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: root.fadeMs }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.hide()
            }
        }

        // Everything else: fades with the sheet and rises into place. Sized
        // rather than anchored because `y` is the slide.
        Item {
            id: stage

            width: parent.width
            height: parent.height
            y: root.shown ? 0 : root.slideDistance
            opacity: root.shown ? 1 : 0

            Behavior on y {
                NumberAnimation { duration: root.fadeMs; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: root.fadeMs }
            }

            // The card: 52% of the width at 16:10, see cardFraction.
            readonly property int cardWidth: Math.round(Math.min(
                stage.width * root.cardFraction,
                stage.height * root.cardFraction * 16 / 10))
            readonly property int cardHeight: Math.round(stage.cardWidth * 10 / 16)

            // --- the carousel ------------------------------------------------
            // Full width, one card tall, across the vertical centre. The
            // highlight range is the centre card's own slot, strictly
            // enforced, so the current item is always centred — including
            // the first and last, which the view pads past its ends for.
            //
            // Not interactive: every move goes through currentIndex (keys,
            // clicks, the wheel below) and the view animates there. A flick
            // or the Flickable's own wheel handling would be a second motion
            // fighting the highlight range.
            ListView {
                id: list

                width: parent.width
                height: stage.cardHeight
                anchors.verticalCenter: parent.verticalCenter

                model: root.visibleThemes
                orientation: ListView.Horizontal
                spacing: root.cardGap
                interactive: false

                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: (list.width - stage.cardWidth) / 2
                preferredHighlightEnd: list.preferredHighlightBegin + stage.cardWidth
                // The range is enforced on the HIGHLIGHT, and it is the
                // highlight's move that the duration below times; an empty one
                // gives the view something to track without drawing anything.
                highlight: Item {}
                // 220ms per move while shown. Instant while hidden, so the
                // index show() sets lands before the fade-in rather than
                // sliding into place under it. -1: duration, not velocity.
                highlightMoveDuration: root.shown ? 220 : 0
                highlightMoveVelocity: -1

                // Every card stays instantiated, so stepping to the far end
                // of the row never creates a delegate (and uploads its
                // texture) mid-slide. Eight thumbs is nothing. Sized from the MODEL,
                // not list.count: count depends on which delegates exist,
                // which depends on cacheBuffer — a binding loop.
                cacheBuffer: Math.max(1, root.visibleThemes.length) * (stage.cardWidth + root.cardGap)

                // A fresh result set starts over at its first card (the
                // lister's handler then re-centres the active theme).
                onModelChanged: list.currentIndex = list.count > 0 ? 0 : -1

                // --- one card ------------------------------------------------
                delegate: Item {
                    id: card

                    required property var modelData
                    required property int index

                    width: stage.cardWidth
                    height: stage.cardHeight

                    readonly property bool current: card.ListView.isCurrentItem
                    readonly property bool active: card.modelData.name === Theme.themeName
                    readonly property string wallpaper: card.modelData.wallpaper ?? ""

                    // 0 at the view's centre, 1 one card-and-gap away, clamped
                    // beyond. A binding on contentX, so it tracks the move
                    // frame by frame with no Behavior of its own.
                    readonly property real distance: Math.min(1,
                        Math.abs(card.x + card.width / 2 - list.contentX - list.width / 2)
                            / (card.width + list.spacing))

                    // Scale only. The side cards used to dim as well, and
                    // a half-transparent picture next to a solid one read as
                    // a loading state rather than depth.
                    scale: 1 - (1 - root.sideScale) * card.distance

                    // The wallpaper, cropped to the card and clipped to the
                    // islands' corners. A theme with no wallpaper (or one Qt
                    // cannot decode) is a `surface` card with its name on it.
                    ClippingRectangle {
                        id: art

                        width: card.width
                        height: card.height
                        radius: Theme.islandRadius
                        color: Theme.surface

                        Image {
                            id: picture

                            anchors.fill: parent
                            visible: card.wallpaper !== ""
                            source: card.wallpaper !== "" ? "file://" + card.wallpaper : ""
                            fillMode: Image.PreserveAspectCrop
                            // Native size: thumb.webp is already 1280 across,
                            // which covers the card. (No sourceSize: Qt would
                            // scale the request by the window's DPR and
                            // re-decode.) The centre card decodes on the GUI
                            // thread so it is on the first frame — a 1280px
                            // webp is ~10ms — the rest arrive in parallel
                            // right behind it.
                            asynchronous: !card.current
                            cache: true
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !picture.visible || picture.status === Image.Error
                            text: card.modelData.name
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeAccent
                        }
                    }

                    // The rim: 1px of `frame` at 0.45 on the centre card,
                    // `hairline` on the rest. Drawn over the art rather than
                    // as the clip's own border, like the launcher's inner
                    // hairline, so it never insets the picture.
                    Rectangle {
                        width: card.width
                        height: card.height
                        radius: Theme.islandRadius
                        color: "#00000000"
                        border.width: 1
                        border.color: card.current ? Theme.withAlpha(Theme.frame, 0.45)
                                                   : Theme.hairline
                    }

                    // "current" on the active theme's card: a chip-shaped tag
                    // in `readout` on `ground`, top-left inside the rim.
                    Rectangle {
                        visible: card.active
                        x: root.tagInset
                        y: root.tagInset
                        width: tagText.implicitWidth + 2 * root.tagPadding
                        height: tagText.implicitHeight + 2 * root.tagPadding
                        radius: Theme.chipRadius
                        color: Theme.withAlpha(Theme.ground, 0.8)

                        Text {
                            id: tagText
                            anchors.centerIn: parent
                            text: "current"
                            color: Theme.readout
                            font.family: Theme.fontFamily
                            font.pixelSize: root.tagFontSize
                        }
                    }

                    // A side card: bring it to the centre. The centre card:
                    // apply it — the pointer half of Enter.
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.current)
                                root.apply(card.modelData);
                            else
                                list.currentIndex = card.index;
                        }
                    }
                }
            }

            // The wheel, over the carousel: one card per notch. Accepts no
            // button, so clicks fall through to the cards underneath. Notches
            // are 120 units; a touchpad sends the same distance in many small
            // events, so they are summed rather than each counted as a step.
            MouseArea {
                id: wheel

                anchors.fill: list
                acceptedButtons: Qt.NoButton

                property real notch: 0

                onWheel: function (event) {
                    // Down or right is "next"; a wheel reports y, a pad either.
                    wheel.notch += event.angleDelta.y !== 0 ? -event.angleDelta.y : event.angleDelta.x;
                    if (Math.abs(wheel.notch) < 120)
                        return;
                    root.step(wheel.notch > 0 ? 1 : -1);
                    wheel.notch = 0;
                }
            }

            // --- the caption ---------------------------------------------------
            // Name, polarity, palette — of the centre card, crossfaded as it
            // changes (captionFade). With nothing matching, the name line
            // says so and the other two go away.
            Column {
                id: caption

                anchors.top: list.bottom
                anchors.topMargin: root.captionGap
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.captionSpacing

                // The name — bold, eight up from the accent size — glows on
                // the themes that glow (GlowText is a plain Text elsewhere).
                GlowText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.captionTheme !== null ? root.captionTheme.name
                        : (root.themes.length > 0 ? "no theme matches" : "")
                    color: root.captionTheme !== null ? Theme.text : Theme.dormant
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeAccent + 8
                    font.bold: true
                    glowOpacity: root.captionTheme !== null ? 0.45 : 0
                }

                // "dark" / "light", from the theme's own palette.json.
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.captionTheme !== null
                    text: root.captionPalette?.polarity ?? "dark"
                    color: Theme.dormant
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                // The twelve roles of THAT theme as discs, in palette order,
                // each rimmed in the ACTIVE theme's hairline so a disc the
                // color of the backdrop still reads as a disc.
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.captionTheme !== null
                    spacing: root.swatchGap

                    Repeater {
                        model: root.captionPalette?.roles ?? []

                        Rectangle {
                            required property string modelData
                            width: root.swatchSize
                            height: root.swatchSize
                            radius: root.swatchSize / 2
                            color: modelData
                            border.width: 1
                            border.color: Theme.hairline
                        }
                    }
                }
            }

            // --- the search field ----------------------------------------------
            // The launcher's #input, free-standing: `surface` at 0.9 inside a
            // 1px `launcher` frame at half strength, the magnifier and the
            // placeholder both in `dormant` — it is a filter, not the subject.
            Rectangle {
                id: inputBox

                width: root.inputWidth
                height: root.inputHeight
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Math.round(stage.height * root.inputBottomFraction)

                radius: Theme.launcherInputRadius
                color: Theme.withAlpha(Theme.surface, 0.9)
                border.width: 1
                border.color: Theme.withAlpha(Theme.launcher, 0.5)

                Text {
                    id: searchGlyph
                    anchors.left: parent.left
                    anchors.leftMargin: root.inputPaddingX
                    anchors.verticalCenter: parent.verticalCenter
                    // U+F002 nf-fa-search, as an escape: BMP private-use glyphs
                    // do not survive every editor (see modules/Clock.qml).
                    text: ""
                    color: Theme.dormant
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.launcherFontSize
                }

                TextInput {
                    id: input

                    anchors.left: searchGlyph.right
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: root.glyphGap
                    anchors.rightMargin: root.inputPaddingX

                    color: Theme.text
                    selectionColor: Theme.launcher
                    selectedTextColor: Theme.ground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.launcherFontSize
                    clip: true
                    selectByMouse: true
                    focus: true

                    onTextChanged: root.query = input.text

                    // The key map from the header. Everything not listed is
                    // typing — including h and l once there is text, which
                    // is why they are tested against the field, not the mode.
                    Keys.onPressed: function (event) {
                        switch (event.key) {
                        case Qt.Key_Escape:
                            root.hide();
                            break;
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            root.apply(root.currentTheme);
                            break;
                        case Qt.Key_Left:
                        case Qt.Key_Backtab:
                            root.step(-1);
                            break;
                        case Qt.Key_Right:
                        case Qt.Key_Tab:
                            root.step(1);
                            break;
                        case Qt.Key_H:
                            if (input.text !== "")
                                return;
                            root.step(-1);
                            break;
                        case Qt.Key_L:
                            if (input.text !== "")
                                return;
                            root.step(1);
                            break;
                        default:
                            return;
                        }
                        event.accepted = true;
                    }

                    // Placeholder in `dormant`, where the typed text will go.
                    Text {
                        anchors.fill: parent
                        text: "theme…"
                        visible: input.text === ""
                        color: Theme.dormant
                        font: input.font
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
