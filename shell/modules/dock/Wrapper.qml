pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components

// Yui dock drawer: grows out of the bottom border like the other panels.
// Slides away while the launcher (same edge) is open and in fullscreen.
Item {
    id: root

    required property ScreenState screenState
    property bool fullscreen

    readonly property bool shouldBeActive: !fullscreen && !(screenState.launcher && Config.launcher.enabled)
    property real offsetScale: shouldBeActive ? 0 : 1

    readonly property bool menuOpen: content.menuOpen
    readonly property Item menu: content.menu

    visible: offsetScale < 1
    anchors.bottomMargin: (-implicitHeight - 5) * offsetScale
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {}
    }

    Content {
        id: content

        anchors.fill: parent
    }
}
