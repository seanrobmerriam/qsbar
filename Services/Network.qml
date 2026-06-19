// Services/Network.qml
// Wraps Quickshell.Networking with wifi / ethernet / vpn reactive
// properties.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var wifi: {
        if (!Quickshell || !Quickshell.Networking) return null;
        return Quickshell.Networking.wifi || null;
    }

    readonly property var ethernet: {
        if (!Quickshell || !Quickshell.Networking) return null;
        return Quickshell.Networking.ethernet || null;
    }

    readonly property var vpn: {
        if (!Quickshell || !Quickshell.Networking) return null;
        return Quickshell.Networking.vpn || null;
    }
}
