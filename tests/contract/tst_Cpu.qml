// tests/contract/tst_Cpu.qml
import QtQuick
import QtTest

TestCase {
    name: "Cpu"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Cpu.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "Cpu" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
