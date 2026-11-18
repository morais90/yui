pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.components
import qs.components.containers
import qs.components.effects
import qs.services

// The floating thumbnail after a screenshot, like macOS: it slides in at the
// bottom-right corner, waits a few seconds (longer while hovered), opens the
// picture on click and can be dragged into other apps as a file.
Scope {
    id: root

    property string path
    property ShellScreen screen
    property real aspect: 16 / 9

    function show(path: string, screen: ShellScreen, aspect: real): void {
        root.path = path;
        root.screen = screen;
        root.aspect = aspect;
        loader.active = false; // restart if one is already showing
        loader.active = true;
    }

    LazyLoader {
        id: loader

        StyledWindow {
            id: win

            screen: root.screen
            name: "screenshot-thumbnail"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors.bottom: true
            anchors.right: true
            implicitWidth: card.width + margin * 2
            implicitHeight: card.height + margin * 2

            readonly property int margin: 24

            function close(): void {
                card.leaving = true;
            }

            Timer {
                running: !area.containsMouse && !area.drag.active && !card.leaving
                interval: 5000
                onTriggered: win.close()
            }

            Item {
                id: card

                property bool leaving
                property bool shown

                // Long side at most 240 px, keeping the picture's proportions
                width: root.aspect >= 1 ? 240 : Math.round(240 * root.aspect)
                height: root.aspect >= 1 ? Math.round(240 / root.aspect) : 240
                x: win.margin + (shown && !leaving ? 0 : width + win.margin * 2)
                y: win.margin
                opacity: leaving ? 0 : 1

                Component.onCompleted: shown = true

                Behavior on x {
                    Anim {
                        type: Anim.DefaultSpatial
                    }
                }
                Behavior on opacity {
                    Anim {
                        onRunningChanged: if (!running && card.leaving)
                            loader.active = false
                    }
                }

                Elevation {
                    anchors.fill: frame
                    radius: frame.radius
                    level: area.containsMouse ? 4 : 3
                }

                ClippingRectangle {
                    id: frame

                    anchors.fill: parent
                    radius: 10
                    color: Colours.palette.m3surfaceContainer
                    border.width: 1
                    border.color: Qt.alpha(Colours.palette.m3outline, 0.4)

                    Image {
                        anchors.fill: parent
                        source: `file://${root.path}`
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 480
                        asynchronous: true
                        cache: false
                    }
                }

                // Drag the picture into an app as a file
                Item {
                    id: dragProxy

                    Drag.active: area.drag.active
                    Drag.dragType: Drag.Automatic
                    Drag.supportedActions: Qt.CopyAction
                    Drag.mimeData: ({
                            "text/uri-list": `file://${root.path}`
                        })
                    Drag.imageSource: `file://${root.path}`
                    Drag.onDragFinished: dropAction => {
                        if (dropAction === Qt.CopyAction)
                            win.close();
                    }
                }

                MouseArea {
                    id: area

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    drag.target: dragProxy

                    onClicked: {
                        Quickshell.execDetached(["xdg-open", root.path]);
                        win.close();
                    }
                }
            }
        }
    }
}
