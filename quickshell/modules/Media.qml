import QtQuick
import Quickshell.Services.Mpris
import "../config"
import "../components"

// Now playing — `#mpris`, waybar's `{player_icon}  {title} · {artist}`:
//
//     color: <readout>; background: rgba(<readout>, <chip opacity>);
//     text-shadow: 0 0 8px rgba(<readout>, 0.45);
//     padding: 0 12px; margin: 3px 0 3px 2px;
//     border-top-right-radius: 0; border-bottom-right-radius: 0;   fused to the wave
//     .spotify   color: <ok>; tint and glow in <ok>
//     .paused    color: rgba(<dormant>, 0.55); no tint; no glow
//
// Playing vs paused is carried by THREE cues, not just a shade of gray: the
// glyph swaps (spotify/play → pause), the color lights up, and the glow
// switches on. Glow already means "live" everywhere else on this bar, so
// music inherits that vocabulary for free. Spotify gets its brand green rather
// than the readout color — the same exception swaync makes.
//
// Takes the first player that can actually be controlled, rather than
// whichever happens to be first on the bus. Renders nothing when there is no
// player or it is stopped, so the left island shrinks to workspaces alone in
// silence.
//
// Position/length deliberately stay out of the label: at a fixed character
// budget they ate the artist before ever showing. They live in the tooltip.
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

    readonly property string title: root.player?.trackTitle ?? ""
    readonly property string artist: root.player?.trackArtist ?? ""
    readonly property bool playing: root.player?.isPlaying ?? false
    readonly property bool stopped: (root.player?.playbackState ?? MprisPlaybackState.Stopped)
                                 === MprisPlaybackState.Stopped
    readonly property bool present: root.player !== null && !root.stopped && root.title !== ""
    readonly property bool paused: root.present && !root.playing
    readonly property bool spotify: {
        const id = ((root.player?.identity ?? "") + " " + (root.player?.desktopEntry ?? ""))
            .toLowerCase();
        return id.indexOf("spotify") !== -1;
    }

    // player-icons: spotify 󰓇, default 󰐊; status-icons: paused 󰏤 (for every
    // player — `format-paused` uses {status_icon}).
    glyph: !root.present ? "" : !root.playing ? "󰏤" : root.spotify ? "󰓇" : "󰐊"
    // Two spaces after the glyph, as in the format string.
    separator: "  "
    label: {
        if (!root.present)
            return "";
        // waybar prints "{title} · {artist}" verbatim; with no artist that is a
        // dangling " · ", which is dropped here on purpose.
        const full = root.artist === "" ? root.title : root.title + " · " + root.artist;
        return full.length > root.maxChars ? full.substring(0, root.maxChars - 1) + "…" : full;
    }

    readonly property color liveColor: root.spotify ? Theme.ok : Theme.readout
    accent: root.paused ? Theme.withAlpha(Theme.dormant, 0.55) : root.liveColor
    tintColor: root.liveColor
    tintOpacity: root.paused ? 0 : Theme.chipOpacity
    glowOpacity: root.paused ? 0 : 0.45

    leftPadding: 12
    rightPadding: 12
    marginRight: 0
    squareRight: true

    // tooltip-format: "{title} — {artist} ({album})  {position}/{length}".
    tooltip: {
        if (!root.present)
            return "";
        let out = root.title + " — " + root.artist + " (" + (root.player.trackAlbum ?? "") + ")";
        if (root.player.lengthSupported)
            out += "  " + root.mmss(root.player.position) + "/" + root.mmss(root.player.length);
        return out;
    }

    function mmss(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + ("0" + (s % 60)).slice(-2);
    }

    // `position` does not update on its own while a track plays — reading it
    // is always current, but nothing notifies. While the tooltip is up, poke
    // positionChanged() once a second so the binding above re-reads it.
    Timer {
        running: root.tooltipShown && root.present
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

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
