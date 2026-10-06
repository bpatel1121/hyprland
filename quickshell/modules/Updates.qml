import QtQuick
import Quickshell.Io
import "../config"
import "../components"

// Repo updates — a Pac-Man glyph, from `checkupdates`. `#custom-updates`:
//
//     font-weight: bold; padding: 0 10px; margin: 3px 2px;
//     .pending  color: <readout>; background rgba(<readout>, 0.10 / 0.12)
//     .zero     color: rgba(<dormant>, 0.45); background rgba(<dormant>, 0.06)
//
// No text-shadow: the right-island instruments are flat so the glow elsewhere
// means something (CSS rule 4). The CSS painted a pending count in `warn`
// (Pac-Man yellow); that was the one chip on the bar in a color the theme did
// not otherwise use, and on glacier it sat on the ice like a sticker. Pending
// is now the readout color, the same as every other live figure: the count
// going from greyed-out to lit IS the signal, it does not need a hue of its own.
//
// scripts/waybar-updates.sh owns the retry/timeout logic: an uncapped network
// call inside a bar module is what used to wedge the counter. Unlike the
// watchdogs, this chip STAYS on screen at zero and grays out (class `zero`), so
// the resting bar really is one color.
//
// Clicking opens the same upgrade terminal waybar's on-click did. waybar then
// relied on `pkill -RTMIN+8 waybar` inside that shell to refresh the counter;
// here the terminal is a child Process and its exit re-runs the script —
// no signal, no name of a bar inside a shell command.
ScriptChip {
    id: root

    script: "waybar-updates.sh"
    args: ["pacman"]
    intervalSec: Config.get("updates", "intervalSec", 120)

    readonly property bool pending: root.stateClass === "pending"

    bold: true
    glowOpacity: 0
    accent: root.pending ? Theme.readout : Theme.withAlpha(Theme.dormant, 0.45)
    tintColor: root.pending ? Theme.readout : Theme.dormant
    // pending: 0.10 / 0.12 in the CSS — the chip tint plus the "state" step
    // (0.10 / 0.11). zero: 0.06 in both themes.
    tintOpacity: root.pending ? Theme.chipOpacity + 0.03 : 0.06

    // Instant after any pacman or yay run, wherever it happened: every
    // transaction appends to pacman.log, and a FileView watches it without
    // loading it (preload off — the log is megabytes). One transaction writes
    // many lines, so the refresh waits for the log to go quiet for 3s. The
    // interval poll below only has to catch updates appearing upstream.
    FileView {
        path: "/var/log/pacman.log"
        preload: false
        watchChanges: true
        onFileChanged: settle.restart()
    }

    Timer {
        id: settle
        interval: 3000
        onTriggered: root.refresh()
    }

    Process {
        id: upgrade
        command: ["wezterm", "start", "--", "sh", "-c", "sudo pacman -Syu; read -p done"]
        onExited: root.refresh()
    }

    onActivated: upgrade.running = true
}
