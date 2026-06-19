// Services/Notifications.qml
// Wraps Quickshell.Services.Notifications with a list, an unread
// count, and a dismiss helper.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: root

    readonly property var list: {
        if (!Notifications) return [];
        return Notifications.list || [];
    }

    readonly property int unread: list.length

    function dismiss(id) {
        if (!Notifications) return;
        if (Notifications.dismiss) Notifications.dismiss(id);
    }
}
