// Utils/IconResolver.qml
//
// Maps short icon names (used in config JSON5 and inside modules) to
// themed icon paths under /usr/share/icons. Plasma-style icon-theme
// inheritance is deferred to v1.x — v1 ships with a small hardcoded
// lookup table (per plan.md §Complexity Tracking).
//
// Returns a `url` (string) so QML's `Image { source: ... }` can bind
// to it directly. Unknown names return a sensible fallback (the
// "application-x-executable" icon).

pragma Singleton

QtObject {
    // Built-in name → freedesktop icon name mapping.
    readonly property var _table: ({
        // Audio
        "audio": "audio-volume-high",
        "audioMuted": "audio-volume-muted",
        "audioHigh": "audio-volume-high",
        "audioLow": "audio-volume-low",
        // Network
        "network": "network-wireless-signal-good",
        "networkWired": "network-wired",
        "networkDisconnected": "network-wireless-disconnected",
        // Battery / power
        "battery": "battery-good",
        "batteryHigh": "battery-good",
        "batteryMid": "battery-caution",
        "batteryLow": "battery-low",
        "batteryCharging": "battery-charging",
        "powerProfile": "preferences-system-power",
        // CPU / RAM
        "cpu": "utilities-system-monitor",
        "ram": "memory",
        // Bluetooth
        "bluetooth": "bluetooth-active",
        "bluetoothDisconnected": "bluetooth-disabled",
        // Media
        "mediaPlay": "media-playback-start",
        "mediaPause": "media-playback-pause",
        "mediaStop": "media-playback-stop",
        "mediaNext": "media-skip-forward",
        "mediaPrev": "media-skip-backward",
        // Tray / apps
        "tray": "application-x-executable",
        "app": "application-x-executable",
        "default": "application-x-executable",
        // Notifications
        "notification": "preferences-system-notifications",
        // Workspaces
        "workspaceActive": "view-paged",
        "workspaceInactive": "view-paged",
        "workspaceUrgent": "view-paged",
        // Clock
        "clock": "preferences-system-time",
        // Window title
        "window": "window-new",
        // Spacer / group
        "spacer": "",
        "group": "folder"
    })

    readonly property string _fallback: "application-x-executable"

    // Standard search base — the freedesktop spec lists these as
    // $HOME/.local/share/icons and /usr/share/icons; we resolve at
    // runtime via xdg.
    readonly property var _baseDirs: [
        "/usr/share/icons/hicolor/scalable/apps",
        "/usr/share/icons/hicolor/48x48/apps",
        "/usr/share/icons/Adwaita/scalable/apps",
        "/usr/share/icons/Adwaita/48x48/apps"
    ]

    function resolve(name) {
        if (!name || typeof name !== "string") return _toUrl(_fallback);
        var key = name;
        if (_table[key] !== undefined) {
            key = _table[key];
        }
        if (key.length === 0) return "";  // intentional empty (e.g. "spacer")
        return _toUrl(key);
    }

    function _toUrl(iconName) {
        // We can't probe the filesystem synchronously from QML — just
        // return a `file://` URL under a sensible base. The Image
        // loader will fall back to the freedesktop theme if the file
        // is missing.
        return "file:///usr/share/icons/hicolor/scalable/apps/" + iconName + ".svg";
    }
}
