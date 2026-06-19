// Modules/WindowTitle.qml
//
// Shows the title of the currently-focused Hyprland toplevel. Empty
// state shows a placeholder from Theme.fonts.family.
//
// Per FR-031: this binding is ≤ 1 lookup per change (we read
// HyprlandMonitor.activeToplevel.title, no work proportional to
// the toplevel count).

import QtQuick
import qs.Theme
import qs.Bar as Bar

Item {
    id: root

    required property var moduleConfig
    required property var dispatcher

    readonly property string title: {
        if (typeof Services === "undefined" || !Services.HyprlandMonitor) return "";
        var tl = Services.HyprlandMonitor.activeToplevel;
        if (!tl) return "";
        return tl.title || tl.class || "";
    }

    readonly property bool _isEmpty: title.length === 0

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: label.implicitWidth + Theme.space.md * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: root._isEmpty ? "—" : root.title
        color: root._isEmpty ? Theme.colors.fgMuted : Theme.colors.fg
        font.family: root._isEmpty ? Theme.fonts.family : Theme.fonts.familyMono
        font.pixelSize: Theme.fonts.size
        font.weight: Theme.fonts.weight
        elide: Text.ElideRight
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
