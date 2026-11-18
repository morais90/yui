import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

// Reloads Hyprland when the Yui CLI regenerates the color scheme
// (~/.config/hypr/scheme/current.lua, e.g. after a wallpaper change), so
// title bars follow the wallpaper colors like the rest of the shell.
Scope {
    FileView {
        path: `${Paths.home}/.config/hypr/scheme/current.lua`
        watchChanges: true
        printErrors: false
        onFileChanged: reloadTimer.restart()
    }

    // Debounce: the scheme file and others are written in a burst
    Timer {
        id: reloadTimer

        interval: 500
        onTriggered: Quickshell.execDetached(["hyprctl", "reload"])
    }
}
