pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.components.misc
import qs.services

// Mission Control: every window of each screen's active workspace zooms out
// from its real position into a grid with live previews, on all screens at
// once. Click a window to bring it to the front; Esc or click the
// background to go back.
Scope {
    id: root

    property bool open
    // Window to focus once the closing animation starts
    property var chosen: null

    function toggle(): void {
        if (open)
            close(null);
        else {
            chosen = null;
            open = true;
        }
    }

    function close(t: var): void {
        if (!open)
            return;
        chosen = t;
        open = false;
        if (t)
            YuiWindows.activate(t);
    }

    Variants {
        id: windows

        model: Screens.screens

        OverviewWindow {
            required property ShellScreen modelData

            screen: modelData
            overview: root
        }
    }

    // One grab for all screens: clicking outside the overview windows closes it
    HyprlandFocusGrab {
        windows: windows.instances
        active: root.open && windows.instances.every(w => w.visible)
        onCleared: root.close(null)
    }

    // Triggered from Hyprland: hl.dsp.global("caelestia:overview")
    CustomShortcut {
        name: "overview"
        description: "Mission Control: show all windows"
        onPressed: root.toggle()
    }

    IpcHandler {
        target: "overview"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            if (!root.open)
                root.toggle();
        }

        function close(): void {
            root.close(null);
        }
    }
}
