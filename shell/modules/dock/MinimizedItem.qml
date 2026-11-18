import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services

// A minimized window: thumbnail with the app icon as a badge.
// Left click restores it, right click closes it.
Item {
    id: root

    required property var win

    implicitWidth: implicitHeight * 1.5

    ClippingRectangle {
        anchors.fill: parent
        radius: Tokens.rounding.medium
        color: Colours.palette.m3surfaceContainerHighest
        border.width: area.containsMouse ? 2 : 0
        border.color: Colours.palette.m3primary

        ScreencopyView {
            id: preview

            anchors.fill: parent
            captureSource: root.win.wayland
            live: false
        }

        IconImage {
            visible: !preview.hasContent
            anchors.centerIn: parent
            implicitSize: parent.height * 0.6
            source: YuiWindows.icon(YuiWindows.appId(root.win))
        }
    }

    IconImage {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -Tokens.padding.extraSmall
        implicitSize: root.implicitHeight * 0.45
        source: YuiWindows.icon(YuiWindows.appId(root.win))
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => mouse.button === Qt.RightButton ? YuiWindows.close(root.win) : YuiWindows.activate(root.win)
    }
}
