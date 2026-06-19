// Services/Power.qml
// Wrapper over Quickshell.Services.UPower.UPower with batteries,
// displayDevice, and onBattery.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var batteries: {
        if (!UPower) return [];
        return UPower.batteries || UPower.devices || [];
    }

    readonly property var displayDevice: {
        if (!UPower) return null;
        return UPower.displayDevice || (batteries.length > 0 ? batteries[0] : null);
    }

    readonly property bool onBattery: {
        if (!UPower) return false;
        return !!(UPower.onBattery);
    }
}
