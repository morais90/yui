pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    readonly property list<string> pinned: YuiWindows.pinned
    readonly property bool menuOpen: menu.expanded
    readonly property bool hovered: hover.containsMouse
    readonly property alias menu: menu

    function openMenu(item: Item): void {
        menu.open(item);
    }

    readonly property int iconSize: 46
    readonly property real maxMagnify: 1.45

    readonly property var windows: {
        Hypr.toplevels.values; // re-evaluate when windows change
        return YuiWindows.all();
    }
    readonly property var apps: {
        const byApp = {};
        for (const t of windows) {
            const id = YuiWindows.appId(t);
            if (!byApp[id])
                byApp[id] = [];
            byApp[id].push(t);
        }
        const list = pinned.map(id => ({ appId: id, windows: byApp[id] ?? [] }));
        for (const id in byApp)
            if (!pinned.includes(id))
                list.push({ appId: id, windows: byApp[id] });
        return list;
    }
    readonly property var minimized: windows.filter(t => YuiWindows.isMinimized(t))

    implicitWidth: row.implicitWidth + Tokens.padding.large * 2
    implicitHeight: iconSize + Tokens.padding.large * 2

    Behavior on implicitWidth {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    // Tracks the pointer for magnification without eating clicks
    MouseArea {
        id: hover

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    // Right-click menu for an app
    DockMenu {
        id: menu
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Tokens.spacing.small

        Repeater {
            model: root.apps

            AppItem {
                id: appItem

                required property var modelData

                app: modelData
                size: root.iconSize
                maxMagnify: root.maxMagnify
                pointerX: hover.containsMouse ? hover.mouseX : -10000
                dock: root
                onMenuRequested: root.openMenu(appItem)
            }
        }

        StyledRect {
            visible: root.minimized.length > 0
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 1
            implicitHeight: root.iconSize * 0.7
            color: Colours.palette.m3outlineVariant
        }

        Repeater {
            model: root.minimized

            MinimizedItem {
                required property var modelData

                win: modelData
                implicitHeight: root.iconSize
            }
        }
    }
}
