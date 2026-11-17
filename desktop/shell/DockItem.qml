import QtQuick
import Quickshell
import Quickshell.Widgets

// One app in the dock.
Item {
    id: item

    property var app            // { appId, pinned, windows }
    property int size: 52
    property real maxMagnify: 1.6
    property real pointerX: -10000
    property Item dockBar

    readonly property bool running: app.windows.length > 0
    readonly property bool focused: app.windows.some(w => w.activated)

    // macOS-like magnification: grows with pointer proximity
    readonly property real magnify: {
        if (!dockBar) return 1;
        const center = item.mapToItem(dockBar, width / 2, 0).x;
        const d = Math.abs(pointerX - center) / (size * 1.8);
        return 1 + (maxMagnify - 1) * Math.max(0, 1 - d * d);
    }

    width: size
    height: size

    // Rendered at max size and scaled down, so magnified icons stay sharp
    IconImage {
        id: icon
        width: item.size * item.maxMagnify
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        transformOrigin: Item.Bottom
        scale: item.magnify / item.maxMagnify
        source: Windows.icon(item.app.appId)
        mipmap: true
        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

        // Launch bounce
        transform: Translate { id: bounce; y: 0 }
    }

    SequentialAnimation {
        id: bounceAnim
        loops: 2
        NumberAnimation { target: bounce; property: "y"; to: -16; duration: 220; easing.type: Easing.OutQuad }
        NumberAnimation { target: bounce; property: "y"; to: 0; duration: 220; easing.type: Easing.InQuad }
    }

    // Running indicator
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 3
        width: item.focused ? 14 : 5
        height: 5
        radius: 2.5
        visible: item.running
        color: item.focused ? Theme.accent : Theme.text
        Behavior on width { NumberAnimation { duration: Theme.fast } }
    }

    // Name tooltip
    Rectangle {
        visible: area.containsMouse
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height - (item.size * (item.magnify - 1)) - 10
        width: label.implicitWidth + 20
        height: label.implicitHeight + 10
        radius: 8
        color: Theme.base
        border.color: Theme.glassBorder
        Text {
            id: label
            anchors.centerIn: parent
            text: Windows.name(item.app.appId)
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 12
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => {
            const wins = item.app.windows;
            if (wins.length === 0 || mouse.button === Qt.MiddleButton) {
                Windows.launch(item.app.appId);
                bounceAnim.restart();
                return;
            }
            // Click a running app: focus it, or cycle through its windows
            const current = wins.findIndex(w => w.activated);
            Windows.activate(wins[(current + 1) % wins.length]);
        }
    }
}
