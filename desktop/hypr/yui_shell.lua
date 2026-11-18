-- Yui Shell integration (shell/ = Caelestia fork with the Yui dock and switcher).
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

-- Alt+Tab / Alt+Shift+Tab: window switcher (shell/modules/switcher)
hl.bind("ALT + TAB",         hl.dsp.global("caelestia:switcherNext"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.global("caelestia:switcherPrev"))

-- Mission Control: Super+Up or a three-finger swipe up (shell/modules/overview)
hl.bind("SUPER + up", hl.dsp.global("caelestia:overview"))
hl.gesture({
    fingers   = 3,
    direction = "up",
    action    = { finish = function() hl.dispatch(hl.dsp.global("caelestia:overview")) end },
})

-- Blur behind the Mission Control backdrop
hl.layer_rule({
    name  = "yui-overview-blur",
    match = { namespace = "^caelestia-overview$" },
    blur  = true,
    ignore_alpha = 0.1,
})
