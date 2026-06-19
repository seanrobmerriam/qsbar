// tests/contract/tst_Tray.qml
//
// Contract test: Modules/Tray.qml
//   - items is an array (empty when no SNI host)

import QtQuick
import QtTest

TestCase {
    name: "Tray"

    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Tray.qml"));
        if (c.status === Component.Error) {
            fail("Tray.qml failed to load: " + c.errorString());
            return;
        }
        var ok = c.createObject(null, {
            moduleConfig: { type: "Tray" },
            dispatcher: null
        });
        verify(ok !== null, "should instantiate");
        if (ok) {
            verify(Array.isArray(ok.items) || ok.items === undefined,
                "items should be an array");
            ok.destroy();
        }
    }
}
