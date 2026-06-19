// Theme/Theme.qml
//
// Singleton: the single source of truth for all visual tokens.
// Per constitution Principle IV (Consistent User Experience Contract),
// no module is allowed to hard-code hex colors, pixel sizes, or
// animation timings — they all bind to these properties.
//
// 50+ `readonly property` tokens grouped under:
//   colors (19), fonts (7), space (5), radius (4),
//   animations (5), opacity (4).
//
// See contracts/theme-tokens.md for the full catalog.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // --- colors (19 tokens) ----------------------------------------------

    readonly property color bg: "#ee222222"
    readonly property color bgAlt: "#22ffffff"
    readonly property color fg: "#ffeeeeee"
    readonly property color fgMuted: "#aaeeeeee"
    readonly property color accent: "#ff7aa2f7"
    readonly property color urgent: "#fff7768e"
    readonly property color success: "#ff9ece6a"
    readonly property color warning: "#ffe0af68"
    readonly property color error: "#ffdb4b4b"
    readonly property color workspaceActive: accent
    readonly property color workspaceInactive: fgMuted
    readonly property color workspaceUrgent: urgent
    readonly property color audioHigh: accent
    readonly property color audioLow: warning
    readonly property color audioMuted: error
    readonly property color batteryHigh: success
    readonly property color batteryMid: warning
    readonly property color batteryLow: error
    readonly property color batteryCharging: accent

    readonly property var colors: ({
        "bg": bg,
        "bgAlt": bgAlt,
        "fg": fg,
        "fgMuted": fgMuted,
        "accent": accent,
        "urgent": urgent,
        "success": success,
        "warning": warning,
        "error": error,
        "workspaceActive": workspaceActive,
        "workspaceInactive": workspaceInactive,
        "workspaceUrgent": workspaceUrgent,
        "audioHigh": audioHigh,
        "audioLow": audioLow,
        "audioMuted": audioMuted,
        "batteryHigh": batteryHigh,
        "batteryMid": batteryMid,
        "batteryLow": batteryLow,
        "batteryCharging": batteryCharging
    })

    // --- fonts (7 tokens) ------------------------------------------------

    readonly property string family: "Inter"
    readonly property string familyMono: "JetBrains Mono"
    readonly property int size: 12
    readonly property int sizeSmall: 10
    readonly property int sizeLarge: 14
    readonly property int weight: 500
    readonly property int weightBold: 700

    readonly property var fonts: ({
        "family": family,
        "familyMono": familyMono,
        "size": size,
        "sizeSmall": sizeSmall,
        "sizeLarge": sizeLarge,
        "weight": weight,
        "weightBold": weightBold
    })

    // --- space (5 tokens) -------------------------------------------------

    readonly property int xs: 2
    readonly property int sm: 4
    readonly property int md: 8
    readonly property int lg: 12
    readonly property int xl: 20

    readonly property var space: ({
        "xs": xs,
        "sm": sm,
        "md": md,
        "lg": lg,
        "xl": xl
    })

    // --- radius (4 tokens) -----------------------------------------------

    readonly property int radiusSm: 4
    readonly property int radiusMd: 8
    readonly property int radiusLg: 12
    readonly property int radiusPill: 9999

    readonly property var radius: ({
        "sm": radiusSm,
        "md": radiusMd,
        "lg": radiusLg,
        "pill": radiusPill
    })

    // --- animations (5 tokens) -------------------------------------------

    readonly property bool animationsEnabled: true
    readonly property int animationsDuration: 150
    readonly property int animationsDurationFast: 75
    readonly property int animationsDurationSlow: 300
    readonly property int animationsEasing: Easing.OutCubic

    readonly property var animations: ({
        "enabled": animationsEnabled,
        "duration": animationsDuration,
        "durationFast": animationsDurationFast,
        "durationSlow": animationsDurationSlow,
        "easing": animationsEasing
    })

    // --- opacity (4 tokens) ----------------------------------------------

    readonly property real opacityDisabled: 0.4
    readonly property real opacityHover: 0.85
    readonly property real opacityPressed: 0.7
    readonly property real opacityBar: 0.9

    readonly property var opacity: ({
        "disabled": opacityDisabled,
        "hover": opacityHover,
        "pressed": opacityPressed,
        "bar": opacityBar
    })
}
