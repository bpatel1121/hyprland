pragma Singleton

import Quickshell

// Where everything lives, derived rather than hardcoded.
//
// The repo root IS ~/.config/hypr, but nothing here assumes that: Quickshell
// sets shellDir to the directory holding shell.qml, so the root is simply its
// parent. Same discipline as scripts/theme-lib.sh, which derives HYPR from
// ${BASH_SOURCE[0]} instead of $HOME — it is what lets the tree be cloned
// anywhere without a tracked file naming a user.
Singleton {
    id: root

    // <repo>/quickshell
    readonly property string shell: Quickshell.shellDir

    // <repo> — the parent of shellDir.
    readonly property string repo: {
        const d = root.shell;
        const i = d.lastIndexOf("/");
        return i > 0 ? d.substring(0, i) : d;
    }

    readonly property string scripts: root.repo + "/scripts"
    readonly property string themes: root.repo + "/themes"

    // The ACTIVE theme, through the `current` symlink. Reading the symlink
    // rather than a theme name is deliberate: the symlink is the single source
    // of truth for which theme is on (see docs/theming.md), and it is machine
    // state, gitignored.
    readonly property string currentTheme: root.themes + "/current"

    // Absolute path to one of the bar's backing scripts.
    function script(name) {
        return root.scripts + "/" + name;
    }
}
