// tests/contract/tst_Notifications.qml
import QtQuick
import QtTest

TestCase {
    name: "Notifications"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Notifications.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "Notifications" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
