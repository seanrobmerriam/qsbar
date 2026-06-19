// Bar/ModuleHost.qml
//
// Iterates a section's module list and instantiates each by `type`.
// Unknown types emit a warn + a placeholder (FR-025: module errors
// are isolated — a single bad module doesn't take down the bar).

import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Modules as ModulesMod

Item {
    id: root

    property var section: []            // Module[] from config
    property string barPosition: "top"
    property var screen: null
    // Bar-level dispatcher, threaded into each module.
    property var dispatcher: null

    readonly property bool _vertical:
        barPosition === "left" || barPosition === "right"

    // --- Per-workspace visibility filter (FR-046 / T098 / T100) ----------
    //
    // Drop modules whose `showOnWorkspace` doesn't include the
    // currently-focused workspace, and any module whose
    // `hideOnWorkspace` does. This is a pure function of the config
    // and `Quickshell.Hyprland.focusedWorkspace.id`; we evaluate it
    // reactively so workspace switches update the bar immediately.
    readonly property var _visibleModules: {
        var focusedId = -1;
        try {
            if (typeof Quickshell !== "undefined"
                && Quickshell.Hyprland
                && Quickshell.Hyprland.focusedWorkspace) {
                focusedId = Quickshell.Hyprland.focusedWorkspace.id;
            }
        } catch (_) { /* fall through */ }
        if (!Array.isArray(section)) return [];
        return section.filter(function(m) {
            if (!m) return false;
            if (Array.isArray(m.showOnWorkspace) && m.showOnWorkspace.length > 0
                && m.showOnWorkspace.indexOf(focusedId) < 0) return false;
            if (Array.isArray(m.hideOnWorkspace) && m.hideOnWorkspace.indexOf(focusedId) >= 0) return false;
            return true;
        });
    }

    default property alias _children: holder.children

    Item {
        id: holder
        anchors.fill: parent
        // We use a Repeater for declarative instantiation.
    }

    // Modules sit side-by-side in the section.
    Row {
        id: hRow
        visible: !root._vertical
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: Theme.space.md
        Repeater {
            model: root._visibleModules
            delegate: ModuleSlot {
                module: modelData
                barPosition: root.barPosition
                screen: root.screen
                dispatcher: root.dispatcher
            }
        }
    }

    Column {
        id: vCol
        visible: root._vertical
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        spacing: Theme.space.md
        Repeater {
            model: root._visibleModules
            delegate: ModuleSlot {
                module: modelData
                barPosition: root.barPosition
                screen: root.screen
                dispatcher: root.dispatcher
            }
        }
    }
}
