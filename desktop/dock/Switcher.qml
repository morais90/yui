import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io

// Alt+Tab window switcher with live previews, most recent first.
// Hold Alt and tap Tab to move; release Alt (or click) to switch; Esc cancels.
PanelWindow {
    id: sw

    property var windows: []
    property int index: 0

    visible: false
    color: "transparent"
    WlrLayershell.namespace: "yui-switcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: panel.width
    implicitHeight: panel.height

    function screenOfFocusedMonitor() {
        const m = Hyprland.focusedMonitor;
        return Quickshell.screens.find(s => m && s.name === m.name) || Quickshell.screens[0];
    }

    function open(step) {
        if (visible) { move(step); return; }
        windows = Windows.byRecency(Windows.all());
        if (windows.length === 0) return;
        index = windows.length > 1 ? (step > 0 ? 1 : windows.length - 1) : 0;
        screen = screenOfFocusedMonitor();
        visible = true;
        keys.forceActiveFocus();
    }

    function move(step) {
        if (windows.length === 0) return;
        index = (index + step + windows.length) % windows.length;
    }

    function commit() {
        if (!visible) return;
        const t = windows[index];
        visible = false;
        if (t) Windows.activate(t);
    }

    function cancel() { visible = false; }

    // Scriptable control (qs ipc call switcher <fn>) for tests and the future AI layer
    IpcHandler {
        target: "switcher"
        function next(): void { sw.open(1); }
        function prev(): void { sw.open(-1); }
        function commit(): void { sw.commit(); }
        function cancel(): void { sw.cancel(); }
    }

    HyprlandFocusGrab {
        windows: [sw]
        active: sw.visible
        onCleared: sw.cancel()
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right) sw.move(1);
            else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Left) sw.move(-1);
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) sw.commit();
            else if (event.key === Qt.Key_Escape) sw.cancel();
            event.accepted = true;
        }
        Keys.onReleased: event => {
            if (event.key === Qt.Key_Alt || event.key === Qt.Key_AltGr) sw.commit();
        }
    }

    Rectangle {
        id: panel
        readonly property int cardWidth: 260
        readonly property int maxWidth: (sw.screen ? sw.screen.width : 1600) - 120
        readonly property int contentWidth: sw.windows.length * (cardWidth + cards.spacing) - cards.spacing
        width: Math.min(contentWidth + 32, maxWidth)
        height: 200 + 32
        radius: Theme.radius + 6
        color: Theme.glass
        border.color: Theme.glassBorder

        ListView {
            id: cards
            anchors.fill: parent
            anchors.margins: 16
            orientation: ListView.Horizontal
            spacing: 14
            model: sw.windows
            currentIndex: sw.index
            highlightMoveDuration: Theme.fast
            interactive: false

            delegate: Item {
                id: card
                required property var modelData
                required property int index
                readonly property bool selected: index === sw.index
                width: panel.cardWidth
                height: 200
                scale: selected ? 1.0 : 0.94
                opacity: selected ? 1.0 : 0.75
                Behavior on scale { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.fast } }

                ClippingRectangle {
                    id: thumb
                    width: parent.width
                    height: 160
                    radius: 14
                    color: Theme.surface
                    border.color: card.selected ? Theme.accent : Theme.glassBorder
                    border.width: card.selected ? 2 : 1

                    ScreencopyView {
                        id: preview
                        anchors.fill: parent
                        anchors.margins: 2
                        captureSource: sw.visible ? card.modelData.wayland : null
                        live: true
                    }

                    IconImage {
                        visible: !preview.hasContent
                        anchors.centerIn: parent
                        implicitSize: 72
                        source: Windows.icon(Windows.appId(card.modelData))
                    }
                }

                Row {
                    anchors.top: thumb.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 8
                    spacing: 8
                    IconImage {
                        implicitSize: 22
                        source: Windows.icon(Windows.appId(card.modelData))
                    }
                    Text {
                        width: parent.width - 30
                        anchors.verticalCenter: parent.verticalCenter
                        text: card.modelData.title || Windows.name(Windows.appId(card.modelData))
                        elide: Text.ElideRight
                        color: card.selected ? Theme.text : Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: sw.index = card.index
                    onClicked: sw.commit()
                }
            }
        }
    }
}
