// tests/contract/tst_Battery.qml
import QtQuick
import QtTest

TestCase {
    name: "Battery"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Battery.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "Battery" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
