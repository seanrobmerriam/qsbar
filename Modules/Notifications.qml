// Modules/Notifications.qml
// Shows unread count + last notification summary.

import QtQuick
import qs.Theme
import qs.Bar as Bar

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property var list: (typeof Services !== "undefined" && Services.Notifications) ? Services.Notifications.list : []
    readonly property int unread: list.length

    readonly property string summary: {
        if (list.length === 0) return "";
        var last = list[0];
        return last.summary || last.body || "";
    }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: row.implicitWidth + Theme.space.md * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.space.xs

        Text {
            text: "🔔"
            font.pixelSize: Theme.fonts.size
            color: root.unread > 0 ? Theme.colors.accent : Theme.colors.fgMuted
        }
        Text {
            visible: root.unread > 0
            text: root.unread.toString()
            color: Theme.colors.fg
            font.family: Theme.fonts.familyMono
            font.pixelSize: Theme.fonts.sizeSmall
            font.weight: Theme.fonts.weightBold
        }
        Text {
            visible: root.unread > 0
            text: root.summary
            color: Theme.colors.fgMuted
            font.family: Theme.fonts.family
            font.pixelSize: Theme.fonts.sizeSmall
            elide: Text.ElideRight
            maximumLineCount: 1
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
