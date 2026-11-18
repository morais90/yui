-- Yui Shell integration (shell/ = Caelestia fork with the Yui dock and switcher).
-- Most features are reachable with the mouse; these keys are shortcuts.

-- Spotlight opens only from the Y on the bar (docs/principles.md, one way to
-- do each thing).

-- Panels
hl.bind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"))     -- power / session menu
hl.bind("SUPER + N",           hl.dsp.global("caelestia:sidebar"))     -- notifications sidebar
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

-- Blur behind the Spotlight panel (the rest of its layer is transparent)
hl.layer_rule({
    name  = "yui-spotlight-blur",
    match = { namespace = "^caelestia-spotlight$" },
    blur  = true,
    ignore_alpha = 0.5,
})
