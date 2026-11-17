import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

// macOS-style dock: pinned + running apps, minimized windows with live
// thumbnails, magnification on hover.
PanelWindow {
    id: dock

    // Apps always shown in the dock (desktop file / app ids)
    property var pinned: ["org.kde.dolphin", "google-chrome", "com.mitchellh.ghostty"]

    readonly property int iconSize: 52
    readonly property real maxMagnify: 1.6
    readonly property int barHeight: iconSize + 20
    readonly property int bottomGap: 8

    anchors { bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "yui-dock"
    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone: barHeight + bottomGap
    implicitHeight: barHeight + bottomGap + iconSize * (maxMagnify - 1) + 34
    mask: Region { item: bar }

    // --- model -----------------------------------------------------------
    readonly property var apps: {
        const byApp = {};
        for (const t of Windows.all()) {
            const id = Windows.appId(t);
            if (!byApp[id]) byApp[id] = [];
            byApp[id].push(t);
        }
        const list = pinned.map(id => ({ appId: id, pinned: true, windows: byApp[id] || [] }));
        for (const id in byApp)
            if (!pinned.includes(id)) list.push({ appId: id, pinned: false, windows: byApp[id] });
        return list;
    }
    readonly property var minimized: Windows.all().filter(t => Windows.isMinimized(t))

    // --- view ------------------------------------------------------------
    Rectangle {
        id: bar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: dock.bottomGap
        anchors.horizontalCenter: parent.horizontalCenter
        height: dock.barHeight
        width: content.implicitWidth + 24
        radius: Theme.radius
        color: Theme.glass
        border.color: Theme.glassBorder
        border.width: 1
        Behavior on width { NumberAnimation { duration: Theme.normal; easing.type: Easing.OutCubic } }

        // Tracks the pointer for magnification (doesn't eat clicks)
        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: dock.apps
                delegate: DockItem {
                    required property var modelData
                    app: modelData
                    size: dock.iconSize
                    maxMagnify: dock.maxMagnify
                    pointerX: hover.containsMouse ? hover.mouseX : -10000
                    dockBar: bar
                }
            }

            // Separator between apps and minimized windows
            Rectangle {
                visible: dock.minimized.length > 0
                width: 1; height: dock.iconSize - 8
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.glassBorder
            }

            Repeater {
                model: dock.minimized
                delegate: MinimizedItem {
                    required property var modelData
                    win: modelData
                    height: dock.iconSize
                }
            }
        }
    }
}
