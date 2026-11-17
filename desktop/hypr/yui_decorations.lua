-- Yui window decorations: floating windows by default and title bars with
-- minimize / maximize / close buttons (hyprbars plugin).

------------------ FLOATING BY DEFAULT ------------------
-- New windows open floating, at the size the app asks for, centered,
-- instead of being tiled to fill the screen. Super+V toggles tiling per window.
hl.window_rule({
    name  = "float-by-default",
    match = { class = ".*" },
    float = true,
    center = true,
})

------------------ TITLE BARS (hyprbars) ------------------
local HYPRBARS = "/usr/lib/libhyprbars.so"

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

if not file_exists(HYPRBARS) then
    return  -- plugin not installed: keep working without title bars
end

hl.plugin.load(HYPRBARS)

hl.config({
    plugin = {
        hyprbars = {
            bar_height            = 28,
            bar_color             = "rgba(1e2030f2)",
            ["col.text"]          = "rgb(cdd6f4)",
            bar_text_font         = "Noto Sans",
            bar_text_size         = 11,
            bar_text_align        = "left",
            bar_padding           = 12,
            bar_button_padding    = 8,
            bar_part_of_window    = true,
            bar_precedence_over_border = true,
            icon_on_hover         = true,
            inactive_button_color = "rgb(585b70)",
            on_double_click       = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
        },
    },
})

-- Buttons are added right to left: close, maximize, minimize
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(f38ba8)", fg_color = "rgb(1e1e2e)", size = 14, icon = "󰖭",
    action = [[hyprctl dispatch 'hl.dsp.window.close()']],
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(a6e3a1)", fg_color = "rgb(1e1e2e)", size = 14, icon = "󰖯",
    action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(f9e2af)", fg_color = "rgb(1e1e2e)", size = 14, icon = "󰖰",
    action = "yui-minimize",
})

-- No title bar on the launcher, menus and other shell windows
hl.window_rule({
    name  = "no-bar-shell",
    match = { class = "^(wofi|hyprlauncher|hyprland-run|hyprpolkitagent)$" },
    ["hyprbars:no_bar"] = true,
})
