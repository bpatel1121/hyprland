import Quickshell.Io
import "../config"
import "../components"

// AUR updates via yay — a party popper, because "yay". `#custom-aur`:
//
//     font-weight: bold; padding: 0 10px; margin: 3px 2px;
//     .pending  color: <readout>; background rgba(<readout>, 0.10 / 0.12)
//     .zero     color: rgba(<dormant>, 0.45); background rgba(<dormant>, 0.06)
//
// Same shape as Updates (the CSS had this one in `ok` green; like Pac-Man's
// yellow it was a hue the bar used nowhere else, so pending is the readout
// color here too — the popper glyph is what tells the two apart), and no glow
// for the same reason. Longer interval on purpose: every check here is a live query to the
// AUR's public RPC rather than a local diff against a synced temp DB.
//
// Click opens the yay terminal; its exit re-runs the script, replacing the
// `pkill -RTMIN+9 waybar` the old on-click carried.
ScriptChip {
    id: root

    script: "waybar-updates.sh"
    args: ["aur"]
    intervalSec: Config.get("aur", "intervalSec", 300)

    readonly property bool pending: root.stateClass === "pending"

    bold: true
    glowOpacity: 0
    accent: root.pending ? Theme.readout : Theme.withAlpha(Theme.dormant, 0.45)
    tintColor: root.pending ? Theme.readout : Theme.dormant
    // pending: 0.10 / 0.12 in the CSS (chip tint + 0.03 → 0.10 / 0.11);
    // zero: 0.06 in both themes.
    tintOpacity: root.pending ? Theme.chipOpacity + 0.03 : 0.06

    Process {
        id: upgrade
        command: ["wezterm", "start", "--", "sh", "-c", "yay -Sua; read -p done"]
        onExited: root.refresh()
    }

    onActivated: upgrade.running = true
}
