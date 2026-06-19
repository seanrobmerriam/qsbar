// Modules/Network.qml
// Shows active connection: WiFi signal strength, ethernet interface,
// or VPN. Left-click default opens network-manager (configurable).

import QtQuick
import qs.Theme
import qs.Bar as Bar

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property var wifi: (typeof Services !== "undefined" && Services.Network) ? Services.Network.wifi : null
    readonly property var ethernet: (typeof Services !== "undefined" && Services.Network) ? Services.Network.ethernet : null

    readonly property string connection: {
        if (wifi && wifi.connected) {
            var s = typeof wifi.signalStrength === "number" ? wifi.signalStrength : 0;
            return "WiFi " + s + "%";
        }
        if (ethernet && ethernet.connected) {
            return "Wired";
        }
        return "Offline";
    }

    readonly property bool online: connection !== "Offline"

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: row.implicitWidth + Theme.space.md * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.space.xs

        Text {
            text: root.online ? "🛜" : "❌"
            color: root.online ? Theme.colors.success : Theme.colors.error
            font.pixelSize: Theme.fonts.size
        }
        Text {
            text: root.connection
            color: root.online ? Theme.colors.fg : Theme.colors.fgMuted
            font.family: Theme.fonts.familyMono
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
        }
    }
}
