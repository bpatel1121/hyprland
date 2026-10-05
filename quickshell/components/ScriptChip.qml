import QtQuick
import Quickshell.Io
import "../config"

// A chip driven by one of the existing scripts/waybar-*.sh emitters.
//
// THIS IS THE REUSE SEAM. scripts/waybar-lib.sh defines wb_emit, which prints
// exactly one line of JSON per update:
//
//     {"text":"...","class":"...","tooltip":"..."}
//
// waybar-agenda.sh, waybar-todos.sh, waybar-updates.sh and waybar-cava.sh all
// speak it, and SplitParser consumes it directly — so those five bar chips work
// here with ZERO changes to the scripts. The escaping, the khal parsing, the
// checkupdates retry logic and the cava framing all stay in one place,
// still covered by shellcheck in CI — their name is history, not a dependency.
//
// `class` is the whole styling protocol: the scripts already emit pending /
// overdue / zero / idle, and Theme.classColor() maps those onto roles.
Chip {
    id: root

    // --- what to run ---------------------------------------------------------
    // Script name only — resolved against scripts/ by Paths.script().
    property string script: ""
    property var args: []

    // Or a full command, for a chip backed by something that is not a repo
    // script (`swaync-client -swb` is the current example — it streams the same
    // one-line-JSON shape wb_emit does, which is why one component covers both).
    property var command: []

    readonly property var resolvedCommand: root.script !== ""
        ? [Paths.script(root.script)].concat(root.args)
        : root.command

    readonly property bool runnable: root.resolvedCommand.length > 0

    // Seconds between runs. 0 means STREAM: start once and keep reading, which
    // is how the cava soundwave and anything using `swaync-client -swb` work.
    property int intervalSec: 0
    readonly property bool streaming: root.intervalSec <= 0

    // --- what came back ------------------------------------------------------
    // The emitter's `text` field, verbatim. Assigned imperatively as lines
    // arrive, so it is kept SEPARATE from Chip.label: label is a binding onto it
    // that a subclass can override without the next line of output clobbering
    // the override (Dnd.qml does exactly that — swaync sends a state word, not a
    // glyph). Writing straight to label would destroy that binding.
    property string rawText: ""

    // Empty text is meaningful: it is how a watchdog chip says "nothing to
    // report", and Chip renders zero-width for it.
    property string stateClass: ""

    label: root.rawText
    accent: Theme.classColor(root.stateClass)

    // A chip whose script has never produced output yet stays invisible rather
    // than flashing a placeholder.
    property bool everRead: false

    // Re-run the emitter now, ahead of its interval. This is the replacement
    // for waybar's `signal` mechanism (`pkill -RTMIN+8 waybar` after a pacman
    // run): Updates.qml and Aur.qml call it when their upgrade terminal exits.
    // A no-op for a streaming chip, whose process is already running.
    function refresh() {
        if (!root.runnable)
            return;
        proc.running = true;
    }

    Process {
        id: proc
        command: root.resolvedCommand
        // Streaming chips run for the life of the shell; polled ones are
        // restarted by the Timer below.
        running: root.streaming && root.runnable

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: function (line) {
                const trimmed = line.trim();
                if (trimmed === "")
                    return;

                root.everRead = true;

                // Plain text rather than JSON is tolerated: it is what a future
                // script that skips waybar-lib.sh would emit, and treating it as
                // the label is friendlier than dropping the chip.
                if (!trimmed.startsWith("{")) {
                    root.rawText = trimmed;
                    return;
                }

                try {
                    const o = JSON.parse(trimmed);
                    root.rawText = o.text ?? "";
                    root.stateClass = o.class ?? "";
                    root.tooltip = o.tooltip ?? "";
                } catch (e) {
                    // A malformed line is exactly what used to make a waybar
                    // module silently vanish — the bug wb_escape() exists to
                    // prevent. Say so instead of disappearing.
                    console.warn("ScriptChip(" + root.describe() + "): unparseable line:", trimmed);
                }
            }
        }
    }

    // For log messages: the script name, or the bare command.
    function describe() {
        return root.script !== "" ? root.script : (root.command[0] ?? "<nothing>");
    }

    // Polled chips only. `triggeredOnStart` so the chip populates immediately
    // rather than after one full interval.
    Timer {
        running: !root.streaming && root.runnable
        interval: root.intervalSec * 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
