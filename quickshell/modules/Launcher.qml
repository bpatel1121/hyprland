import Quickshell
import "../config"
import "../components"

// The Arch chip that opens the launcher — the bar's left bookend,
// `#custom-launcher`:
//
//     color: <frame>; font-size: 16px;
//     padding: 0 12px 0 10px; margin: 3px 2px;
//     background-color: rgba(<frame>, 0.08 / 0.10);
//     text-shadow: 0 0 8px rgba(<frame>, 0.55);            cyberpunk
//     :hover  cyberpunk: color <readout>, glow in <readout>
//             gruvbox:   color <text>, background rgba(<frame>, 0.22)
//
// The hover rule is the one place the two stylesheets diverge in KIND rather
// than in value: a glowing theme answers a hover by changing what glows, a
// matte theme by brightening the lamp behind the glyph. `Theme.glow` is the
// palette's own statement of which kind it is, so it is what picks the hover
// vocabulary here.
//
// Clicking goes through the shell's own IPC rather than a direct call: the
// launcher surface owns its `launcher` IpcHandler, and `qs ipc` is the same
// door hyprland.lua's SUPER+R uses, so the chip and the keybind cannot drift.
Chip {
    id: root

    glyph: Config.get("launcher", "glyph", "󰃃")
    fontSize: Theme.fontSizeAccent

    accent: Theme.frame
    // 0.08 cyberpunk / 0.10 gruvbox in the CSS; the chip tint (0.07 / 0.08) is
    // within a hundredth and keeps the bookend on the same scale as the rest.
    tintColor: Theme.frame
    tintOpacity: Theme.chipOpacity
    glowOpacity: 0.55

    hoverAccent: Theme.glow ? Theme.readout : Theme.text
    hoverTintColor: Theme.frame
    hoverTintOpacity: Theme.glow ? Theme.chipOpacity : 0.22
    hoverGlowOpacity: 0.55

    leftPadding: 10
    rightPadding: 12

    onActivated: Quickshell.execDetached([
        "qs", "ipc", "-p", Paths.shell, "call", "launcher", "toggle"
    ])
}
