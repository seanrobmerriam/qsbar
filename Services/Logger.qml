// Services/Logger.qml
//
// Leveled stderr logger. Emits
//   [<ISO timestamp>] [<LEVEL>] [<source>] <message>
// for each call. Gated by `Config.data.debug.verbose` — non-verbose
// mode suppresses DEBUG lines but always shows WARN and ERROR.
//
// Per FR-062 (errors MUST log with module + source + line context).

pragma Singleton
import QtQuick

Singleton {
    id: root

    // Levels (ascending severity).
    readonly property int LEVEL_DEBUG: 0
    readonly property int LEVEL_INFO: 1
    readonly property int LEVEL_WARN: 2
    readonly property int LEVEL_ERROR: 3

    function isVerbose() {
        return Config && Config.data && Config.data.debug && Config.data.debug.verbose;
    }

    function _emit(level, levelName, source, message) {
        if (level >= LEVEL_WARN || isVerbose()) {
            var line = "[" + new Date().toISOString() + "] ["
                + levelName + "] [" + source + "] " + message;
            if (level >= LEVEL_ERROR) console.error(line);
            else if (level >= LEVEL_WARN) console.warn(line);
            else console.log(line);
        }
    }

    function debug(source, message) { _emit(LEVEL_DEBUG, "DEBUG", source, message); }
    function info(source, message)  { _emit(LEVEL_INFO,  "INFO",  source, message); }
    function warn(source, message)  { _emit(LEVEL_WARN,  "WARN",  source, message); }
    function error(source, message) { _emit(LEVEL_ERROR, "ERROR", source, message); }
}
