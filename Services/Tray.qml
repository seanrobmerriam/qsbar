// Services/Tray.qml
//
// Thin wrapper over Quickshell.Services.SystemTray.SystemTray exposing
// `items` as a reactive list. We do not call `registerHost()` here —
// Quickshell's SNI host is set up at the shell level via the
// `Quickshell.service` config block; the bar only consumes the items.
//
// Per FR-037: subscriptions are torn down on `Component.onDestruction`.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    readonly property var _tray: SystemTray

    readonly property var items: {
        if (!SystemTray) return [];
        return SystemTray.items || [];
    }

    Component.onDestruction: {
        // Quickshell handles SystemTray teardown; nothing for us to do.
    }
}
