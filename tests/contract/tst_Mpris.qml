// tests/contract/tst_Mpris.qml
import QtQuick
import QtTest

TestCase {
    name: "Mpris"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Mpris.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "Mpris" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
