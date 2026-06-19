# qsbar Theming Reference

qsbar's theme is the single source of truth for visual tokens.
Modules never hard-code colors, fonts, or animation timings — they all
bind to `Theme.*` properties. The shipped theme system has three layers:

1. **`Theme/Theme.qml`** — A QML singleton with 50+ `readonly property`
   tokens. These are the defaults.
2. **`Theme/ThemeLoader.qml`** — Bridges JSON5 overrides from
   `Config.data.themeOverrides` and named themes under `Theme/themes/`
   into the runtime view. Validates per-token: clamps `space.*`,
   `animations.duration`, `opacity.*` to safe ranges; rejects
   unparseable colors; warns on unknown tokens.
3. **Named themes** — `Theme/themes/<name>.json5`. Shipped:
   `default`, `gruvbox-dark`, `nord`.

## Token catalog

### Colors (19 tokens)

| Token               | Default       | Notes                                  |
|---------------------|---------------|----------------------------------------|
| `bg`                | `#ee222222`   | Bar background                         |
| `bgAlt`             | `#22ffffff`   | Alternative background                 |
| `fg`                | `#ffeeeeee`   | Foreground text                        |
| `fgMuted`           | `#aaeeeeee`   | Muted text                             |
| `accent`            | `#ff7aa2f7`   | Brand accent                           |
| `urgent`            | `#fff7768e`   | Attention state                        |
| `success`           | `#ff9ece6a`   | Success state                          |
| `warning`           | `#ffe0af68`   | Warning state                          |
| `error`             | `#ffdb4b4b`   | Error state                            |
| `workspaceActive`   | = `accent`    | Active workspace pill                  |
| `workspaceInactive` | = `fgMuted`   | Inactive workspace pill                |
| `workspaceUrgent`   | = `urgent`    | Urgent workspace pill                  |
| `audioHigh`         | = `accent`    | Audio bar ≥ 33 %                       |
| `audioLow`          | = `warning`   | Audio bar < 33 %                       |
| `audioMuted`        | = `error`     | Audio muted                            |
| `batteryHigh`       | = `success`   | Battery ≥ 50 %                         |
| `batteryMid`        | = `warning`   | Battery 20 % – 49 %                    |
| `batteryLow`        | = `error`     | Battery < 20 %                         |
| `batteryCharging`   | = `accent`    | Battery charging                       |

### Fonts (7 tokens)

| Token         | Default             |
|---------------|---------------------|
| `family`      | `"Inter"`           |
| `familyMono`  | `"JetBrains Mono"`  |
| `size`        | `12`                |
| `sizeSmall`   | `10`                |
| `sizeLarge`   | `14`                |
| `weight`      | `500`               |
| `weightBold`  | `700`               |

### Space (5 tokens) — pixel sizes for gaps / padding

`xs: 2`, `sm: 4`, `md: 8`, `lg: 12`, `xl: 20`.

### Radius (4 tokens) — corner radius in px

`sm: 4`, `md: 8`, `lg: 12`, `pill: 9999`.

### Animations (5 tokens)

| Token             | Default        |
|-------------------|----------------|
| `enabled`         | `true`         |
| `duration`        | `150` ms       |
| `durationFast`    | `75` ms        |
| `durationSlow`    | `300` ms       |
| `easing`          | `Easing.OutCubic` |

### Opacity (4 tokens)

`disabled: 0.4`, `hover: 0.85`, `pressed: 0.7`, `bar: 0.9`.

## Custom theme

Save your overrides to `~/.config/quickshell/qsbar/config.json`:

```json5
{
  theme: "gruvbox-dark",
  themeOverrides: {
    colors: { accent: "#ffb8bb26" },
    fonts:  { size: 14 }
  }
}
```

## WCAG AA contrast

Per FR-012, the `ThemeLoader` enforces a minimum contrast ratio of
4.5:1 between `colors.fg` and `colors.bg`. Overrides that drop below
this threshold are rejected and a warning is logged.
