// examples/modules/Weather.qml
//
// Sample custom module demonstrating the module contract:
//
//   required properties:
//     - moduleConfig (the {type, widget?, ...} object from config)
//     - dispatcher (Bar/ClickDispatcher instance)
//
//   reactive outputs:
//     - text (string)
//
// Conforms to contracts/module-interface.md. Loads Open-Meteo
// (https://open-meteo.com/) for the configured latitude / longitude.

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Theme
import qs.Bar as Bar

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    // --- Configured widget defaults -------------------------------------

    readonly property real lat: (moduleConfig && moduleConfig.widget
        && typeof moduleConfig.widget.lat === "number") ? moduleConfig.widget.lat : 47.6062
    readonly property real lon: (moduleConfig && moduleConfig.widget
        && typeof moduleConfig.widget.lon === "number") ? moduleConfig.widget.lon : -122.3321

    readonly property string url: "https://api.open-meteo.com/v1/forecast"
        + "?latitude=" + lat + "&longitude=" + lon
        + "&current=temperature_2m,weather_code"

    // --- Reactive outputs -----------------------------------------------

    readonly property real temperature: {
        if (!_lastJson) return NaN;
        try { return _lastJson.current && _lastJson.current.temperature_2m; }
        catch (_) { return NaN; }
    }
    readonly property int weatherCode: {
        if (!_lastJson) return -1;
        try { return _lastJson.current && _lastJson.current.weather_code; }
        catch (_) { return -1; }
    }
    readonly property string text: {
        if (isNaN(temperature)) return "—";
        return temperature.toFixed(0) + "°C";
    }

    // --- Fetch ----------------------------------------------------------

    property var _lastJson: null

    Process {
        id: fetchProc
        running: false
        command: ["sh", "-c", "curl -sS '" + root.url + "'"]
        stdout: StdioCollector {}
        onExited: function(c) {
            if (c !== 0) return;
            try { root._lastJson = JSON.parse(stdout.text); }
            catch (_) { /* leave _lastJson null */ }
        }
    }

    Timer {
        interval: 15 * 60 * 1000  // 15 minutes
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: fetchProc.running = true
    }

    // --- Visual ---------------------------------------------------------

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: label.implicitWidth + Theme.space.md * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: isNaN(root.temperature) ? Theme.colors.fgMuted : Theme.colors.fg
        font.family: Theme.fonts.family
        font.pixelSize: Theme.fonts.size
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            var a = null;
            if (mouse.button === Qt.LeftButton) a = root.moduleConfig && root.moduleConfig.clickLeft;
            else if (mouse.button === Qt.RightButton) a = root.moduleConfig && root.moduleConfig.clickRight;
            if (a && root.dispatcher) root.dispatcher.dispatch(a);
        }
    }
}
