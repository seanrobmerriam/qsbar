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
import Quickshell

Singleton {
    id: root

    // Levels (ascending severity). Property names must start with a
    // lowercase letter in QML, so we use `levelDebug` / `levelInfo` /
    // `levelWarn` / `levelError` rather than SCREAMING_SNAKE_CASE.
    readonly property int levelDebug: 0
    readonly property int levelInfo: 1
    readonly property int levelWarn: 2
    readonly property int levelError: 3

    function isVerbose() {
        return Config && Config.data && Config.data.debug && Config.data.debug.verbose;
    }

    function _emit(level, levelName, source, message) {
        if (level >= levelWarn || isVerbose()) {
            var line = "[" + new Date().toISOString() + "] ["
                + levelName + "] [" + source + "] " + message;
            if (level >= levelError) console.error(line);
            else if (level >= levelWarn) console.warn(line);
            else console.log(line);
        }
    }

    function debug(source, message) { _emit(levelDebug, "DEBUG", source, message); }
    function info(source, message)  { _emit(levelInfo,  "INFO",  source, message); }
    function warn(source, message)  { _emit(levelWarn,  "WARN",  source, message); }
    function error(source, message) { _emit(levelError, "ERROR", source, message); }
}
