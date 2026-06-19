// Theme/ThemeLoader.qml
//
// Bridges the user's `themeOverrides` (and named themes under
// `themes[<name>]`) into the Theme singleton's tokens.
//
// Pure data manipulation — does not touch Theme.qml's properties
// directly (they are `readonly`). Instead, this loader is consulted
// by individual QML bindings via `ThemeLoader.activeColors`,
// `ThemeLoader.activeFonts`, etc., which return the merged view.
//
// Validation per contracts/theme-tokens.md:
//   - color unparseable → fallback to default + warn
//   - fonts.size < 6 or > 64 → clamp + warn
//   - space.* / radius.* < 0 → clamp to 0 + warn
//   - animations.duration < 0 or > 2000 → clamp + warn
//   - opacity.* not in [0, 1] → clamp + warn
//   - unknown token → warn + ignore

import QtQuick

QtObject {
    // Returns a deep-merged colors map: defaults < namedTheme < themeOverrides.
    function activeColors(namedTheme, themeOverrides) {
        var base = Theme.colors;
        var merged = deepClone(base);
        if (namedTheme && namedTheme.colors) {
            merged = deepMerge(merged, namedTheme.colors);
        }
        if (themeOverrides && themeOverrides.colors) {
            merged = deepMerge(merged, themeOverrides.colors);
        }
        return validateColors(merged);
    }

    function activeFonts(namedTheme, themeOverrides) {
        var base = Theme.fonts;
        var merged = deepClone(base);
        if (namedTheme && namedTheme.fonts) {
            merged = deepMerge(merged, namedTheme.fonts);
        }
        if (themeOverrides && themeOverrides.fonts) {
            merged = deepMerge(merged, themeOverrides.fonts);
        }
        return validateFonts(merged);
    }

    function activeSpace(namedTheme, themeOverrides) {
        var merged = deepClone(Theme.space);
        if (namedTheme && namedTheme.space) merged = deepMerge(merged, namedTheme.space);
        if (themeOverrides && themeOverrides.space) merged = deepMerge(merged, themeOverrides.space);
        return validateInts(merged, "space", 0, 1e9);
    }

    function activeRadius(namedTheme, themeOverrides) {
        var merged = deepClone(Theme.radius);
        if (namedTheme && namedTheme.radius) merged = deepMerge(merged, namedTheme.radius);
        if (themeOverrides && themeOverrides.radius) merged = deepMerge(merged, themeOverrides.radius);
        return validateInts(merged, "radius", 0, 1e9);
    }

    function activeAnimations(namedTheme, themeOverrides) {
        var merged = deepClone(Theme.animations);
        if (namedTheme && namedTheme.animations) merged = deepMerge(merged, namedTheme.animations);
        if (themeOverrides && themeOverrides.animations) merged = deepMerge(merged, themeOverrides.animations);
        return validateAnimations(merged);
    }

    function activeOpacity(namedTheme, themeOverrides) {
        var merged = deepClone(Theme.opacity);
        if (namedTheme && namedTheme.opacity) merged = deepMerge(merged, namedTheme.opacity);
        if (themeOverrides && themeOverrides.opacity) merged = deepMerge(merged, themeOverrides.opacity);
        return validateReals(merged, "opacity", 0, 1);
    }

    // --- Helpers ---------------------------------------------------------

    function deepClone(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    function deepMerge(base, over) {
        var out = base;
        for (var k in over) {
            if (over[k] && typeof over[k] === "object" && !Array.isArray(over[k])
                && base[k] && typeof base[k] === "object" && !Array.isArray(base[k])) {
                out[k] = deepMerge(base[k], over[k]);
            } else {
                out[k] = over[k];
            }
        }
        return out;
    }

    function validateColors(map) {
        var known = Object.keys(Theme.colors);
        var out = {};
        for (var k in map) {
            if (known.indexOf(k) < 0) {
                Logger.warn("ThemeLoader", "unknown color token \"" + k + "\" ignored");
                continue;
            }
            var v = map[k];
            var parsed = typeof v === "string" ? parseColor(v) : v;
            if (parsed === undefined) {
                Logger.warn("ThemeLoader",
                    "color \"" + k + "\" = \"" + v + "\" unparseable; using default");
                out[k] = Theme.colors[k];
            } else {
                out[k] = parsed;
            }
        }
        // Fill in any missing tokens with defaults.
        for (var i = 0; i < known.length; i++) {
            var name = known[i];
            if (!(name in out)) out[name] = Theme.colors[name];
        }
        // WCAG AA contrast gate (FR-012 / T051): if the user-provided
        // `fg` and `bg` produce a ratio < 4.5:1, reject the override
        // and fall back to the default fg/bg.
        var ratio = contrastRatio(out.fg, out.bg);
        if (ratio < 4.5) {
            Logger.warn("ThemeLoader",
                "fg/bg contrast ratio " + ratio.toFixed(2) +
                ":1 is below WCAG AA 4.5:1; reverting to defaults");
            out.fg = Theme.colors.fg;
            out.bg = Theme.colors.bg;
        }
        return out;
    }

    // Compute WCAG-style relative luminance for a hex color string.
    function _hexChannel(hex, idx, n) {
        return parseInt(hex.substr(idx, n), 16) / (n === 1 ? 15 : 255);
    }

    function _luminance(hex) {
        if (typeof hex !== "string") return 0;
        hex = hex.replace(/^#/, "");
        var r, g, b, a = 1;
        if (hex.length === 3) {
            r = _hexChannel(hex, 1, 1); g = _hexChannel(hex, 2, 1); b = _hexChannel(hex, 3, 1);
        } else if (hex.length === 6) {
            r = _hexChannel(hex, 1, 2); g = _hexChannel(hex, 3, 2); b = _hexChannel(hex, 5, 2);
        } else if (hex.length === 8) {
            a = _hexChannel(hex, 1, 2); r = _hexChannel(hex, 3, 2); g = _hexChannel(hex, 5, 2); b = _hexChannel(hex, 7, 2);
        } else {
            return 0;
        }
        function lin(v) { return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
    }

    function contrastRatio(fg, bg) {
        var l1 = _luminance(fg), l2 = _luminance(bg);
        var lo = Math.min(l1, l2), hi = Math.max(l1, l2);
        return (hi + 0.05) / (lo + 0.05);
    }

    function parseColor(s) {
        // Accept "#rgb", "#rrggbb", "#aarrggbb".
        if (typeof s !== "string") return undefined;
        if (!/^#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?([0-9a-fA-F]{2})?$/.test(s)) return undefined;
        return s;
    }

    function validateFonts(map) {
        var out = {};
        for (var k in map) {
            var v = map[k];
            if (k === "family" || k === "familyMono") {
                if (typeof v !== "string") {
                    Logger.warn("ThemeLoader", "fonts." + k + " must be a string; using default");
                    out[k] = Theme.fonts[k];
                } else {
                    out[k] = v;
                }
            } else if (k === "size" || k === "sizeSmall" || k === "sizeLarge" ||
                       k === "weight" || k === "weightBold") {
                if (typeof v !== "number") {
                    Logger.warn("ThemeLoader", "fonts." + k + " must be a number; using default");
                    out[k] = Theme.fonts[k];
                } else if (k === "size" && (v < 6 || v > 64)) {
                    Logger.warn("ThemeLoader",
                        "fonts." + k + " = " + v + " out of range [6, 64]; clamping");
                    out[k] = Math.max(6, Math.min(64, v));
                } else {
                    out[k] = v;
                }
            } else {
                Logger.warn("ThemeLoader", "unknown font token \"" + k + "\" ignored");
            }
        }
        for (var fk in Theme.fonts) {
            if (!(fk in out)) out[fk] = Theme.fonts[fk];
        }
        return out;
    }

    function validateInts(map, groupName, min, max) {
        var out = {};
        for (var k in map) {
            var v = map[k];
            if (typeof v !== "number" || isNaN(v)) {
                Logger.warn("ThemeLoader", groupName + "." + k + " must be a number; using default");
                out[k] = Theme[groupName][k];
            } else if (v < min) {
                Logger.warn("ThemeLoader",
                    groupName + "." + k + " = " + v + " below " + min + "; clamping");
                out[k] = min;
            } else if (v > max) {
                Logger.warn("ThemeLoader",
                    groupName + "." + k + " = " + v + " above " + max + "; clamping");
                out[k] = max;
            } else {
                out[k] = Math.floor(v);
            }
        }
        for (var dk in Theme[groupName]) {
            if (!(dk in out)) out[dk] = Theme[groupName][dk];
        }
        return out;
    }

    function validateReals(map, groupName, min, max) {
        var out = {};
        for (var k in map) {
            var v = map[k];
            if (typeof v !== "number" || isNaN(v)) {
                Logger.warn("ThemeLoader", groupName + "." + k + " must be a number; using default");
                out[k] = Theme[groupName][k];
            } else if (v < min || v > max) {
                Logger.warn("ThemeLoader",
                    groupName + "." + k + " = " + v + " out of range [" + min + ", " + max + "]; clamping");
                out[k] = Math.max(min, Math.min(max, v));
            } else {
                out[k] = v;
            }
        }
        for (var dk in Theme[groupName]) {
            if (!(dk in out)) out[dk] = Theme[groupName][dk];
        }
        return out;
    }

    function validateAnimations(map) {
        var out = {};
        for (var k in map) {
            var v = map[k];
            if (k === "enabled") {
                out[k] = !!v;
            } else if (k === "duration" || k === "durationFast" || k === "durationSlow") {
                if (typeof v !== "number" || v < 0 || v > 2000) {
                    Logger.warn("ThemeLoader",
                        "animations." + k + " = " + v + " out of range [0, 2000]; clamping");
                    out[k] = Math.max(0, Math.min(2000, v));
                } else {
                    out[k] = Math.floor(v);
                }
            } else if (k === "easing") {
                out[k] = v;
            } else {
                Logger.warn("ThemeLoader", "unknown animations token \"" + k + "\" ignored");
            }
        }
        for (var dk in Theme.animations) {
            if (!(dk in out)) out[dk] = Theme.animations[dk];
        }
        return out;
    }
}
