import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

// A minimized window in the dock: thumbnail + app badge.
// Left click restores it, right click closes it.
Item {
    id: item
    property var win
    width: height * 1.5

    ClippingRectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.surface
        border.color: area.containsMouse ? Theme.accent : Theme.glassBorder
        border.width: 1

        ScreencopyView {
            id: preview
            anchors.fill: parent
            captureSource: item.win.wayland
            live: false
        }

        IconImage {
            visible: !preview.hasContent
            anchors.centerIn: parent
            implicitSize: parent.height * 0.6
            source: Windows.icon(Windows.appId(item.win))
        }
    }

    IconImage {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -4
        implicitSize: 22
        source: Windows.icon(Windows.appId(item.win))
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        // Left click restores, right click closes
        onClicked: mouse => mouse.button === Qt.RightButton ? Windows.close(item.win) : Windows.activate(item.win)
    }
}
