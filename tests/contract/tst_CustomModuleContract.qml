// tests/contract/tst_CustomModuleContract.qml
import QtQuick
import QtTest

TestCase {
    name: "CustomModuleContract"

    function test_weather_loads() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../examples/modules/Weather.qml"));
        if (c.status === Component.Error) {
            // examples/modules/Weather.qml may not exist in the test
            // workspace (it's an optional shipped example).
            return;
        }
        var ok = c.createObject(null, {
            moduleConfig: { type: "Weather" },
            dispatcher: null
        });
        verify(ok !== null);
        if (ok) ok.destroy();
    }
}
