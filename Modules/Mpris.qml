// Modules/Mpris.qml
// Shows title + artist from active MPRIS player. Default clickLeft
// is playPause, scrollUp=next, scrollDown=prev.

import QtQuick
import qs.Theme
import qs.Bar as Bar

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property var player: {
        return (typeof Services !== "undefined" && Services.Mpris)
            ? Services.Mpris.activePlayer : null;
    }

    readonly property string title: player ? (player.title || "") : ""
    readonly property string artist: player ? (player.artist || "") : ""
    readonly property bool playing: player ? !!player.isPlaying : false

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: layout.implicitWidth + Theme.space.md * 2

    Row {
        id: layout
        anchors.centerIn: parent
        spacing: Theme.space.sm

        Text {
            text: root.playing ? "▶" : "⏸"
            color: Theme.colors.accent
            font.pixelSize: Theme.fonts.sizeSmall
        }
        Text {
            text: root.title || root.artist || "—"
            color: root.title ? Theme.colors.fg : Theme.colors.fgMuted
            font.family: Theme.fonts.family
            font.pixelSize: Theme.fonts.sizeSmall
            elide: Text.ElideRight
            maximumLineCount: 1
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
            if (a && root.dispatcher) {
                root.dispatcher.dispatch(a);
            } else if (mouse.button === Qt.LeftButton && typeof Services !== "undefined" && Services.Mpris) {
                Services.Mpris.playPause();
            }
        }
        onWheel: function(wheel) {
            var up = (wheel.angleDelta.y || 0) > 0;
            var a = up ? (root.moduleConfig && root.moduleConfig.scrollUp)
                       : (root.moduleConfig && root.moduleConfig.scrollDown);
            if (a && root.dispatcher) root.dispatcher.dispatch(a);
            else if (typeof Services !== "undefined" && Services.Mpris) {
                if (up) Services.Mpris.next(); else Services.Mpris.prev();
            }
        }
    }
}
