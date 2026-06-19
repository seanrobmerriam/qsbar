// Modules/Bluetooth.qml
// Shows connected-device count + primary device name.

import QtQuick
import qs.Theme
import qs.Bar as Bar

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property var devices: (typeof Services !== "undefined" && Services.Bluetooth) ? Services.Bluetooth.connectedDevices : []
    readonly property bool enabled: (typeof Services !== "undefined" && Services.Bluetooth) ? Services.Bluetooth.enabled() : false

    readonly property string label: {
        if (!enabled) return "BT off";
        if (devices.length === 0) return "BT";
        if (devices.length === 1) return devices[0].name || "device";
        return devices.length + " devices";
    }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: row.implicitWidth + Theme.space.md * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.space.xs

        Text {
            text: "🅱"
            color: root.enabled ? Theme.colors.accent : Theme.colors.fgMuted
            font.pixelSize: Theme.fonts.size
            font.weight: Theme.fonts.weightBold
        }
        Text {
            text: root.label
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
            else if (mouse.button === Qt.LeftButton && typeof Services !== "undefined" && Services.Bluetooth) {
                Services.Bluetooth.setEnabled(!root.enabled);
            }
        }
    }
}
