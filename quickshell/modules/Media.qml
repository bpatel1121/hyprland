import Quickshell.Services.Mpris
import "../config"
import "../components"

// Now playing — "󰓇  Title · Artist".
//
// Takes the first player that can actually be controlled, rather than whichever
// happens to be first on the bus. Renders nothing when nothing is playing, so
// the left island shrinks to workspaces alone in silence.
//
// Position/length deliberately stay out of the label: at a fixed character
// budget they ate the artist before ever showing. They belong in the tooltip.
Chip {
    id: root

    readonly property int maxChars: Config.get("media", "maxChars", 45)

    readonly property var player: {
        const list = Mpris.players?.values ?? [];
        for (let i = 0; i < list.length; i++) {
            if (list[i].canControl)
                return list[i];
        }
        return null;
    }

    readonly property bool playing: root.player?.isPlaying ?? false

    readonly property string title: root.player?.trackTitle ?? ""
    readonly property string artist: root.player?.trackArtist ?? ""

    // Spotify gets its own glyph; anything else gets play/pause.
    glyph: {
        if (!root.player)
            return "";
        const id = (root.player.identity ?? "").toLowerCase();
        if (id.indexOf("spotify") !== -1)
            return "󰓇";
        return root.playing ? "󰐊" : "󰏤";
    }

    label: {
        if (!root.player || root.title === "")
            return "";
        const full = root.artist === "" ? root.title : root.title + " · " + root.artist;
        return full.length > root.maxChars ? full.substring(0, root.maxChars - 1) + "…" : full;
    }

    tooltip: root.player
        ? root.title + " — " + root.artist + " (" + (root.player.trackAlbum ?? "") + ")"
        : ""

    // Paused reads one step back, so play-vs-pause is carried by color as well
    // as by the glyph.
    accent: root.playing ? Theme.readout : Theme.dim

    onActivated: {
        if (root.player?.canTogglePlaying)
            root.player.togglePlaying();
    }

    onScrolled: function (delta) {
        if (delta > 0) {
            if (root.player?.canGoNext)
                root.player.next();
        } else if (root.player?.canGoPrevious) {
            root.player.previous();
        }
    }
}
