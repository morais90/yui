# Yui

> A personal operating system built on **Arch Linux + Hyprland**, designed to one day be managed entirely by an AI.
> Named after Yui from *Sword Art Online*: the AI that lives inside the system and looks after its users.

Hobby project. Yui is shipped as Arch packages; a bootable ISO will come later.

## How it works

Yui is distributed as **Arch packages** (`yui-*`). A machine running Yui does not need this repository: it only has the packages, updated by `pacman`.

| Package | Contents |
|---|---|
| `yui-base` | Network, audio, Bluetooth and base tools |
| `yui-shell` | The Yui Shell: bar, launcher, dashboard, notifications, OSD, lock screen, wallpaper and dynamic colors (fork of Caelestia) |
| `yui-cli` | Shell control, color schemes, wallpapers, screenshots (fork of the Caelestia CLI) |
| `yui-desktop` | Hyprland plus Yui's defaults in `/usr/share/yui`, the Yui dock and window switcher, idle, `yui-*` scripts |
| `yui-nvidia` | NVIDIA GPU support |

Defaults live in `/usr/share/yui`. User configs in `~/.config` always take precedence:

- `~/.config/hypr/hyprland.lua` loads `/usr/share/yui/hypr/yui.lua`, then applies the user's overrides.
- hypridle and Ghostty use the user's config if it exists, otherwise Yui's.

## Repository layout

| Folder | Contents |
|---|---|
| `shell/` | Yui Shell, imported from [Caelestia shell](https://github.com/caelestia-dots/shell) (GPL-3.0) |
| `cli/` | Yui CLI, imported from [Caelestia CLI](https://github.com/caelestia-dots/cli) (GPL-3.0) |
| `desktop/` | Files installed by `yui-desktop` (configs, scripts, service drop-ins) |
| `plugins/` | Yui's Hyprland plugins (C++), e.g. `yui-snap`; rebuilt for every Hyprland version |
| `pkgs/` | One `PKGBUILD` per Yui package; `pkgs/third-party` holds reviewed recipes for dependencies outside the official repos |
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
| `yui-lock` | Locks the screen (Yui Shell lock screen) |
| `yui-snap` | Snaps a window to a half, quarter or the whole free area (`left`, `topright`, `top`...) |
| `yui-maximize` | Zoom (macOS-style): fills the free area of the monitor, toggles back; used by the maximize button |
| `yui-minimize` | Minimize / restore windows (Hyprland has no native minimize) |
| `yui-config-run` | Chooses between the user's config and Yui's default |

## Windows

Windows open **floating** and centered, at the size the app asks for, with a title bar
(hyprbars plugin) holding minimize, maximize and close buttons. Double-click the title bar
to maximize.

## Yui Shell

The desktop interface is built with [Quickshell](https://quickshell.org) (QML) on top of
[Caelestia](https://github.com/caelestia-dots/shell), imported into `shell/` and `cli/` with
`git subtree` so upstream fixes can be pulled in:

```bash
git subtree pull --prefix=shell caelestia-shell main --squash
git subtree pull --prefix=cli caelestia-cli main --squash
```

It provides the bar, launcher (tap `Super`), dashboard, notifications sidebar, on-screen
displays, session menu, lock screen and wallpaper-based colors. It runs as the `yui-shell`
user service (`qs -c caelestia`).

Yui adds:

- **Dock** (`shell/modules/dock`): a drawer that grows out of the bottom border like the
  other panels, with the same wallpaper-based colors. Pinned and running apps, magnification
  on hover, launch bounce, running/focused indicators. Minimized windows appear on the right
  with a thumbnail: left click restores, right click closes. Right click an app to keep it in
  or remove it from the dock (saved in `~/.local/state/caelestia/dock.json`). It slides away while the
  launcher is open and in fullscreen, and windows don't go under it.
- **Window switcher** (`shell/modules/switcher`): `Alt+Tab` / `Alt+Shift+Tab` show live previews of every window, most
  recent first. Release `Alt` or click a preview to switch; `Esc` cancels.
- **Mission Control** (`shell/modules/overview`): `Super+↑` or a three-finger swipe up shows
  every window of each screen side by side, zooming out from their real positions. Click a
  window to bring it to the front; `Esc` or click the background to go back.
- **IPC**: `qs -c caelestia ipc call switcher next|prev|commit|cancel`, `... overview toggle`, the entry
  point for scripts and the future AI layer.

## Session startup

The session is **Hyprland (uwsm-managed)**, started by SDDM. Autostart happens in three layers:

1. **systemd user services**: yui-shell, hypridle, hyprpolkitagent
2. **`/etc/xdg/autostart`** (run by uwsm): nm-applet, blueman-applet
3. **`hl.on("hyprland.start")`** in `yui.lua`: cliphist

## Keybinds (`Super` = Windows key)

| Keybind | Action |
|---|---|
| `Super` (tap) or `Super+R` | Launcher |
| `Super+Q` / `Super+E` | Terminal / file manager |
| `Super+N` / `Super+K` | Notifications sidebar / all panels |
| `Ctrl+Alt+Del` | Session menu (lock, log out, reboot, shut down) |
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
- [x] Yui Shell based on Caelestia (bar, launcher, dashboard, notifications, lock)
- [x] Dock as a native Yui Shell drawer
- [x] Window switcher in the Yui Shell's visual language
- [x] Mission Control (Super+Up or three-finger swipe up)
- [x] macOS-style windows: traffic lights, click to focus, zoom, minimize into the dock, dock auto-hide
- [x] Snap windows by dragging them to screen edges and corners (yui-snap plugin)
- [ ] Spotlight-style search
- [x] Yui logo in the bar, dashboard, lock screen and About page
- [ ] Rebrand the remaining identifiers (`caelestia` command, config paths) and os-release
- [ ] Yui pacman repository (GitHub Releases + Actions), including hyprbars from AUR
- [ ] btrfs snapshots (snapper, snap-pac, grub-btrfs)
- [ ] Test installation in a VM
- [ ] AI layer
- [ ] ISO with archiso

## License

Yui is [MIT](LICENSE), **except** `shell/` and `cli/`, which are derived from
[Caelestia](https://github.com/caelestia-dots) by soramane and contributors and remain under
the GPL-3.0 (see `shell/LICENSE` and `cli/LICENSE`). Packages in `pkgs/third-party` keep their
upstream licenses.
