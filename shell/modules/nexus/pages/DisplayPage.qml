pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

// Yui Settings > Displays: arrange screens by dragging them, pick resolution,
// refresh rate, scale and rotation. Changes are tried live and reverted unless
// kept within a few seconds (YuiDisplays).
PageBase {
    id: root

    // Working copy of the layout being edited
    property list<var> config: []
    property int selected: 0
    readonly property var current: config[selected] ?? null
    readonly property bool dirty: JSON.stringify(strip(config)) !== JSON.stringify(strip(YuiDisplays.monitors))

    function strip(list: list<var>): list<var> {
        return list.map(m => [m.name, m.width, m.height, Math.round(m.refresh), Math.round(m.x), Math.round(m.y), m.scale, m.transform]);
    }

    function reset(): void {
        config = YuiDisplays.monitors.map(m => Object.assign({}, m));
        if (selected >= config.length)
            selected = 0;
    }

    function update(changes: var): void {
        const c = config.map(m => Object.assign({}, m));
        Object.assign(c[selected], changes);
        config = arrange(c, selected);
    }

    // Close gaps and overlaps after a size change or a drag: the moved screen
    // snaps to the nearest edge of another one, then everything starts at 0,0
    function arrange(c: list<var>, moved: int): list<var> {
        if (c.length > 1) {
            const m = c[moved];
            const w = YuiDisplays.logicalWidth(m), h = YuiDisplays.logicalHeight(m);
            let best = null;
            c.forEach((o, i) => {
                if (i === moved)
                    return;
                const ow = YuiDisplays.logicalWidth(o), oh = YuiDisplays.logicalHeight(o);
                const clampY = y => Math.max(o.y - h + 40, Math.min(o.y + oh - 40, y));
                const clampX = x => Math.max(o.x - w + 40, Math.min(o.x + ow - 40, x));
                const snap = (v, target) => Math.abs(v - target) < 60 ? target : v;
                const candidates = [
                    {
                        x: o.x - w,
                        y: snap(clampY(m.y), o.y)
                    },
                    {
                        x: o.x + ow,
                        y: snap(clampY(m.y), o.y)
                    },
                    {
                        x: snap(clampX(m.x), o.x),
                        y: o.y - h
                    },
                    {
                        x: snap(clampX(m.x), o.x),
                        y: o.y + oh
                    }
                ];
                for (const p of candidates) {
                    const d = Math.hypot(p.x - m.x, p.y - m.y);
                    if (!best || d < best.d)
                        best = {
                            x: p.x,
                            y: p.y,
                            d
                        };
                }
            });
            if (best) {
                m.x = Math.round(best.x);
                m.y = Math.round(best.y);
            }
        }
        const minX = Math.min(...c.map(m => m.x)), minY = Math.min(...c.map(m => m.y));
        for (const m of c) {
            m.x -= minX;
            m.y -= minY;
        }
        return c;
    }

    title: Tr.tr("Displays")

    Component.onCompleted: {
        YuiDisplays.refresh();
        reset();
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        Connections {
            target: YuiDisplays

            function onMonitorsChanged(): void {
                if (!YuiDisplays.pending)
                    root.reset();
            }
        }

        // Arrangement
        StyledRect {
            id: canvas

            readonly property real pad: 28
            readonly property var bounds: {
                const c = root.config;
                if (!c.length)
                    return {
                        x: 0,
                        y: 0,
                        w: 1,
                        h: 1
                    };
                const x0 = Math.min(...c.map(m => m.x)), y0 = Math.min(...c.map(m => m.y));
                const x1 = Math.max(...c.map(m => m.x + YuiDisplays.logicalWidth(m))), y1 = Math.max(...c.map(m => m.y + YuiDisplays.logicalHeight(m)));
                return {
                    x: x0,
                    y: y0,
                    w: x1 - x0,
                    h: y1 - y0
                };
            }
            readonly property real k: Math.min((width - pad * 2) / bounds.w, (height - pad * 2) / bounds.h)
            readonly property real ox: (width - bounds.w * k) / 2 - bounds.x * k
            readonly property real oy: (height - bounds.h * k) / 2 - bounds.y * k

            Layout.fillWidth: true
            implicitHeight: 240
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainer

            Repeater {
                model: root.config.length

                StyledRect {
                    id: screenRect

                    required property int index
                    readonly property var mon: root.config[index]
                    readonly property bool isSelected: root.selected === index

                    // Dragging overrides these; released, they bind to the layout again
                    x: canvas.ox + mon.x * canvas.k
                    y: canvas.oy + mon.y * canvas.k
                    width: YuiDisplays.logicalWidth(mon) * canvas.k
                    height: YuiDisplays.logicalHeight(mon) * canvas.k
                    z: dragArea.drag.active ? 2 : 1
                    radius: Tokens.rounding.small
                    color: isSelected ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHighest
                    border.width: isSelected ? 2 : 1
                    border.color: isSelected ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outline, 0.5)

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: screenRect.mon.model || screenRect.mon.name
                            font.weight: Font.Medium
                            color: screenRect.isSelected ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: `${screenRect.mon.width}×${screenRect.mon.height}`
                            font.pointSize: Tokens.font.body.small.pointSize * 0.9
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }

                    MouseArea {
                        id: dragArea

                        anchors.fill: parent
                        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        drag.target: root.config.length > 1 ? screenRect : null
                        drag.threshold: 4
                        onPressed: root.selected = screenRect.index
                        onReleased: {
                            if (!drag.active)
                                return;
                            const c = root.config.map(m => Object.assign({}, m));
                            c[screenRect.index].x = (screenRect.x - canvas.ox) / canvas.k;
                            c[screenRect.index].y = (screenRect.y - canvas.oy) / canvas.k;
                            root.config = root.arrange(c, screenRect.index);
                            screenRect.x = Qt.binding(() => canvas.ox + screenRect.mon.x * canvas.k);
                            screenRect.y = Qt.binding(() => canvas.oy + screenRect.mon.y * canvas.k);
                        }
                    }
                }
            }

            StyledText {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 6
                visible: root.config.length > 1
                text: Tr.tr("Drag the screens to match how they sit on your desk")
                font.pointSize: Tokens.font.body.small.pointSize * 0.9
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        // Apply / keep / revert
        RowLayout {
            Layout.topMargin: Tokens.spacing.medium
            Layout.fillWidth: true
            visible: YuiDisplays.pending || root.dirty
            spacing: Tokens.spacing.medium

            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: YuiDisplays.pending ? Tr.tr("Keep these display settings? Reverting in %1 s").arg(YuiDisplays.secondsLeft) : root.dirty ? Tr.tr("You have changes that are not applied yet") : ""
                color: YuiDisplays.pending ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                font.weight: YuiDisplays.pending ? Font.Medium : Font.Normal
            }

            TextButton {
                visible: YuiDisplays.pending || root.dirty
                text: YuiDisplays.pending ? Tr.tr("Revert") : Tr.tr("Reset")
                type: TextButton.Tonal
                onClicked: YuiDisplays.pending ? YuiDisplays.revert() : root.reset()
            }

            TextButton {
                visible: YuiDisplays.pending || root.dirty
                text: YuiDisplays.pending ? Tr.tr("Keep") : Tr.tr("Apply")
                type: TextButton.Filled
                onClicked: YuiDisplays.pending ? YuiDisplays.keep() : YuiDisplays.apply(root.config)
            }
        }

        SectionHeader {
            Layout.topMargin: Tokens.spacing.large
            first: true
            text: root.current ? `${root.current.make ?? ""} ${root.current.model || root.current.name}`.trim() : ""
        }

        SelectRow {
            first: true
            label: Tr.tr("Resolution")
            menuItems: resItems.instances
            active: resItems.instances.find(i => root.current && i.value.width === root.current.width && i.value.height === root.current.height) ?? null
            onSelected: item => {
                // Keep the refresh rate if the new resolution has it, else the highest
                const modes = root.current.modes.filter(m => m.width === item.value.width && m.height === item.value.height);
                const same = modes.find(m => Math.round(m.refresh) === Math.round(root.current.refresh));
                const mode = same ?? modes.sort((a, b) => b.refresh - a.refresh)[0];
                root.update({
                    width: mode.width,
                    height: mode.height,
                    refresh: mode.refresh
                });
            }

            Variants {
                id: resItems

                model: {
                    const seen = new Set();
                    return (root.current?.modes ?? []).filter(m => {
                        const k = `${m.width}x${m.height}`;
                        if (seen.has(k))
                            return false;
                        seen.add(k);
                        return true;
                    }).sort((a, b) => b.width * b.height - a.width * a.height);
                }

                MenuItem {
                    required property var modelData

                    text: `${modelData.width} × ${modelData.height}`
                    value: modelData
                }
            }
        }

        SelectRow {
            label: Tr.tr("Refresh rate")
            menuItems: rateItems.instances
            active: rateItems.instances.find(i => root.current && Math.round(i.value) === Math.round(root.current.refresh)) ?? null
            onSelected: item => root.update({
                    refresh: item.value
                })

            Variants {
                id: rateItems

                model: (root.current?.modes ?? []).filter(m => m.width === root.current.width && m.height === root.current.height).map(m => m.refresh).sort((a, b) => b - a)

                MenuItem {
                    required property real modelData

                    text: `${Math.round(modelData)} Hz`
                    value: modelData
                }
            }
        }

        SelectRow {
            label: Tr.tr("Scale")
            subtext: Tr.tr("Bigger text and controls, less space")
            menuItems: scaleItems.instances
            active: scaleItems.instances.find(i => root.current && Math.abs(i.value - root.current.scale) < 0.01) ?? null
            onSelected: item => root.update({
                    scale: item.value
                })

            Variants {
                id: scaleItems

                model: {
                    const list = [1, 1.25, 1.333333, 1.5, 1.6, 1.666667, 1.75, 2, 2.5, 3];
                    const s = root.current?.scale;
                    if (s && !list.some(v => Math.abs(v - s) < 0.01))
                        list.push(s);
                    return list.sort((a, b) => a - b);
                }

                MenuItem {
                    required property real modelData

                    text: `${Math.round(modelData * 100)}%`
                    value: modelData
                }
            }
        }

        SelectRow {
            last: true
            label: Tr.tr("Rotation")
            menuItems: root.rotationItems
            active: root.rotationItems.find(i => root.current && i.value === root.current.transform) ?? null
            onSelected: item => root.update({
                    transform: item.value
                })
        }

    }

    readonly property list<MenuItem> rotationItems: [
        MenuItem {
            text: Tr.tr("Normal")
            value: 0
        },
        MenuItem {
            text: Tr.tr("90°")
            value: 1
        },
        MenuItem {
            text: Tr.tr("180°")
            value: 2
        },
        MenuItem {
            text: Tr.tr("270°")
            value: 3
        }
    ]
}
