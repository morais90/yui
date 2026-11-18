pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.services
import qs.utils

// Yui window helpers shared by the dock and the window switcher:
// grouping by app, recency, minimize/restore, launch and pinned apps.
// Minimized windows live on the special:minimized workspace (see yui-minimize).
Singleton {
    id: root

    readonly property string minimizedWorkspace: "special:minimized"
    readonly property list<string> pinned: dockState.pinned
    readonly property bool dockAutoHide: dockState.autoHide

    // Most recently used window addresses (front = last focused)
    property list<string> mru: []

    Connections {
        target: Hypr

        function onActiveToplevelChanged(): void {
            const t = Hypr.activeToplevel;
            if (!t)
                return;
            const a = root.address(t);
            root.mru = [a, ...root.mru.filter(x => x !== a)];
        }
    }

    // Pinned apps persist in ~/.local/state/caelestia/dock.json
    FileView {
        path: `${Paths.state}/dock.json`
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: dockState

            property list<string> pinned: ["org.kde.dolphin", "google-chrome", "com.mitchellh.ghostty"]
            property bool autoHide: false
        }
    }

    function isPinned(appId: string): bool {
        return pinned.includes(appId);
    }

    function pin(appId: string): void {
        if (!isPinned(appId))
            dockState.pinned = [...dockState.pinned, appId];
    }

    function unpin(appId: string): void {
        dockState.pinned = dockState.pinned.filter(id => id !== appId);
    }

    function setDockAutoHide(on: bool): void {
        dockState.autoHide = on;
    }

    function address(t: HyprlandToplevel): string {
        const a = t.address;
        return a.startsWith("0x") ? a : "0x" + a;
    }

    function appId(t: HyprlandToplevel): string {
        return t.wayland?.appId || t.lastIpcObject?.class || "";
    }

    function isMinimized(t: HyprlandToplevel): bool {
        return t.workspace?.name === minimizedWorkspace;
    }

    function entry(appId: string): DesktopEntry {
        return DesktopEntries.heuristicLookup(appId);
    }

    function icon(appId: string): string {
        const e = entry(appId);
        for (const name of [e?.icon, appId, appId.toLowerCase()])
            if (name && (name.startsWith("/") || Quickshell.hasThemeIcon(name)))
                return name.startsWith("/") ? `file://${name}` : Quickshell.iconPath(name);
        return Quickshell.iconPath("application-x-executable");
    }

    function name(appId: string): string {
        return entry(appId)?.name ?? appId;
    }

    // Normal windows (positive workspaces) plus minimized ones
    function all(): list<HyprlandToplevel> {
        return Hypr.toplevels.values.filter(t => t.workspace && (t.workspace.id > 0 || isMinimized(t)));
    }

    // Most recent first; falls back to Hyprland's focus history for unseen windows
    function byRecency(list: list<HyprlandToplevel>): list<HyprlandToplevel> {
        const rank = t => {
            const i = mru.indexOf(address(t));
            if (i >= 0)
                return i;
            return 1000 + (t.lastIpcObject?.focusHistoryID ?? 1000);
        };
        return [...list].sort((a, b) => rank(a) - rank(b));
    }

    // Focus and raise; minimized windows grow back out of the dock (yui-minimize)
    function activate(t: HyprlandToplevel): void {
        const a = address(t);
        if (isMinimized(t)) {
            Quickshell.execDetached(["yui-minimize", "restore", a]);
            return;
        }
        Hypr.dispatch(`hl.dsp.focus({ window = "address:${a}" })`);
        Hypr.dispatch(`hl.dsp.window.alter_zorder({ window = "address:${a}", mode = "top" })`);
    }

    // Hyprland ignores close requests for windows on hidden special workspaces
    function close(t: HyprlandToplevel): void {
        if (isMinimized(t))
            Hypr.dispatch(`hl.dsp.window.move({ window = "address:${address(t)}", workspace = "${Hypr.activeWsId}" })`);
        Hypr.dispatch(`hl.dsp.window.close({ window = "address:${address(t)}" })`);
    }

    function launch(appId: string): void {
        entry(appId)?.execute();
    }

    Component.onCompleted: Hyprland.refreshToplevels()
}
