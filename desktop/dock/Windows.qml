pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Helpers shared by the dock and the switcher.
Singleton {
    id: root

    readonly property string minimizedWorkspace: "special:minimized"

    // Most-recently-used window addresses (front = last focused)
    property var mru: []

    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            const t = Hyprland.activeToplevel;
            if (!t) return;
            const a = root.address(t);
            root.mru = [a].concat(root.mru.filter(x => x !== a));
        }
    }

    // Seed with Hyprland's own focus history (lastIpcObject.focusHistoryID)
    Component.onCompleted: Hyprland.refreshToplevels()

    function byRecency(list) {
        const rank = t => {
            const i = mru.indexOf(address(t));
            if (i >= 0) return i;
            const h = t.lastIpcObject ? t.lastIpcObject.focusHistoryID : undefined;
            return 1000 + (h === undefined ? 1000 : h);
        };
        return list.slice().sort((a, b) => rank(a) - rank(b));
    }

    function address(t) {
        const a = t.address;
        return a.startsWith("0x") ? a : "0x" + a;
    }

    function appId(t) {
        if (t.wayland && t.wayland.appId) return t.wayland.appId;
        return (t.lastIpcObject && t.lastIpcObject.class) || "";
    }

    function isMinimized(t) {
        return !!t.workspace && t.workspace.name === minimizedWorkspace;
    }

    function entry(appId) {
        return DesktopEntries.heuristicLookup(appId);
    }

    function icon(appId) {
        const e = entry(appId);
        const candidates = [e && e.icon, appId, appId.toLowerCase(), "application-x-executable"];
        for (const name of candidates)
            if (name && (name.startsWith("/") || Quickshell.hasThemeIcon(name)))
                return name.startsWith("/") ? "file://" + name : Quickshell.iconPath(name);
        return Quickshell.iconPath("application-x-executable");
    }

    function name(appId) {
        const e = entry(appId);
        return e ? e.name : appId;
    }

    // Normal (non-special) windows, plus minimized ones
    function all() {
        return Hyprland.toplevels.values.filter(t =>
            t.workspace && (t.workspace.id > 0 || isMinimized(t)));
    }

    // Bring a window to the user: restore it if minimized, then focus and raise it
    function activate(t) {
        const a = address(t);
        if (isMinimized(t)) {
            const ws = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1;
            Hyprland.dispatch(`hl.dsp.window.move({ window = "address:${a}", workspace = "${ws}" })`);
        }
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${a}" })`);
        Hyprland.dispatch(`hl.dsp.window.alter_zorder({ window = "address:${a}", mode = "top" })`);
    }

    // Close a window; minimized windows are restored first (Hyprland ignores
    // close requests for windows on hidden special workspaces)
    function close(t) {
        const a = address(t);
        if (isMinimized(t)) activate(t);
        Hyprland.dispatch(`hl.dsp.window.close({ window = "address:${a}" })`);
    }

    function launch(appId) {
        const e = entry(appId);
        if (e) e.execute();
    }
}
