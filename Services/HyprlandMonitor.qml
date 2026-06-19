// Services/HyprlandMonitor.qml
//
// Thin wrapper over `Quickshell.Hyprland.Hyprland` exposing the
// properties the bar binds to. `available` is true when the Hyprland
// IPC socket is present (so the bar degrades gracefully — FR-061).
//
// Per FR-030, this is the SOLE path by which the bar reads
// Hyprland state — modules MUST NOT bind to Quickshell.Hyprland
// directly (per module-interface.md).

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

QtObject {
    id: root

    readonly property var hyprland: Hyprland

    readonly property bool available: {
        // Hyprland's `Hyprland` singleton is itself only present when
        // running under Hyprland. We expose `available` as a stable
        // boolean for downstream bindings.
        return typeof Hyprland !== "undefined";
    }

    readonly property var workspaces: {
        if (!available) return [];
        var all = Hyprland.workspaces || [];
        // Filter per-monitor in callers; expose the full list here.
        return all;
    }

    readonly property var focusedWorkspace: {
        if (!available) return null;
        return Hyprland.focusedWorkspace || null;
    }

    readonly property var monitors: {
        if (!available) return [];
        return Hyprland.monitors || [];
    }

    readonly property var focusedMonitor: {
        if (!available) return null;
        return Hyprland.focusedMonitor || null;
    }

    readonly property var activeToplevel: {
        if (!available) return null;
        return Hyprland.activeToplevel || null;
    }

    function workspacesOnMonitor(monitor) {
        if (!available) return [];
        var all = Hyprland.workspaces || [];
        if (!monitor) return all;
        var mid = monitor.id !== undefined ? monitor.id : monitor.name;
        return all.filter(function(ws) { return ws.monitor === mid; });
    }

    function dispatch(cmd) {
        if (!available) {
            Logger.warn("HyprlandMonitor", "dispatch(\"" + cmd + "\") skipped — Hyprland unavailable");
            return;
        }
        Hyprland.dispatch(cmd);
    }
}
