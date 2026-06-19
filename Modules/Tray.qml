// Modules/Tray.qml
//
// Renders one icon per SNI status-notifier item. Uses
// Services/Tray.items (which wraps Quickshell.Services.SystemTray).
// Left-click → clickLeft action; right-click → clickRight action.
//
// Icon resolution: Utils/IconResolver.qml maps a status-notifier
// icon name to a freedesktop icon-theme path.

import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Utils
import qs.Bar as Bar

Item {
    id: root

    required property var moduleConfig
    required property var dispatcher

    readonly property var items: {
        if (typeof Services !== "undefined" && Services.Tray) {
            return Services.Tray.items || [];
        }
        return [];
    }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: trayRow.implicitWidth

    Row {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.space.xs

        Repeater {
            model: root.items
            delegate: TrayItem {
                item: modelData
                moduleConfig: root.moduleConfig
                dispatcher: root.dispatcher
            }
        }
    }
}
