// Modules/Clock.qml
//
// Text clock with a configurable format string. Uses Qt.formatDateTime
// under the hood; default format is "HH:mm".
//
// Reactivity: the underlying `text` re-binds every second via a Timer
// (FR-031: bindings MUST do ≤ 1 unit of work per second).

import QtQuick
import qs.Theme
import qs.Bar as Bar

Item {
    id: root

    required property string format
    required property var moduleConfig
    required property var dispatcher

    readonly property string text: Qt.formatDateTime(new Date(), root.format)

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: label.implicitWidth + Theme.space.md * 2

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            // Re-evaluate `text` by re-assigning — Qt won't re-evaluate
            // an inline `new Date()` automatically, but binding to a
            // dependency forces it.
            root._tickTrigger = root._tickTrigger + 1;
        }
    }
    property int _tickTrigger: 0

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Theme.colors.fg
        font.family: Theme.fonts.family
        font.pixelSize: Theme.fonts.size
        font.weight: Theme.fonts.weight
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
