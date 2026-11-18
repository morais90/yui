pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.components.misc
import qs.services

// Spotlight: one search box for apps, calculations, settings, files and the
// web, centred on the focused screen. Esc or a click outside closes it.
Scope {
    id: root

    property bool open
    // Text to put in the search box when it opens (IPC)
    property string initialText
    // Screen it shows on: the focused one when it opened
    property string screenName

    onOpenChanged: {
        if (open)
            screenName = Hypr.focusedMonitor?.name ?? "";
    }

    function toggle(): void {
        initialText = "";
        open = !open;
    }

    Variants {
        model: Screens.screens

        SpotlightWindow {
            required property ShellScreen modelData

            screen: modelData
            spotlight: root
        }
    }

    // Triggered from Hyprland: hl.dsp.global("caelestia:spotlight")
    CustomShortcut {
        name: "spotlight"
        description: "Spotlight: search apps, files, settings and the web"
        onPressed: root.toggle()
    }

    IpcHandler {
        target: "spotlight"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.initialText = "";
            root.open = true;
        }

        function close(): void {
            root.open = false;
        }

        // Open with a query already typed (tests, future AI layer)
        function search(text: string): void {
            root.open = false;
            root.initialText = text;
            root.open = true;
        }
    }
}
