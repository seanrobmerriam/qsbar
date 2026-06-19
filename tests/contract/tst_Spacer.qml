// tests/contract/tst_Spacer.qml
import QtQuick
import QtTest

TestCase {
    name: "Spacer"

    function test_required_props() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Spacer.qml"));
        if (c.status === Component.Error) {
            fail("Spacer.qml failed to load: " + c.errorString());
            return;
        }
        var ok = c.createObject(null, { width: 24 });
        verify(ok !== null, "should instantiate with width");
        if (ok) {
            compare(ok.implicitWidth, 24);
            ok.destroy();
        }
    }
}
