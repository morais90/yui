# Yui defaults for fish, loaded from vendor_conf.d before the user's
# ~/.config/fish/config.fish (which can override anything here).

status is-interactive; or exit

# No greeting banner
set -g fish_greeting ""

# Starship prompt: the user's ~/.config/starship.toml wins, else Yui's theme
if command -q starship
    if not test -e ~/.config/starship.toml; and not set -q STARSHIP_CONFIG
        set -gx STARSHIP_CONFIG /usr/share/yui/starship/starship.toml
    end
    starship init fish | source
end
