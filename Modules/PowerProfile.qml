// Modules/PowerProfile.qml
// Shows the current power profile; left-click cycles.

import QtQuick
import qs.Theme
import qs.Bar as Bar

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property string profile: (typeof Services !== "undefined" && Services.PowerProfile) ? Services.PowerProfile.current : "balanced"

    readonly property var _icon: {
        if (profile === "performance") return "⚡";
        if (profile === "power-saver") return "🌱";
        return "⚖️";
    }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: row.implicitWidth + Theme.space.md * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.space.xs

        Text {
            text: root._icon
            color: Theme.colors.accent
            font.pixelSize: Theme.fonts.size
        }
        Text {
            text: root.profile
            color: Theme.colors.fg
            font.family: Theme.fonts.family
            font.pixelSize: Theme.fonts.sizeSmall
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            var a = null;
            if (mouse.button === Qt.LeftButton) a = root.moduleConfig && root.moduleConfig.clickLeft;
            else if (mouse.button === Qt.RightButton) a = root.moduleConfig && root.moduleConfig.clickRight;
            if (a && root.dispatcher) root.dispatcher.dispatch(a);
            else if (mouse.button === Qt.LeftButton && typeof Services !== "undefined" && Services.PowerProfile) {
                Services.PowerProfile.next();
            }
        }
    }
}
