// Modules/Workspaces.qml
//
// Renders one clickable button per workspace on the bound monitor.
// Reactive: switching workspaces updates the active highlight
// within one frame (per US-1 / FR-051).
//
// Required props:
//   - monitor: Hyprland monitor descriptor (id / name); used to filter
//     the workspace list down to this monitor's workspaces
//
// Click actions: per Module.clickLeft / clickMiddle / clickRight.

import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Bar as Bar

Item {
    id: root

    // --- Configuration --------------------------------------------------

    required property var monitor
    property var moduleConfig: null  // full Module entry from config
    property var dispatcher: null    // Bar/ClickDispatcher

    // --- Reactive data --------------------------------------------------

    readonly property var workspaces: {
        var all = (typeof Services !== "undefined" && Services.HyprlandMonitor)
            ? Services.HyprlandMonitor.workspacesOnMonitor(monitor)
            : [];
        return all;
    }

    readonly property int focusedId: {
        var ws = (typeof Services !== "undefined" && Services.HyprlandMonitor)
            ? Services.HyprlandMonitor.focusedWorkspace
            : null;
        return ws ? ws.id : -1;
    }

    signal clicked(int id)

    // --- Visual --------------------------------------------------------

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: row.implicitWidth

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.space.xs

        Repeater {
            model: root.workspaces
            delegate: WorkspaceButton {
                workspace: modelData
                focused: modelData.id === root.focusedId
                urgent: modelData.id === root.focusedId
                    ? false
                    : (modelData.urgent || modelData.id in
                        (Services.HyprlandMonitor && Services.HyprlandMonitor.urgent
                            ? Services.HyprlandMonitor.urgent
                            : {}))
            }
        }
    }

    // --- Click routing --------------------------------------------------

    MouseArea {
        anchors.fill: parent
        // Click routing lives on the buttons themselves; this is a
        // fallback that catches clicks in inter-button gaps.
        onClicked: function(mouse) {
            // No default action on background — leave clicks to the buttons.
        }
    }

    // Per-Button clickable lives in the WorkspaceButton component.
}
