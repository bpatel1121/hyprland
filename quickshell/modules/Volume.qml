import Quickshell.Services.Pipewire
import "../config"
import "../components"

// Output volume.
//
// PwObjectTracker is NOT optional: Pipewire node properties stay unbound until
// something declares interest in the node, so without the tracker below `volume`
// and `muted` read as defaults forever and the chip looks frozen.
Chip {
    id: root

    readonly property int step: Config.get("volume", "stepPercent", 5)

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: root.sink?.audio ?? null

    readonly property bool muted: root.audio?.muted ?? false
    readonly property int percent: Math.round((root.audio?.volume ?? 0) * 100)

    glyph: {
        if (!root.audio)
            return "";
        if (root.muted)
            return "󰝟";
        if (root.percent < 34)
            return "󰕿";
        if (root.percent < 67)
            return "󰖀";
        return "󰕾";
    }

    label: root.audio ? (root.muted ? "muted" : root.percent + "%") : ""
    accent: root.muted ? Theme.dormant : Theme.readout

    // Binds the sink so its volume/muted actually update. See the note above.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    onActivated: {
        if (root.audio)
            root.audio.muted = !root.audio.muted;
    }

    onScrolled: function (delta) {
        if (!root.audio)
            return;
        const next = root.audio.volume + (delta * root.step / 100);
        // Clamped to 1.0 — matching the `-l 1` waybar passes to wpctl, which is
        // there to stop a scroll from pushing the sink into software boost.
        root.audio.volume = Math.max(0, Math.min(1, next));
    }
}
