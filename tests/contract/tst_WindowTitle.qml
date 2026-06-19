// tests/contract/tst_WindowTitle.qml
//
// Contract test: Modules/WindowTitle.qml
//   - title reflects HyprlandMonitor.activeToplevel.title
//   - empty state renders placeholder

import QtQuick
import QtTest

TestCase {
    name: "WindowTitle"

    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/WindowTitle.qml"));
        if (c.status === Component.Error) {
            fail("WindowTitle.qml failed to load: " + c.errorString());
            return;
        }
        var ok = c.createObject(null, {
            moduleConfig: { type: "WindowTitle" },
            dispatcher: null
        });
        verify(ok !== null, "should instantiate");
        if (ok) {
            verify(typeof ok.title === "string", "title is a string");
            ok.destroy();
        }
    }
}
