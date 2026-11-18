pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.components.misc
import qs.services

// Alt+Tab window switcher with live previews, most recent first.
// Hold Alt and tap Tab to move; release Alt (or click) to switch; Esc cancels.
Scope {
    id: root

    property bool open
    property list<HyprlandToplevel> windows: []
    property int index
    property ShellScreen activeScreen

    function show(step: int): void {
        if (open) {
            move(step);
            return;
        }
        windows = YuiWindows.byRecency(YuiWindows.all());
        if (windows.length === 0)
            return;
        index = windows.length > 1 ? (step > 0 ? 1 : windows.length - 1) : 0;
        activeScreen = Screens.screens.find(s => Hypr.monitorFor(s) === Hypr.focusedMonitor) ?? Screens.screens[0];
        open = true;
    }

    function move(step: int): void {
        if (windows.length > 0)
            index = (index + step + windows.length) % windows.length;
    }

    function commit(): void {
        if (!open)
            return;
        const t = windows[index];
        open = false;
        if (t)
            YuiWindows.activate(t);
    }

    function cancel(): void {
        open = false;
    }

    Variants {
        model: Screens.screens

        SwitcherWindow {
            required property ShellScreen modelData

            screen: modelData
            switcher: root
        }
    }

    // Triggered from Hyprland: hl.dsp.global("caelestia:switcherNext")
    CustomShortcut {
        name: "switcherNext"
        description: "Window switcher: next window"
        onPressed: root.show(1)
    }

    CustomShortcut {
        name: "switcherPrev"
        description: "Window switcher: previous window"
        onPressed: root.show(-1)
    }

    // Scriptable control (caelestia shell switcher <fn>) for tests and the future AI layer
    IpcHandler {
        target: "switcher"

        function next(): void {
            root.show(1);
        }

        function prev(): void {
            root.show(-1);
        }

        function commit(): void {
            root.commit();
        }

        function cancel(): void {
            root.cancel();
        }
    }
}
