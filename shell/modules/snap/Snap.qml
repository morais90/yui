pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services

// Window snapping (macOS Sequoia style). The yui-snap Hyprland plugin reports
// on socket2 which edge a dragged window touches ("yuisnap>>hint,...") and
// when it is dropped there ("yuisnap>>apply,..."). This draws the preview of
// the target area and runs yui-snap to place the window.
Scope {
    id: root

    property string zone: "none"
    property string monitor: ""

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (event.name !== "yuisnap")
                return;
            const [kind, zone, monitor, address] = event.data.split(",");
            if (kind === "hint") {
                root.zone = zone;
                root.monitor = monitor;
            } else if (kind === "apply") {
                root.zone = "none";
                Quickshell.execDetached(["yui-snap", zone, address]);
            }
        }
    }

    // Scriptable control: preview a zone, or snap a window
    IpcHandler {
        target: "snap"

        function preview(zone: string, monitor: string): void {
            root.zone = zone;
            root.monitor = monitor;
        }

        function apply(zone: string, address: string): void {
            root.zone = "none";
            Quickshell.execDetached(["yui-snap", zone, address]);
        }
    }

    Variants {
        model: Screens.screens

        StyledWindow {
            id: win

            required property ShellScreen modelData

            readonly property bool active: root.zone !== "none" && root.monitor === modelData.name
            readonly property var reserved: Hypr.monitorFor(modelData)?.lastIpcObject?.reserved ?? [0, 0, 0, 0]
            // Same area as yui-snap: free area minus gaps_out (20), tiles split by 2 * gaps_in (10)
            readonly property real ax: reserved[0] + 20
            readonly property real ay: reserved[1] + 20
            readonly property real aw: width - reserved[0] - reserved[2] - 40
            readonly property real ah: height - reserved[1] - reserved[3] - 40
            readonly property real hw: (aw - 10) / 2
            readonly property real hh: (ah - 10) / 2
            readonly property var rect: {
                switch (root.zone) {
                case "left":
                    return [ax, ay, hw, ah];
                case "right":
                    return [ax + hw + 10, ay, hw, ah];
                case "topleft":
                    return [ax, ay, hw, hh];
                case "topright":
                    return [ax + hw + 10, ay, hw, hh];
                case "bottomleft":
                    return [ax, ay + hh + 10, hw, hh];
                case "bottomright":
                    return [ax + hw + 10, ay + hh + 10, hw, hh];
                default:
                    return [ax, ay, aw, ah];
                }
            }

            screen: modelData
            name: "snap"
            visible: active || preview.opacity > 0
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            mask: Region {}

            StyledRect {
                id: preview

                x: win.rect[0]
                y: win.rect[1]
                width: win.rect[2]
                height: win.rect[3]
                radius: Tokens.rounding.large
                color: Qt.alpha(Colours.palette.m3primary, 0.18)
                border.width: 2
                border.color: Qt.alpha(Colours.palette.m3primary, 0.6)
                opacity: win.active ? 1 : 0
                scale: win.active ? 1 : 0.96

                Behavior on x {
                    Anim {}
                }
                Behavior on y {
                    Anim {}
                }
                Behavior on width {
                    Anim {}
                }
                Behavior on height {
                    Anim {}
                }
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
            }
        }
    }
}
