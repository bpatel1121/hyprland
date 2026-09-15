import QtQuick

// Turns a module name from settings.json into its QML file.
//
// "agenda" -> ../modules/Agenda.qml. The indirection is what lets the island
// lists in settings.json be plain strings a user can reorder by hand, with no
// QML edit and no restart — Config watches the file, the Repeater re-runs.
//
// asynchronous: a module that fails to load leaves a hole rather than taking
// the whole bar down with it.
Loader {
    id: root

    required property string moduleName

    readonly property string fileName: root.moduleName === ""
        ? ""
        : root.moduleName.charAt(0).toUpperCase() + root.moduleName.slice(1) + ".qml"

    height: parent ? parent.height : 0
    asynchronous: false
    source: root.fileName === "" ? "" : Qt.resolvedUrl("../modules/" + root.fileName)

    onStatusChanged: {
        if (root.status === Loader.Error)
            console.warn("Bar: no module named '" + root.moduleName
                         + "' (expected quickshell/modules/" + root.fileName + ")");
    }
}
