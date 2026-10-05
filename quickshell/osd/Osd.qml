import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "../config"
import "../components"

// Volume / brightness on-screen display — what swayosd used to draw.
//
// One pill, centered near the bottom of the FOCUSED monitor, that answers the
// SUPER+F1..F3 / F5,F6 binds in hyprland.lua over IPC:
//
//     qs ipc -p ~/.config/hypr/quickshell call osd volumeRaise
//
// The look is themes/<name>/swayosd/style.css, rule for rule (cited inline),
// with every color resolved to its palette role and the per-theme geometry
// (radius, frame, track radius, opacity) read through Theme.osd*. The layout
// is swayosd's own (src/server/osd_window.rs): a horizontal box named
// `container` with 12px spacing holding an icon, a progress bar and a "N%"
// label, on an Overlay layer surface that takes no input.
//
// Volume acts straight on Pipewire — no wpctl round trip — so the pill shows
// the value it just set. Brightness has no Quickshell service, so it shells
// out to `brightnessctl -m`, whose one output line carries the new percent.
//
// Nothing here ticks while the pill is hidden: the only Timer is the hide
// timeout, and the only Processes are one-shots started by a keypress.
Scope {
    id: root

    // --- behavior (settings.json → surfaces.osd) ----------------------------
    readonly property int timeoutMs: Config.surface("osd", "timeoutMs", 1500)
    readonly property int volumeStep: Config.surface("osd", "volumeStepPercent", 5)
    readonly property int brightnessStep: Config.surface("osd", "brightnessStepPercent", 5)

    // --- typography ----------------------------------------------------------
    // swayosd drew a 32px symbolic icon (ICON_SIZE) and a GTK `title-4` label;
    // the brief sizes the Nerd Font glyph at the palette's accent size and the
    // label at its body size. Everything below derives from these two, so
    // raising them is the one knob if the pill reads too small next to the old
    // one (~28 lands the glyph's ink where the 32px icon's was).
    readonly property int glyphSize: Theme.fontSizeAccent
    readonly property int labelSize: Theme.fontSize

    // --- geometry --------------------------------------------------------------
    // swayosd's progress bar is a GtkProgressBar with hexpand, whose natural
    // width is GTK's MIN_HORIZONTAL_BAR_WIDTH (150); the window's own 250px
    // width request never binds once the icon, label and paddings are added.
    readonly property int trackWidth: 150
    // `gtk::Box::new(Orientation::Horizontal, 12)` — the gap between the three.
    readonly property int spacing: 12
    // `progressbar { min-height: 8px }` / `trough { min-height: 8px }`.
    readonly property int trackHeight: 8

    // --- state ---------------------------------------------------------------
    property bool shown: false
    // "volume" | "brightness" — picks the glyph set.
    property string kind: "volume"
    property int percent: 0
    property bool muted: false

    readonly property string glyph: {
        if (root.kind === "brightness")
            return root.percent < 34 ? "󰃞" : (root.percent < 67 ? "󰃟" : "󰃠");
        // swayosd's icon_state match: muted OR 0% both show the muted icon.
        if (root.muted || root.percent <= 0)
            return "󰝟";
        if (root.percent < 34)
            return "󰕿";
        if (root.percent < 67)
            return "󰖀";
        return "󰕾";
    }

    // --- audio ---------------------------------------------------------------
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: root.sink?.audio ?? null

    // NOT optional — see modules/Volume.qml. Without this `volume` and `muted`
    // are never populated and the pill would show 0% forever.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // --- the screen ------------------------------------------------------------
    // HyprlandMonitor carries no ShellScreen reference, but both it and
    // ShellScreen expose the connector name (DP-1, eDP-1 …), so match on that.
    // No focused monitor (startup race, or Hyprland's socket not up yet) falls
    // back to the first screen rather than nowhere.
    readonly property var focusedScreen: {
        const name = Hyprland.focusedMonitor?.name ?? "";
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === name)
                return screens[i];
        }
        return screens[0] ?? null;
    }

    // --- showing ---------------------------------------------------------------

    // Put the pill up with these values and (re)arm the hide timeout — the
    // equivalent of swayosd's run_timeout() after every change.
    function present(kind, percent, muted) {
        root.kind = kind;
        root.percent = percent;
        root.muted = muted;
        root.shown = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: root.timeoutMs
        onTriggered: root.shown = false
    }

    // --- volume ----------------------------------------------------------------

    // Move the sink by `direction` (±1) steps. Shows the value it asked for
    // rather than reading it back, so the pill never lags a round trip behind
    // a held key.
    function nudgeVolume(direction) {
        if (!root.audio) {
            root.wpctl(["set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@",
                        root.volumeStep + "%" + (direction > 0 ? "+" : "-")]);
            return;
        }
        // Clamped to 1.0 — the `-l 1` the old bind passed to wpctl, there to
        // stop a held key from pushing the sink into software boost.
        const next = Math.max(0, Math.min(1, root.audio.volume + direction * root.volumeStep / 100));
        root.audio.volume = next;
        root.present("volume", Math.round(next * 100), root.audio.muted);
    }

    function toggleMute() {
        if (!root.audio) {
            root.wpctl(["set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
            return;
        }
        const next = !root.audio.muted;
        root.audio.muted = next;
        root.present("volume", Math.round(root.audio.volume * 100), next);
    }

    function showVolume() {
        if (!root.audio) {
            root.wpctl([]);
            return;
        }
        root.present("volume", Math.round(root.audio.volume * 100), root.audio.muted);
    }

    // The path for when Pipewire.defaultAudioSink is null (pipewire not up yet,
    // or Quickshell's sync with it not done): the keypress must still land, so
    // do what the bind's own fallback does — run wpctl — and read the sink back
    // so the pill can still show something. `$@` keeps the args unquoted-safe;
    // an empty list (show) skips the action and only reads.
    function wpctl(args) {
        wpctlProc.command = ["sh", "-c",
            '[ $# -eq 0 ] || wpctl "$@"; exec wpctl get-volume @DEFAULT_AUDIO_SINK@',
            "wpctl"].concat(args);
        wpctlProc.running = true;
    }

    Process {
        id: wpctlProc

        stdout: StdioCollector {
            id: wpctlOut
            // `Volume: 0.45` or `Volume: 0.45 [MUTED]`
            onStreamFinished: {
                const m = /Volume:\s*([\d.]+)(.*)/.exec(wpctlOut.text);
                if (!m) {
                    console.warn("Osd: wpctl gave no volume:", wpctlOut.text.trim());
                    return;
                }
                root.present("volume", Math.round(parseFloat(m[1]) * 100), m[2].indexOf("MUTED") !== -1);
            }
        }
    }

    // --- brightness --------------------------------------------------------------

    // `brightnessctl -m set 5%+` and `brightnessctl -m info` both print exactly
    // one line, `device,class,current,percent%,max`, so one parser serves the
    // raise/lower/show calls alike. The default device is the first `backlight`
    // class entry — the same one the old bare `brightnessctl set 5%+` moved.
    //
    // ponytail: a press that lands while the previous brightnessctl is still
    // running (a few ms) is dropped; queue the deltas if key-repeat ever shows it.
    function backlight(op, value) {
        backlightProc.command = value === undefined
            ? ["brightnessctl", "-m", op]
            : ["brightnessctl", "-m", op, value];
        backlightProc.running = true;
    }

    Process {
        id: backlightProc

        stdout: StdioCollector {
            id: backlightOut
            onStreamFinished: {
                const fields = backlightOut.text.trim().split(",");
                const pct = parseInt(fields[3]);
                if (fields.length < 5 || isNaN(pct)) {
                    console.warn("Osd: unexpected brightnessctl output:", backlightOut.text.trim());
                    return;
                }
                root.present("brightness", pct, false);
            }
        }
    }

    // --- IPC ---------------------------------------------------------------------
    // The contract hyprland.lua's binds call. Type annotations are what register
    // a function with `qs ipc`; a function without them is invisible to it.
    IpcHandler {
        target: "osd"

        function volumeRaise(): void { root.nudgeVolume(1); }
        function volumeLower(): void { root.nudgeVolume(-1); }
        function volumeMute(): void { root.toggleMute(); }
        function brightnessRaise(): void { root.backlight("set", root.brightnessStep + "%+"); }
        function brightnessLower(): void { root.backlight("set", root.brightnessStep + "%-"); }

        // Show the current state without touching it. kind = "volume" | "brightness".
        // Not `show`: `qs ipc show` is a subcommand, and the CLI parser takes a
        // bare `show` after `call osd` as that subcommand, not as a function.
        function display(kind: string): void {
            if (kind === "brightness")
                root.backlight("info");
            else
                root.showVolume();
        }
    }

    // --- the window ----------------------------------------------------------------
    PanelWindow {
        id: win

        screen: root.focusedScreen

        // Stays mapped until the fade-out below has finished, so the pill
        // dissolves instead of blinking off.
        visible: root.shown || pill.opacity > 0

        WlrLayershell.namespace: "qs-hypr-osd"
        // swayosd: `window.set_layer(Layer::Overlay)` — above fullscreen too.
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Reserves nothing (swayosd: exclusive_zone -1) and takes no clicks:
        // an empty mask leaves the window with no clickable area, which is
        // swayosd's empty cairo input region.
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}

        // Never the `transparent` keyword — see bar/Bar.qml.
        color: "#00000000"

        implicitWidth: pill.implicitWidth
        implicitHeight: pill.implicitHeight

        // Bottom edge only: the compositor centers an edge-anchored surface
        // along that edge, which is the horizontal centering swayosd got from
        // the same anchor. The margin is swayosd's placement, inverted: it set
        // top = (monitor − window) × top_margin with top_margin 0.85, i.e. the
        // pill sits 15% of the free height up from the bottom.
        //
        // Static analysis cannot resolve these two C++-side grouped scopes on
        // a PanelWindow — the same narrow suppression bar/Bar.qml uses, for
        // the same reason.
        // qmllint disable unqualified unresolved-type
        anchors.bottom: true
        margins.bottom: Math.round(((win.screen?.height ?? 0) - win.implicitHeight) * 0.15)
        // qmllint enable unqualified unresolved-type

        // window#osd { background-color: rgba(surface, osd.opacity); border: Npx solid frame;
        //              border-radius: osd.radius; padding: 10px 18px }
        // #container { margin: 6px }
        Rectangle {
            id: pill

            // The CSS box, from the outside in: border, padding, container
            // margin. Rectangle.border is drawn inside the item, so content
            // margins are measured from the item edge.
            readonly property real padX: Theme.osdBorderWidth + 18 + 6
            readonly property real padY: Theme.osdBorderWidth + 10 + 6

            anchors.fill: parent

            implicitWidth: 2 * pill.padX + icon.implicitWidth + root.spacing
                + root.trackWidth + root.spacing + label.width
            implicitHeight: 2 * pill.padY
                + Math.max(icon.implicitHeight, label.implicitHeight, root.trackHeight)

            // 999 in the CSS means "fully round"; Qt wants it no larger than
            // half the shorter side, and Scanlines clips to the same value.
            radius: Math.min(Theme.osdRadius, pill.height / 2)
            color: Theme.withAlpha(Theme.surface, Theme.osdOpacity)
            border.width: Theme.osdBorderWidth
            border.color: Theme.frame

            opacity: root.shown ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            // Gruvbox's CRT stripes. No-op for cyberpunk. Inset by the border
            // so they ride the fill and not the frame — a CSS background-image
            // paints the padding box, inside the border, whose inner corner
            // radius is the outer one less the border width.
            Scanlines {
                anchors.margins: pill.border.width
                radius: Math.max(0, pill.radius - pill.border.width)
            }

            // image { color: readout; text-shadow: 0 0 8px rgba(readout, 0.45) }
            GlowText {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: pill.padX
                anchors.verticalCenter: parent.verticalCenter
                text: root.glyph
                color: Theme.readout
                font.family: Theme.fontFamily
                font.pixelSize: root.glyphSize
                glowRadius: 8
                glowOpacity: 0.45
            }

            // progressbar / trough { min-height: 8px; border-radius: osd.trackRadius }
            // trough { background-color: hairline }
            Rectangle {
                id: trough
                anchors.left: icon.right
                anchors.leftMargin: root.spacing
                anchors.right: label.left
                anchors.rightMargin: root.spacing
                anchors.verticalCenter: parent.verticalCenter
                height: root.trackHeight
                radius: Theme.osdTrackRadius
                color: Theme.hairline

                // swayosd desensitizes the bar while muted, and its built-in
                // stylesheet (under the theme's) dims `progressbar:disabled`
                // to 0.5 — the muted glyph plus a dimmed bar is the old look.
                opacity: (root.kind === "volume" && root.muted) ? 0.5 : 1

                // progress { background-color: readout; border-radius: osd.trackRadius }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: trough.width * Math.max(0, Math.min(1, root.percent / 100))
                    radius: Theme.osdTrackRadius
                    color: Theme.readout

                    Behavior on width {
                        NumberAnimation { duration: 120 }
                    }
                }
            }

            // label { color: readout; text-shadow: 0 0 8px rgba(readout, 0.45) }
            // Fixed to the width of "100%" so the track does not jiggle as the
            // digit count changes; centered inside that box like GTK's
            // halign(Center) label.
            GlowText {
                id: label
                anchors.right: parent.right
                anchors.rightMargin: pill.padX
                anchors.verticalCenter: parent.verticalCenter
                width: labelMetrics.width
                horizontalAlignment: Text.AlignHCenter
                text: root.percent + "%"
                color: Theme.readout
                font.family: Theme.fontFamily
                font.pixelSize: root.labelSize
                glowRadius: 8
                glowOpacity: 0.45
            }

            TextMetrics {
                id: labelMetrics
                font.family: Theme.fontFamily
                font.pixelSize: root.labelSize
                text: "100%"
            }
        }
    }
}
