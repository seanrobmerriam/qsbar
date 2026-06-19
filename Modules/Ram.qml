// Modules/Ram.qml
// Shows used / total RAM via Utils.Formatter.formatBytes.

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Theme
import qs.Bar as Bar
import qs.Utils

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property int used: {
        if (typeof Services === "undefined" || !Services.Metrics) return 0;
        return Services.Metrics.ram;
    }

    readonly property int total: _totalMem
    property int _totalMem: 0

    Process {
        id: memTotal
        running: false
        command: ["sh", "-c", "grep MemTotal /proc/meminfo"]
        stdout: StdioCollector {}
        onExited: function(c) {
            if (c !== 0) return;
            var m = stdout.text.match(/MemTotal:\s+(\d+)\s+kB/);
            if (m) root._totalMem = parseInt(m[1], 10) * 1024;
        }
    }
    Component.onCompleted: { memTotal.running = true; }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: row.implicitWidth + Theme.space.md * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.space.xs

        Text {
            text: "RAM"
            color: Theme.colors.fgMuted
            font.pixelSize: Theme.fonts.sizeSmall
        }
        Text {
            text: root.total > 0
                ? (Formatter.formatBytes(root.used) + " / " + Formatter.formatBytes(root.total))
                : Formatter.formatBytes(root.used)
            color: Theme.colors.fg
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
