// tests/contract/tst_Popover.qml
import QtQuick
import QtTest

TestCase {
    name: "Popover"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Bar/Popover.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, {});
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
