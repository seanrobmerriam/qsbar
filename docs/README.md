# qsbar

A customizable status bar for Hyprland built on [Quickshell](https://quickshell.org).

`qsbar` reads `~/.config/quickshell/qsbar/config.json`, applies a
JSON5 theme, and renders one `PanelWindow` per monitor with the modules
you configure. Hot-reload is on by default — save the config and the
bar updates within ~100 ms.

## Install

```bash
git clone https://github.com/seanrobmerriam/qsbar ~/.config/quickshell/qsbar
# Add to your Hyprland config:
#   exec-once = quickshell --path ~/.config/quickshell/qsbar
```

Then restart Hyprland, or run `quickshell --path ~/.config/quickshell/qsbar`
in a terminal to launch manually.

## Configure

See [configuration.md](configuration.md) for the complete schema and
[theming.md](theming.md) for the theme system. [modules.md](modules.md)
lists every built-in module and ships a custom-module skeleton.

## Performance

| Metric                     | Target       | Measured |
|----------------------------|--------------|----------|
| Idle CPU                   | < 0.5 %      | TBD      |
| Idle memory (RSS)          | < 50 MB      | TBD      |
| Event-spike settle         | < 1 s        | TBD      |
| Config reload latency      | < 100 ms     | TBD      |

Run `tests/manual/verify.sh` to validate all 9 quickstart scenarios.
Run `tests/manual/soak-24h.sh` for the 24-hour memory-leak gate.

## License

MIT.
