// Modules/Cpu.qml
// Shows CPU percent + (optionally) temperature. Bound to Services/Metrics.

import QtQuick
import qs.Theme
import qs.Bar as Bar
import qs.Utils

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property int percent: {
        if (typeof Services === "undefined" || !Services.Metrics) return 0;
        return Math.round(Services.Metrics.cpu);
    }

    readonly property real temp: {
        if (typeof Services === "undefined" || !Services.Metrics) return NaN;
        return Services.Metrics.temp;
    }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: row.implicitWidth + Theme.space.md * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.space.xs

        Text {
            text: "CPU"
            color: Theme.colors.fgMuted
            font.pixelSize: Theme.fonts.sizeSmall
        }
        Text {
            text: Formatter.formatPercent(root.percent)
            color: root.percent > 80 ? Theme.colors.warning : Theme.colors.fg
            font.family: Theme.fonts.familyMono
            font.pixelSize: Theme.fonts.sizeSmall
        }
        Text {
            visible: !isNaN(root.temp)
            text: " · " + root.temp.toFixed(0) + "°"
            color: Theme.colors.fgMuted
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
