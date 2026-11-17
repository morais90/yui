-- Yui Shell integration (shell/ = Caelestia fork, desktop/dock = Yui dock).
-- Most features are reachable with the mouse; these keys are shortcuts.

local release = { release = true }

-- Launcher: tap Super alone (or Super+R)
hl.bind("SUPER + SUPER_L", hl.dsp.global("caelestia:launcher"), release)
hl.bind("SUPER + R",       hl.dsp.global("caelestia:launcher"))

-- Panels
hl.bind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"))     -- power / session menu
hl.bind("SUPER + N",           hl.dsp.global("caelestia:sidebar"))     -- notifications sidebar
hl.bind("SUPER + K",           hl.dsp.global("caelestia:showall"))     -- launcher + dashboard + OSD
hl.bind("CTRL + ALT + C",      hl.dsp.global("caelestia:clearNotifs"), { locked = true })

-- Alt+Tab / Alt+Shift+Tab: Yui window switcher (desktop/dock)
hl.bind("ALT + TAB",         hl.dsp.global("quickshell:switcher-next"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.global("quickshell:switcher-prev"))

-- Glass: blur behind the Yui dock and switcher
hl.layer_rule({
    name  = "yui-dock-glass",
    match = { namespace = "^yui-(dock|switcher)$" },
    blur  = true,
    ignore_alpha = 0.2,
})
