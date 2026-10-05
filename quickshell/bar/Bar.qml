import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"

// The bar: three detached islands on one transparent layer-shell surface.
//
// This IS the desktop's bar. hyprland.lua autostarts the shell and waybar is
// gone; waybar/config.jsonc and the themes' waybar/style.css survive only as
// the spec this was matched against. Two properties tie it to the compositor:
//
//   namespace       "qs-hypr-bar" — hyprland.lua's blur layer rule matches
//                   this name, which is what frosts the translucent islands
//                   (the CSS fills were tuned for that blur; without it they
//                   read as flat dark boxes).
//   exclusive zone  left at the default (ExclusionMode.Auto), so the strip is
//                   derived from the anchors, height and top margin — the same
//                   space waybar reserved with `height: 36, margin-top: 8`.
PanelWindow {
    id: root

    // Supplied by the Variants in shell.qml — one Bar per screen.
    required property var modelData
    screen: root.modelData

    WlrLayershell.namespace: "qs-hypr-bar"
    WlrLayershell.layer: WlrLayer.Top

    // Never the `transparent` keyword — the themes' CSS bans it repo-wide
    // because it composites as a black halo on GTK3 layer-shell surfaces. An
    // explicit zero-alpha color says the same thing unambiguously.
    color: "#00000000"

    implicitHeight: Config.height

    anchors {
        left: true
        right: true
        top: Config.atTop
        bottom: !Config.atTop
    }

    // Static analysis cannot resolve this grouped scope: `margins` is declared
    // on the C++ side, so it is reported as an unqualified access even though it
    // binds correctly at runtime. Suppressed narrowly, right here, rather than
    // by turning the `unqualified` category off tree-wide — that category
    // catches real delegate-scope bugs and stays on everywhere else.
    //
    // (A comment line must not START with the linter's name, or it is parsed as
    // a directive and every word in it is read as a category.)
    // qmllint disable unqualified unresolved-type
    margins {
        top: Config.atTop ? Config.marginTop : 0
        bottom: Config.atTop ? 0 : Config.marginBottom
        left: Config.marginLeft
        right: Config.marginRight
    }
    // qmllint enable unqualified unresolved-type

    // --- left island ---------------------------------------------------------
    Island {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: Config.leftModules

            // `required property string modelData` is load-bearing: PanelWindow
            // above already has a `modelData` (the screen, from Variants), and
            // without this declaration the delegate resolves the OUTER one and
            // tries to assign a screen where a module name belongs.
            ModuleLoader {
                required property string modelData
                moduleName: modelData
            }
        }
    }

    // --- center island -------------------------------------------------------
    // The clock lives here ALONE. Nothing variable-width shares the island, so
    // it sits at true screen center and never drifts as a neighbour's text
    // changes width. That is a design rule, not an accident — see docs/bar.md.
    Island {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: Config.centerModules

            ModuleLoader {
                required property string modelData
                moduleName: modelData
            }
        }
    }

    // --- right island --------------------------------------------------------
    Island {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: Config.rightModules

            ModuleLoader {
                required property string modelData
                moduleName: modelData
            }
        }
    }
}
