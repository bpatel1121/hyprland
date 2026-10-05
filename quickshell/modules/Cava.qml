import "../config"
import "../components"

// The soundwave fused onto the media chip — `#custom-cava-wave`:
//
//     color: <readout>; background: rgba(<readout>, <chip opacity>);
//     text-shadow: 0 0 8px rgba(<readout>, 0.45);
//     padding: 0 10px 0 2px; margin: 3px 2px 3px 0;
//     border-top-left-radius: 0; border-bottom-left-radius: 0;   fused to #mpris
//     .quiet   color: rgba(<readout>, ~0.2); no glow     resting ridge, lights off
//
// Shared fill, zero gap, squared inner corners: one pill, waves rising out of
// the title. The wave keeps its readout tint even while a Spotify chip beside
// it has gone green — that is what the CSS did, and it is what keeps the
// seam between the two readable as a seam.
//
// STREAMING, not polled: intervalSec 0 keeps scripts/waybar-cava.sh running for
// the life of the shell, and it pushes a frame whenever the spectrum changes
// (deduping identical frames itself). It emits empty text in silence, so the
// wave exists only while sound does; class `quiet` is the constant-width
// resting ridge, class `live` the moving one.
ScriptChip {
    id: root

    script: "waybar-cava.sh"
    intervalSec: 0

    readonly property bool quiet: root.stateClass === "quiet"

    // 0.18 in cyberpunk, 0.20 in gruvbox: one value, the difference is below
    // what the eye separates on a dim ridge.
    accent: root.quiet ? Theme.withAlpha(Theme.readout, 0.2) : Theme.readout
    tintColor: Theme.readout
    glowOpacity: root.quiet ? 0 : 0.45

    leftPadding: 2
    rightPadding: 10
    marginLeft: 0
    squareLeft: true
}
