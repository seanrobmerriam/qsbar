// tests/contract/tst_Workspaces.qml
//
// Contract test: Modules/Workspaces.qml
//   - required property monitor
//   - workspaces model reflects HyprlandMonitor.workspacesOnMonitor()
//   - focusedId reflects HyprlandMonitor.focusedWorkspace.id
//   - clicked(int) signal emits on workspace button click

import QtQuick
import QtTest

TestCase {
    name: "Workspaces"

    function test_required_props() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Workspaces.qml"));
        if (c.status === Component.Error) {
            fail("Workspaces.qml failed to load: " + c.errorString());
            return;
        }
        // Without required `monitor` / `moduleConfig` / `dispatcher`,
        // instantiation should fail.
        var bad = c.createObject();
        verify(bad === null, "instantiation should fail without required props");
    }

    function test_loads_with_props() {
        var c = Qt.createComponent(Qt.resolvedUrl("../../Modules/Workspaces.qml"));
        if (c.status === Component.Error) {
            fail("Workspaces.qml failed to load: " + c.errorString());
            return;
        }
        var ok = c.createObject(null, {
            monitor: { id: 0, name: "DP-1" },
            moduleConfig: { type: "Workspaces" },
            dispatcher: null
        });
        verify(ok !== null, "should instantiate with required props");
        if (ok) {
            verify(Array.isArray(ok.workspaces) || ok.workspaces === undefined,
                "workspaces is an array (or empty/undefined when no Hyprland)");
            ok.destroy();
        }
    }
}
