// Utils/Formatter.qml
//
// Pure formatting helpers — unit-testable, no I/O.
//
// Per the constitution's separation (Utils/ holds pure helpers,
// Services/ holds I/O wrappers), this is the home for `formatPercent`,
// `formatBytes`, `formatDuration`.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // 0..100 → "NN%"
    function formatPercent(v) {
        if (typeof v !== "number" || isNaN(v)) return "—";
        return Math.round(v) + "%";
    }

    // Bytes → human-readable (e.g. 1610612736 → "1.5 GB").
    function formatBytes(b) {
        if (typeof b !== "number" || isNaN(b) || b < 0) return "—";
        var units = ["B", "KB", "MB", "GB", "TB", "PB"];
        var i = 0;
        var v = b;
        while (v >= 1024 && i < units.length - 1) { v /= 1024; i++; }
        if (i === 0) return v + " " + units[0];
        if (v >= 100) return v.toFixed(0) + " " + units[i];
        if (v >= 10) return v.toFixed(1) + " " + units[i];
        return v.toFixed(2) + " " + units[i];
    }

    // Seconds → "Hh Mm" / "Mm Ss" / "Ss".
    function formatDuration(seconds) {
        if (typeof seconds !== "number" || isNaN(seconds) || seconds < 0) return "—";
        seconds = Math.floor(seconds);
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var s = seconds % 60;
        if (h > 0) return h + "h " + m + "m";
        if (m > 0) return m + "m " + s + "s";
        return s + "s";
    }
}
