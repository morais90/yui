# Screenshots

## Purpose

Capture what is on the screen, the way macOS does it: one key, choose what to capture, and the
picture is both saved and ready to paste.

## Experience

1. **Press Print Screen.** The screen freezes and dims slightly; the pointer becomes a crosshair.
2. **Choose what to capture:**
   - **Hover a window**: it is highlighted. Click to capture just that window.
   - **Hover the empty desktop**: the whole screen is highlighted. Click to capture it.
   - **Drag** to capture any rectangle.
   - **Esc** cancels.
3. **A thumbnail** of the picture slides in at the bottom-right corner of that screen and stays
   for a few seconds (longer while the mouse is over it):
   - **Click** it to open the picture in the image viewer.
   - **Drag** it into an app (chat, e-mail, a document) to drop the file there.
   - It slides away on its own; nothing to dismiss.
4. The picture is **saved** to `Pictures/Screenshots` as `Screenshot 2026-11-18 at 14.05.32.png`
   and **copied** to the clipboard, so Ctrl+V pastes it right away.

## Decisions

- **One key, one flow** (principle 4). The separate shortcuts for "full screen to file" and
  "area to clipboard" are gone: the picker covers the whole screen, a window and an area, and
  every capture is both saved and copied.
- **The screen freezes when the picker opens**, so menus and tooltips that vanish on the next
  click can still be captured.
- **Built into the shell**, not separate tools: same colours and motion as the rest of Yui, no
  extra program started per capture (principle 1).
- **Loupe is the image viewer**: GNOME's viewer, written in Rust, fast and simple.

## Open

- Annotating a capture (arrows, text, blur) before sharing.
- Recording the screen as a video.
