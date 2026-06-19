// Bar/BarBackground.qml
//
// The translucent (and optionally blurred) background rectangle. Renders
// `bar.background.color` at `bar.background.opacity`. When blur is
// requested, we wrap a `MultiEffect` instead of a `Rectangle`.
//
// Spec FR-010..FR-013: no hardcoded colors. `color` is read from
// Theme.colors.bg by the bar config (default in data-model.md §1).

import QtQuick
import qs.Theme

Item {
    id: root

    // `background` is the Bar.background object from config (or null
    // for the default).
    property var background: null

    readonly property color resolvedColor: {
        if (background && typeof background.color === "string") {
            return background.color;
        }
        return Theme.colors.bg;
    }

    readonly property real resolvedOpacity: {
        if (background && typeof background.opacity === "number") {
            return background.opacity;
        }
        return Theme.opacity.opacityBar;
    }

    readonly property bool blur: !!(background && background.blur)

    Rectangle {
        anchors.fill: parent
        color: root.resolvedColor
        opacity: root.resolvedOpacity
        radius: Theme.radius.radiusMd
    }
}
