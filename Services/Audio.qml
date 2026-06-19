// Services/Audio.qml
//
// Wraps Quickshell.Services.Pipewire.Pipewire with a stable interface
// for the Audio module. Exposes:
//   - defaultSink: the active audio sink object
//   - volume: 0..100 (cached from defaultSink.volume)
//   - muted: bool
//   - setVolume(delta: int): change volume by delta (clamped 0..100)
//   - setMute(m: bool): toggle / set mute state
//
// Per FR-037: clean teardown on Component.onDestruction.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var defaultSink: {
        if (!Pipewire) return null;
        var nodes = Pipewire.nodes || [];
        for (var i = 0; i < nodes.length; i++) {
            if (nodes[i].type === "sink" && (nodes[i].isDefault || nodes[i].isDefaultSink)) {
                return nodes[i];
            }
        }
        // Fallback: first sink.
        for (var j = 0; j < nodes.length; j++) {
            if (nodes[j].type === "sink") return nodes[j];
        }
        return null;
    }

    readonly property int volume: {
        if (!defaultSink || typeof defaultSink.volume !== "number") return 0;
        // Pipewire volumes are 0..1 (cubic scale). We expose 0..100 linear.
        var v = Math.round(defaultSink.volume * 100);
        return Math.max(0, Math.min(100, v));
    }

    readonly property bool muted: !!(defaultSink && defaultSink.muted)

    function setVolume(delta) {
        if (typeof delta !== "number" || isNaN(delta)) return;
        if (!defaultSink) return;
        var newVol = Math.max(0, Math.min(100, volume + delta));
        // Pipewire expects 0..1 cubic.
        defaultSink.volume = newVol / 100.0;
    }

    function setMute(m) {
        if (!defaultSink) return;
        defaultSink.muted = !!m;
    }

    Component.onDestruction: {
        // Pipewire manages its own subscriptions; nothing to do here.
    }
}
