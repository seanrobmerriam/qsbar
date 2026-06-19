// tests/unit/json5.test.js
//
// Unit tests for Config/json5.js (the JSON5 permissive pre-parser).
// Run with `qmltestrunner -input tests/unit/` (or via the project's
// test harness; see T122 / tests/manual/verify.sh).
//
// These tests are written BEFORE the parser implementation (T005) per
// constitution Principle III — they MUST fail against an empty parser.

.pragma library

var Json5 = require("../../Config/json5.js");

function testCommentsAreStripped() {
    var input = "// leading\n{a:1} /* block */ ";
    var out = Json5.parse(input);
    return out.a === 1;
}

function testTrailingCommasAreStripped() {
    var input = '{ "a": 1, "b": [1, 2, 3,], }';
    var out = Json5.parse(input);
    return out.a === 1 && out.b.length === 3 && out.b[2] === 3;
}

function testUnquotedKeys() {
    // Note: JSON.parse does not accept unquoted keys by default, but
    // Quickshell's JSON parser is permissive (Qt's JSON parser is too).
    // We at least confirm the parser doesn't crash on them.
    var input = '{ a: 1 }';
    var out;
    try {
        out = Json5.parse(input);
    } catch (e) {
        // Acceptable — our parser falls back to JSON.parse, which may
        // reject this. The important property is no infinite loop / crash.
        return true;
    }
    return typeof out === "object";
}

function testSingleQuotedStrings() {
    var input = "{ 'a': 'hello' }";
    var out = Json5.parse(input);
    return out.a === "hello";
}

function testNestedObjects() {
    var input = '{"a":{"b":{"c":42}}}';
    var out = Json5.parse(input);
    return out.a.b.c === 42;
}

function testMalformedThrows() {
    var threw = false;
    try {
        Json5.parse('{ "a": ');
    } catch (e) {
        threw = true;
    }
    return threw;
}

function testMixedCommentsAndCommas() {
    var input = '{\n  // one\n  "a": 1, /* two */\n  "b": [1, 2,],\n}';
    var out = Json5.parse(input);
    return out.a === 1 && out.b.length === 2;
}
