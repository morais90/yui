pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

// Yui dock drawer: grows out of the bottom border like the other panels.
// Slides away while the launcher (same edge) is open and in fullscreen.
// With auto-hide on (macOS "Automatically hide and show the Dock") it stays
// hidden until the pointer touches the bottom edge below it.
Item {
    id: root

    required property ScreenState screenState
    property bool fullscreen

    // Pointer on the bottom edge below the dock (set by the drawers' Interactions)
    property bool edgeHovered
    readonly property bool autoHide: YuiWindows.dockAutoHide
    readonly property bool hovered: edgeHovered || content.hovered || content.menuOpen
    property bool revealed

    onHoveredChanged: {
        if (hovered) {
            hideTimer.stop();
            revealed = true;
        } else {
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer

        interval: 400
        onTriggered: root.revealed = false
    }

    readonly property bool shouldBeActive: !fullscreen && !(screenState.launcher && Config.launcher.enabled) && (!autoHide || revealed)
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
