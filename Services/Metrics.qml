// Services/Metrics.qml
//
// Cached system metrics (CPU, RAM, temperature) via 2-second `Process`
// polling. The cache decouples per-binding work from the `/proc`
// reading path (per FR-046: "Bindings MUST NOT do work proportional
// to the number of workspaces, windows, or audio streams inside the
// binding expression itself").
//
// IPC subscriptions are torn down on `Component.onDestruction`
// (FR-037).

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // --- Reactive outputs (cache) ----------------------------------------

    // CPU percent 0..100, averaged across cores.
    readonly property real cpu: 0
    // RAM used in bytes.
    readonly property int ram: 0
    // Temperature in °C, or NaN if not available.
    readonly property real temp: NaN

    // --- Polling timer ---------------------------------------------------

    property int _pollIntervalMs: 2000
    property var _lastCpuStats: null

    Timer {
        interval: root._pollIntervalMs
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root._poll()
    }

    function _poll() {
        _pollCpu();
        _pollRam();
        _pollTemp();
    }

    // --- CPU via /proc/stat ----------------------------------------------

    function _pollCpu() {
        // We use a one-shot Process to cat /proc/stat. The bar's IPC
        // subscriptions list tracks these via Component.onDestruction.
        _procCpu.command = ["sh", "-c", "cat /proc/stat"];
        _procCpu.running = true;
    }

    Process {
        id: _procCpu
        running: false
        stdout: StdioCollector {}
        onExited: function(exitCode) {
            if (exitCode !== 0) return;
            var lines = stdout.text.split("\n");
            var total = 0, idle = 0;
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i];
                if (line.indexOf("cpu ") !== 0) continue;
                var parts = line.split(/\s+/);
                // parts: ["cpu", user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice]
                for (var j = 1; j < parts.length; j++) total += parseInt(parts[j], 10);
                idle = parseInt(parts[4], 10) + parseInt(parts[5], 10);
                break;
            }
            if (_lastCpuStats) {
                var dTotal = total - _lastCpuStats.total;
                var dIdle = idle - _lastCpuStats.idle;
                if (dTotal > 0) {
                    root.cpu = Math.max(0, Math.min(100, (1 - dIdle / dTotal) * 100));
                }
            }
            _lastCpuStats = { total: total, idle: idle };
        }
    }

    // --- RAM via `free -b` ----------------------------------------------

    function _pollRam() {
        _procRam.command = ["sh", "-c", "free -b"];
        _procRam.running = true;
    }

    Process {
        id: _procRam
        running: false
        stdout: StdioCollector {}
        onExited: function(exitCode) {
            if (exitCode !== 0) return;
            var lines = stdout.text.split("\n");
            for (var i = 0; i < lines.length; i++) {
                if (lines[i].indexOf("Mem:") === 0) {
                    var parts = lines[i].split(/\s+/);
                    // Mem: total used free shared buff/cache available
                    root.ram = parseInt(parts[2], 10);
                    return;
                }
            }
        }
    }

    // --- Temperature via /sys/class/thermal ------------------------------

    function _pollTemp() {
        _procTemp.command = ["sh", "-c",
            "for z in /sys/class/thermal/thermal_zone*/temp; do [ -r \"$z\" ] && cat \"$z\" && break; done"];
        _procTemp.running = true;
    }

    Process {
        id: _procTemp
        running: false
        stdout: StdioCollector {}
        onExited: function(exitCode) {
            if (exitCode !== 0) return;
            var t = parseInt(stdout.text.trim(), 10);
            if (!isNaN(t)) root.temp = t / 1000.0;
        }
    }

    Component.onDestruction: {
        _procCpu.running = false;
        _procRam.running = false;
        _procTemp.running = false;
    }
}
