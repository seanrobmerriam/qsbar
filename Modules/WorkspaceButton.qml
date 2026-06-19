// Modules/WorkspaceButton.qml
//
// Single workspace button — a clickable pill with active / inactive
// / urgent visual states from Theme.

import QtQuick
import qs.Theme
import qs.Bar as Bar

Rectangle {
    id: root

    required property var workspace
    property bool focused: false
    property bool urgent: false
    property var dispatcher: null
    property var moduleConfig: null

    readonly property color _fgColor: {
        if (urgent) return Theme.colors.workspaceUrgent;
        if (focused) return Theme.colors.workspaceActive;
        return Theme.colors.workspaceInactive;
    }
    readonly property real _opacityBg: focused || urgent ? 0.18 : 0.0

    implicitWidth: Theme.fonts.size * 2 + Theme.space.sm * 2
    implicitHeight: Theme.fonts.size + Theme.space.sm
    radius: Theme.radius.radiusMd
    color: Qt.rgba(_fgColor.r, _fgColor.g, _fgColor.b, _opacityBg)
    border.color: _fgColor
    border.width: 1

    Text {
        anchors.centerIn: parent
        text: root.workspace ? (root.workspace.id + 1) : "?"
        color: root._fgColor
        font.family: Theme.fonts.family
        font.pixelSize: Theme.fonts.size
        font.weight: root.focused ? Theme.fonts.weightBold : Theme.fonts.weight
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
            var action = null;
            if (mouse.button === Qt.LeftButton && root.moduleConfig && root.moduleConfig.clickLeft) {
                action = root.moduleConfig.clickLeft;
            } else if (mouse.button === Qt.MiddleButton && root.moduleConfig && root.moduleConfig.clickMiddle) {
                action = root.moduleConfig.clickMiddle;
            } else if (mouse.button === Qt.RightButton && root.moduleConfig && root.moduleConfig.clickRight) {
                action = root.moduleConfig.clickRight;
            }
            if (action && root.dispatcher) {
                root.dispatcher.dispatch(action);
            } else {
                // No click action configured — fall back to focus this
                // workspace. (Per FR-022: no-op is fine when not configured,
                // but a default focus-on-click is the more helpful default.)
                if (mouse.button === Qt.LeftButton && root.workspace) {
                    if (typeof Services !== "undefined" && Services.HyprlandMonitor) {
                        Services.HyprlandMonitor.dispatch(
                            "workspace " + root.workspace.id);
                    }
                }
            }
        }
    }
}
