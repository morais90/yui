pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.modules.nexus

StyledWindow {
    id: win

    required property var spotlight

    readonly property bool active: spotlight.open && spotlight.screenName === screen.name
    property real progress: active ? 1 : 0

    property string query
    property list<var> fileResults: []
    property string calcResult
    readonly property bool isMath: query.length > 1 && query.length < 120 && /\d/.test(query) && /[-+*\/^%()]|\bto\b|\bin\b|^=/.test(query)
    readonly property list<var> results: buildResults()

    name: "spotlight"
    visible: progress > 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    Behavior on progress {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    onActiveChanged: {
        if (active) {
            field.text = spotlight.initialText;
            field.selectAll();
            field.forceActiveFocus();
            list.currentIndex = results.length ? 0 : -1;
        } else {
            field.text = "";
        }
    }

    // ---- Results -----------------------------------------------------------

    function item(section: string, title: string, subtitle: string, icon: string, symbol: string, run: var): var {
        return {
            section,
            title,
            subtitle,
            icon,
            symbol,
            run
        };
    }

    function matches(q: string, texts: list<var>): bool {
        const l = q.toLowerCase();
        return texts.some(t => (t ?? "").toLowerCase().includes(l));
    }

    function buildResults(): list<var> {
        const q = query.trim();
        if (!q)
            return [];
        const out = [];

        if (calcResult && !/error|warning/i.test(calcResult)) {
            const value = calcResult;
            out.push(item(qsTr("Calculator"), `= ${value}`, qsTr("Press Enter to copy"), "", "calculate", () => Quickshell.execDetached(["wl-copy", value])));
        }

        for (const e of Apps.search(q).slice(0, 5))
            out.push(item(qsTr("Applications"), e.name, e.genericName || e.comment || "", Quickshell.iconPath(e.icon, "application-x-executable"), "", () => Apps.launch(e)));

        const settings = [];
        PageRegistry.pages.forEach((p, i) => {
            if (matches(q, [p.label, p.description, p.category]))
                settings.push(item(qsTr("Settings"), p.label, p.description, "", p.icon, () => WindowFactory.create(null, {
                        initialPage: i
                    })));
        });
        for (const a of systemActions())
            if (matches(q, [a.title, a.keywords]))
                settings.push(item(qsTr("Settings"), a.title, a.subtitle, "", a.symbol, a.run));
        out.push(...settings.slice(0, 4));

        for (const f of fileResults.slice(0, 6))
            out.push(item(qsTr("Files"), f.name, f.dir, Quickshell.iconPath(f.icon, "text-x-generic"), "", () => Apps.open(f.path)));

        out.push(item(qsTr("Web"), qsTr("Search the web for “%1”").arg(q), "Google", "", "travel_explore", () => Apps.open(`https://www.google.com/search?q=${encodeURIComponent(q)}`)));
        return out;
    }

    function systemActions(): list<var> {
        const ipc = ["qs", "-c", "caelestia", "ipc", "call"];
        return [
            {
                title: qsTr("Mission Control"),
                subtitle: qsTr("Show all windows"),
                symbol: "view_compact",
                keywords: "overview windows expose",
                run: () => Quickshell.execDetached([...ipc, "overview", "open"])
            },
            {
                title: YuiWindows.dockAutoHide ? qsTr("Turn Dock Hiding Off") : qsTr("Turn Dock Hiding On"),
                subtitle: qsTr("Dock"),
                symbol: "dock_to_bottom",
                keywords: "dock hide autohide",
                run: () => YuiWindows.setDockAutoHide(!YuiWindows.dockAutoHide)
            },
            {
                title: qsTr("Lock Screen"),
                subtitle: qsTr("Session"),
                symbol: "lock",
                keywords: "lock session",
                run: () => Quickshell.execDetached([...ipc, "lock", "lock"])
            }
        ];
    }

    function activate(i: int): void {
        const r = results[i];
        if (!r)
            return;
        spotlight.open = false;
        r.run();
    }

    onQueryChanged: {
        calcResult = "";

        fileResults = [];
        fileTimer.restart();
    }
    onResultsChanged: list.currentIndex = results.length ? 0 : -1

    Process {
        id: calc

        property string expr

        command: ["qalc", "-t", expr]
        stdout: StdioCollector {
            onStreamFinished: {
                if (calc.expr === win.query.replace(/^=/, ""))
                    win.calcResult = text.trim();
            }
        }
    }

    // ---- Files -------------------------------------------------------------

    Timer {
        id: fileTimer

        interval: 120
        onTriggered: {
            files.running = false;
            calc.running = false;
            const q = win.query.trim();
            if (win.isMath) {
                calc.expr = q.replace(/^=/, "");
                calc.running = true;
            }
            if (q.length < 2 || win.isMath)
                return;
            files.query = q;
            files.running = true;
        }
    }

    Process {
        id: files

        property string query

        // Home, skipping hidden folders and build/dependency trees
        command: ["sh", "-c", `find "$HOME" -maxdepth 6 \\( -name '.*' -o -name node_modules -o -name __pycache__ -o -name target -o -name build \\) -prune -o -iname "*$1*" -printf '%y\\t%p\\n' 2>/dev/null | head -80`, "sh", query.replace(/[\[\]*?\\]/g, "\\$&")]
        stdout: StdioCollector {
            onStreamFinished: {
                if (files.query !== win.query.trim())
                    return;
                const q = files.query.toLowerCase();
                const home = Quickshell.env("HOME");
                win.fileResults = text.split("\n").filter(l => l).map(l => {
                    const [type, path] = l.split("\t");
                    const name = path.slice(path.lastIndexOf("/") + 1);
                    const dir = path.slice(0, path.lastIndexOf("/")).replace(home, "~");
                    const n = name.toLowerCase();
                    return {
                        path,
                        name,
                        dir,
                        icon: type === "d" ? "folder" : win.fileIcon(n),
                        score: (n.startsWith(q) ? 0 : 10) + path.split("/").length
                    };
                }).sort((a, b) => a.score - b.score);
            }
        }
    }

    function fileIcon(name: string): string {
        const ext = name.includes(".") ? name.slice(name.lastIndexOf(".") + 1) : "";
        if (/^(png|jpe?g|gif|webp|svg|bmp|avif)$/.test(ext))
            return "image-x-generic";
        if (/^(mp4|mkv|webm|mov|avi)$/.test(ext))
            return "video-x-generic";
        if (/^(mp3|flac|ogg|wav|m4a|opus)$/.test(ext))
            return "audio-x-generic";
        if (ext === "pdf")
            return "application-pdf";
        if (/^(zip|tar|gz|xz|zst|7z|rar)$/.test(ext))
            return "package-x-generic";
        if (/^(sh|py|js|ts|qml|lua|c|cpp|h|rs|go|java|json|toml|ya?ml)$/.test(ext))
            return "text-x-script";
        return "text-x-generic";
    }

    // ---- UI ----------------------------------------------------------------

    // Click outside the panel closes it
    MouseArea {
        anchors.fill: parent
        enabled: win.active
        onClicked: win.spotlight.open = false
    }

    Rectangle {
        id: panel

        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(win.height * 0.2)
        width: Math.min(680, win.width - 32)
        height: searchRow.height + (win.results.length ? divider.height + list.height + 12 : 0)
        radius: 18
        color: Qt.alpha(Colours.palette.m3surfaceContainer, 0.96)
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3outline, 0.35)
        clip: true

        opacity: win.progress
        scale: 0.96 + 0.04 * win.progress

        Behavior on height {
            Anim {
                type: Anim.DefaultSpatial
            }
        }

        // Swallow clicks so they don't close the panel
        MouseArea {
            anchors.fill: parent
        }

        Item {
            id: searchRow

            width: parent.width
            height: 60

            MaterialIcon {
                id: searchIcon

                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: "search"
                fontStyle: Tokens.font.icon.extraLarge
                color: Colours.palette.m3onSurfaceVariant
            }

            TextInput {
                id: field

                anchors.left: searchIcon.right
                anchors.right: parent.right
                anchors.leftMargin: 14
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Rubik"
                font.pointSize: 18
                color: Colours.palette.m3onSurface
                selectionColor: Qt.alpha(Colours.palette.m3primary, 0.4)
                clip: true
                onTextChanged: win.query = text

                Keys.onEscapePressed: win.spotlight.open = false
                Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
                Keys.onDownPressed: list.currentIndex = Math.min(win.results.length - 1, list.currentIndex + 1)
                Keys.onTabPressed: list.currentIndex = Math.min(win.results.length - 1, list.currentIndex + 1)
                Keys.onReturnPressed: win.activate(list.currentIndex)
                Keys.onEnterPressed: win.activate(list.currentIndex)

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !field.text
                    text: qsTr("Spotlight Search")
                    font.family: "Rubik"
                    font.pointSize: 18
                    color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.7)
                }
            }
        }

        Rectangle {
            id: divider

            anchors.top: searchRow.bottom
            width: parent.width
            height: 1
            color: Qt.alpha(Colours.palette.m3outline, 0.25)
            visible: win.results.length > 0
        }

        ListView {
            id: list

            anchors.top: divider.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            height: Math.min(contentHeight, 440)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 0
            model: win.results

            section.property: "section"
            section.delegate: StyledText {
                required property string section

                leftPadding: 12
                topPadding: 8
                bottomPadding: 4
                text: section
                font.pointSize: 9
                font.weight: Font.DemiBold
                color: Colours.palette.m3onSurfaceVariant
            }

            delegate: Item {
                id: row

                required property var modelData
                required property int index
                readonly property bool selected: ListView.isCurrentItem

                width: list.width
                height: 44

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: row.selected ? Qt.alpha(Colours.palette.m3primary, 0.22) : "transparent"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: list.currentIndex = row.index
                    onClicked: win.activate(row.index)
                }

                IconImage {
                    id: rowIcon

                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: 28
                    visible: !!row.modelData.icon
                    source: row.modelData.icon
                    asynchronous: true
                }

                MaterialIcon {
                    anchors.centerIn: rowIcon
                    visible: !row.modelData.icon
                    text: row.modelData.symbol
                    fontStyle: Tokens.font.icon.large
                    color: row.selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    id: title

                    anchors.left: rowIcon.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, row.width - 80)
                    text: row.modelData.title
                    elide: Text.ElideRight
                    font.pointSize: 11
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    anchors.left: title.right
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.subtitle
                    elide: Text.ElideMiddle
                    font.pointSize: 9.5
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }
}
