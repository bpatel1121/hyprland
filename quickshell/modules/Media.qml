import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../config"
import "../components"

// Now playing — `#mpris`, waybar's `{player_icon}  {title} · {artist}`, with
// the track's album art as a rounded thumbnail ahead of the glyph:
//
//     color: <readout>; background: rgba(<readout>, <chip opacity>);
//     text-shadow: 0 0 8px rgba(<readout>, 0.45);
//     padding: 0 12px; margin: 3px 0 3px 2px;
//     border-top-right-radius: 0; border-bottom-right-radius: 0;   fused to the wave
//     .spotify   color: <ok>; tint and glow in <ok>
//     .paused    color: rgba(<dormant>, 0.55); no tint; no glow; art at half
//
// The art is the one thing waybar never drew: a 20px square of the player's
// `mpris:artUrl`, corners rounded a step inside the chip's own, then an 8px
// gap, then the glyph. It lives INSIDE the left padding — the padding widens
// by art + gap while a thumbnail is up, so the chip grows around it over
// 120ms and the title keeps its 12px inset from whatever is on its left. No
// art (no URL, or one that fails to load) means no slot at all, not an empty
// box: the chip is exactly what it was.
//
// Playing vs paused is carried by FOUR cues, not just a shade of gray: the
// glyph swaps (spotify/play → pause), the color lights up, the glow switches
// on, and the art comes up from half to full. Glow already means "live"
// everywhere else on this bar, so music inherits that vocabulary for free.
// Spotify gets its brand green rather than the readout color — the same
// exception swaync makes.
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

    // --- art -----------------------------------------------------------------
    // `trackArtUrl` is whatever the player put in mpris:artUrl — a file:// path
    // for local players, https:// for Spotify and browsers, "" for none.
    readonly property string artUrl: root.present ? (root.player?.trackArtUrl ?? "") : ""
    // The slot opens as soon as a URL is known, not once it has loaded: a track
    // change swaps the URL and the thumbnail reloads, and keying the width on
    // Image.Ready would have the chip shrink and regrow on every track. It
    // closes only for no URL, or one the player lied about.
    readonly property bool hasArt: root.artUrl !== "" && art.status !== Image.Error
    readonly property int artSize: 20
    readonly property int artGap: 8

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

    // `padding: 0 12px`, plus the art and its gap while there is art. The chip
    // measures its width from this, so the thumbnail costs nothing to lay out.
    leftPadding: 12 + (root.hasArt ? root.artSize + root.artGap : 0)
    Behavior on leftPadding {
        NumberAnimation { duration: 120 }
    }
    rightPadding: 12
    marginRight: 0
    squareRight: true

    // The thumbnail, clipped to its rounded corners. ClippingRectangle is
    // Quickshell's rounded clip — a plain Rectangle clips to its bounding box
    // only — with a zero-alpha fill so nothing shows but the picture.
    ClippingRectangle {
        // At the start of the original 12px padding, so the art sits where the
        // glyph used to and the glyph moves right to make room; centred on the
        // chip's height like the text run is.
        x: root.marginLeft + 12
        y: (root.height - root.artSize) / 2
        width: root.artSize
        height: root.artSize
        // A step inside the chip's own corners, floored so gruvbox's 4px chip
        // still rounds the picture a little: 5 in cyberpunk, 3 in gruvbox.
        radius: Math.max(3, Theme.chipRadius - 4)
        color: Qt.rgba(0, 0, 0, 0)

        // Invisible until decoded (nothing to show while loading, and nothing
        // for a URL that failed), then fades in; half-strength while paused —
        // the art's share of `.paused`'s dimming.
        opacity: art.status !== Image.Ready ? 0 : root.paused ? 0.5 : 1
        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }

        Image {
            id: art
            anchors.fill: parent
            source: root.artUrl
            fillMode: Image.PreserveAspectCrop
            // Decoded at 2x for the 1.5 monitor scale; a 600px cover is never
            // held in memory larger than this.
            sourceSize: Qt.size(2 * root.artSize, 2 * root.artSize)
            asynchronous: true
            smooth: true
        }
    }

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
