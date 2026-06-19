// tests/contract/tst_ClickDispatcher.qml
import QtQuick
import QtTest

TestCase {
    name: "ClickDispatcher"

    function test_dispatches() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Bar/ClickDispatcher.qml"));
        if (c.status === Component.Error) {
            fail("ClickDispatcher.qml failed to load: " + c.errorString());
            return;
        }
        var ok = c.createObject(null, {});
        verify(ok !== null);
        // Exercise dispatch with a malformed action — should be a no-op.
        ok.dispatch({ type: "unknown" });
        ok.dispatch(null);
        if (ok) ok.destroy();
    }
}
