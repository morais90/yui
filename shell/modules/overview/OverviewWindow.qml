pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services

StyledWindow {
    id: win

    required property var overview

    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    // 0 = windows at their real place, 1 = arranged in the grid
    property real progress: overview.open ? 1 : 0

    // Windows of this screen's active workspace, snapshotted when opening
    property list<HyprlandToplevel> windows: []

    readonly property real areaX: width * 0.07
    readonly property real areaY: height * 0.1
    readonly property real areaW: width * 0.86
    readonly property real areaH: height * 0.78
    readonly property int cols: Math.max(1, Math.ceil(Math.sqrt(windows.length * (areaW / areaH) / 1.6)))
    readonly property int rows: Math.max(1, Math.ceil(windows.length / cols))
    readonly property real gap: 40

    name: "overview"
    visible: progress > 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: overview.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    Behavior on progress {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    Connections {
        target: win.overview

        function onOpenChanged(): void {
            if (win.overview.open) {
                const ws = win.monitor?.activeWorkspace;
                const list = YuiWindows.all().filter(t => t.workspace === ws && !YuiWindows.isMinimized(t));
                // Stable, spatial order: top-to-bottom, left-to-right
                win.windows = list.sort((a, b) => {
                    const pa = a.lastIpcObject?.at ?? [0, 0], pb = b.lastIpcObject?.at ?? [0, 0];
                    return (pa[1] - pb[1]) || (pa[0] - pb[0]);
                });
                keys.forceActiveFocus();
            }
        }
    }

    // Dimmed backdrop; clicking it goes back
    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colours.palette.m3surface, 0.6)
        opacity: win.progress

        MouseArea {
            anchors.fill: parent
            onClicked: win.overview.close(null)
        }
    }

    Item {
        id: keys

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: win.overview.close(null)
    }

    Repeater {
        model: win.windows

        Item {
            id: card

            required property HyprlandToplevel modelData
            required property int index

            // Real geometry, relative to this screen
            readonly property var ipc: modelData.lastIpcObject
            readonly property real realX: (ipc?.at?.[0] ?? 0) - (win.monitor?.x ?? 0)
            readonly property real realY: (ipc?.at?.[1] ?? 0) - (win.monitor?.y ?? 0)
            readonly property real realW: ipc?.size?.[0] ?? 400
            readonly property real realH: ipc?.size?.[1] ?? 300

            // Grid cell, keeping the window's aspect ratio
            readonly property int col: index % win.cols
            readonly property int row: Math.floor(index / win.cols)
            readonly property int rowCount: row === win.rows - 1 ? win.windows.length - row * win.cols : win.cols
            readonly property real cellW: (win.areaW - win.gap * (win.cols - 1)) / win.cols
            readonly property real cellH: (win.areaH - win.gap * (win.rows - 1)) / win.rows
            readonly property real fit: Math.min(cellW / realW, cellH / realH, 1)
            readonly property real gridW: realW * fit
            readonly property real gridH: realH * fit
            // Center each row (the last one may be shorter)
            readonly property real rowOffset: (win.cols - rowCount) * (cellW + win.gap) / 2
            readonly property real gridX: win.areaX + rowOffset + col * (cellW + win.gap) + (cellW - gridW) / 2
            readonly property real gridY: win.areaY + (win.areaH - (win.rows * cellH + (win.rows - 1) * win.gap)) / 2 + row * (cellH + win.gap) + (cellH - gridH) / 2

            readonly property real p: win.progress

            x: realX + (gridX - realX) * p
            y: realY + (gridY - realY) * p
            width: realW + (gridW - realW) * p
            height: realH + (gridH - realH) * p
            // The chosen window comes forward when going back
            z: win.overview.chosen === modelData ? 1 : 0

            StyledRect {
                anchors.fill: parent
                anchors.margins: -4
                radius: Tokens.rounding.large + 4
                color: Colours.palette.m3primary
                opacity: area.containsMouse && win.overview.open ? 1 : 0

                Behavior on opacity {
                    Anim {
                        type: Anim.FastEffects
                    }
                }
            }

            ClippingRectangle {
                anchors.fill: parent
                radius: Tokens.rounding.large
                color: Colours.palette.m3surfaceContainerHigh

                ScreencopyView {
                    id: preview

                    anchors.fill: parent
                    captureSource: win.visible ? card.modelData.wayland : null
                    live: true
                }

                IconImage {
                    visible: !preview.hasContent
                    anchors.centerIn: parent
                    implicitSize: Math.min(parent.width, parent.height) * 0.4
                    source: YuiWindows.icon(YuiWindows.appId(card.modelData))
                }
            }

            // Title pill under the hovered window
            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: Tokens.spacing.medium
                implicitWidth: Math.min(title.implicitWidth, card.width * 1.4) + Tokens.padding.large * 2
                implicitHeight: title.implicitHeight + Tokens.padding.small * 2
                radius: Tokens.rounding.full
                color: Colours.palette.m3inverseSurface
                opacity: area.containsMouse && win.overview.open ? 1 : 0

                Behavior on opacity {
                    Anim {
                        type: Anim.FastEffects
                    }
                }

                StyledText {
                    id: title

                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, card.width * 1.4)
                    elide: Text.ElideRight
                    text: card.modelData.title || YuiWindows.name(YuiWindows.appId(card.modelData))
                    color: Colours.palette.m3inverseOnSurface
                    font: Tokens.font.body.small
                }
            }

            // App icon badge
            IconImage {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom
                implicitSize: 40
                opacity: win.progress
                source: YuiWindows.icon(YuiWindows.appId(card.modelData))
            }

            MouseArea {
                id: area

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: win.overview.close(card.modelData)
            }
        }
    }
}
