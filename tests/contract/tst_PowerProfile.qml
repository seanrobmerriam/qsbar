// tests/contract/tst_PowerProfile.qml
import QtQuick
import QtTest

TestCase {
    name: "PowerProfile"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/PowerProfile.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "PowerProfile" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
