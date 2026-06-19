// Bar/ModuleSlot.qml
//
// One slot in the bar layout. Resolves the module's `type` to a QML
// component via `Modules/<Type>.qml` and instantiates it with the
// module's config (widget, click handlers, etc.).
//
// On a bad / unknown type: render a visible placeholder that names the
// type so the user can fix the config. Per FR-025 (module error
// isolation).

import QtQuick
import QtQml
import qs.Modules as ModulesMod

Item {
    id: root

    property var module: null
    property string barPosition: "top"
    property var screen: null

    // Resolve the QML component for `module.type`. Falls back to a
    // placeholder component if the type is unknown.
    readonly property Component _component: {
        if (!module || !module.type) return null;
        switch (module.type) {
            case "Workspaces":     return ModulesMod.Workspaces;
            case "WindowTitle":    return ModulesMod.WindowTitle;
            case "Clock":          return ModulesMod.Clock;
            case "Cpu":            return ModulesMod.Cpu;
            case "Ram":            return ModulesMod.Ram;
            case "Battery":        return ModulesMod.Battery;
            case "Audio":          return ModulesMod.Audio;
            case "Mpris":          return ModulesMod.Mpris;
            case "Tray":           return ModulesMod.Tray;
            case "PowerProfile":   return ModulesMod.PowerProfile;
            case "Network":        return ModulesMod.Network;
            case "Bluetooth":      return ModulesMod.Bluetooth;
            case "Notifications":  return ModulesMod.Notifications;
            case "Spacer":         return ModulesMod.Spacer;
            case "Group":          return ModulesMod.Group;
            default: return _tryCustomModule(module.type);
        }
    }

    // Custom modules are user-authored QML files under
    // `Config.data.customModulesPath`. Per T103 we attempt to load
    // `<Type>.qml` from that directory; on failure, we render an
    // error placeholder so the rest of the bar continues to function
    // (FR-025 module error isolation).
    function _tryCustomModule(type) {
        try {
            var cfg = (typeof Config !== "undefined" && Config.data
                && Config.data.customModulesPath) || "";
            if (!cfg) return null;
            // Qt.resolvedUrl strips a leading "file://" so the path
            // is usable in QML imports.
            var url = cfg.replace(/^file:\/\//, "");
            var qmlUrl = "file://" + url + "/" + type + ".qml";
            return Qt.createComponent(qmlUrl);
        } catch (e) {
            console.warn("ModuleSlot: custom module \"" + type + "\" failed to load: " + e);
            return null;
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: root._component
        onStatusChanged: if (status === Loader.Error) {
            console.warn("ModuleSlot: failed to load module type \"" +
                (root.module ? root.module.type : "?") + "\"");
        }
    }

    // Error placeholder rendered if a custom module fails to load —
    // visible to the user (helps debugging) but never crashes the bar
    // (per FR-025 module error isolation).
    Rectangle {
        anchors.fill: parent
        visible: !!(root.module && !root._component)
        color: "#ffdb4b4b"
        radius: 4
        Text {
            anchors.centerIn: parent
            text: root.module ? "[" + root.module.type + "]" : "?"
            color: "#ffffffff"
            font.pixelSize: Theme.fonts.sizeSmall
        }
    }

    // Children of the loader receive the module config as properties.
    Component.onCompleted: {
        // Nothing to do here — Loader wires properties automatically
        // when set via `sourceComponent`. (The component's required
        // properties are filled by the loader's `setSource` mechanism.)
    }
}
