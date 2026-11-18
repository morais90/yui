# Apps

## Purpose

The few apps Yui ships with, one for each everyday job, chosen so the system feels like one
piece from the first boot.

## Experience

| Job | App | Opens |
|---|---|---|
| Terminal | Ghostty | see [Terminal](terminal.md) |
| Files | Dolphin | folders |
| Text and code | Zed | `.txt`, Markdown, config files, scripts and source code |
| Images | Loupe | `.png`, `.jpg`, screenshots |
| Archives | Ark | `.zip`, `.7z`, `.tar` (and "Extract here" in Dolphin) |

Double-clicking a file opens it in the app above; you never land in a terminal editor by
surprise.

## Decisions

- **Zed is the one editor** for both quick notes and programming (principle 4): it opens
  instantly, renders on the GPU, looks good, and is written in Rust, the direction Yui is going.
  It replaces the need for a separate "TextEdit"-style app.
- **Defaults are system-wide** (`/etc/xdg/mimeapps.list`), so your own choices in
  `~/.config/mimeapps.list` always win.

## Open

- Zed's look should follow the wallpaper colours like the rest of the system (principle 2).
- Dolphin and Ark are KDE apps; their look differs a little from the rest of Yui.
