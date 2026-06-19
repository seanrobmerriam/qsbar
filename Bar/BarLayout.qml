// Bar/BarLayout.qml
//
// Three-section layout: left, center, right. RowLayout for horizontal
// bars, ColumnLayout for vertical. Modules are placed by ID into the
// section the config assigns.
//
// Per data-model.md §1: `modules.{left, center, right}` are arrays of
// Module descriptors; the renderer instantiates each from its `type`
// field (Modules/<Type>.qml).

import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Modules as ModulesMod

Item {
    id: root

    // Inputs
    property var modules: null      // { left: [], center: [], right: [] }
    property string barPosition: "top"
    property var screen: null
    // Forwarded into every ModuleHost → ModuleSlot so modules can
    // call `dispatcher.dispatch(...)` on click / wheel.
    property var dispatcher: null

    readonly property bool _vertical:
        barPosition === "left" || barPosition === "right"

    // The bar's height comes from the parent (PanelWindow.implicitHeight).
    // We use Layout.fillWidth/fillHeight so modules expand correctly.

    Loader {
        id: rowLoader
        anchors.fill: parent
        sourceComponent: root._vertical ? verticalLayout : horizontalLayout
        active: true
    }

    Component {
        id: horizontalLayout
        RowLayout {
            spacing: 0
            // Left section
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                ModuleHost {
                    section: root.modules ? (root.modules.left || []) : []
                    barPosition: root.barPosition
                    screen: root.screen
                    dispatcher: root.dispatcher
                }
            }
            // Center section
            Item {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                ModuleHost {
                    section: root.modules ? (root.modules.center || []) : []
                    barPosition: root.barPosition
                    screen: root.screen
                    dispatcher: root.dispatcher
                }
            }
            // Right section
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                ModuleHost {
                    section: root.modules ? (root.modules.right || []) : []
                    barPosition: root.barPosition
                    screen: root.screen
                    dispatcher: root.dispatcher
                }
            }
        }
    }

    Component {
        id: verticalLayout
        ColumnLayout {
            spacing: 0
            Item {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                ModuleHost {
                    section: root.modules ? (root.modules.left || []) : []
                    barPosition: root.barPosition
                    screen: root.screen
                    dispatcher: root.dispatcher
                }
            }
            Item {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                ModuleHost {
                    section: root.modules ? (root.modules.center || []) : []
                    barPosition: root.barPosition
                    screen: root.screen
                    dispatcher: root.dispatcher
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                ModuleHost {
                    section: root.modules ? (root.modules.right || []) : []
                    barPosition: root.barPosition
                    screen: root.screen
                    dispatcher: root.dispatcher
                }
            }
        }
    }
}
