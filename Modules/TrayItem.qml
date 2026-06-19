// Modules/TrayItem.qml
//
// Single tray item: icon + left/right-click action routing.

import QtQuick
import qs.Theme
import qs.Utils
import qs.Bar as Bar

Item {
    id: root

    required property var item
    required property var moduleConfig
    required property var dispatcher

    readonly property string _iconName: {
        // SNI items expose IconThemePath + IconName. We prefer IconName
        // resolved through IconResolver; if it returns a URL that
        // fails to load, the Image element will fall back gracefully.
        if (!item) return "";
        if (item.IconName) return IconResolver.resolve(item.IconName);
        if (item.iconName) return IconResolver.resolve(item.iconName);
        return IconResolver.resolve("tray");
    }

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: implicitHeight

    Image {
        id: img
        anchors.fill: parent
        anchors.margins: Theme.space.xs
        source: root._iconName
        fillMode: Image.PreserveAspectFit
        smooth: true
        sourceSize.width: width
        sourceSize.height: height
        asynchronous: true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
            var a = null;
            if (mouse.button === Qt.LeftButton) {
                // Default: invoke the SNI item's Activate method.
                if (root.dispatcher && root.moduleConfig && root.moduleConfig.clickLeft) {
                    a = root.moduleConfig.clickLeft;
                } else if (root.item && (root.item.activate || root.item.Activate)) {
                    var fn = root.item.activate || root.item.Activate;
                    try { fn.call(root.item); return; } catch (_) { /* fall through */ }
                }
            } else if (mouse.button === Qt.RightButton) {
                if (root.dispatcher && root.moduleConfig && root.moduleConfig.clickRight) {
                    a = root.moduleConfig.clickRight;
                } else if (root.item && (root.item.secondaryActivate || root.item.SecondaryActivate)) {
                    var fn2 = root.item.secondaryActivate || root.item.SecondaryActivate;
                    try { fn2.call(root.item); return; } catch (_) { /* fall through */ }
                }
            } else if (mouse.button === Qt.MiddleButton) {
                a = root.moduleConfig && root.moduleConfig.clickMiddle;
            }
            if (a && root.dispatcher) root.dispatcher.dispatch(a);
        }
    }
}
