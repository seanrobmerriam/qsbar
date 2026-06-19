// Bar/ModuleSlot.qml
//
// One slot in the bar layout. Resolves the module's `type` to a QML
// file under `Modules/<Type>.qml` (or, for custom modules, the
// directory in `Config.data.customModulesPath`) and instantiates it
// with the module's config (widget, click handlers, etc.).
//
// On a bad / unknown type: render a visible placeholder that names the
// type so the user can fix the config. Per FR-025 (module error
// isolation).
//
// Why `Loader.setSource(url, props)` instead of `sourceComponent: comp`
// with forwarding properties on the Loader?
//   1. Loader inherits from Item, which has FINAL `width`/`height`/etc.
//      properties. Declaring forwarding properties of the same name on
//      the Loader fails with "Cannot override FINAL property".
//   2. `required property` declarations on the loaded item must be
//      satisfied at construction time. Loader property forwarding
//      happens AFTER construction, so it does not satisfy
//      `required property`. `setSource(url, props)` passes the props
//      to the constructor and so DOES satisfy them.

import QtQuick
import QtQml
import qs.Modules as ModulesMod
import qs.Theme

Item {
    id: root

    property var module: null
    property string barPosition: "top"
    property var screen: null
    // Click dispatcher, threaded through from the Bar to the loaded
    // module (FR-018). Modules declare `required property var
    // dispatcher`.
    property var dispatcher: null

    // Build the property bag that gets handed to the loaded module's
    // constructor. The set of keys here MUST match the `required
    // property` declarations on the target module exactly — extras
    // cause "Cannot assign to non-existent property" errors.
    //   moduleConfig — every module (user config object)
    //   dispatcher   — every module (click router)
    //   format       — Clock only
    //   width        — Spacer only (FINAL on Item but OK at construct)
    //   monitor      — Workspaces only
    function _propsFor(type) {
        var m = root.module || {};
        var w = m.widget || {};
        var p = {
            moduleConfig: m,
            dispatcher: root.dispatcher
        };
        if (type === "Clock") p.format = w.format || "HH:mm";
        if (type === "Spacer") p.width = (typeof w.width === "number") ? w.width : 0;
        if (type === "Workspaces") p.monitor = root.screen;
        return p;
    }

    // Map a module type to the file URL of its QML definition.
    // Built-ins live alongside this file at `../Modules/<Type>.qml`.
    // Anything not on this list falls through to the custom-modules
    // directory (FR-046: user-extensible modules).
    function _urlForType(type) {
        if (!type) return "";
        switch (type) {
            case "Workspaces":
            case "WindowTitle":
            case "Clock":
            case "Cpu":
            case "Ram":
            case "Battery":
            case "Audio":
            case "Mpris":
            case "Tray":
            case "PowerProfile":
            case "Network":
            case "Bluetooth":
            case "Notifications":
            case "Spacer":
            case "Group":
                return Qt.resolvedUrl("../Modules/" + type + ".qml");
            default:
                return _customUrlForType(type);
        }
    }

    function _customUrlForType(type) {
        try {
            var cfg = (typeof Config !== "undefined" && Config.data
                && Config.data.customModulesPath) || "";
            if (!cfg) return "";
            // Strip a leading "file://" so we can build a clean URL.
            var path = cfg.replace(/^file:\/\//, "");
            return "file://" + path + "/" + type + ".qml";
        } catch (e) {
            console.warn("ModuleSlot: custom module \"" + type
                + "\" URL resolution failed: " + e);
            return "";
        }
    }

    // Reload the loader when the module's identity or any forwarded
    // input changes. Cheap when nothing actually changed — setSource
    // is idempotent.
    function _reload() {
        if (!root.module || !root.module.type) {
            moduleLoader.source = "";
            return;
        }
        var url = _urlForType(root.module.type);
        if (!url) {
            moduleLoader.source = "";
            return;
        }
        // setSource(url, properties) hands the property bag to the
        // loaded item's constructor, which is the only mechanism that
        // satisfies `required property` declarations.
        moduleLoader.setSource(url, _propsFor(root.module.type));
    }

    Loader {
        id: moduleLoader
        anchors.fill: parent

        onStatusChanged: if (status === Loader.Error) {
            console.warn("ModuleSlot: failed to load module type \""
                + (root.module ? root.module.type : "?")
                + "\" from " + moduleLoader.source);
        }
    }

    // Error placeholder rendered when the Loader reports an Error
    // status — visible to the user (helps debugging) but never crashes
    // the bar (per FR-025 module error isolation).
    Rectangle {
        anchors.fill: parent
        visible: !!(root.module && moduleLoader.status === Loader.Error)
        color: "#ffdb4b4b"
        radius: 4
        Text {
            anchors.centerIn: parent
            text: root.module ? "[" + root.module.type + "]" : "?"
            color: "#ffffffff"
            font.pixelSize: Theme.fonts.sizeSmall
        }
    }

    // (Re)load on construction and whenever any forwarded input
    // changes. The visible/Loader wiring above takes care of cleanup.
    Component.onCompleted: _reload()
    onModuleChanged: _reload()
    onDispatcherChanged: _reload()
    onScreenChanged: _reload()
}