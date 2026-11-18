//@ pragma IconTheme Papirus-Dark
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Yui window switcher (the dock lives in the Yui Shell: shell/modules/dock).
ShellRoot {
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
