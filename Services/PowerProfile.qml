// Services/PowerProfile.qml
// Wraps Quickshell.Services.PowerProfile (when available) with a
// fallback that detects via /etc/default/grub is NOT used — pure
// UPower / PowerProfile proxy.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.PowerProfile

Singleton {
    id: root

    readonly property var profiles: {
        if (!PowerProfile) return [];
        return PowerProfile.profiles || [];
    }

    readonly property string current: {
        if (!PowerProfile) return "balanced";
        return PowerProfile.currentProfile || "balanced";
    }

    function setProfile(p) {
        if (!PowerProfile) return;
        if (PowerProfile.setProfile) PowerProfile.setProfile(p);
    }

    function next() {
        if (profiles.length === 0) return;
        var i = profiles.indexOf(current);
        var nextProfile = profiles[(i + 1) % profiles.length];
        setProfile(nextProfile);
    }
}
