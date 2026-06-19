# qsbar Configuration Reference

The user config lives at `~/.config/quickshell/qsbar/config.json`.
Override with the `QSBAR_CONFIG` env var.

Top-level keys:

| Key                | Type    | Required | Default  | Description                                   |
|--------------------|---------|----------|----------|-----------------------------------------------|
| `version`          | int     | yes      | —        | Schema version. Must be `1`.                  |
| `theme`            | string  | no       | "default"| One of `default`, `gruvbox-dark`, `nord`, or any file in `Theme/themes/` |
| `themeOverrides`   | object  | no       | `{}`     | Deep-merged on top of the named theme.        |
| `bars`             | array   | yes      | —        | One entry per bar to render.                  |
| `customModulesPath`| string  | no       | `~/.local/share/qsbar/modules` | Where to look for custom modules |
| `debug`            | object  | no       | `{verbose:false}` | Verbose logger switch                 |
| `reduceMotion`     | bool    | no       | `false`  | Disable animations.                           |

## Bar entry

```json5
{
  name: "default",            // identifier, freeform
  position: "top",            // top | bottom | left | right
  layer: "top",               // top | bottom | overlay
  height: 30,
  margin: 0,
  exclusiveZone: true,        // reserve space
  perMonitor: true,           // one PanelWindow per Quickshell.screens entry
  enabled: true,
  background: {
    color: "#ee222222",
    opacity: 0.9,
    blur: false
  },
  modules: {
    left:   [{ type: "Workspaces" }],
    center: [{ type: "WindowTitle" }],
    right:  [
      { type: "Clock", widget: { format: "HH:mm" } },
      { type: "Tray" }
    ]
  }
}
```

## Module entry

```json5
{
  type: "Clock",                          // required
  widget: { format: "HH:mm:ss" },         // optional, depends on module
  clickLeft:  { type: "hyprlandDispatch", args: "exec kitty" },
  clickRight: { type: "menu", items: [] },
  scrollUp:   { type: "setVolume", delta: 5 },
  scrollDown: { type: "setVolume", delta: -5 },
  showOnWorkspace: [3],                   // optional, hide unless focused ws ∈ this list
  hideOnWorkspace: [1, 2]                 // optional, hide if focused ws ∈ this list
}
```

## Click action types

| Type               | Required fields           | Effect                                |
|--------------------|---------------------------|---------------------------------------|
| `hyprlandDispatch` | `args: string`            | Calls `HyprlandMonitor.dispatch(args)` |
| `exec`             | `command: [string, ...]`  | Spawns the command                    |
| `openUrl`          | `url: string`             | Opens in default handler              |
| `setVolume`        | `delta: int`              | Adjusts Pipewire sink volume          |
| `menu`             | `items: [...]`            | Opens a popover menu                  |

## Hot reload

`qsbar` watches the config file via `Quickshell.Io.FileView`. On a
detected change (debounced 100 ms) the new content is parsed; on
success, modules rebind; on failure, the previous good config is kept
and a transient toast is shown.
