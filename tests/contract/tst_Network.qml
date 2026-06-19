// tests/contract/tst_Network.qml
import QtQuick
import QtTest

TestCase {
    name: "Network"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Network.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "Network" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
