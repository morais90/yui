# Yui

> A personal operating system built on **Arch Linux + Hyprland**, designed to one day be managed entirely by an AI.
> Named after Yui from *Sword Art Online*: the AI that lives inside the system and looks after its users.

Hobby project. Yui is shipped as Arch packages; a bootable ISO will come later.

## How it works

Yui is distributed as **Arch packages** (`yui-*`). A machine running Yui does not need this repository: it only has the packages, updated by `pacman`.

| Package | Contents |
|---|---|
| `yui-base` | Network, audio, Bluetooth and base tools |
| `yui-desktop` | Hyprland plus Yui's defaults in `/usr/share/yui`, Waybar, lock/idle, `yui-*` scripts |
| `yui-nvidia` | NVIDIA GPU support |

Defaults live in `/usr/share/yui`. User configs in `~/.config` always take precedence:

- `~/.config/hypr/hyprland.lua` loads `/usr/share/yui/hypr/yui.lua`, then applies the user's overrides.
- Waybar, hyprlock, hypridle and hyprpaper use the user's config if it exists, otherwise Yui's.

## Repository layout

| Folder | Contents |
|---|---|
| `desktop/` | Files installed by `yui-desktop` (configs, scripts, service drop-ins) |
| `pkgs/` | One `PKGBUILD` per package |
| `iso/` | (planned) archiso profile |
| `docs/` | Documentation and design decisions |

## Build and install (development)

```bash
cd pkgs/yui-desktop && makepkg -f
sudo pacman -U yui-desktop-*.pkg.tar.zst
yui-setup          # prepares the user's ~/.config (--reset restores Yui's defaults)
```

## Scripts

| Command | Purpose |
|---|---|
| `yui-setup` | Creates the user's `hyprland.lua` pointing to Yui's defaults |
| `yui-brightness` | Internal display brightness (picks the right device on hybrid laptops) |
| `yui-lock` | Locks the screen |
| `yui-power-menu` | Power menu |
| `yui-minimize` | Minimize / restore windows (Hyprland has no native minimize) |
| `yui-waybar`, `yui-config-run` | Choose between the user's config and Yui's default |

## Windows

Windows open **floating** and centered, at the size the app asks for, with a title bar
(hyprbars plugin) holding minimize, maximize and close buttons. Double-click the title bar
to maximize. Minimized windows show up as a counter in Waybar; click it to restore one.

## Session startup

The session is **Hyprland (uwsm-managed)**, started by SDDM. Autostart happens in three layers:

1. **systemd user services**: waybar, hyprpaper, hypridle, hyprpolkitagent
2. **`/etc/xdg/autostart`** (run by uwsm): nm-applet, blueman-applet
3. **`hl.on("hyprland.start")`** in `yui.lua`: cliphist

## Keybinds (`Super` = Windows key)

| Keybind | Action |
|---|---|
| `Super+Q` / `Super+R` / `Super+E` | Terminal / launcher / file manager |
| `Super+C` | Close window |
| `Super+V` | Toggle floating / tiling for a window |
| `Super+L` | Lock screen |
| `Super+F` / `Super+Shift+F` | Fullscreen / maximize |
| `Super+Shift+arrows` | Move window |
| `Super+Ctrl+arrows` | Resize window |
| `Super+Alt+←/→` | Send window to the other monitor |
| `Alt+Tab` / `Super+Tab` | Cycle windows / previous workspace |
| `Super+G` | Group windows into tabs |
| `Super+Shift+V` | Clipboard history |
| `Print` / `Shift+Print` | Region screenshot (copy) / full screenshot (save) |

## Roadmap

- [x] Package model (`yui-base`, `yui-desktop`, `yui-nvidia`)
- [x] Automatic brightness device detection (no per-machine config)
- [x] Floating windows with title bars (minimize, maximize, close)
- [ ] Yui pacman repository (GitHub Releases + Actions), including hyprbars from AUR
- [ ] btrfs snapshots (snapper, snap-pac, grub-btrfs)
- [ ] Test installation in a VM
- [ ] AI layer
- [ ] ISO with archiso

## License

[MIT](LICENSE)
