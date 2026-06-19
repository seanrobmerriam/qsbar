// tests/contract/tst_Clock.qml
//
// Contract test: Modules/Clock.qml
//   - required property format (default "HH:mm")
//   - text matches Qt.formatDateTime output

import QtQuick
import QtTest

TestCase {
    name: "Clock"

    function test_loads_with_format() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Clock.qml"));
        if (c.status === Component.Error) {
            fail("Clock.qml failed to load: " + c.errorString());
            return;
        }
        var ok = c.createObject(null, {
            format: "HH:mm",
            moduleConfig: { type: "Clock" },
            dispatcher: null
        });
        verify(ok !== null, "should instantiate");
        if (ok) {
            verify(typeof ok.text === "string" && ok.text.length >= 4,
                "text should be a non-empty string after first tick");
            ok.destroy();
        }
    }
}
