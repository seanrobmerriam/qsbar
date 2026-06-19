// Config/ConfigModel.qml
//
// Validation, defaults, and unknown-key warnings for the parsed
// Config object. Pure data — no I/O, no UI bindings. Called from
// Config.qml's `_reload()` to produce the validated `Config.data`.

import QtQuick

QtObject {
    // --- Top-level validators ---------------------------------------------

    function validate(parsed) {
        if (!parsed || typeof parsed !== "object") {
            Logger.warn("Config", "config root is not an object; using defaults");
            return defaults();
        }

        // version (required)
        var v = parsed.version;
        if (v !== undefined && v !== 1) {
            Logger.warn("Config",
                "unsupported version " + v + " (expected 1). See CHANGELOG.md for migrations.");
        }

        // bars (required, at least one)
        if (!parsed.bars || !Array.isArray(parsed.bars) || parsed.bars.length === 0) {
            Logger.warn("Config", "at least one bar must be defined; using default");
            parsed.bars = [defaultBar()];
        } else {
            for (var i = 0; i < parsed.bars.length; i++) {
                parsed.bars[i] = validateBar(parsed.bars[i], i);
            }
        }

        // theme / themeOverrides / themes — accepted as-is; ThemeLoader
        // applies the validation per-token.

        // animations / reduceMotion
        if (parsed.animations === undefined) parsed.animations = true;
        if (parsed.reduceMotion === undefined) parsed.reduceMotion = false;

        // debug.verbose
        if (!parsed.debug) parsed.debug = { verbose: false };
        if (parsed.debug.verbose === undefined) parsed.debug.verbose = false;

        // customModulesPath: where to look for user-authored modules
        // (ModuleSlot.qml falls back to this when the type is not
        // built-in).
        if (parsed.customModulesPath === undefined) {
            parsed.customModulesPath = "file://" + (typeof Config !== "undefined"
                && Config.starterConfigPath
                ? Config.starterConfigPath
                : "").replace(/[^/]+$/, "") + "../../share/qsbar/modules";
        }

        return parsed;
    }

    function validateBar(bar, index) {
        if (!bar || typeof bar !== "object") {
            Logger.warn("Config", "bars[" + index + "] is not an object; using defaults");
            return defaultBar();
        }
        if (!bar.id) bar.id = "bar-" + index;
        var validPos = { "top": 1, "bottom": 1, "left": 1, "right": 1 };
        if (!validPos[bar.position]) {
            Logger.warn("Config",
                "bar \"" + bar.id + "\".position \"" + bar.position +
                "\" is not one of top/bottom/left/right; defaulting to \"top\"");
            bar.position = "top";
        }
        var validLayer = { "top": 1, "bottom": 1, "overlay": 1 };
        if (!validLayer[bar.layer]) bar.layer = "top";
        if (bar.exclusiveZone === undefined) bar.exclusiveZone = 30;
        if (bar.margin === undefined) bar.margin = 0;
        if (bar.perMonitor === undefined) bar.perMonitor = true;
        if (bar.enabled === undefined) bar.enabled = true;
        if (bar.height === undefined) bar.height = 30;
        if (bar.height < 16 || bar.height > 64) {
            Logger.warn("Config",
                "bar \"" + bar.id + "\".height " + bar.height +
                " out of range [16, 64]; clamping");
            bar.height = Math.max(16, Math.min(64, bar.height));
        }
        if (!bar.background) bar.background = {};
        if (bar.background.color === undefined) bar.background.color = undefined; // = Theme.colors.bg
        if (bar.background.opacity === undefined) bar.background.opacity = 0.9;
        if (bar.background.blur === undefined) bar.background.blur = false;
        if (!bar.modules) {
            bar.modules = { left: [], center: [], right: [] };
        } else {
            if (!bar.modules.left) bar.modules.left = [];
            if (!bar.modules.center) bar.modules.center = [];
            if (!bar.modules.right) bar.modules.right = [];
        }

        // Validate per-module entries — filter unknown keys, normalize
        // showOnWorkspace / hideOnWorkspace to int arrays.
        bar.modules.left   = _validateModules(bar.modules.left);
        bar.modules.center = _validateModules(bar.modules.center);
        bar.modules.right  = _validateModules(bar.modules.right);

        return bar;
    }

    function _validateModules(list) {
        if (!Array.isArray(list)) return [];
        var knownTypes = {
            Workspaces: 1, WindowTitle: 1, Clock: 1, Cpu: 1, Ram: 1,
            Battery: 1, Network: 1, Bluetooth: 1, Audio: 1, Mpris: 1,
            Tray: 1, PowerProfile: 1, Notifications: 1, Spacer: 1, Group: 1
        };
        var out = [];
        for (var i = 0; i < list.length; i++) {
            var m = list[i];
            if (!m || typeof m !== "object" || !m.type) continue;
            if (!knownTypes[m.type]) {
                Logger.warn("Config",
                    "module entry has unknown type \"" + m.type + "\" — will be resolved at runtime");
                // not dropped; custom modules are allowed
            }
            m.showOnWorkspace = _coerceIntArray(m.showOnWorkspace);
            m.hideOnWorkspace = _coerceIntArray(m.hideOnWorkspace);
            out.push(m);
        }
        return out;
    }

    function _coerceIntArray(v) {
        if (!Array.isArray(v)) return [];
        var out = [];
        for (var i = 0; i < v.length; i++) {
            var n = parseInt(v[i], 10);
            if (!isNaN(n)) out.push(n);
        }
        return out;
    }

    // --- Defaults ----------------------------------------------------------

    function defaults() {
        return {
            version: 1,
            theme: "default",
            themeOverrides: {},
            animations: true,
            reduceMotion: false,
            bars: [defaultBar()],
            themes: {},
            debug: { verbose: false }
        };
    }

    function defaultBar() {
        return {
            id: "main",
            position: "top",
            layer: "top",
            exclusiveZone: 30,
            margin: 0,
            perMonitor: true,
            enabled: true,
            height: 30,
            background: { color: undefined, opacity: 0.9, blur: false },
            modules: { left: [], center: [], right: [] }
        };
    }
}
