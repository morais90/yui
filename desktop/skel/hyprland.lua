-- Your personal Hyprland config.
-- Yui's defaults live in /usr/share/yui/hypr and are updated by pacman.
-- Anything you set below this line overrides them.
package.path = "/usr/share/yui/hypr/?.lua;" .. package.path
require("yui")

-- Examples:
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "auto-right", scale = 1 })
-- hl.config({ general = { gaps_out = 10 } })
