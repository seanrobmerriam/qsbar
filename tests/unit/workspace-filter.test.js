// tests/unit/workspace-filter.test.js
.pragma library

// Given a module list with showOnWorkspace / hideOnWorkspace, returns
// the visible subset for a given focused workspace id.

function test_no_filter_all_visible() {
    var modules = [{ type: "Clock" }, { type: "Battery" }];
    return _filter(modules, 1).length === 2;
}

function test_showOn_workspace_3() {
    var modules = [{ type: "Clock" }, { type: "Battery", showOnWorkspace: [3] }];
    return _filter(modules, 1).length === 1
        && _filter(modules, 3).length === 2;
}

function test_hideOn_workspace_2() {
    var modules = [{ type: "Clock", hideOnWorkspace: [2] }];
    return _filter(modules, 1).length === 1
        && _filter(modules, 2).length === 0;
}

function _filter(modules, focusedId) {
    return modules.filter(function(m) {
        if (Array.isArray(m.showOnWorkspace) && m.showOnWorkspace.length > 0
            && m.showOnWorkspace.indexOf(focusedId) < 0) return false;
        if (Array.isArray(m.hideOnWorkspace) && m.hideOnWorkspace.indexOf(focusedId) >= 0) return false;
        return true;
    });
}
