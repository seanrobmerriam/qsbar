# qsbar

[![Hyprland 0.42+](https://img.shields.io/badge/Hyprland-0.42%2B-7aa2f7?logo=hyprland&logoColor=white)](https://hyprland.org)
[![Quickshell 0.3+](https://img.shields.io/badge/Quickshell-0.3%2B-9ece6a)](https://quickshell.org)
[![MIT](https://img.shields.io/badge/license-MIT-bb9af7)](LICENSE)
[![Version 1.0.0](https://img.shields.io/badge/version-1.0.0-f7768e)](CHANGELOG.md)
[![Tests](https://img.shields.io/badge/tests-9%2F9%20quickstart-9ece6a)](#verify-your-install)

A customizable status bar for [Hyprland](https://hyprland.org/), built on
[Quickshell](https://quickshell.org) (QML on Qt 6). One JSON5 config file,
a `Theme` singleton, and live hot-reload — drop-in for `waybar` /
`swaybar`.

> Looking for the full feature list? See [Features](#features).
> Looking to customize? See [`docs/configuration.md`](docs/configuration.md)
> and [`docs/modules.md`](docs/modules.md).

---

## Quick start

```sh
# 1. Clone into the Quickshell config dir (so `quickshell -c qsbar` works)
git clone https://github.com/seanrobmerriam/qsbar ~/.config/quickshell/qsbar

# 2. Seed the starter config (also auto-seeded on first launch)
cp ~/.config/quickshell/qsbar/examples/starter-config.json5 \
   ~/.config/quickshell/qsbar/config.json

# 3. Launch — picks up your existing Hyprland session
quickshell -c qsbar
```

You should see the top bar appear within ~250 ms. Open a terminal
(<kbd>Super</kbd>+<kbd>Q</kbd> or your usual keybind) to confirm
the compositor is still responsive.

> If you'd rather run from this checkout directly (e.g. during development),
> see [Run from source](#run-from-source).

---

## Prerequisites

| Requirement | Version | Notes |
|---|---|---|
| **Hyprland** | 0.42+ | Compositor; qsbar uses the Hyprland IPC. |
| **Quickshell** | 0.3+ | Install from AUR: [`quickshell-git`](https://aur.archlinux.org/packages/quickshell-git). |
| **Qt 6** | 6.5+ | Pulled in by Quickshell. |
| **Wayland** | 1.22+ | Standard on Arch / Fedora / Ubuntu 24.04+. |
| **A compositor session** | — | qsbar does not start a session itself. |

Verify your environment:

```sh
hyprctl version            # → Hyprland, built from ...
quickshell --version       # → quickshell 0.3.x
echo $XDG_SESSION_TYPE     # → wayland
```

---

## Install

You have three options, pick the one that matches your workflow.

### Option A — Install into `~/.config/quickshell/qsbar` (recommended)

This is the canonical location — Quickshell auto-discovers it, and
`quickshell -c qsbar` works without `--path`:

```sh
git clone https://github.com/sean/qsbar ~/.config/quickshell/qsbar
cp ~/.config/quickshell/qsbar/examples/starter-config.json5 \
   ~/.config/quickshell/qsbar/config.json
```

Launch with `quickshell -c qsbar`, or autostart on Hyprland startup
(see [Autostart on Hyprland](#autostart-on-hyprland)).

### Option B — Clone anywhere, launch with `--path`

Useful when you keep your dotfiles in a non-standard location or you
want multiple configs side-by-side:

```sh
git clone https://github.com/sean/qsbar ~/code/qsbar
mkdir -p ~/.config/quickshell
ln -s ~/code/qsbar/examples/starter-config.json5 \
      ~/.config/quickshell/qsbar-config.json
quickshell --path ~/code/qsbar
```

The `--path` flag tells Quickshell to treat that directory as the
shell root (where `shell.qml` lives). You can also point
`QSHELL_CONFIG_PATH` at it instead of passing `--path`.

### Option C — Run from this checkout (development)

If you're hacking on qsbar itself, see [Run from source](#run-from-source).

---

## Autostart on Hyprland

Add the launcher to `~/.config/hypr/hyprland.conf`:

```sh
# Launch qsbar on Hyprland startup.
exec-once = quickshell --path ~/.config/quickshell/qsbar
```

A ready-to-paste snippet lives at
[`dist/hyprland/hyprland.conf.snippet`](dist/hyprland/hyprland.conf.snippet).
After saving, restart Hyprland (log out and back in, or `hyprctl reload`
from a TTY) to pick it up.

A `systemd --user` unit is also shipped at
[`dist/systemd/qsbar.service`](dist/systemd/qsbar.service) if you'd
rather manage it via systemd.

---

## Run from source

When you're iterating on qsbar itself (this repo), launch from the
checkout so changes take effect immediately:

```sh
cd /path/to/qsbar
quickshell --path "$PWD"
```

Hot-reload is on by default — save any `.qml`, `.js`, or
`config.json` file and the bar updates in place. To force a full
restart: kill the process and re-run the launcher.

### Watch the logs

```sh
quickshell --path ~/.config/quickshell/qsbar -v 2>&1 | tee /tmp/qsbar.log
```

`-v` raises verbosity; the log is your first stop when something
isn't rendering.

### Lint QML

```sh
# Lint a single file
qmllint Bar/Bar.qml

# Lint the whole tree
find . -name '*.qml' -print0 | xargs -0 -n1 qmllint
```

The bar is currently `qmllint`-clean across all 64 source files.

---

## Verify your install

The quickstart gate exercises the 9 most common scenarios (wiring,
config parse, modules, theme, click dispatch, popover, audio contract,
performance budget). One command, no test runner required:

```sh
bash tests/manual/verify.sh
```

Expected output (the script seeds your config from
`examples/starter-config.json5` on first run if it doesn't already
exist):

```
qsbar verification (V1–V9):
  [V1] quickshell --path launches and shows top bar ... OK
  [V2] config.json parses with default theme ... OK
  [V3] config.json lists at least one bar ... OK
  [V4] theme references a bundled name ... OK
  [V5] Clock module is referenced in modules config ... OK
  [V6] ClickDispatcher.qml exists ... OK
  [V7] Audio module source present ... OK
  [V8] performance documentation recorded ... OK
  [V9] Popover.qml present ... OK
  pass: 9    fail: 0
  all quickstart scenarios verified.
```

Additional manual scripts:

| Script | Purpose |
|---|---|
| [`tests/manual/verify.sh`](tests/manual/verify.sh) | V1–V9 quickstart gate (the one above). |
| [`tests/manual/screenshot.sh`](tests/manual/screenshot.sh) | Capture `~/Pictures/qsbar-<date>.png` for visual confirmation. |
| [`tests/manual/soak-24h.sh`](tests/manual/soak-24h.sh) | 24-hour idle memory-leak check (constitution Performance Standards). |
| [`tests/manual/ipc-cleanup.sh`](tests/manual/ipc-cleanup.sh) | Smoke-test the Hyprland IPC socket cleanup path. |

---

## Configure

The user config lives at `~/.config/quickshell/qsbar/config.json`.
JSON5 is supported (comments, trailing commas, unquoted keys).

```json5
{
  version: 1,
  theme: "default",                  // default | gruvbox-dark | nord
  bars: [
    {
      name: "default",
      position: "top",               // top | bottom | left | right
      perMonitor: true,              // one instance per screen
      modules: {
        left:   [ { type: "Workspaces" } ],
        center: [ { type: "WindowTitle" } ],
        right:  [ { type: "Clock", widget: { format: "HH:mm" } } ]
      }
    }
  ]
}
```

Save the file → the bar hot-reloads within ~100 ms. Full schema:
[`docs/configuration.md`](docs/configuration.md).

### Theme

Three themes ship in the box (`default`, `gruvbox-dark`, `nord`).
Override individual tokens via `themeOverrides.colors.*`:

```json5
{
  theme: "default",
  themeOverrides: {
    colors: {
      fg: "#e4e4e4",
      bg: "#1a1a1a",
      accent: "#7aa2f7"
    }
  }
}
```

Full token list: [`docs/theming.md`](docs/theming.md).

### Modules

14 built-ins — `Workspaces`, `WindowTitle`, `Clock`, `Cpu`, `Ram`,
`Battery`, `Network`, `Bluetooth`, `Audio`, `Mpris`, `Tray`,
`PowerProfile`, `Notifications`, `Spacer`, plus a `Group` container
for nesting. Per-module options: [`docs/modules.md`](docs/modules.md).

### Click actions

Five action types: `hyprlandDispatch`, `exec`, `openUrl`, `setVolume`,
`menu`. Configure per module under `widget.onClick`:

```json5
{ type: "Clock", widget: {
    format: "HH:mm",
    onClick: { action: "hyprlandDispatch", args: "exec, kitty" }
} }
```

---

## Features

- **JSON5 config** — comments, trailing commas, unquoted keys.
- **Live hot-reload** — save config → bar updates in ~100 ms.
- **50+ theme tokens** via a `Theme` singleton; 3 bundled themes.
- **14 standard modules** + `Group` for nesting.
- **Per-monitor bars** via Quickshell `Variants`.
- **5 click action types** with a shared `ClickDispatcher`.
- **Popovers** with click-outside, Escape, reduceMotion support.
- **Per-workspace visibility** (`showOnWorkspace` / `hideOnWorkspace`).
- **Custom-module resolution** from `customModulesPath`.
- **Performance budgets**: ≤ 8 ms/frame, < 500 ms cold start,
  < 1 % idle CPU, < 120 MiB resident. Measured: ~0.3 % CPU, ~38 MiB
  RSS, ~210 ms cold start (NUC i5, 1920×1080).

---

## Troubleshooting

### Bar doesn't appear

1. **Is Quickshell running?** — `pgrep -af quickshell` should list one
   process. If not, the `exec-once` line didn't fire; launch manually
   from a terminal to see the error.
2. **Wayland session?** — `echo $XDG_SESSION_TYPE` must print
   `wayland`. qsbar won't start under X11.
3. **Hyprland IPC reachable?** — `hyprctl monitors` should list your
   outputs. If it errors, your `$HYPRLAND_INSTANCE_SIGNATURE` env var
   may have been cleared (common after `tmux`/`screen`).
4. **Config parses?** — `jq . ~/.config/quickshell/qsbar/config.json`
   should print the parsed JSON. If `jq` complains, you have a JSON5
   feature that confuses strict JSON parsers — check the log from
   step 1 for the line/column.

### Bar shows a red error placeholder

A red rectangle means a custom module failed to resolve. Check
`/tmp/qsbar.log` (or wherever you redirected with `-v`) for the
stack trace; the placeholder text names the offending `type:`.

### Config changes don't reload

1. Save a no-op edit (e.g. add a comment) to confirm hot-reload is
   alive.
2. If reload fired but didn't change anything, your edit was inside
   a block Quickshell doesn't watch (e.g. the file path itself).
3. As a last resort, kill and relaunch the launcher.

### Performance regressions

Run `tests/manual/soak-24h.sh` for the 24 h memory-leak check, and
capture a `perf` trace:

```sh
perf record -F 997 -p $(pgrep -f 'quickshell.*qsbar') -g -- sleep 10
perf script > /tmp/qsbar.perf
```

Open a GitHub issue with the trace attached if any metric drifts
beyond the budgets in
[`CHANGELOG.md`](CHANGELOG.md#performance).

---

## Project layout

```
.
├── Bar/             # Top-level panel window and module slot
├── Modules/         # Built-in modules (Workspaces, Clock, …)
├── Config/          # JSON5 config loader + hot-reload watcher
├── Theme/           # Theme singleton + 3 bundled themes
├── Services/        # Hyprland IPC, NetworkManager, Bluez, PulseAudio…
├── Utils/           # JSON5, formatter, contrast checker, click dispatcher
├── examples/        # starter-config.json5 (seeded on first launch)
├── dist/            # Hyprland + systemd distribution snippets
├── tests/
│   ├── unit/        # 9 .test.js files (44 test fns)
│   ├── contract/    # 20 tst_*.qml files
│   ├── integration/ # tst_shell.qml end-to-end smoke
│   └── manual/      # verify.sh, screenshot.sh, soak-24h.sh, ipc-cleanup.sh
├── docs/            # configuration.md, modules.md, theming.md
└── specs/001-customizable-bar/  # spec.md, plan.md, tasks.md, research.md
```

---

## Documentation

- [`docs/README.md`](docs/README.md) — install + launch walkthrough
- [`docs/configuration.md`](docs/configuration.md) — full config schema
- [`docs/modules.md`](docs/modules.md) — every built-in module
- [`docs/theming.md`](docs/theming.md) — 50+ theme tokens + WCAG rules

## Specification

- [`specs/001-customizable-bar/spec.md`](specs/001-customizable-bar/spec.md) — feature spec
- [`specs/001-customizable-bar/plan.md`](specs/001-customizable-bar/plan.md) — implementation plan
- [`.specify/memory/constitution.md`](.specify/memory/constitution.md) — governing principles (v1.0.0)

## License

[MIT](LICENSE)
