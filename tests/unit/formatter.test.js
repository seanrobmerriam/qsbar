// tests/unit/formatter.test.js
//
// Unit tests for Utils/Formatter.qml. Run with `qmltestrunner`.

.pragma library

var F = require("../../Utils/Formatter.qml");

function testFormatPercent() {
    return F.formatPercent(0)   === "0%"
        && F.formatPercent(50)  === "50%"
        && F.formatPercent(100) === "100%"
        && F.formatPercent(33.7) === "34%"
        && F.formatPercent(NaN) === "—"
        && F.formatPercent(undefined) === "—";
}

function testFormatBytes() {
    return F.formatBytes(0)    === "0 B"
        && F.formatBytes(512)  === "512 B"
        && F.formatBytes(1024) === "1.00 KB"
        && F.formatBytes(1536) === "1.50 KB"
        && F.formatBytes(1048576) === "1.00 MB"
        && F.formatBytes(1610612736) === "1.50 GB";
}

function testFormatDuration() {
    return F.formatDuration(0)   === "0s"
        && F.formatDuration(45)  === "45s"
        && F.formatDuration(60)  === "1m 0s"
        && F.formatDuration(125) === "2m 5s"
        && F.formatDuration(3600) === "1h 0m"
        && F.formatDuration(3661) === "1h 1m";
}
