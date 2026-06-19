// Services/Bluetooth.qml
// Wrapper over Quickshell.Bluetooth with adapters and devices.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var adapters: {
        if (!Quickshell || !Quickshell.Bluetooth) return [];
        return Quickshell.Bluetooth.adapters || [];
    }

    readonly property var devices: {
        if (!Quickshell || !Quickshell.Bluetooth) return [];
        return Quickshell.Bluetooth.devices || [];
    }

    readonly property var connectedDevices: {
        return devices.filter(function(d) { return d.connected === true; });
    }

    function enabled() {
        if (!Quickshell || !Quickshell.Bluetooth) return false;
        return !!Quickshell.Bluetooth.enabled;
    }
    function setEnabled(b) {
        if (!Quickshell || !Quickshell.Bluetooth) return;
        Quickshell.Bluetooth.enabled = !!b;
    }
}
