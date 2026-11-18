pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.effects
import qs.services

StyledWindow {
    id: win

    required property var switcher

    readonly property bool shown: switcher.open && switcher.activeScreen === screen
    readonly property int cardWidth: 280
    readonly property int thumbHeight: 170

    name: "switcher"
    visible: shown || panel.opacity > 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    mask: Region {
        item: win.shown ? panel : null
    }

    onShownChanged: if (shown)
        keys.forceActiveFocus()

    HyprlandFocusGrab {
        windows: [win]
        active: win.shown
        onCleared: win.switcher.cancel()
    }

    Item {
        id: keys

        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right)
                win.switcher.move(1);
            else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Left)
                win.switcher.move(-1);
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                win.switcher.commit();
            else if (event.key === Qt.Key_Escape)
                win.switcher.cancel();
            event.accepted = true;
        }
        Keys.onReleased: event => {
            if (event.key === Qt.Key_Alt || event.key === Qt.Key_AltGr)
                win.switcher.commit();
        }
    }

    Elevation {
        anchors.fill: panel
        radius: panel.radius
        level: 3
        opacity: panel.opacity
        scale: panel.scale
    }

    StyledRect {
        id: panel

        readonly property real maxWidth: win.width - Tokens.padding.extraLarge * 4

        anchors.centerIn: parent
        implicitWidth: Math.min(cards.contentWidth + Tokens.padding.large * 2, maxWidth)
        implicitHeight: win.thumbHeight + title.height + Tokens.spacing.medium + Tokens.padding.large * 2
        radius: Tokens.rounding.extraLarge
        color: Colours.tPalette.m3surface
        opacity: win.shown ? 1 : 0
        scale: win.shown ? 1 : 0.92

        Behavior on opacity {
            Anim {
                type: Anim.FastEffects
            }
        }
        Behavior on scale {
            Anim {
                type: Anim.FastSpatial
            }
        }

        // Title of the selected window
        StyledText {
            id: title

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Tokens.padding.large
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Tokens.padding.large * 2
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font: Tokens.font.body.medium
            text: {
                const t = win.switcher.windows[win.switcher.index];
                return t ? (t.title || YuiWindows.name(YuiWindows.appId(t))) : "";
            }
        }

        ListView {
            id: cards

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Tokens.padding.large
            height: win.thumbHeight
            orientation: ListView.Horizontal
            spacing: Tokens.spacing.medium
            interactive: false
            model: win.shown ? win.switcher.windows : []
            currentIndex: win.switcher.index
            highlightMoveDuration: 150
            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: width / 2 - win.cardWidth / 2
            preferredHighlightEnd: width / 2 + win.cardWidth / 2

            delegate: Item {
                id: card

                required property HyprlandToplevel modelData
                required property int index
                readonly property bool selected: index === win.switcher.index

                implicitWidth: win.cardWidth
                implicitHeight: win.thumbHeight
                scale: selected ? 1 : 0.94

                Behavior on scale {
                    Anim {
                        type: Anim.FastSpatial
                    }
                }

                StyledRect {
                    anchors.fill: parent
                    anchors.margins: -Tokens.padding.extraSmall
                    radius: Tokens.rounding.large + Tokens.padding.extraSmall
                    color: Colours.palette.m3primary
                    opacity: card.selected ? 1 : 0

                    Behavior on opacity {
                        Anim {
                            type: Anim.FastEffects
                        }
                    }
                }

                ClippingRectangle {
                    anchors.fill: parent
                    radius: Tokens.rounding.large
                    color: Colours.palette.m3surfaceContainerHigh

                    ScreencopyView {
                        id: preview

                        anchors.fill: parent
                        captureSource: win.shown ? card.modelData.wayland : null
                        live: true
                    }

                    IconImage {
                        visible: !preview.hasContent
                        anchors.centerIn: parent
                        implicitSize: parent.height * 0.4
                        source: YuiWindows.icon(YuiWindows.appId(card.modelData))
                    }
                }

                // App icon badge
                StyledRect {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: Tokens.padding.small
                    implicitWidth: badge.implicitSize + Tokens.padding.small * 2
                    implicitHeight: implicitWidth
                    radius: Tokens.rounding.full
                    color: Colours.tPalette.m3surfaceContainer

                    IconImage {
                        id: badge

                        anchors.centerIn: parent
                        implicitSize: 28
                        source: YuiWindows.icon(YuiWindows.appId(card.modelData))
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: win.switcher.index = card.index
                    onClicked: win.switcher.commit()
                }
            }
        }
    }
}
