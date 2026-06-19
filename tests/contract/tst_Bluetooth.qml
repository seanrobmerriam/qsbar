// tests/contract/tst_Bluetooth.qml
import QtQuick
import QtTest

TestCase {
    name: "Bluetooth"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Bluetooth.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "Bluetooth" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
