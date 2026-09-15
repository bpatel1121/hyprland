import "../components"

// The soundwave fused onto the media chip.
//
// STREAMING, not polled: intervalSec 0 keeps scripts/waybar-cava.sh running for
// the life of the shell, and it pushes a frame whenever the spectrum changes
// (deduping identical frames itself). It emits empty text in silence, so the
// wave exists only while sound does.
//
// The script renders cava's raw output as block glyphs rather than relying on a
// build flag, which is exactly why it ports here untouched.
ScriptChip {
    script: "waybar-cava.sh"
    intervalSec: 0
    // Fused to the media chip: no padding on the side that meets it.
    horizontalPadding: 2
}
