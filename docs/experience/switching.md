# Switching between windows

## Purpose

Getting to the window you want, fast, when there are many open.

## Experience

- **Alt+Tab** shows a row of live previews of every window, most recently used first. Keep Alt
  held and press Tab to move along; let go of Alt to switch, or click a preview. Esc cancels.
  The chosen window comes to the front, even a maximized one on another screen.
- **Mission Control** shows every window of each screen at once: they zoom out from where they
  are into a grid. Click one to bring it to the front; Esc or a click on the background goes
  back. Opens with a three-finger swipe up on the trackpad, or `Super+↑`.

## Decisions

- **Alt+Tab is a shell overlay** with the same look as the rest of Yui, not Hyprland's
  built-in cycling.
- **The switch happens just after the overlay closes.** Doing it while the overlay still held
  the keyboard sent the focus back to the previous window.

## Open

- Mission Control has two entry points (swipe and `Super+↑`). Under principle 4, the swipe is
  the natural one on a trackpad; decide what a mouse user's single way is (for example, a
  screen corner or a dock item) and drop the shortcut.
- `Super+Tab` (previous workspace) overlaps with Alt+Tab conceptually.
