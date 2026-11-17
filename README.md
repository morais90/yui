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
| `yui-shell` | Starts the Yui Shell (dock, window switcher) |
| `yui-waybar`, `yui-config-run` | Choose between the user's config and Yui's default |

## Windows

Windows open **floating** and centered, at the size the app asks for, with a title bar
(hyprbars plugin) holding minimize, maximize and close buttons. Double-click the title bar
to maximize.

## Yui Shell

The dock and the window switcher are built with [Quickshell](https://quickshell.org) (QML),
in `desktop/shell`, and run as the `yui-shell` user service.

- **Dock**: pinned and running apps, magnification on hover, launch bounce, running/focused
  indicators. Minimized windows appear on the right with a thumbnail: left click restores,
  right click closes.
- **Window switcher**: `Alt+Tab` / `Alt+Shift+Tab` show live previews of every window, most
  recent first. Release `Alt` or click a preview to switch; `Esc` cancels.
- **IPC**: `qs -p /usr/share/yui/shell ipc call switcher next|prev|commit|cancel`, the entry
  point for scripts and the future AI layer.

Development: `YUI_SHELL_DIR=~/code/yui/desktop/shell` (systemd drop-in) runs the shell from
the checkout with hot reload.

## Terminal

**Ghostty** is the default terminal (set in `/etc/xdg/xdg-terminals.list`, used by `xdg-terminal-exec`),
themed with Catppuccin Mocha. `Ctrl+C` copies when text is selected (otherwise it interrupts the
running command) and `Ctrl+V` pastes. Personal settings go in `~/.config/ghostty/custom.ghostty`.

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
| `Alt+Tab` / `Super+Tab` | Window switcher / previous workspace |
| `Super+G` | Group windows into tabs |
| `Super+Shift+V` | Clipboard history |
| `Print` / `Shift+Print` | Region screenshot (copy) / full screenshot (save) |

## Roadmap

- [x] Package model (`yui-base`, `yui-desktop`, `yui-nvidia`)
- [x] Automatic brightness device detection (no per-machine config)
- [x] Floating windows with title bars (minimize, maximize, close)
- [x] Yui Shell phase 1: dock and window switcher (Quickshell)
- [ ] Yui Shell phase 2: overview + search (Mission Control / Spotlight)
- [ ] Yui Shell phase 3: top bar replaces Waybar
- [ ] Yui pacman repository (GitHub Releases + Actions), including hyprbars from AUR
- [ ] btrfs snapshots (snapper, snap-pac, grub-btrfs)
- [ ] Test installation in a VM
- [ ] AI layer
- [ ] ISO with archiso

## License

[MIT](LICENSE)
