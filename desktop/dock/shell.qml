//@ pragma IconTheme Papirus-Dark
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Yui Shell entry point.
ShellRoot {
    // One dock per monitor
    Variants {
        model: Quickshell.screens
        delegate: Dock {
            required property var modelData
            screen: modelData
        }
    }

    Switcher { id: switcher }

    // Triggered from Hyprland: hl.dsp.global("quickshell:switcher-next")
    GlobalShortcut {
        name: "switcher-next"
        description: "Window switcher: next window"
        onPressed: switcher.open(1)
    }
    GlobalShortcut {
        name: "switcher-prev"
        description: "Window switcher: previous window"
        onPressed: switcher.open(-1)
    }
}
