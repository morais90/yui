-- Yui Shell (Quickshell) integration: dock, window switcher.

-- Alt+Tab / Alt+Shift+Tab open the window switcher (GlobalShortcut in shell.qml)
hl.bind("ALT + TAB",         hl.dsp.global("quickshell:switcher-next"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.global("quickshell:switcher-prev"))

-- Glass: blur behind the shell's translucent surfaces
hl.layer_rule({
    name  = "yui-shell-glass",
    match = { namespace = "^yui-(dock|switcher)$" },
    blur  = true,
    ignore_alpha = 0.2,
})
