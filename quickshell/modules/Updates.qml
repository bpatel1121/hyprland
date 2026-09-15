import Quickshell
import "../config"
import "../components"

// Repo updates — a Pac-Man glyph, Pac-Man yellow, from `checkupdates`.
//
// scripts/waybar-updates.sh owns the retry/timeout logic: an uncapped network
// call inside a bar module is what used to wedge the counter. Unlike the
// watchdogs, this chip STAYS on screen at zero and grays out (class `zero`), so
// the resting bar really is one color.
//
// No `pkill -RTMIN+8` equivalent is needed here — waybar's signal mechanism was
// a workaround for its refusal to respawn an in-flight module. This chip simply
// re-runs on its own interval.
ScriptChip {
    script: "waybar-updates.sh"
    args: ["pacman"]
    intervalSec: Config.get("updates", "intervalSec", 120)

    onActivated: Quickshell.execDetached([
        "wezterm", "start", "--", "sh", "-c", "sudo pacman -Syu; read -p done"
    ])
}
