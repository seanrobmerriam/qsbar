// shell.qml — Quickshell entrypoint for qsbar.
//
// Mounts `Bar/Bar.qml` via `Variants { model: Quickshell.screens }` so
// that one bar instance is created per monitor (matching `perMonitor:
// true` in the default config). For single-monitor setups, the same
// pattern works (Quickshell.screens has length 1).
//
// Launch:
//   quickshell --path /home/sean/qsbar
//   quickshell -c qsbar   # if installed at ~/.config/quickshell/qsbar

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Bar as BarMod
import qs.Config as Cfg
import qs.Theme

ShellRoot {
    id: shell

    Variants {
        id: barsVariants
        model: shell._barsModel
        delegate: BarMod.Bar {
            barIndex: modelData.barIndex
            screen: modelData.screen
        }
    }

    // Derive the (barIndex, screen) matrix from Config.data.bars.
    // Each bar with `perMonitor: true` produces N entries (one per
    // screen). Each bar with `perMonitor: false` produces 1 entry on
    // the focused screen.
    readonly property var _barsModel: {
        if (!Cfg.Config.ready) return [];
        var cfg = Cfg.Config.data || {};
        var bars = cfg.bars || [];
        var screens = (typeof Quickshell !== "undefined" && Quickshell.screens)
            ? Quickshell.screens : [];
        var focused = screens.length > 0 ? screens[0] : null;

        var out = [];
        for (var i = 0; i < bars.length; i++) {
            var b = bars[i];
            if (b.enabled === false) continue;
            if (b.perMonitor === false) {
                out.push({ barIndex: i, screen: focused });
            } else if (screens.length === 0) {
                out.push({ barIndex: i, screen: null });
            } else {
                for (var s = 0; s < screens.length; s++) {
                    out.push({ barIndex: i, screen: screens[s] });
                }
            }
        }
        return out;
    }
}
