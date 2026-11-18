pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Caelestia
import Caelestia.I18n
import qs.components
import qs.components.effects
import qs.services

MouseArea {
    id: root

    required property LazyLoader loader
    required property ShellScreen screen

    property bool onClient

    property real realBorderWidth: 2
    property real realRounding: onClient ? (Hypr.options["decoration:rounding"] ?? 0) : 0

    property real ssx
    property real ssy

    property real sx: 0
    property real sy: 0
    property real ex: screen.width
    property real ey: screen.height

    property real rsx: Math.min(sx, ex)
    property real rsy: Math.min(sy, ey)
    property real sw: Math.abs(sx - ex)
    property real sh: Math.abs(sy - ey)

    property list<var> clients: {
        const mon = Hypr.monitorFor(screen);
        if (!mon)
            return [];

        const special = mon.lastIpcObject?.specialWorkspace;
        const wsId = special?.name ? special.id : mon.activeWorkspace?.id;
        if (wsId === undefined)
            return [];

        return Hypr.toplevelsForWs(wsId).sort((a, b) => {
            // Pinned first, then fullscreen, then floating, then any other
            const ac = a?.lastIpcObject;
            const bc = b?.lastIpcObject;
            if (!ac || !bc)
                return !ac - !bc; // Missing IPC last
            return (bc.pinned - ac.pinned) || ((bc.fullscreen !== 0) - (ac.fullscreen !== 0)) || (bc.floating - ac.floating);
        });
    }

    function checkClientRects(x: real, y: real): void {
        for (const client of clients) {
            if (!client)
                continue;

            const ipc = client.lastIpcObject;
            if (!ipc?.at || !ipc?.size)
                continue;

            let {
                at: [cx, cy],
                size: [cw, ch]
            } = ipc;
            cx -= screen.x;
            cy -= screen.y;
            if (cx <= x && cy <= y && cx + cw >= x && cy + ch >= y) {
                onClient = true;
                sx = cx;
                sy = cy;
                ex = cx + cw;
                ey = cy + ch;
                return;
            }
        }
        onClient = false;
        sx = 0;
        sy = 0;
        ex = screen.width;
        ey = screen.height;
    }

    // Save to Pictures/Screenshots, copy to the clipboard, then show the thumbnail
    function save(): void {
        const name = `Screenshot ${Qt.formatDateTime(new Date(), "yyyy-MM-dd 'at' HH.mm.ss")}.png`;
        const file = Qt.resolvedUrl(`${root.loader.folder}/${name}`);
        const rect = Qt.rect(Math.ceil(rsx), Math.ceil(rsy), Math.floor(sw), Math.floor(sh));
        CUtils.saveItem(screencopy, file, rect, path => {
            Quickshell.execDetached(["sh", "-c", "wl-copy --type image/png < \"$1\"", "sh", path]);
            root.loader.captured(path, root.screen, rect.width / Math.max(1, rect.height));
            closeAnim.start();
        });
    }

    onClientsChanged: checkClientRects(mouseX, mouseY)

    anchors.fill: parent
    opacity: 0
    hoverEnabled: true
    cursorShape: Qt.CrossCursor

    Component.onCompleted: {
        Hypr.extras.refreshOptions();

        // Break binding if frozen
        if (loader.freeze)
            clients = clients;

        opacity = 1;

        const ipc = clients[0]?.lastIpcObject;
        if (ipc?.at && ipc?.size) {
            const cx = ipc.at[0] - screen.x;
            const cy = ipc.at[1] - screen.y;
            onClient = true;
            sx = cx;
            sy = cy;
            ex = cx + ipc.size[0];
            ey = cy + ipc.size[1];
        } else {
            sx = 0;
            sy = 0;
            ex = screen.width;
            ey = screen.height;
        }
    }

    onPressed: event => {
        ssx = event.x;
        ssy = event.y;
    }

    onReleased: {
        if (closeAnim.running)
            return;

        if (root.loader.freeze) {
            save();
        } else {
            overlay.visible = border.visible = false;
            screencopy.visible = false;
            screencopy.active = true;
        }
    }

    onPositionChanged: event => {
        const x = event.x;
        const y = event.y;

        if (pressed && Math.abs(x - ssx) + Math.abs(y - ssy) > 6) {
            onClient = false;
            sx = ssx;
            sy = ssy;
            ex = x;
            ey = y;
        } else if (!pressed) {
            checkClientRects(x, y);
        }
    }

    focus: true
    Keys.onEscapePressed: closeAnim.start()

    SequentialAnimation {
        id: closeAnim

        PropertyAction {
            target: root.loader
            property: "closing"
            value: true
        }
        ParallelAnimation {
            Anim {
                target: root
                property: "opacity"
                to: 0
                type: Anim.StandardLarge
            }
            Anim {
                target: root
                properties: "rsx,rsy"
                to: 0
            }
            Anim {
                target: root
                property: "sw"
                to: root.screen.width
            }
            Anim {
                target: root
                property: "sh"
                to: root.screen.height
            }
        }
        PropertyAction {
            target: root.loader
            property: "activeAsync"
            value: false
        }
    }

    Process {
        running: true
        command: ["hyprctl", "cursorpos", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const pos = JSON.parse(text);
                root.checkClientRects(pos.x - root.screen.x, pos.y - root.screen.y);
            }
        }
    }

    Loader {
        id: screencopy

        asynchronous: true
        anchors.fill: parent

        active: root.loader.freeze

        sourceComponent: ScreencopyView {
            captureSource: root.screen

            onHasContentChanged: {
                if (hasContent && !root.loader.freeze) {
                    overlay.visible = border.visible = true;
                    root.save();
                }
            }
        }
    }

    // Dim everything outside the selection (four plain rectangles: no shader,
    // and it stands out on any wallpaper)
    Item {
        id: overlay

        anchors.fill: parent

        Rectangle {
            color: "black"
            opacity: 0.45
            x: 0
            y: 0
            width: parent.width
            height: Math.max(0, root.rsy)
        }
        Rectangle {
            color: "black"
            opacity: 0.45
            x: 0
            y: root.rsy + root.sh
            width: parent.width
            height: Math.max(0, parent.height - y)
        }
        Rectangle {
            color: "black"
            opacity: 0.45
            x: 0
            y: root.rsy
            width: Math.max(0, root.rsx)
            height: root.sh
        }
        Rectangle {
            color: "black"
            opacity: 0.45
            x: root.rsx + root.sw
            y: root.rsy
            width: Math.max(0, parent.width - x)
            height: root.sh
        }
    }

    Item {
        id: selectionWrapper

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            id: selectionRect

            radius: root.realRounding
            x: root.rsx
            y: root.rsy
            implicitWidth: root.sw
            implicitHeight: root.sh
        }
    }

    Rectangle {
        id: border

        color: "transparent"
        radius: root.realRounding > 0 ? root.realRounding + root.realBorderWidth : 0
        border.width: root.realBorderWidth
        border.color: Colours.palette.m3primary

        x: selectionRect.x - root.realBorderWidth
        y: selectionRect.y - root.realBorderWidth
        implicitWidth: selectionRect.implicitWidth + root.realBorderWidth * 2
        implicitHeight: selectionRect.implicitHeight + root.realBorderWidth * 2

        Behavior on border.color {
            CAnim {}
        }
    }

    Behavior on opacity {
        Anim {
            type: Anim.StandardLarge
        }
    }

    Behavior on rsx {
        enabled: !root.pressed

        Anim {}
    }

    Behavior on rsy {
        enabled: !root.pressed

        Anim {}
    }

    Behavior on sw {
        enabled: !root.pressed

        Anim {}
    }

    Behavior on sh {
        enabled: !root.pressed

        Anim {}
    }
}
