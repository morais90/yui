pragma Singleton
import QtQuick
import Quickshell

// Yui visual language (Catppuccin Mocha palette).
Singleton {
    readonly property color base:     "#1e1e2e"
    readonly property color mantle:   "#181825"
    readonly property color surface:  "#313244"
    readonly property color overlay:  "#6c7086"
    readonly property color text:     "#cdd6f4"
    readonly property color subtext:  "#a6adc8"
    readonly property color accent:   "#89b4fa"
    readonly property color accent2:  "#cba6f7"
    readonly property color yellow:   "#f9e2af"

    // Glass surfaces: translucent, blurred by Hyprland (see yui.lua layer rules)
    readonly property color glass:       Qt.rgba(0.12, 0.12, 0.18, 0.55)
    readonly property color glassBorder: Qt.rgba(1, 1, 1, 0.10)

    readonly property string font: "Noto Sans"
    readonly property int radius: 22

    // Motion: one spring for everything, so the shell feels like one object
    readonly property int fast: 140
    readonly property int normal: 240
}
