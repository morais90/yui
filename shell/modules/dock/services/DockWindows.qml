pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services

// Window helpers for the Yui dock: grouping by app, minimize/restore, launch.
// Minimized windows live on the special:minimized workspace (see yui-minimize).
Singleton {
    id: root

    readonly property string minimizedWorkspace: "special:minimized"

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

    // Restore if minimized, then focus and raise
    function activate(t: HyprlandToplevel): void {
        const a = address(t);
        if (isMinimized(t))
            Hypr.dispatch(`hl.dsp.window.move({ window = "address:${a}", workspace = "${Hypr.activeWsId}" })`);
        Hypr.dispatch(`hl.dsp.focus({ window = "address:${a}" })`);
        Hypr.dispatch(`hl.dsp.window.alter_zorder({ window = "address:${a}", mode = "top" })`);
    }

    // Hyprland ignores close requests for windows on hidden special workspaces
    function close(t: HyprlandToplevel): void {
        if (isMinimized(t))
            activate(t);
        Hypr.dispatch(`hl.dsp.window.close({ window = "address:${address(t)}" })`);
    }

    function launch(appId: string): void {
        entry(appId)?.execute();
    }
}
