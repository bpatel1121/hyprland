import Quickshell
import "../config"
import "../components"

// AUR updates via yay — a party popper, because "yay".
//
// Longer interval than Updates on purpose: every check here is a live query to
// the AUR's public RPC rather than a local diff against a synced temp DB.
ScriptChip {
    script: "waybar-updates.sh"
    args: ["aur"]
    intervalSec: Config.get("aur", "intervalSec", 300)

    onActivated: Quickshell.execDetached([
        "wezterm", "start", "--", "sh", "-c", "yay -Sua; read -p done"
    ])
}
