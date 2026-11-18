import QtQuick
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services

// One app in the dock: icon, running indicator, name tooltip.
// Click launches it, or focuses / cycles through its windows.
Item {
    id: root

    required property var app // { appId, windows }
    required property Item dock
    property int size: 46
    property real maxMagnify: 1.45
    property real pointerX: -10000

    signal menuRequested

    readonly property bool running: app.windows.length > 0
    readonly property bool focused: app.windows.some(w => w.activated)

    // Grows with pointer proximity (macOS-like)
    readonly property real magnify: {
        const center = mapToItem(dock, width / 2, 0).x;
        const d = Math.abs(pointerX - center) / (size * 1.8);
        return 1 + (maxMagnify - 1) * Math.max(0, 1 - d * d);
    }

    implicitWidth: size
    implicitHeight: size

    StyledRect {
        anchors.fill: parent
        anchors.margins: -Tokens.padding.extraSmall
        radius: Tokens.rounding.large
        color: Colours.palette.m3onSurface
        opacity: root.focused ? 0.08 : 0

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    // Rendered at max size and scaled down, so magnified icons stay sharp
    IconImage {
        id: icon

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        implicitSize: root.size * root.maxMagnify
        transformOrigin: Item.Bottom
        scale: root.magnify / root.maxMagnify
        source: YuiWindows.icon(root.app.appId)
        mipmap: true
        asynchronous: true

        transform: Translate {
            id: bounce
        }

        Behavior on scale {
            Anim {
                type: Anim.FastSpatial
            }
        }
    }

    SequentialAnimation {
        id: bounceAnim

        loops: 2

        Anim {
            target: bounce
            property: "y"
            to: -root.size * 0.3
            type: Anim.EmphasizedSmall
        }
        Anim {
            target: bounce
            property: "y"
            to: 0
            type: Anim.StandardSmall
        }
    }

    // Running indicator: dot, stretches into a pill on the focused app
    StyledRect {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: Tokens.padding.extraSmall / 2
        implicitWidth: root.focused ? root.size * 0.35 : 5
        implicitHeight: 4
        radius: Tokens.rounding.full
        color: root.focused ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
        opacity: root.running ? 1 : 0

        Behavior on implicitWidth {
            Anim {}
        }
        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    // Name tooltip
    StyledRect {
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height - root.size * (root.magnify - 1) - Tokens.spacing.medium
        implicitWidth: label.implicitWidth + Tokens.padding.large * 2
        implicitHeight: label.implicitHeight + Tokens.padding.small * 2
        radius: Tokens.rounding.full
        color: Colours.palette.m3inverseSurface
        opacity: area.containsMouse && !root.dock.menuOpen ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            Anim {
                type: Anim.FastEffects
            }
        }

        StyledText {
            id: label

            anchors.centerIn: parent
            text: YuiWindows.name(root.app.appId)
            color: Colours.palette.m3inverseOnSurface
            font: Tokens.font.body.small
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.menuRequested();
                return;
            }
            const wins = root.app.windows;
            if (wins.length === 0 || mouse.button === Qt.MiddleButton) {
                YuiWindows.launch(root.app.appId);
                bounceAnim.restart();
                return;
            }
            const current = wins.findIndex(w => w.activated);
            YuiWindows.activate(wins[(current + 1) % wins.length]);
        }
    }
}
