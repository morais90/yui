# Settings

## Purpose

Change how the system looks and behaves without editing files. Only the settings a person
actually needs are here (principle 3).

## Experience

The Settings app opens as a window with a list of pages on the left. Spotlight finds every page
by name.

### Displays

- A drawing of your screens, to scale. **Drag them** to match how they sit on your desk; they
  snap edge to edge.
- Click a screen to choose its **resolution**, **refresh rate**, **scale** and **rotation**.
- **Apply** changes the screens immediately and asks *"Keep these display settings?"* with a
  15-second countdown. **Keep** saves them; if you do nothing, or click **Revert**, the previous
  settings come back. A mode your screen can't show never leaves you with a black screen.
- Screens are recognised by model, not by the port they're plugged into, so a monitor keeps its
  place when you plug it elsewhere.

## Decisions

- **Changes apply live, then must be confirmed**, like macOS: you see the result before
  committing to it, and mistakes undo themselves.
- **Saved displays live in `~/.config/hypr/monitors.lua`**, written by the page. Hand edits
  belong in `hyprland.lua` instead.

## Open

- Several pages come from Caelestia and haven't been reviewed against the principles yet;
  "Updates" and "Plugins" are still placeholders, which breaks principle 2. Either build them
  or remove them.
- Mirroring and turning a screen off aren't offered yet.
