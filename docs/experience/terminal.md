# Terminal

## Purpose

A terminal that is pleasant from the first second, with no configuration needed.

## Experience

- **Ghostty** runs the **fish** shell: it suggests the rest of a command from your history as
  you type (→ accepts it), colours commands, and completes options with descriptions.
- The prompt is **Starship** with the *Tokyo Night* theme: folder, git branch and status, time.
- Accents work as on any other app (´ + e = é).
- Programs installed in `~/.local/bin` are found.
- **Developer basics come installed**: git (with `less` for `git log`), and Docker with
  Compose and Buildx, usable without `sudo`.

## Decisions

- **fish over zsh or bash**: it is helpful out of the box, with no plugins to maintain.
  Scripts keep using bash through their `#!/bin/bash` line.
- **Defaults are system-wide** (`/usr/share/fish/vendor_conf.d/yui.fish`), so your own
  `~/.config/fish/config.fish` and `~/.config/starship.toml` always win.
- **Docker starts on first use** (socket activation), not at boot: no daemon running for people
  who don't use it (principle 1). Users are added to the `docker` group on install.
- **Dead keys use GTK's own composer** (`GTK_IM_MODULE=simple`), since Yui runs no input-method
  service.

## Open

- The Tokyo Night prompt has fixed colours; decide whether it should follow the wallpaper like
  the rest of the system (principle 2).
