// Config/Config.qml
//
// Singleton owning the user config file. Reads
// `~/.config/quickshell/qsbar/config.json` (override via `QSBAR_CONFIG`),
// hot-reloads on save via `Quickshell.Io.FileView`, and exposes the
// parsed object as `Config.data`.
//
// Behaviour:
//   - On first run with no config: seed from `examples/starter-config.json5`
//     (FR-004: "if missing, copy starter to user config dir and load it").
//   - On parse error: keep the previous good `Config.data` in memory
//     and emit `loadError(msg, line, col)` (FR-060).
//
// Per spec FR-002..FR-005.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Utils
import "json5.js" as Json5

Singleton {
    id: root

    // --- File location -----------------------------------------------------

    readonly property string configPath: {
        var env = Quickshell.env("QSBAR_CONFIG");
        if (env && env.length > 0) return env;
        var home = Quickshell.env("HOME") || "/tmp";
        return home + "/.config/quickshell/qsbar/config.json";
    }

    readonly property string starterConfigPath: {
        var qsShare = Quickshell.env("QSBAR_SHARE");
        if (qsShare && qsShare.length > 0) {
            return qsShare + "/examples/starter-config.json5";
        }
        return Quickshell.scriptPath + "/examples/starter-config.json5";
    }

    // --- Parsed config -----------------------------------------------------

    property var data: ({})

    readonly property bool ready: false

    // --- Signals -----------------------------------------------------------

    signal loadError(string message, int line, int col)

    // --- FileView: watches the config file ---------------------------------

    FileView {
        id: fileView
        path: root.configPath
        watchChanges: true
        blockLoading: false
        onFileChanged: root._reload()
        onAdapterChanged: root._reload()
    }

    // 100ms debounce per FR-005.
    Timer {
        id: debounce
        interval: 100
        repeat: false
        onTriggered: root._doReload()
    }

    function _reload() { debounce.restart(); }

    function _doReload() {
        var raw = "";
        try { raw = fileView.text(); } catch (_) { raw = ""; }

        if (raw === undefined || raw === null || raw.length === 0) {
            var seeded = _trySeedFromStarter();
            if (seeded) {
                Logger.info("Config", "seeded missing config from starter-config.json5");
                data = seeded;
                ready = true;
                return;
            }
            Logger.warn("Config",
                "config missing at " + configPath + " and no starter-config found");
            data = {};
            ready = true;
            return;
        }

        try {
            var parsed = Json5.parse(raw);
            data = ConfigModel.validate(parsed);
            ready = true;
        } catch (e) {
            var msg = String(e && e.message ? e.message : e);
            var line = -1, col = -1;
            var lm = msg.match(/position (\d+)/);
            if (lm) line = parseInt(lm[1], 10);
            Logger.warn("Config", "parse error at " + (line >= 0 ? line : "?") + ": " + msg);
            loadError(msg, line, col);
        }
    }

    // --- Starter seed ------------------------------------------------------

    function _trySeedFromStarter() {
        var starterPath = starterConfigPath;
        var raw = "";
        try {
            var comp = Qt.createQmlObject(
                'import Quickshell.Io; FileView { path: "' + starterPath + '" }', root);
            raw = comp.text();
            comp.destroy();
        } catch (_) {
            return null;
        }
        if (!raw || raw.length === 0) return null;
        try {
            var parsed = Json5.parse(raw);
            return ConfigModel.validate(parsed);
        } catch (_) {
            return null;
        }
    }

    Component.onCompleted: _reload()
}
