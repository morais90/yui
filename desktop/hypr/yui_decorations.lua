-- Yui window decorations: floating windows by default and macOS-style title
-- bars (hyprbars plugin): traffic-light buttons on the left, centered title.

------------------ FLOATING BY DEFAULT ------------------
-- New windows open floating, at the size the app asks for, centered,
-- instead of being tiled to fill the screen. Super+V toggles tiling per window.
hl.window_rule({
    name  = "float-by-default",
    match = { class = ".*" },
    float = true,
    center = true,
})

-- Terminals ask for odd sizes when floating: give them a comfortable default
hl.window_rule({
    name  = "terminal-size",
    match = { class = "^(kitty|com\\.mitchellh\\.ghostty|foot|Alacritty|org\\.wezfurlong\\.wezterm)$" },
    size  = { 1100, 700 },
})

------------------ SNAPPING (yui-snap plugin) ------------------
-- Drag a window to a screen edge or corner to snap it to a half or a quarter
-- (top edge fills the screen). The plugin reports the drag; the Yui Shell
-- shows the preview and runs yui-snap. See plugins/yui-snap.
local YUI_SNAP = "/usr/lib/libyui-snap.so"
do
    local f = io.open(YUI_SNAP, "r")
    if f then
        f:close()
        hl.plugin.load(YUI_SNAP)
    end
end

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
if not hl.plugin.hyprbars then
    return  -- plugin failed to load (or config is only being verified)
end

-- Colors follow the Yui Shell scheme (generated from the wallpaper by the
-- Yui CLI in ~/.config/hypr/scheme/current.lua), with dark fallbacks.
local scheme = { surfaceContainer = "201f23", onSurfaceVariant = "c8c5d1", outlineVariant = "47464f" }
do
    local path = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr/scheme/current.lua"
    local ok, loaded = pcall(dofile, path)
    if ok and type(loaded) == "table" then
        for k, v in pairs(loaded) do scheme[k] = v end
    end
end

hl.config({
    plugin = {
        hyprbars = {
            bar_height            = 32,
            bar_color             = "rgb(" .. scheme.surfaceContainer .. ")",
            ["col.text"]          = "rgb(" .. scheme.onSurfaceVariant .. ")",
            bar_text_font         = "Rubik Medium",
            bar_text_size         = 10,
            bar_text_align        = "center",
            bar_buttons_alignment = "left",
            bar_padding           = 12,
            bar_button_padding    = 8,
            bar_part_of_window    = true,
            bar_precedence_over_border = true,
            icon_on_hover         = true,
            inactive_button_color = "rgb(" .. scheme.outlineVariant .. ")",  -- grey lights on inactive windows
            on_double_click       = [[yui-maximize]],
        },
    },
})

-- Traffic lights (macOS colors), left to right: close, minimize, zoom.
-- Symbols show on hover. Buttons are added from the outer edge inwards.
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(ff5f57)", fg_color = "rgb(4d0000)", size = 13, icon = "",
    action = [[hyprctl dispatch 'hl.dsp.window.close()']],
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(febc2e)", fg_color = "rgb(5a3a00)", size = 13, icon = "",
    action = "yui-minimize",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(28c840)", fg_color = "rgb(004d00)", size = 13, icon = "",
    action = [[yui-maximize]],
})

-- Chromium-based browsers draw their own macOS-like title bar: tabs with the
-- window buttons on the left (button layout set by yui-setup)
hl.window_rule({
    name  = "no-bar-browsers",
    match = { class = "^(google-chrome|chromium|brave-browser|microsoft-edge)$" },
    ["hyprbars:no_bar"] = true,
})

-- No title bar on the launcher, menus and other shell windows
hl.window_rule({
    name  = "no-bar-shell",
    match = { class = "^(wofi|hyprlauncher|hyprland-run|hyprpolkitagent)$" },
    ["hyprbars:no_bar"] = true,
})
