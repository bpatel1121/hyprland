//@ pragma UseQApplication

import Quickshell
import "bar"

// Entry point for the QML shell — a SCAFFOLD, not yet the live desktop.
//
// Run it:    qs -p ~/.config/hypr/quickshell
//            qs -p ~/.config/hypr/quickshell -d -n     (daemonize, single instance)
// Stop it:   Ctrl-C, or  pkill -f 'qs -p'
//
// Waybar remains the autostarted bar and is untouched. This shell reserves no
// screen space, so both can be on screen at once while you compare them.
//
// Read next: quickshell/README.md  (what each file is, module-by-module map)
//            docs/qml-migration.md (what switching over would take)
ShellRoot {
    // One bar per monitor. Variants re-evaluates as screens come and go, so a
    // display plugged in later gets a bar without a restart — and the monitor
    // block in hyprland.lua stays generic (output "", mode preferred), which is
    // why nothing here names a specific output either.
    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
