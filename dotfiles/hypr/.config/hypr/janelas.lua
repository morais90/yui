-- Melhorias de gerenciamento de janelas
local mainMod = "SUPER"

hl.config({
    general = { resize_on_border = true },   -- redimensionar arrastando a borda
})

------------------ ATALHOS ------------------
-- Tela cheia / maximizar (mantém a Waybar)
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Mover janela: Super+Shift+setas
for _, d in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + SHIFT + " .. d, hl.dsp.window.move({ direction = d }))
end

-- Redimensionar: Super+Ctrl+setas (segure para repetir)
local passo = 40
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x =  passo, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -passo, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y =  passo, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -passo, relative = true }), { repeating = true })

-- Mandar janela para o outro monitor: Super+Alt+setas
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.move({ monitor = "l", follow = true }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.move({ monitor = "r", follow = true }))

-- Alternar janelas
hl.bind("ALT + TAB",           hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT + TAB",   hl.dsp.window.cycle_next({ next = false }))
hl.bind(mainMod .. " + TAB",   hl.dsp.focus({ workspace = "previous" }))   -- workspace anterior

-- Fixar janela flutuante em todos os workspaces / centralizar
hl.bind(mainMod .. " + Y", hl.dsp.window.pin())
hl.bind(mainMod .. " + X", hl.dsp.window.center())

-- Abas (grupos): Super+G cria/desfaz, Super+Alt+Tab troca de aba
hl.bind(mainMod .. " + G",         hl.dsp.group.toggle())
hl.bind(mainMod .. " + ALT + TAB", hl.dsp.group.next())

------------------ REGRAS ------------------
-- Janelas pequenas de configuração abrem flutuando e centralizadas
hl.window_rule({
    name  = "dialogos-flutuantes",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|blueman-manager|\\.?blueman-manager-wrapped|nm-connection-editor|nwg-look|hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1)$" },
    float = true, center = true, size = { 900, 600 },
})

-- Diálogos de abrir/salvar arquivo
hl.window_rule({
    name  = "seletor-de-arquivos",
    match = { title = "^(Abrir.*|Salvar.*|Open.*|Save.*|Escolher.*|Selecionar.*)$" },
    float = true, center = true, size = { 1000, 650 },
})

-- Picture-in-picture do Chrome: flutua, fica em todos os workspaces, canto inferior direito
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture.in.[Pp]icture|Picture-in-Picture)$" },
    float = true, pin = true, keep_aspect_ratio = true,
    size = { 480, 270 }, move = "monitor_w-500 monitor_h-290",
})

-- Não bloquear/apagar a tela enquanto algo estiver em tela cheia (vídeos, jogos)
hl.window_rule({
    name  = "sem-idle-em-tela-cheia",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})
