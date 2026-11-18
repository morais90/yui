pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Caelestia.Config
import qs.components
import qs.components.effects
import qs.services

// Right-click menu for a dock app. Lives inside the dock (no reparenting);
// the drawers input region includes it while open, and clicking anywhere
// else closes it through a focus grab.
Item {
    id: root

    property var app: ({ appId: "", windows: [] })
    property Item attachTo
    property bool expanded

    readonly property bool running: app.windows.length > 0
    readonly property bool pinned: YuiWindows.pinned.includes(app.appId)
    readonly property var actions: {
        const list = [
            { icon: "open_in_new", text: running ? qsTr("New window") : qsTr("Open"), run: () => YuiWindows.launch(app.appId) },
            { icon: pinned ? "keep_off" : "keep", text: pinned ? qsTr("Remove from Dock") : qsTr("Keep in Dock"), run: () => pinned ? YuiWindows.unpin(app.appId) : YuiWindows.pin(app.appId) }
        ];
        list.push({ icon: YuiWindows.dockAutoHide ? "visibility" : "visibility_off", text: YuiWindows.dockAutoHide ? qsTr("Turn Hiding Off") : qsTr("Turn Hiding On"), run: () => YuiWindows.setDockAutoHide(!YuiWindows.dockAutoHide) });
        if (running)
            list.push({ icon: "close", text: app.windows.length > 1 ? qsTr("Close all windows") : qsTr("Close window"), run: () => app.windows.forEach(w => YuiWindows.close(w)) });
        return list;
    }

    function open(item: Item): void {
        app = item.app;
        attachTo = item;
        expanded = true;
    }

    x: attachTo ? attachTo.mapToItem(parent, attachTo.width / 2, 0).x - width / 2 : 0
    y: -height - Tokens.spacing.large
    implicitWidth: Math.max(200, column.implicitWidth + Tokens.padding.extraSmall * 2)
    implicitHeight: column.implicitHeight + Tokens.padding.extraSmall * 2
    visible: opacity > 0
    opacity: expanded ? 1 : 0
    scale: expanded ? 1 : 0.9
    transformOrigin: Item.Bottom

    Behavior on opacity {
        Anim {
            type: Anim.FastEffects
        }
    }
    Behavior on scale {
        Anim {
            type: Anim.FastSpatial
        }
    }

    HyprlandFocusGrab {
        windows: [QsWindow.window]
        active: root.expanded
        onCleared: root.expanded = false
    }

    Elevation {
        anchors.fill: parent
        radius: bg.radius
        level: 2
    }

    StyledRect {
        id: bg

        anchors.fill: parent
        radius: Tokens.rounding.large
        color: Colours.palette.m3surfaceContainerLow

        ColumnLayout {
            id: column

            anchors.fill: parent
            anchors.margins: Tokens.padding.extraSmall
            spacing: 0

            Repeater {
                model: root.actions

                Item {
                    id: entry

                    required property var modelData

                    Layout.fillWidth: true
                    implicitWidth: row.implicitWidth + Tokens.padding.medium * 2
                    implicitHeight: row.implicitHeight + Tokens.padding.medium * 2

                    StateLayer {
                        radius: Tokens.rounding.medium
                        disabled: !root.expanded
                        onClicked: {
                            root.expanded = false;
                            entry.modelData.run();
                        }
                    }

                    RowLayout {
                        id: row

                        anchors.fill: parent
                        anchors.margins: Tokens.padding.medium
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            text: entry.modelData.icon
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: entry.modelData.text
                        }
                    }
                }
            }
        }
    }
}
