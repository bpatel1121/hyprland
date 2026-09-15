import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"

// The bar: three detached islands on one transparent layer-shell surface.
//
// ISOLATION IS THE POINT OF THIS SCAFFOLD. Nothing starts it — no autostart
// line in hyprland.lua, no keybind, no theme-apply.sh hook. It exists only
// while you run `qs -p ~/.config/hypr/quickshell` by hand. Two properties keep
// it from disturbing the waybar it is meant to eventually replace:
//
//   namespace     "qs-hypr-bar", NOT "waybar" — so the existing `waybar-blur`
//                 layer rule in hyprland.lua neither matches nor is affected.
//                 (A matching rule is the documented switch-day change; see
//                 docs/qml-migration.md.)
//   exclusiveZone 0 / ExclusionMode.Ignore — reserves NO screen space, so it
//                 cannot shift a window or fight waybar's reserved strip even
//                 with both bars on screen at once.
PanelWindow {
    id: root

    // Supplied by the Variants in shell.qml — one Bar per screen.
    required property var modelData
    screen: root.modelData

    WlrLayershell.namespace: "qs-hypr-bar"
    WlrLayershell.layer: WlrLayer.Top

    // Claim no space. See the note above.
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

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
