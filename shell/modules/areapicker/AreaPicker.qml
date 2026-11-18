pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components.containers
import qs.components.misc
import qs.services

// Screenshots (docs/experience/screenshots.md): Print opens the picker on every
// screen, frozen; the capture is saved to Pictures/Screenshots, copied to the
// clipboard and shown as a thumbnail in the corner.
Scope {
    id: scope

    // Pictures/Screenshots, resolved once through xdg-user-dir (localised names)
    property string folder: `${Quickshell.env("HOME")}/Pictures/Screenshots`

    function open(): void {
        picker.freeze = true;
        picker.closing = false;
        picker.activeAsync = true;
    }

    Process {
        running: true
        command: ["xdg-user-dir", "PICTURES"]
        stdout: StdioCollector {
            onStreamFinished: {
                const dir = text.trim();
                if (dir)
                    scope.folder = `${dir}/Screenshots`;
            }
        }
    }

    LazyLoader {
        id: picker

        property bool freeze: true
        property bool closing
        readonly property string folder: scope.folder

        signal captured(path: string, screen: ShellScreen, aspect: real)

        onCaptured: (path, screen, aspect) => thumbnail.show(path, screen, aspect)

        Variants {
            model: Screens.screens

            StyledWindow {
                id: win

                required property ShellScreen modelData

                screen: modelData
                name: "area-picker"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: picker.closing ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
                mask: picker.closing ? empty : null

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true

                Region {
                    id: empty
                }

                Picker {
                    loader: picker
                    screen: win.modelData
                }
            }
        }
    }

    Thumbnail {
        id: thumbnail
    }

    IpcHandler {
        function open(): void {
            scope.open();
        }

        target: "screenshot"
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshot"
        description: "Take a screenshot"
        onPressed: scope.open()
    }
}
