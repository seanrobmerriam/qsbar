# qsbar Modules Reference

This document describes every built-in module shipped with qsbar, the
required properties each one expects, the reactive outputs they expose,
the default `widget` configuration, and a copy-pasteable custom-module
skeleton.

## Module contract (per `contracts/module-interface.md`)

Every module is a QML `Item` with these `required` properties:

| Property        | Type        | Notes                                       |
|-----------------|-------------|---------------------------------------------|
| `moduleConfig`  | `var`       | The `{type, widget?, ...}` from config.json |
| `dispatcher`    | `var`       | `Bar/ClickDispatcher.qml` instance          |

Optional `required` properties vary per module (e.g. `monitor` on
`Workspaces`, `format` on `Clock`).

Reactive outputs are exposed as `readonly property` so the bar's
`MouseArea` / `WheelHandler` can react via bindings.

## Built-in modules

### Workspaces
- Required: `monitor: var`
- Outputs: `workspaces: list`, `focusedId: int`
- ClickLeft default: focus workspace

### WindowTitle
- Required: —
- Outputs: `title: string`

### Clock
- Required: `format: string` (default `"HH:mm"`)
- Outputs: `text: string`

### Cpu
- Outputs: `percent: int`, `temp: real`

### Ram
- Outputs: `used: int`, `total: int`

### Battery
- Outputs: `percent: int`, `state: string`, `time: string`

### Network
- Outputs: `connection: string`, `online: bool`

### Bluetooth
- Outputs: `enabled: bool`, `label: string`
- ClickLeft default: toggle Bluetooth

### Audio
- Outputs: `sinkName: string`, `volume: int`, `muted: bool`
- scrollUp/scrollDown default: ±5%

### Mpris
- Outputs: `title: string`, `artist: string`, `playing: bool`
- ClickLeft default: playPause

### Tray
- Outputs: `items: list`

### PowerProfile
- Outputs: `profile: string`
- ClickLeft default: cycle profile

### Notifications
- Outputs: `unread: int`, `summary: string`

### Spacer (layout)
- Required: `width: int`

### Group (layout)
- Required: `modules: list`

## Custom module skeleton

```qml
import QtQuick
import qs.Theme
import qs.Bar as Bar

Item {
    id: root
    required property var moduleConfig
    required property var dispatcher

    readonly property string text: "Hello"

    implicitHeight: Theme.fonts.size + Theme.space.sm * 2
    implicitWidth: label.implicitWidth + Theme.space.md * 2

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Theme.colors.fg
        font.family: Theme.fonts.family
        font.pixelSize: Theme.fonts.size
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            var a = null;
            if (mouse.button === Qt.LeftButton) a = root.moduleConfig.clickLeft;
            else if (mouse.button === Qt.RightButton) a = root.moduleConfig.clickRight;
            if (a && root.dispatcher) root.dispatcher.dispatch(a);
        }
    }
}
```

Drop the file under `~/.local/share/qsbar/modules/MyModule.qml` and
add to your config:

```json5
modules: {
  right: [
    { type: "MyModule", widget: { /* ... */ } }
  ]
}
```
