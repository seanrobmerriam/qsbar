// tests/contract/tst_Group.qml
import QtQuick
import QtTest

TestCase {
    name: "Group"

    function test_required_props() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Group.qml"));
        if (c.status === Component.Error) {
            fail("Group.qml failed to load: " + c.errorString());
            return;
        }
        var ok = c.createObject(null, { modules: [], vertical: false });
        verify(ok !== null, "should instantiate with empty modules list");
        if (ok) ok.destroy();
    }
}
