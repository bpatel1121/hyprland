//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import "config"
import "bar"
import "launcher"
import "osd"
import "session"

// Entry point for the QML shell — THE desktop's shell layer.
//
// hyprland.lua starts it:   qs -p ~/.config/hypr/quickshell -d -n
// Talk to it:               qs ipc -p ~/.config/hypr/quickshell call <target> <fn>
// Stop it:                  pkill -x quickshell
//
// Four surfaces live in this one process, each owning its own windows and IPC
// target: the bar (one per screen), the launcher (`launcher`), the volume and
// brightness OSD (`osd`) and the power menu (`session`). Notifications stay
// with swaync and the lock screen with hyprlock — see docs/qml-migration.md.
//
// Read next: quickshell/README.md  (what each file is, module-by-module map)
ShellRoot {
    // One bar per monitor. Variants re-evaluates as screens come and go, so a
    // display plugged in later gets a bar without a restart — and the monitor
    // block in hyprland.lua stays generic (output "", mode preferred), which is
    // why nothing here names a specific output either.
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    // Each of these picks the focused monitor itself when it opens.
    Launcher {}
    Osd {}
    SessionMenu {}

    // theme-switch.sh calls `theme reload` after repointing themes/current.
    // The FileViews watch the resolved file, not the symlink, so a repoint is
    // invisible to them until asked; settings.json is re-read too, cheaply,
    // so one call is "pick up whatever changed".
    IpcHandler {
        target: "theme"

        function reload(): void {
            Theme.reload();
            Config.reload();
        }
    }
}
