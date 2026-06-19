// Bar/Bar.qml
//
// Top-level bar component. A `PanelWindow` that reads its config from
// `Config.data.bars[barIndex]`. The shell wires `Variants {
// model: Quickshell.screens }` for per-monitor or a single Loader for
// single-monitor (per FR-051).
//
// Config keys read:
//   - position: top | bottom | left | right
//   - layer:    top | bottom | overlay
//   - exclusiveZone, margin, height, enabled
//   - background.{color, opacity, blur}
//   - modules.{left, center, right}
//
// We resolve the screen target via the `screen` property set by the
// surrounding Variants; in single-instance mode, it falls back to the
// focused screen.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Theme
import qs.Modules as Modules
import qs.Config as Cfg

PanelWindow {
    id: root

    // --- Configuration wiring -------------------------------------------

    // barIndex: which entry in Config.data.bars to consume.
    // screen: the Hyprland screen this instance belongs to (set by the
    //         Variants host in shell.qml).
    required property int barIndex
    property var screen: null

    readonly property var bar: {
        if (!Cfg.Config.ready) return null;
        var bars = Cfg.Config.data.bars || [];
        return bars[Math.min(barIndex, bars.length - 1)] || null;
    }

    readonly property bool enabled: bar && bar.enabled !== false

    // --- Panel positioning ----------------------------------------------

    // Map Bar.position → anchors. "top" / "bottom" / "left" / "right".
    anchors {
        top: bar && bar.position === "top"
        bottom: bar && bar.position === "bottom"
        left: bar && bar.position === "left"
        right: bar && bar.position === "right"
    }

    margins {
        top: (bar && (bar.position === "top" || bar.position === "left" || bar.position === "right"))
              ? (bar.margin || 0) : 0
        bottom: (bar && (bar.position === "bottom" || bar.position === "left" || bar.position === "right"))
              ? (bar.margin || 0) : 0
        left: (bar && (bar.position === "left" || bar.position === "top" || bar.position === "bottom"))
              ? (bar.margin || 0) : 0
        right: (bar && (bar.position === "right" || bar.position === "top" || bar.position === "bottom"))
              ? (bar.margin || 0) : 0
    }

    exclusiveZone: bar ? (bar.exclusiveZone || 0) : 0

    aboveWindows: bar && bar.layer === "overlay"
    // `WlrLayers` mapping: top→top, bottom→bottom, overlay→overlay. The
    // `aboveWindows` shorthand covers the common case; for full control,
    // use `WlrLayer.namespace` (Quickshell extension).

    visible: enabled

    // --- Geometry --------------------------------------------------------

    implicitHeight: bar ? bar.height : 30
    implicitWidth: bar && (bar.position === "left" || bar.position === "right")
                   ? bar.height : -1

    color: "transparent"  // background is rendered by BarBackground

    // --- Content ---------------------------------------------------------

    BarBackground {
        anchors.fill: parent
        background: root.bar ? root.bar.background : null
    }

    BarLayout {
        anchors.fill: parent
        anchors.margins: Theme.space.sm
        modules: root.bar ? (root.bar.modules || { left: [], center: [], right: [] }) : null
        barPosition: root.bar ? root.bar.position : "top"
        screen: root.screen
        dispatcher: root.dispatcher
    }

    // Per-bar click dispatcher (FR-014, T057). One instance shared
    // across every ModuleSlot in this bar; modules call
    // `dispatcher.dispatch({ type, ... })` on click / wheel.
    property var dispatcher: Qt.createQmlObject('
        import QtQuick
        import qs.Bar as Bar
        QtObject {
            function dispatch(action) { return Bar.ClickDispatcher.dispatch(action); }
        }
    ', root, "BarDispatcher")
}
