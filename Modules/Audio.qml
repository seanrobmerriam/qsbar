// Modules/Audio.qml
// Volume indicator. Renders the current volume % and a coloured bar.
// scrollUp / scrollDown default to setVolume(±5).

import QtQuick
import qs.Theme
import qs.Bar as Bar
import qs.Utils

Item {
    id: root

    required property var moduleConfig
    required property var dispatcher

    readonly property string sinkName: {
        if (typeof Services === "undefined" || !Services.Audio) return "";
        var s = Services.Audio.defaultSink;
        return s ? (s.name || s.description || "") : "";
    }

    readonly property int volume: {
        if (typeof Services === "undefined" || !Services.Audio) return 0;
        return Services.Audio.volume;
    }

    readonly property bool muted: {
        return typeof Services !== "undefined" && Services.Audio && Services.Audio.muted;
    }

    readonly property color _barColor: {
        if (muted) return Theme.colors.audioMuted;
        if (volume < 33) return Theme.colors.audioLow;
        return Theme.colors.audioHigh;
    }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: layout.implicitWidth + Theme.space.md * 2

    Row {
        id: layout
        anchors.centerIn: parent
        spacing: Theme.space.sm

        Text {
            text: root.muted ? "🔇" : "🔊"
            color: root._barColor
            font.family: Theme.fonts.family
            font.pixelSize: Theme.fonts.size
        }
        Text {
            text: root.muted ? "muted" : (Formatter.formatPercent(root.volume))
            color: root.muted ? Theme.colors.fgMuted : Theme.colors.fg
            font.family: Theme.fonts.familyMono
            font.pixelSize: Theme.fonts.sizeSmall
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) {
            var a = null;
            if (mouse.button === Qt.LeftButton) a = root.moduleConfig && root.moduleConfig.clickLeft;
            else if (mouse.button === Qt.MiddleButton) a = root.moduleConfig && root.moduleConfig.clickMiddle;
            else if (mouse.button === Qt.RightButton) a = root.moduleConfig && root.moduleConfig.clickRight;
            if (a && root.dispatcher) root.dispatcher.dispatch(a);
        }
        onWheel: function(wheel) {
            var up = (wheel.angleDelta.y || 0) > 0;
            var a = up
                ? (root.moduleConfig && root.moduleConfig.scrollUp)
                : (root.moduleConfig && root.moduleConfig.scrollDown);
            if (a && root.dispatcher) {
                root.dispatcher.dispatch(a);
            } else {
                // Default: ±5%.
                if (typeof Services !== "undefined" && Services.Audio) {
                    Services.Audio.setVolume(up ? 5 : -5);
                }
            }
        }
    }
}
