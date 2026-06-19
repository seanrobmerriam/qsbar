// tests/unit/icon-resolver.test.js
//
// Unit tests for Utils/IconResolver.qml.

.pragma library

var R = require("../../Utils/IconResolver.qml");

function testKnownNamesResolve() {
    var audio = R.resolve("audio");
    var network = R.resolve("network");
    var battery = R.resolve("battery");
    return typeof audio === "string" && audio.length > 0
        && typeof network === "string" && network.length > 0
        && typeof battery === "string" && battery.length > 0;
}

function testUnknownReturnsFallback() {
    var fb = R.resolve("nonexistent-icon-zzz");
    return typeof fb === "string" && fb.length > 0;
}

function testEmptyInputHandled() {
    return R.resolve("") === R.resolve("nonexistent-icon-zzz")
        || R.resolve("") === "";
}
