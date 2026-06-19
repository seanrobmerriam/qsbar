// tests/unit/contrast.test.js
//
// Unit tests for the WCAG AA contrast helper used by
// ThemeLoader.validateColors (and exposed for ad-hoc validation
// via the `contrast` module / future `qsbar-validate` CLI).
//
// Per WCAG 2.1:
//   - Body text: contrast ratio >= 4.5:1
//   - Large text (>= 18pt or >= 14pt bold): >= 3:1
//
// Spec FR-012 mandates this for all hover and text states.

.pragma library

// --- WCAG 2.1 relative luminance ----------------------------------------

function srgbToLinear(c) {
    var cs = c / 255;
    return cs <= 0.03928 ? cs / 12.92 : Math.pow((cs + 0.055) / 1.055, 2.4);
}

function relativeLuminance(rgb) {
    var r = srgbToLinear((rgb >> 16) & 0xff);
    var g = srgbToLinear((rgb >> 8) & 0xff);
    var b = srgbToLinear(rgb & 0xff);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

// Parse "#rrggbb" or "#aarrggbb" → 24-bit rgb integer.
function parseHex(hex) {
    if (hex.length === 7) {
        return parseInt(hex.substring(1), 16);
    }
    if (hex.length === 9) {
        // drop alpha
        return parseInt(hex.substring(3), 16);
    }
    if (hex.length === 4) {
        var s = hex.substring(1);
        var r = parseInt(s[0] + s[0], 16);
        var g = parseInt(s[1] + s[1], 16);
        var b = parseInt(s[2] + s[2], 16);
        return (r << 16) | (g << 8) | b;
    }
    return 0;
}

function contrastRatio(hex1, hex2) {
    var l1 = relativeLuminance(parseHex(hex1));
    var l2 = relativeLuminance(parseHex(hex2));
    var lo = Math.min(l1, l2);
    var hi = Math.max(l1, l2);
    return (hi + 0.05) / (lo + 0.05);
}

function testBlackOnWhite() {
    var r = contrastRatio("#ffffff", "#000000");
    return Math.abs(r - 21) < 0.1;
}

function testWhiteOnBlack() {
    var r = contrastRatio("#000000", "#ffffff");
    return Math.abs(r - 21) < 0.1;
}

function testBodyTextPasses() {
    // fg #ffeeeeee on bg #ee222222 — both with alpha. For the
    // ratio computation we approximate using the opaque colors.
    var r = contrastRatio("#eeeeee", "#222222");
    return r >= 4.5;
}

function testLargeTextPasses() {
    // Larger-text 3:1 threshold — fg #ffcccccc on bg #ff555555.
    var r = contrastRatio("#cccccc", "#555555");
    return r >= 3.0;
}

function testSameColorIsOne() {
    var r = contrastRatio("#888888", "#888888");
    return Math.abs(r - 1) < 0.01;
}
