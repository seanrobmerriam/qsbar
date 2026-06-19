// Config/json5.js
//
// A permissive JSON5 pre-parser. Strips `//` line comments and `/* */`
// block comments, strips trailing commas in arrays/objects, then hands
// the result to Qt's built-in JSON.parse (which handles the rest of JSON5
// via the bare JSON subset: strings, numbers, booleans, null, arrays,
// objects, and unquoted keys when they happen to be valid identifiers).
//
// This is intentionally small (≈30 lines of logic) per plan.md R2. The
// Quickshell QML engine calls `JSON.parse(text)` for us; we just clean
// the text first.
//
// Exposed as a singleton via `pragma Singleton` (see Config/qmldir).

.pragma library

// .pragma Singleton

// Strip line and block comments, then strip trailing commas.
// Throws SyntaxError on unbalanced brackets / truly malformed input
// (caught by the caller).
function parse(text) {
    var src = stripComments(text);
    src = stripTrailingCommas(src);
    return JSON.parse(src);
}

function stripComments(text) {
    var out = "";
    var i = 0;
    var n = text.length;
    var inString = false;
    var stringQuote = "";
    while (i < n) {
        var c = text[i];
        var c2 = i + 1 < n ? text[i + 1] : "";
        if (inString) {
            out += c;
            if (c === "\\" && i + 1 < n) {
                out += c2;
                i += 2;
                continue;
            }
            if (c === stringQuote) {
                inString = false;
            }
            i++;
            continue;
        }
        if (c === "\"" || c === "'") {
            inString = true;
            stringQuote = c;
            out += c;
            i++;
            continue;
        }
        if (c === "/" && c2 === "/") {
            // line comment — skip to end of line
            while (i < n && text[i] !== "\n") i++;
            continue;
        }
        if (c === "/" && c2 === "*") {
            // block comment — skip to */
            i += 2;
            while (i < n - 1 && !(text[i] === "*" && text[i + 1] === "/")) i++;
            i += 2;
            continue;
        }
        out += c;
        i++;
    }
    return out;
}

function stripTrailingCommas(text) {
    // Replace ", ]" or ", }" (with optional whitespace/newlines between)
    // with "] / "}".
    return text.replace(/,(\s*[\]\}])/g, "$1");
}
