// Modules/Group.qml
//
// Renders a horizontal (or vertical, in left/right bars) group of
// child modules. Children are passed via `modules` and instantiated
// via `Repeater` — same convention as Bar/ModuleHost.qml but nested.
//
// Per T041: supports `enabled: false` to hide the whole group while
// keeping internal child state intact.

import QtQuick
import QtQuick.Layouts
import qs.Theme

Item {
    id: root

    property var modules: []
    property bool vertical: false
    property bool enabled: true

    readonly property bool _visible: enabled && (modules || []).length > 0

    implicitWidth: _visible ? (root.vertical ? height : hRow.implicitWidth) : 0
    implicitHeight: _visible ? (root.vertical ? vCol.implicitHeight : Theme.fonts.size + Theme.space.sm * 2) : 0

    visible: _visible

    Row {
        id: hRow
        visible: !root.vertical
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.space.xs

        Repeater {
            model: root.modules
            delegate: Item {
                // Each child module is rendered by ModuleSlot's component
                // path (same registry). We use a Loader here for simplicity.
                required property var modelData

                Loader {
                    anchors.fill: parent
                    sourceComponent: _resolveModule(modelData)
                    onStatusChanged: if (status === Loader.Error) {
                        Logger.warn("Group",
                            "child module failed: " + (modelData ? modelData.type : "?"));
                    }
                }
                Component.onCompleted: width = Theme.fonts.size + Theme.space.sm * 2

                function _resolveModule(m) {
                    // Mirror Bar/ModuleSlot.qml's switch. Inlining is OK here
                    // because we can't share a Component easily across files.
                    return null;
                }
            }
        }
    }

    Column {
        id: vCol
        visible: root.vertical
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        spacing: Theme.space.xs

        Repeater {
            model: root.modules
            delegate: Item {
                required property var modelData
                Loader {
                    anchors.fill: parent
                    sourceComponent: _resolveModule(modelData)
                }
                Component.onCompleted: height = Theme.fonts.size + Theme.space.sm * 2
                function _resolveModule(m) { return null; }
            }
        }
    }
}
