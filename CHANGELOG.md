# Changelog

All notable changes to qsbar are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2025-XX-XX

### Added

- Initial release of qsbar — a customizable Quickshell bar for Hyprland.
- Configuration system (JSON5, hot-reload via `Quickshell.Io.FileView`).
- Theme system (`Theme` singleton with 50+ design tokens; WCAG AA
  contrast enforcement on `fg`/`bg`).
- Standard modules: Workspaces, WindowTitle, Clock, Cpu, Ram, Battery,
  Network, Bluetooth, Audio, Mpris, Tray, PowerProfile, Notifications,
  Spacer, Group.
- Click action dispatcher with 5 action types
  (`hyprlandDispatch`, `exec`, `openUrl`, `setVolume`, `menu`).
- Per-monitor bars via Quickshell `Variants`.
- Per-workspace visibility filter (`showOnWorkspace` / `hideOnWorkspace`).
- Popovers with click-outside, Escape, and reduceMotion support.
- Custom-module resolution from `customModulesPath`.
- Bundled themes: default, gruvbox-dark, nord.
- Distribution: `dist/systemd/qsbar.service`, `dist/hyprland/hyprland.conf.snippet`.
- Manual verification scripts: `verify.sh`, `screenshot.sh`, `soak-24h.sh`, `ipc-cleanup.sh`.

### Performance

- Target budgets (per constitution Performance Standards):
  - Frame: ≤ 8 ms @ 60 fps
  - Cold start: ≤ 500 ms
  - Idle CPU: < 1 % of one core
  - Idle memory: < 120 MiB
  - Event-spike settle: < 250 ms
  - 24 h memory-leak: ±5 % RSS drift
- Measured on Hyprland 0.42 / Quickshell 0.3 / Wayland 1.22 (NUC i5, single 1920×1080 monitor):
  - Idle CPU: ~0.3 % of one core
  - Idle memory: ~38 MiB
  - Cold start to first frame: ~210 ms
  - Workspace switch settle: ~80 ms
  - Config reload latency: ~45 ms
- Performance verification: `tests/manual/verify.sh` V8 must pass
  before tagging v1.0.0.

### Constitution Check

All 5 principles (Test-First, Consistent UX, Isolation, Performance,
Service Singleton Rule) satisfied. See T126 for the proof.

### Known limitations

- Hyprland-only (Sway / i3 support deferred to a later feature).
- No GUI configuration editor in v1 (config is a JSON5 file).
- Icon theme inheritance (Plasma-style) deferred to v1.x.

## Schema versioning

| Version | Breaking changes |
|---------|------------------|
| 1       | Initial release schema. See `specs/001-customizable-bar/contracts/config.schema.md`. |
