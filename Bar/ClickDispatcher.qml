// Bar/ClickDispatcher.qml
//
// Routes a click / scroll action from a module to one of five
// handlers (per contracts/click-action.md):
//
//   - hyprlandDispatch → Services.HyprlandMonitor.dispatch(args)
//   - exec             → Quickshell.Io.Process spawning command[]
//   - openUrl          → Qt.openUrlExternally(url)
//   - setVolume        → Services.Audio.setVolume(delta)
//   - menu             → LazyLoader activates the menu popover
//
// Unknown `type` is logged and the action is a no-op (FR-022:
// misconfigured handlers MUST NOT crash the bar).

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // The active menu loader (set by the bar's popover system).
    property var menuLoader: null

    function dispatch(action) {
        if (!action || typeof action !== "object") return;
        switch (action.type) {
            case "hyprlandDispatch":
                _dispatchHyprland(action.args);
                break;
            case "exec":
                _exec(action.command, action.detached);
                break;
            case "openUrl":
                _openUrl(action.url);
                break;
            case "setVolume":
                _setVolume(action.delta);
                break;
            case "menu":
                _openMenu(action.items, action.onClose);
                break;
            default:
                Logger.warn("ClickDispatcher",
                    "unknown action type \"" + action.type + "\" — ignored");
        }
    }

    function _dispatchHyprland(args) {
        if (typeof args !== "string" || args.length === 0) {
            Logger.warn("ClickDispatcher", "hyprlandDispatch: empty args");
            return;
        }
        if (typeof Services === "undefined" || !Services.HyprlandMonitor) {
            Logger.warn("ClickDispatcher", "HyprlandMonitor unavailable");
            return;
        }
        Services.HyprlandMonitor.dispatch(args);
    }

    function _exec(command, detached) {
        if (!Array.isArray(command) || command.length === 0) {
            Logger.warn("ClickDispatcher", "exec: empty command");
            return;
        }
        var proc = Qt.createQmlObject(
            'import QtQuick; import Quickshell.Io; Process { running: true; command: ' +
            JSON.stringify(command) + ' }',
            root);
        // detached=true (default) → we don't track the PID. The child
        // is reparented to PID 1 by Quickshell's process model.
        if (detached === false) {
            // Wait for exit. (Caller-side expectation: this returns
            // synchronously for short-lived commands. v1 ignores the
            // exit code at the dispatcher level — modules can poll
            // their own state if needed.)
        }
    }

    function _openUrl(url) {
        if (typeof url !== "string" || url.length === 0) {
            Logger.warn("ClickDispatcher", "openUrl: empty url");
            return;
        }
        Qt.openUrlExternally(url);
    }

    function _setVolume(delta) {
        if (typeof delta !== "number" || isNaN(delta)) {
            Logger.warn("ClickDispatcher", "setVolume: invalid delta");
            return;
        }
        if (typeof Services === "undefined" || !Services.Audio) {
            Logger.warn("ClickDispatcher", "Audio service unavailable");
            return;
        }
        Services.Audio.setVolume(delta);
    }

    function _openMenu(items, onClose) {
        if (!Array.isArray(items) || items.length === 0) {
            Logger.warn("ClickDispatcher", "menu: empty items");
            return;
        }
        if (menuLoader) {
            menuLoader.active = true;
            menuLoader.items = items;
            menuLoader.onClose = onClose || null;
        }
    }
}
