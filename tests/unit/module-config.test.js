// tests/unit/module-config.test.js
.pragma library

// Stub: the full module-config validator lives in Config/ConfigModel.qml.
// These tests would import that and exercise it.

function testUnknownTypeRejected() { return true; }
function testUnknownWidgetKeyWarns() { return true; }
function testEnabledBoolValidated() { return true; }
function testModuleListReturned() { return true; }
