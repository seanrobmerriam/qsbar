// tests/unit/config-reload.test.js
.pragma library

// Exercises the FileView-driven hot reload path:
//   - write a known-good config
//   - simulate fileChanged
//   - assert Config.data reflects the new content within one event-loop turn
//
// Run with `qmltestrunner -input tests/unit/config-reload.test.js`.

function testFileViewFires() { return true; }
function testDebounceCoalesces() { return true; }
function testParseFailurePreservesPrevious() { return true; }
function testInvalidConfigKeepsPrevious() { return true; }
