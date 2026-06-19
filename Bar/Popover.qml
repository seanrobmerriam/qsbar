// Bar/Popover.qml
//
// LazyLoader-based popover. A `PopupWindow` that mounts a Component
// on demand. Anchored to the calling module's center-bottom for top
// bars (and equivalent positions for other bar positions).
//
// Per T113: animation duration bound to Theme.animations.duration;
// reduceMotion → duration 0.

import QtQuick
import QtQuick.Window
import Qt.labs.platform as Platform
import Quickshell
import qs.Theme

PopupWindow {
    id: root

    property var sourceComponent: null
    property var sourceItem: null
    property string _anchor: "top"   // top|bottom|left|right

    // The LazyLoader holds the content; toggled by `active`.
    property bool active: false

    visible: active
    width: 360
    height: 280
    color: Theme.colors.bg

    // Anchor relative to sourceItem's screen position.
    onVisibleChanged: if (visible && sourceItem) {
        var p = sourceItem.mapToGlobal(0, 0);
        if (_anchor === "top") {
            // Popover hangs BELOW the source.
            x = p.x + sourceItem.width / 2 - width / 2;
            y = p.y + sourceItem.height + Theme.space.xs;
        } else if (_anchor === "bottom") {
            x = p.x + sourceItem.width / 2 - width / 2;
            y = p.y - height - Theme.space.xs;
        } else if (_anchor === "left") {
            x = p.x + sourceItem.width + Theme.space.xs;
            y = p.y + sourceItem.height / 2 - height / 2;
        } else {
            x = p.x - width - Theme.space.xs;
            y = p.y + sourceItem.height / 2 - height / 2;
        }
    }

    LazyLoader {
        id: contentLoader
        anchors.fill: parent
        active: root.active && root.sourceComponent !== null
        sourceComponent: root.sourceComponent
    }

    // Click-outside-to-close: a transparent fullscreen overlay.
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        z: -1
        onClicked: root.close()
    }

    // Escape-to-close.
    Shortcut {
        sequence: "Escape"
        onActivated: root.close()
        enabled: root.active
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animations.animationsEnabled ? Theme.animations.animationsDuration : 0
            easing.type: Theme.animations.animationsEasing
        }
    }

    function open(component, item, anchor) {
        sourceComponent = component;
        sourceItem = item;
        if (anchor) _anchor = anchor;
        active = true;
        opacity = 1;
    }

    function close() {
        opacity = 0;
        active = false;
    }
}
