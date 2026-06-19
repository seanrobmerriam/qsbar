// Modules/Battery.qml
// Shows battery percentage + charging/discharging state. Colour from
// Theme.colors.batteryHigh/Mid/Low/Charging.

import QtQuick
import qs.Theme
import qs.Bar as Bar
import qs.Utils

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property var battery: {
        if (typeof Services === "undefined" || !Services.Power) return null;
        return Services.Power.displayDevice;
    }

    readonly property int percent: battery ? Math.round(battery.percentage * 100) : -1
    readonly property string state: {
        if (!battery) return "unknown";
        if (battery.state === 1) return "charging";
        if (battery.state === 2 || battery.state === 6) return "discharging";
        if (battery.state === 4) return "full";
        return "unknown";
    }
    readonly property real timeToEmpty: battery && battery.timeToEmpty ? battery.timeToEmpty : 0

    readonly property color _color: {
        if (state === "charging") return Theme.colors.batteryCharging;
        if (percent < 20) return Theme.colors.batteryLow;
        if (percent < 50) return Theme.colors.batteryMid;
        return Theme.colors.batteryHigh;
    }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: row.implicitWidth + Theme.space.md * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.space.xs

        Text {
            text: root.state === "charging" ? "⚡"
                : root.percent < 20 ? "🪫" : "🔋"
            color: root._color
            font.pixelSize: Theme.fonts.size
        }
        Text {
            text: root.percent >= 0 ? (root.percent + "%") : "—"
            color: root._color
            font.family: Theme.fonts.familyMono
            font.pixelSize: Theme.fonts.sizeSmall
        }
        Text {
            visible: root.state === "discharging" && root.timeToEmpty > 0
            text: Formatter.formatDuration(root.timeToEmpty)
            color: Theme.colors.fgMuted
            font.family: Theme.fonts.family
            font.pixelSize: Theme.fonts.sizeSmall
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            var a = null;
            if (mouse.button === Qt.LeftButton) a = root.moduleConfig && root.moduleConfig.clickLeft;
            else if (mouse.button === Qt.MiddleButton) a = root.moduleConfig && root.moduleConfig.clickMiddle;
            else if (mouse.button === Qt.RightButton) a = root.moduleConfig && root.moduleConfig.clickRight;
            if (a && root.dispatcher) root.dispatcher.dispatch(a);
        }
    }
}
