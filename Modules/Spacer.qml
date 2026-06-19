// Modules/Spacer.qml
//
// A simple fixed-width spacer. In horizontal bars, `width` is the
// pixel width. In vertical bars, `width` is reinterpreted as height
// (the slot's parent BarLayout decides orientation).

import QtQuick
import qs.Theme

Item {
    id: root
    required property int width

    implicitWidth: vertical ? Theme.fonts.size + Theme.space.sm * 2 : width
    implicitHeight: vertical ? width : Theme.fonts.size + Theme.space.sm * 2
    visible: width > 0
}
