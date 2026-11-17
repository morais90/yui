-- Yui window management: extra keybinds and window rules.
local mainMod = "SUPER"

hl.config({
    general = { resize_on_border = true },   -- resize windows by dragging their borders
})

------------------ KEYBINDS ------------------
-- Fullscreen / maximize (keeps the bar visible)
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Move window: Super+Shift+arrows
for _, d in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + SHIFT + " .. d, hl.dsp.window.move({ direction = d }))
end

-- Resize: Super+Ctrl+arrows (hold to repeat)
local step = 40
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x =  step, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y =  step, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })

-- Send window to the other monitor: Super+Alt+arrows
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.move({ monitor = "l", follow = true }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.move({ monitor = "r", follow = true }))

-- Previous workspace (Alt+Tab is handled by the Yui Shell switcher, see yui_shell.lua)
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))

-- Pin a floating window on all workspaces / center it
hl.bind(mainMod .. " + Y", hl.dsp.window.pin())
hl.bind(mainMod .. " + X", hl.dsp.window.center())

-- Tabs (groups): Super+G toggles, Super+Alt+Tab cycles tabs
hl.bind(mainMod .. " + G",         hl.dsp.group.toggle())
hl.bind(mainMod .. " + ALT + TAB", hl.dsp.group.next())

------------------ WINDOW RULES ------------------
-- Small settings apps open floating and centered
hl.window_rule({
    name  = "floating-dialogs",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|blueman-manager|\\.?blueman-manager-wrapped|nm-connection-editor|nwg-look|hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1)$" },
    float = true, center = true, size = { 900, 600 },
})

-- File open/save dialogs (English and Portuguese titles)
hl.window_rule({
    name  = "file-pickers",
    match = { title = "^(Open.*|Save.*|Abrir.*|Salvar.*|Escolher.*|Selecionar.*)$" },
    float = true, center = true, size = { 1000, 650 },
})

-- Browser picture-in-picture: floating, on every workspace, bottom-right corner
hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^(Picture.in.[Pp]icture|Picture-in-Picture)$" },
    float = true, pin = true, keep_aspect_ratio = true,
    size = { 480, 270 }, move = "monitor_w-500 monitor_h-290",
})

-- Don't lock or blank the screen while something is fullscreen (videos, games)
hl.window_rule({
    name  = "no-idle-when-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})
