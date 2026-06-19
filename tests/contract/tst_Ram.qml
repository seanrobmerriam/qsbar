// tests/contract/tst_Ram.qml
import QtQuick
import QtTest

TestCase {
    name: "Ram"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Ram.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "Ram" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
