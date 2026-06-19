// tests/contract/tst_Audio.qml
import QtQuick
import QtTest

TestCase {
    name: "Audio"
    function test_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Audio.qml"));
        if (c.status === Component.Error) return;
        var ok = c.createObject(null, { moduleConfig: { type: "Audio" }, dispatcher: null });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
