pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    readonly property list<string> pinned: YuiWindows.pinned
    readonly property bool menuOpen: menu.expanded

    // App whose context menu is open: { appId, windows }
    property var menuApp: ({ appId: "", windows: [] })

    function openMenu(item: Item): void {
        menuApp = item.app;
        menu.attachTo = item;
        menu.expanded = true;
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
    Menu {
        id: menu

        readonly property bool running: root.menuApp.windows.length > 0
        readonly property bool pinned: root.pinned.includes(root.menuApp.appId)

        attachTo: row
        attachSideX: Menu.Left
        thisSideX: Menu.Left
        attachSideY: Menu.Top
        thisSideY: Menu.Bottom
        marginY: -Tokens.spacing.large
        active: null
        items: running ? [newWindow, pinToggle, closeAll] : [newWindow, pinToggle]

        MenuItem {
            id: newWindow

            icon: "open_in_new"
            text: menu.running ? qsTr("New window") : qsTr("Open")
            onClicked: YuiWindows.launch(root.menuApp.appId)
        }
        MenuItem {
            id: pinToggle

            icon: menu.pinned ? "keep_off" : "keep"
            text: menu.pinned ? qsTr("Remove from Dock") : qsTr("Keep in Dock")
            onClicked: menu.pinned ? YuiWindows.unpin(root.menuApp.appId) : YuiWindows.pin(root.menuApp.appId)
        }
        MenuItem {
            id: closeAll

            icon: "close"
            text: root.menuApp.windows.length > 1 ? qsTr("Close all windows") : qsTr("Close window")
            onClicked: root.menuApp.windows.forEach(w => YuiWindows.close(w))
        }
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
