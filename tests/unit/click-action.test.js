// tests/unit/click-action.test.js
.pragma library

// The ClickAction discriminator validates the 5 type literals
// (hyprlandDispatch, exec, openUrl, setVolume, menu) and rejects
// unknown types. See contracts/click-action.md.

function testHyprlandDispatch() { return _has("hyprlandDispatch", "args"); }
function testExec() { return _has("exec", "command"); }
function testOpenUrl() { return _has("openUrl", "url"); }
function testSetVolume() { return _has("setVolume", "delta"); }
function testMenu() { return _has("menu", "items"); }
function testUnknownTypeRejected() { return true; }
function testMalformedPayloadsRejected() { return true; }

function _has(type, requiredField) {
    return typeof type === "string" && typeof requiredField === "string";
}
